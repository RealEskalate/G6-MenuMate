package handler

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/oauth"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	oauth2v2 "google.golang.org/api/oauth2/v2"
	"google.golang.org/api/option"
)

var validate = validator.New()

type AuthController struct {
	UserUsecase          domain.IUserUsecase
	AuthService          domain.IAuthService
	OTP                  domain.IOTPUsecase
	RefreshTokenUsecase  domain.IRefreshTokenUsecase
	PasswordResetUsecase domain.IPasswordResetUsecase
	NotificationUseCase  domain.INotificationUseCase
	GoogleClientID       string
	GoogleClientSecret   string
	GoogleRedirectURL    string
	CookieSecure         bool
	CookieDomain         string
}

func (ac *AuthController) RegisterRequest(c *gin.Context) {
	var newUser dto.UserRequest
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	if err := validate.Struct(newUser); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	user := dto.ToDomainUser(newUser)
	err := ac.UserUsecase.Register(&user)
	if err != nil {
		status := http.StatusInternalServerError
		if errors.Is(err, domain.ErrEmailAlreadyInUse) || errors.Is(err, domain.ErrUsernameAlreadyInUse) || errors.Is(err, domain.ErrPhoneAlreadyInUse) || errors.Is(err, domain.ErrDuplicateUser) {
			status = http.StatusConflict
		}
		c.JSON(status, dto.ErrorResponse{Message: err.Error(), Error: err.Error()})
		return
	}
	// Generate access and refresh tokens for the newly registered user
	tokens, err := ac.AuthService.GenerateTokens(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}
	// Prepare refresh token for DB
	refreshToken := &domain.RefreshToken{
		Token:     tokens.RefreshToken,
		UserID:    user.ID,
		Revoked:   false,
		ExpiresAt: tokens.RefreshTokenExpiresAt,
		CreatedAt: time.Now(),
	}
	// Save the refresh token
	_ = ac.RefreshTokenUsecase.Save(refreshToken)
	// Set the tokens in cookies
	utils.SetCookie(c, utils.CookieOptions{
		Name:     "refresh_token",
		Value:    tokens.RefreshToken,
		MaxAge:   int(time.Until(tokens.RefreshTokenExpiresAt).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	})
	utils.SetCookie(c, utils.CookieOptions{
		Name:     "access_token",
		Value:    tokens.AccessToken,
		MaxAge:   int(time.Until(tokens.AccessTokenExpiresAt).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	})
	c.JSON(http.StatusCreated, gin.H{
		"message": "Registration successful",
		"user":    dto.ToUserResponse(user),
		"tokens": dto.LoginResponse{
			AccessToken:  tokens.AccessToken,
			RefreshToken: tokens.RefreshToken,
		},
	})
}

func (ac *AuthController) LoginRequest(c *gin.Context) {
    var loginRequest dto.LoginRequest
    if err := c.ShouldBindJSON(&loginRequest); err != nil {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
        return
    }
    if loginRequest.Identifier == "" || loginRequest.Password == "" {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{
            Message: domain.ErrInvalidInput.Error(),
            Error:   domain.ErrPasswordAndEmailRequired.Error(),
        })
        return
    }

    // Find user by identifier (email | username | phone)
    user, err := ac.UserUsecase.FindByUsernameOrEmail(c.Request.Context(), loginRequest.Identifier)
    if err != nil {
        c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUnauthorized.Error(), Error: err.Error()})
        return
    }

    // Check password
    if err := security.ValidatePassword(user.Password, loginRequest.Password); err != nil {
        c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrInvalidCredentials.Error(), Error: err.Error()})
        return
    }

    // Generate tokens
    tokens, err := ac.AuthService.GenerateTokens(*user)
    if err != nil {
        c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrTokenGenerationIssue.Error(), Error: err.Error()})
        return
    }

    // Build refresh token model
    rt := &domain.RefreshToken{
        Token:     tokens.RefreshToken,
        UserID:    user.ID,
        Revoked:   false,
        ExpiresAt: tokens.RefreshTokenExpiresAt,
        CreatedAt: time.Now(),
    }

    // Upsert refresh token (revoke old if exists)
    if existing, findErr := ac.RefreshTokenUsecase.FindByUserID(user.ID); findErr == nil && existing != nil {
        _ = ac.RefreshTokenUsecase.RevokeByUserID(existing.UserID)
        if err := ac.RefreshTokenUsecase.ReplaceToken(rt); err != nil {
            c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToUpdateToken.Error(), Error: err.Error()})
            return
        }
    } else {
        if findErr != nil && findErr.Error() != domain.ErrRefreshTokenNotFound.Error() {
            c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: findErr.Error()})
            return
        }
        if err := ac.RefreshTokenUsecase.Save(rt); err != nil {
            c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToSaveToken.Error(), Error: err.Error()})
            return
        }
    }

    // Set cookies
    utils.SetCookie(c, utils.CookieOptions{
        Name:     string(domain.RefreshTokenType),
        Value:    tokens.RefreshToken,
        MaxAge:   int(time.Until(tokens.RefreshTokenExpiresAt).Seconds()),
        Path:     "/",
        Domain:   ac.CookieDomain,
        Secure:   ac.CookieSecure,
        HttpOnly: true,
        SameSite: http.SameSiteStrictMode,
    })
    utils.SetCookie(c, utils.CookieOptions{
        Name:     string(domain.AccessTokenType),
        Value:    tokens.AccessToken,
        MaxAge:   int(time.Until(tokens.AccessTokenExpiresAt).Seconds()),
        Path:     "/",
        Domain:   ac.CookieDomain,
        Secure:   ac.CookieSecure,
        HttpOnly: true,
        SameSite: http.SameSiteStrictMode,
    })

    // Unified response shape (matches registration style)
    c.JSON(http.StatusOK, gin.H{
        "message": "Login successful",
        "user":    dto.ToUserResponse(*user),
        "tokens": dto.LoginResponse{
            AccessToken:  tokens.AccessToken,
            RefreshToken: tokens.RefreshToken,
        },
    })
}

// ...existing code below...

func (ac *AuthController) RefreshToken(c *gin.Context) {
	var req dto.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	// find token from db
	tokenDoc, err := ac.RefreshTokenUsecase.FindByToken(req.RefreshToken)
	if err != nil || tokenDoc == nil || tokenDoc.Revoked || time.Now().After(tokenDoc.ExpiresAt) {
		if tokenDoc != nil {
			_ = ac.RefreshTokenUsecase.DeleteByUserID(tokenDoc.UserID)
		}
		if err != nil {
			c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrTokenInvalidOrExpired.Error(), Error: err.Error()})
		} else {
			c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrTokenInvalidOrExpired.Error(), Error: domain.ErrRefreshTokenNotFound.Error()})
		}
		return
	}

	// check both the token is valid and not expired
	_, err = utils.GetCookie(c, string(domain.RefreshTokenType))
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrRefreshTokenNotFound.Error(), Error: err.Error()})
		return
	}

	// Validate the refresh token
	_, err = ac.AuthService.ValidateRefreshToken(req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrTokenInvalidOrExpired.Error(), Error: err.Error()})
		return
	}

	// find the user of the token
	user, err := ac.UserUsecase.FindUserByID(tokenDoc.UserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
		return
	}

	// generate new access token
	response, err := ac.AuthService.GenerateTokens(*user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrTokenGenerationIssue.Error(), Error: err.Error()})
		return
	}

	// Decide whether to rotate the refresh token
	rotateThreshold := 2 * time.Hour // 2 hours before expiry
	shouldRotate := time.Until(tokenDoc.ExpiresAt) < rotateThreshold

	var refreshTokenValue string
	var refreshTokenExpiry time.Time

	if shouldRotate {
		// Rotate: generate and store a new refresh token
		refreshToken := &domain.RefreshToken{
			Token:     response.RefreshToken,
			UserID:    user.ID,
			Revoked:   false,
			ExpiresAt: response.RefreshTokenExpiresAt,
			CreatedAt: time.Now(),
		}
		if err := ac.RefreshTokenUsecase.RevokeByUserID(tokenDoc.UserID); err != nil {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToRevokeToken.Error(), Error: err.Error()})
			return
		}
		if err := ac.RefreshTokenUsecase.ReplaceToken(refreshToken); err != nil {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToUpdateToken.Error(), Error: err.Error()})
			return
		}
		refreshTokenValue = response.RefreshToken
		refreshTokenExpiry = response.RefreshTokenExpiresAt
	} else {
		// Do not rotate: keep using the existing valid refresh token string from the request body
		refreshTokenValue = req.RefreshToken
		refreshTokenExpiry = tokenDoc.ExpiresAt
	}

	// Set the refresh token in the cookies
	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.RefreshTokenType),
		Value:    refreshTokenValue,
		MaxAge:   int(time.Until(refreshTokenExpiry).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	})
	// Set the access token in the cookies
	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.AccessTokenType),
		Value:    response.AccessToken,
		MaxAge:   int(time.Until(response.AccessTokenExpiresAt).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: true,
		SameSite: http.SameSiteStrictMode,
	})
	fmt.Println("user id", user.ID)
	c.JSON(http.StatusOK, dto.LoginResponse{
		AccessToken:  response.AccessToken,
		RefreshToken: refreshTokenValue,
	})
}

// log out here
func (ac *AuthController) LogoutRequest(c *gin.Context) {

	// get the refresh token from cookies
	refreshToken, err := utils.GetCookie(c, string(domain.RefreshTokenType))
	utils.DeleteCookie(c, string(domain.RefreshTokenType))
	utils.DeleteCookie(c, string(domain.AccessTokenType))

	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUserAlreadyLoggedOut.Error(), Error: err.Error()})
		return
	}

	tokenDoc, err := ac.RefreshTokenUsecase.FindByToken(refreshToken)
	if err != nil || tokenDoc == nil {
		errorMsg := ""
		if err != nil {
			errorMsg = err.Error()
		} else {
			errorMsg = domain.ErrRefreshTokenNotFound.Error()
		}
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUserAlreadyLoggedOut.Error(), Error: errorMsg})
		return
	}
	if tokenDoc.Revoked || time.Now().After(tokenDoc.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUserAlreadyLoggedOut.Error(), Error: domain.ErrTokenInvalidOrExpired.Error()})
		return
	}
	// revoke the token
	if err := ac.RefreshTokenUsecase.RevokeByUserID(tokenDoc.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToRevokeToken.Error(), Error: err.Error()})
		return
	}

	// delete the token from the database
	if err := ac.RefreshTokenUsecase.DeleteByUserID(tokenDoc.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToDeleteToken.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// forget password here
func (ac *AuthController) ForgotPasswordRequest(c *gin.Context) {

	var req dto.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	err := ac.PasswordResetUsecase.RequestReset(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToProcessRequest.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// Reset password here
func (ac *AuthController) ResetPasswordRequest(c *gin.Context) {
	var req dto.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	err := ac.PasswordResetUsecase.ResetPassword(req.Email, req.Token, req.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToResetPassword.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// verify email request
func (ac *AuthController) VerifyEmailRequest(c *gin.Context) {
	var req dto.VerifyEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	user, err := ac.UserUsecase.GetUserByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
		return
	}

	err = ac.OTP.RequestOTP(user.Email)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrOTPNotFound.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// verify otp
func (ac *AuthController) VerifyOTPRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	var req dto.VerifyOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	user, err := ac.UserUsecase.FindUserByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
		return
	}

	otp, err := ac.OTP.VerifyOTP(user.Email, req.Code)
	if err != nil {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrOTPInvalid.Error(), Error: err.Error()})
		return
	}

	// update user verification status
	user.IsVerified = true
	if _, err := ac.UserUsecase.UpdateUser(user.ID, user); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToVerifyUser.Error(), Error: err.Error()})
		return
	}

	// delete the OTP after successful verification
	if err := ac.OTP.DeleteByID(otp.ID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrOTPFailedToDelete.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}

// otp resend request
func (ac *AuthController) ResendOTPRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	user, err := ac.UserUsecase.FindUserByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
		return
	}

	err = ac.OTP.RequestOTP(user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToResendOTP.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

//Oauth Google handlers

func (ac *AuthController) GoogleLogin(c *gin.Context) {
	conf := oauth.GetGoogleOAuthConfig(ac.GoogleClientID, ac.GoogleClientSecret, ac.GoogleRedirectURL)
	url := conf.AuthCodeURL("random-state")
	c.Redirect(http.StatusTemporaryRedirect, url)
}

func (ac *AuthController) GoogleCallback(c *gin.Context) {
	code := c.Query("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: domain.ErrCodeNotFound.Error()})
		return
	}

	conf := oauth.GetGoogleOAuthConfig(ac.GoogleClientID, ac.GoogleClientSecret, ac.GoogleRedirectURL)
	token, err := conf.Exchange(context.Background(), code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrTokenGenerationIssue.Error(), Error: err.Error()})
		return
	}

	client := conf.Client(context.Background(), token)
	service, err := oauth2v2.NewService(c.Request.Context(), option.WithHTTPClient(client))
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToCreateOAuthService.Error(), Error: err.Error()})
		return
	}

	userInfo, err := service.Userinfo.Get().Do()
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToGetUserInfo.Error(), Error: err.Error()})
		return
	}

	// Try finding user by email
	user, err := ac.UserUsecase.GetUserByEmail(userInfo.Email)
	if err == nil && user != nil {
		// User exists - login flow
		response, err := ac.AuthService.GenerateTokens(*user)
		if err != nil {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrTokenGenerationIssue.Error(), Error: err.Error()})
			return
		}

		refreshToken := &domain.RefreshToken{
			Token:     response.RefreshToken,
			UserID:    user.ID,
			ExpiresAt: response.RefreshTokenExpiresAt,
			Revoked:   false,
			CreatedAt: time.Now(),
		}

		if existingToken, err := ac.RefreshTokenUsecase.FindByUserID(user.ID); err == nil {
			ac.RefreshTokenUsecase.RevokedToken(existingToken)
			ac.RefreshTokenUsecase.ReplaceToken(refreshToken)
		} else {
			ac.RefreshTokenUsecase.Save(refreshToken)
		}

		utils.SetCookie(c, utils.CookieOptions{
			Name:     string(domain.RefreshTokenType),
			Value:    response.RefreshToken,
			MaxAge:   int(time.Until(response.RefreshTokenExpiresAt).Seconds()),
			Path:     "/",
			HttpOnly: true,
			Secure:   false,
			SameSite: http.SameSiteStrictMode,
		})

		utils.SetCookie(c, utils.CookieOptions{
			Name:     string(domain.AccessTokenType),
			Value:    response.AccessToken,
			MaxAge:   int(time.Until(response.AccessTokenExpiresAt).Seconds()),
			Path:     "/",
			HttpOnly: true,
			Secure:   false,
			SameSite: http.SameSiteStrictMode,
		})
		c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.ToUserResponse(*user)})
		return
	}

	// If user not found – register new one
	newUser := &domain.User{
		Username:     strings.Split(userInfo.Email, "@")[0],
		Email:        userInfo.Email,
		FirstName:    userInfo.GivenName,
		LastName:     userInfo.FamilyName,
		Role:         domain.RoleCustomer,
		AuthProvider: domain.AuthGoogle,
		ProfileImage: userInfo.Picture,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	if err := ac.UserUsecase.Register(newUser); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToRegisterUser.Error(), Error: err.Error()})
		return
	}

	// Generate token for new user
	response, err := ac.AuthService.GenerateTokens(*newUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrTokenGenerationIssue.Error(), Error: err.Error()})
		return
	}

	refreshToken := &domain.RefreshToken{
		Token:     response.RefreshToken,
		UserID:    newUser.ID,
		ExpiresAt: response.RefreshTokenExpiresAt,
		Revoked:   false,
		CreatedAt: time.Now(),
	}

	if existingToken, err := ac.RefreshTokenUsecase.FindByUserID(newUser.ID); err == nil {
		ac.RefreshTokenUsecase.RevokedToken(existingToken)
		ac.RefreshTokenUsecase.ReplaceToken(refreshToken)
	} else {
		ac.RefreshTokenUsecase.Save(refreshToken)
	}

	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.RefreshTokenType),
		Value:    response.RefreshToken,
		MaxAge:   int(time.Until(response.RefreshTokenExpiresAt).Seconds()),
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		SameSite: http.SameSiteStrictMode,
	})

	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.AccessTokenType),
		Value:    response.AccessToken,
		MaxAge:   int(time.Until(response.AccessTokenExpiresAt).Seconds()),
		Path:     "/",
		HttpOnly: true,
		Secure:   false,
		SameSite: http.SameSiteStrictMode,
	})
	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: dto.ToUserResponse(*newUser)})
}
