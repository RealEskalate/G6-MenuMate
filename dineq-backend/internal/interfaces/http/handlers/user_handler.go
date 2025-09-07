package handler

import (
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

// UserController aggregates all user related handlers.
type UserController struct {
	userUC         domain.IUserUsecase
	notificationUC domain.INotificationUseCase
}

func NewUserController(userUC domain.IUserUsecase, notificationUC domain.INotificationUseCase) *UserController {
	return &UserController{userUC: userUC, notificationUC: notificationUC}
}


func (ctrl *UserController) GetAvatarOptions(c *gin.Context) {
	gender := c.Query("gender")
	numParam := c.Query("number")
	base := "https://avatar.iran.liara.run/public"
	// Ranges as per requirements
	type avatar struct {
		ID     int    `json:"id"`
		URL    string `json:"url"`
		Gender string `json:"gender"`
	}
	// ensure empty array [] instead of null when no results
	list := make([]avatar, 0)
	includeMale := gender == "" || gender == "male"
	includeFemale := gender == "" || gender == "female"
	if gender != "" && gender != "male" && gender != "female" {
		dto.WriteValidationError(c, "gender", domain.ErrInvalidInput.Error(), "invalid_gender", fmt.Errorf("invalid gender"))
		return
	}

	// Defaults if number not provided
	defaultCount := 10
	// Male range
	maleStart, maleMax := 1, 49
	maleEnd := maleStart + defaultCount - 1
	if maleEnd > maleMax {
		maleEnd = maleMax
	}
	// Female range
	femaleStart, femaleMax := 50, 100
	femaleEnd := femaleStart + defaultCount - 1
	if femaleEnd > femaleMax {
		femaleEnd = femaleMax
	}
	if numParam != "" {
		if n, err := strconv.Atoi(numParam); err == nil && n > 0 {
			// For male: 1..min(1+n-1,49)
			maleEnd = maleStart + n - 1
			if maleEnd > maleMax {
				maleEnd = maleMax
			}
			// For female: 50..min(50+n-1,100)
			femaleEnd = femaleStart + n - 1
			if femaleEnd > femaleMax {
				femaleEnd = femaleMax
			}
		}
	}

	if includeMale {
		for i := 1; i <= maleEnd; i++ {
			list = append(list, avatar{ID: i, URL: fmt.Sprintf("%s/%d", base, i), Gender: "male"})
		}
	}
	if includeFemale {
		for i := femaleStart; i <= femaleEnd; i++ {
			list = append(list, avatar{ID: i, URL: fmt.Sprintf("%s/%d", base, i), Gender: "female"})
		}
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"count": len(list), "avatars": list}})
}

// Me returns the currently authenticated user's profile
func (ctrl *UserController) Me(c *gin.Context) {
	uid := c.GetString("user_id")
	if uid == "" {
		uid = c.GetString("userId")
	}
	if uid == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}
	user, err := ctrl.userUC.FindUserByID(uid)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.ToUserResponse(*user)})
}

// GetPublicUser exposes a public profile by user id (limited fields)
func (ctrl *UserController) GetPublicUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		dto.WriteValidationError(c, "id", domain.ErrInvalidInput.Error(), "missing_id", fmt.Errorf("missing id"))
		return
	}
	user, err := ctrl.userUC.FindUserByID(id)
	if err != nil {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	resp := dto.ToUserResponse(*user)
	// Redact sensitive fields (email, phone) for public
	resp.Email = ""
	resp.PhoneNumber = ""
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: resp})
}

func (ctrl *UserController) UpdateProfile(c *gin.Context) {
	// Accept either key set by upstream middleware
	uid := c.GetString("user_id")
	if uid == "" {
		uid = c.GetString("userId")
	}
	if uid == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	var req dto.UserUpdateProfileRequest
	var bindErr error
	// First, try to bind JSON body safely (keeps a copy of body for later use if needed)
	if err := c.ShouldBindBodyWithJSON(&req); err != nil {
		// Fallback to generic binding (form/multipart)
		bindErr = c.ShouldBind(&req)
	}
	if bindErr != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", bindErr)
		return
	}
	// Debug: show what was bound
	fmt.Printf("[UpdateProfile] bound: first_name=%q last_name=%q profile_image=%q contentType=%q\n", req.FirstName, req.LastName, req.ProfileImageURL, c.GetHeader("Content-Type"))
	if err := validate.Struct(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}

	var avatarData []byte
	var fileName string
	// Prefer bound file header; fallback to manual lookup (profile_image or avatar)
	fileHeader := req.ProfileImage
	if fileHeader == nil {
		if fh, err := c.FormFile("avatar"); err == nil {
			fileHeader = fh
		}
	}
	if fileHeader != nil {
		f, err := fileHeader.Open()
		if err != nil {
			dto.WriteValidationError(c, "profile_image", domain.ErrInvalidFile.Error(), "invalid_file", err)
			return
		}
		defer f.Close()
		data, err := io.ReadAll(f)
		if err != nil {
			dto.WriteValidationError(c, "profile_image", domain.ErrInvalidFile.Error(), "invalid_file", err)
			return
		}
		avatarData = data
		fileName = fileHeader.Filename
	}

	// Normalize inputs
	fn := strings.TrimSpace(req.FirstName)
	ln := strings.TrimSpace(req.LastName)
	update := domain.UserProfileUpdate{AvatarData: avatarData, FirstName: fn, LastName: ln}
	// If JSON provided a profile_image URL and no file, use it
	if len(avatarData) == 0 && req.ProfileImageURL != "" {
		update.AvatarURL = req.ProfileImageURL
	}
	updatedUser, err := ctrl.userUC.UpdateProfile(uid, update, fileName)
	if err == domain.ErrUserNotFound {
		dto.WriteError(c, domain.ErrUserNotFound)
		return
	}
	if err == domain.ErrInvalidFile {
		dto.WriteError(c, domain.ErrInvalidFile)
		return
	}
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	if err := ctrl.notificationUC.SendNotificationFromRoute(c.Request.Context(), uid, "Your profile has been updated successfully!", domain.InfoUpdate); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.ToUserResponse(*updatedUser)})
}

func (ctrl *UserController) ChangePassword(c *gin.Context) {
	var req dto.ChangePasswordRequest
	if err := c.ShouldBindBodyWithJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := validate.Struct(req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}
	userID := c.GetString("userId")
	if userID == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	// check password strength
	if err := dto.ValidatePasswordStrength(req.NewPassword); err != nil {
		dto.WriteValidationError(c, "new_password", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}

	if err := ctrl.userUC.ChangePassword(userID, req.OldPassword, req.NewPassword); err != nil {
		dto.WriteError(c, err)
		return
	}
	if err := ctrl.notificationUC.SendNotificationFromRoute(c.Request.Context(), userID, "Your password has been changed successfully!", domain.InfoUpdate); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}
