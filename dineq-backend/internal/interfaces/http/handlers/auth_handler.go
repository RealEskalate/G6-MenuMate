package handler

import (
	"context"
	"errors"
	"net/http"
	"net/url"
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
	FrontendBaseURL      string
}

func (ac *AuthController) RegisterRequest(c *gin.Context) {
	var newUser dto.UserRequest
	if err := c.ShouldBindJSON(&newUser); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(newUser); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}

	user := dto.ToDomainUser(newUser)
	if err := ac.UserUsecase.Register(&user); err != nil {
		if errors.Is(err, domain.ErrEmailAlreadyInUse) || errors.Is(err, domain.ErrUsernameAlreadyInUse) || errors.Is(err, domain.ErrPhoneAlreadyInUse) || errors.Is(err, domain.ErrDuplicateUser) {
			field := ""
			switch {
			case errors.Is(err, domain.ErrEmailAlreadyInUse):
				field = "email"
			case errors.Is(err, domain.ErrUsernameAlreadyInUse):
				field = "username"
			case errors.Is(err, domain.ErrPhoneAlreadyInUse):
				field = "phone"
			}
			dto.WriteValidationError(c, field, err.Error(), "", err)
			return
		}
		dto.WriteError(c, err)
		return
	}

	tokens, err := ac.AuthService.GenerateTokens(user)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenGenerationIssue)
		return
	}
	refreshToken := &domain.RefreshToken{Token: tokens.RefreshToken, UserID: user.ID, Revoked: false, ExpiresAt: tokens.RefreshTokenExpiresAt, CreatedAt: time.Now()}
	_ = ac.RefreshTokenUsecase.Save(refreshToken)
	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.RefreshTokenType), Value: tokens.RefreshToken, MaxAge: int(time.Until(tokens.RefreshTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, Secure: ac.CookieSecure, HttpOnly: false, SameSite: http.SameSiteStrictMode})
	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.AccessTokenType), Value: tokens.AccessToken, MaxAge: int(time.Until(tokens.AccessTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, Secure: ac.CookieSecure, HttpOnly: false, SameSite: http.SameSiteStrictMode})
	c.JSON(http.StatusCreated, gin.H{"message": "Registration successful", "user": dto.ToUserResponse(user), "tokens": dto.LoginResponse{AccessToken: tokens.AccessToken, RefreshToken: tokens.RefreshToken}})
}

func (ac *AuthController) LoginRequest(c *gin.Context) {
	var loginRequest dto.LoginRequest
	if err := c.ShouldBindJSON(&loginRequest); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(loginRequest); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}
	ctx := context.Background()
	user, err := ac.UserUsecase.FindByUsernameOrEmail(ctx, loginRequest.Identifier)
	if err != nil || user == nil {
		dto.WriteError(c, domain.ErrInvalidCredentials)
		return
	}
	if err := security.ValidatePassword(user.Password, loginRequest.Password); err != nil {
		dto.WriteError(c, domain.ErrInvalidCredentials)
		return
	}
	tokens, err := ac.AuthService.GenerateTokens(*user)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenGenerationIssue)
		return
	}
	rt := &domain.RefreshToken{Token: tokens.RefreshToken, UserID: user.ID, Revoked: false, ExpiresAt: tokens.RefreshTokenExpiresAt, CreatedAt: time.Now()}
	if existing, findErr := ac.RefreshTokenUsecase.FindByUserID(user.ID); findErr == nil && existing != nil {
		_ = ac.RefreshTokenUsecase.RevokeByUserID(existing.UserID)
		_ = ac.RefreshTokenUsecase.ReplaceToken(rt)
	} else {
		_ = ac.RefreshTokenUsecase.Save(rt)
	}
	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.RefreshTokenType), Value: tokens.RefreshToken, MaxAge: int(time.Until(tokens.RefreshTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, Secure: ac.CookieSecure, HttpOnly: false, SameSite: http.SameSiteStrictMode})
	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.AccessTokenType), Value: tokens.AccessToken, MaxAge: int(time.Until(tokens.AccessTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, Secure: ac.CookieSecure, HttpOnly: false, SameSite: http.SameSiteStrictMode})
	c.JSON(http.StatusOK, gin.H{"message": "Login successful", "user": dto.ToUserResponse(*user), "tokens": dto.LoginResponse{AccessToken: tokens.AccessToken, RefreshToken: tokens.RefreshToken}})
}

func (ac *AuthController) RefreshToken(c *gin.Context) {
	var req dto.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}

	tokenDoc, err := ac.RefreshTokenUsecase.FindByToken(req.RefreshToken)
	if err != nil || tokenDoc == nil || tokenDoc.Revoked || time.Now().After(tokenDoc.ExpiresAt) {
		if tokenDoc != nil {
			_ = ac.RefreshTokenUsecase.DeleteByUserID(tokenDoc.UserID)
		}
		if err != nil {
			dto.WriteError(c, domain.ErrTokenInvalidOrExpired)
		} else {
			dto.WriteError(c, domain.ErrRefreshTokenNotFound)
		}
		return
	}

	_, err = utils.GetCookie(c, string(domain.RefreshTokenType))
	if err != nil {
		dto.WriteError(c, domain.ErrRefreshTokenNotFound)
		return
	}

	_, err = ac.AuthService.ValidateRefreshToken(req.RefreshToken)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenInvalidOrExpired)
		return
	}

	user, err := ac.UserUsecase.FindUserByID(tokenDoc.UserID)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}

	response, err := ac.AuthService.GenerateTokens(*user)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenGenerationIssue)
		return
	}

	rotateThreshold := 2 * time.Hour
	shouldRotate := time.Until(tokenDoc.ExpiresAt) < rotateThreshold

	var refreshTokenValue string
	var refreshTokenExpiry time.Time

	if shouldRotate {
		refreshToken := &domain.RefreshToken{
			Token:     response.RefreshToken,
			UserID:    user.ID,
			Revoked:   false,
			ExpiresAt: response.RefreshTokenExpiresAt,
			CreatedAt: time.Now(),
		}
		if err := ac.RefreshTokenUsecase.RevokeByUserID(tokenDoc.UserID); err != nil {
			dto.WriteError(c, domain.ErrFailedToRevokeToken)
			return
		}
		if err := ac.RefreshTokenUsecase.ReplaceToken(refreshToken); err != nil {
			dto.WriteError(c, domain.ErrFailedToUpdateToken)
			return
		}
		refreshTokenValue = response.RefreshToken
		refreshTokenExpiry = response.RefreshTokenExpiresAt
	} else {
		refreshTokenValue = req.RefreshToken
		refreshTokenExpiry = tokenDoc.ExpiresAt
	}

	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.RefreshTokenType),
		Value:    refreshTokenValue,
		MaxAge:   int(time.Until(refreshTokenExpiry).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: false,
		SameSite: http.SameSiteStrictMode,
	})
	utils.SetCookie(c, utils.CookieOptions{
		Name:     string(domain.AccessTokenType),
		Value:    response.AccessToken,
		MaxAge:   int(time.Until(response.AccessTokenExpiresAt).Seconds()),
		Path:     "/",
		Domain:   "",
		Secure:   ac.CookieSecure,
		HttpOnly: false,
		SameSite: http.SameSiteStrictMode,
	})
	c.JSON(http.StatusOK, dto.LoginResponse{AccessToken: response.AccessToken, RefreshToken: refreshTokenValue})
}

func (ac *AuthController) LogoutRequest(c *gin.Context) {
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
	if err := ac.RefreshTokenUsecase.RevokeByUserID(tokenDoc.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToRevokeToken.Error(), Error: err.Error()})
		return
	}
	if err := ac.RefreshTokenUsecase.DeleteByUserID(tokenDoc.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToDeleteToken.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

func (ac *AuthController) ForgotPasswordRequest(c *gin.Context) {
	var req dto.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}
	err := ac.PasswordResetUsecase.RequestReset(req.Email, req.Platform)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToProcessRequest.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

func (ac *AuthController) VerifyResetToken(c *gin.Context) {
	email := c.Query("email")
	if email == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Email is required"})
		return
	}
	token := c.Query("token")
	if token == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Token is required"})
		return
	}
	sessionToken, err := ac.PasswordResetUsecase.VerifyResetToken(email, token)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"session_token": sessionToken})
}

func (ac *AuthController) ResetPassword(c *gin.Context) {
	var req dto.SetNewPasswordRequest
	if err := c.BindJSON(&req); err != nil {
		c.JSON(400, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	if err := ac.PasswordResetUsecase.ResetPasswordWithSession(req.SessionToken, req.NewPassword); err != nil {
		c.JSON(400, dto.ErrorResponse{Message: domain.ErrFailedToResetPassword.Error(), Error: err.Error()})
		return
	}
	c.JSON(200, dto.SuccessResponse{Message: domain.MsgSuccess})
}

func (ac *AuthController) VerifyEmailRequest(c *gin.Context) {
	var req dto.VerifyEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}
	user, err := ac.UserUsecase.GetUserByEmail(req.Email)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	if err = ac.OTP.RequestOTP(user.Email); err != nil {
		dto.WriteError(c, domain.ErrOTPNotFound)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

func (ac *AuthController) VerifyOTPRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	var req dto.VerifyOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}
	user, err := ac.UserUsecase.FindUserByID(userID)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	otp, err := ac.OTP.VerifyOTP(user.Email, req.Code)
	if err != nil {
		dto.WriteError(c, domain.ErrOTPInvalid)
		return
	}
	user.IsVerified = true
	if _, err := ac.UserUsecase.UpdateUser(user.ID, user); err != nil {
		dto.WriteError(c, domain.ErrFailedToVerifyUser)
		return
	}
	if err := ac.OTP.DeleteByID(otp.ID); err != nil {
		dto.WriteError(c, domain.ErrOTPFailedToDelete)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}

func (ac *AuthController) ResendOTPRequest(c *gin.Context) {
	userID := c.GetString("user_id")
	user, err := ac.UserUsecase.FindUserByID(userID)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	if err = ac.OTP.RequestOTP(user.Email); err != nil {
		dto.WriteError(c, domain.ErrFailedToResendOTP)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

func (ac *AuthController) GoogleLogin(c *gin.Context) {
	client := c.Query("client")
	if client == "" {
		client = "web"
	}
	conf := oauth.GetGoogleOAuthConfig(ac.GoogleClientID, ac.GoogleClientSecret, ac.GoogleRedirectURL)
	authURL := conf.AuthCodeURL(client)
	c.Redirect(http.StatusTemporaryRedirect, authURL)
}

func (ac *AuthController) GoogleCallback(c *gin.Context) {
	code := c.Query("code")
	if code == "" {
		dto.WriteValidationError(c, "code", domain.ErrInvalidRequest.Error(), "invalid_request", domain.ErrCodeNotFound)
		return
	}

	conf := oauth.GetGoogleOAuthConfig(ac.GoogleClientID, ac.GoogleClientSecret, ac.GoogleRedirectURL)
	token, err := conf.Exchange(context.Background(), code)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenGenerationIssue)
		return
	}

	client := conf.Client(context.Background(), token)
	service, err := oauth2v2.NewService(c.Request.Context(), option.WithHTTPClient(client))
	if err != nil {
		dto.WriteError(c, domain.ErrFailedToCreateOAuthService)
		return
	}

	userInfo, err := service.Userinfo.Get().Do()
	if err != nil {
		dto.WriteError(c, domain.ErrFailedToGetUserInfo)
		return
	}

	user, err := ac.UserUsecase.GetUserByEmail(userInfo.Email)
	if err == nil && user != nil {
		response, err := ac.AuthService.GenerateTokens(*user)
		if err != nil {
			dto.WriteError(c, domain.ErrTokenGenerationIssue)
			return
		}

		refreshToken := &domain.RefreshToken{
			Token:     response.RefreshToken,
			UserID:    user.ID,
			ExpiresAt: response.RefreshTokenExpiresAt,
			Revoked:   false,
			CreatedAt: time.Now(),
		}

		if existingToken, err := ac.RefreshTokenUsecase.FindByUserID(user.ID); err == nil && existingToken != nil {
			_ = ac.RefreshTokenUsecase.RevokedToken(existingToken)
			_ = ac.RefreshTokenUsecase.ReplaceToken(refreshToken)
		} else {
			_ = ac.RefreshTokenUsecase.Save(refreshToken)
		}

		utils.SetCookie(c, utils.CookieOptions{Name: string(domain.RefreshTokenType), Value: response.RefreshToken, MaxAge: int(time.Until(response.RefreshTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, HttpOnly: false, Secure: ac.CookieSecure, SameSite: http.SameSiteNoneMode})
		utils.SetCookie(c, utils.CookieOptions{Name: string(domain.AccessTokenType), Value: response.AccessToken, MaxAge: int(time.Until(response.AccessTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, HttpOnly: false, Secure: ac.CookieSecure, SameSite: http.SameSiteNoneMode})

		redir := ac.FrontendBaseURL
		if redir == "" {
			redir = "https://dineqmenumate.vercel.app"
		}
		base := strings.TrimRight(redir, "/") + "/"
		qs := "?access_token=" + url.QueryEscape(response.AccessToken) + "&refresh_token=" + url.QueryEscape(response.RefreshToken)
		hash := "#access_token=" + url.QueryEscape(response.AccessToken) + "&refresh_token=" + url.QueryEscape(response.RefreshToken)
		finalURL := base + qs + hash
		c.Redirect(http.StatusTemporaryRedirect, finalURL)
		return
	}

	newUser := &domain.User{Username: strings.Split(userInfo.Email, "@")[0], Email: strings.ToLower(userInfo.Email), FirstName: userInfo.GivenName, LastName: userInfo.FamilyName, Role: domain.RoleCustomer, AuthProvider: domain.AuthGoogle, ProfileImage: userInfo.Picture, CreatedAt: time.Now(), UpdatedAt: time.Now(), IsVerified: true}
	if err := ac.UserUsecase.Register(newUser); err != nil {
		dto.WriteError(c, domain.ErrServerIssue)
		return
	}
	newTokens, err := ac.AuthService.GenerateTokens(*newUser)
	if err != nil {
		dto.WriteError(c, domain.ErrTokenGenerationIssue)
		return
	}
	refreshToken := &domain.RefreshToken{Token: newTokens.RefreshToken, UserID: newUser.ID, ExpiresAt: newTokens.RefreshTokenExpiresAt, Revoked: false, CreatedAt: time.Now()}
	_ = ac.RefreshTokenUsecase.Save(refreshToken)

	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.RefreshTokenType), Value: newTokens.RefreshToken, MaxAge: int(time.Until(newTokens.RefreshTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, HttpOnly: false, Secure: ac.CookieSecure, SameSite: http.SameSiteNoneMode})
	utils.SetCookie(c, utils.CookieOptions{Name: string(domain.AccessTokenType), Value: newTokens.AccessToken, MaxAge: int(time.Until(newTokens.AccessTokenExpiresAt).Seconds()), Path: "/", Domain: ac.CookieDomain, HttpOnly: false, Secure: ac.CookieSecure, SameSite: http.SameSiteNoneMode})

	redir := ac.FrontendBaseURL
	if redir == "" {
		redir = "https://dineqmenumate.vercel.app"
	}
	base := strings.TrimRight(redir, "/") + "/"
	qs := "?access_token=" + url.QueryEscape(newTokens.AccessToken) + "&refresh_token=" + url.QueryEscape(newTokens.RefreshToken)
	hash := "#access_token=" + url.QueryEscape(newTokens.AccessToken) + "&refresh_token=" + url.QueryEscape(newTokens.RefreshToken)
	finalURL := base + qs + hash
	c.Redirect(http.StatusTemporaryRedirect, finalURL)
}
