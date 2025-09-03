package handler

import (
	"fmt"
	"io"
	"net/http"
	"strconv"

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

// GetAvatarOptions returns selectable avatar image URLs.
// Query param: gender=male|female (optional). If omitted returns combined list.
func (ctrl *UserController) GetAvatarOptions(c *gin.Context) {
	gender := c.Query("gender")
	numParam := c.Query("number")
	base := "https://avatar.iran.liara.run/public"
	// Ranges: male 1-20, female 50-69 (20 each)
	type avatar struct {
		ID     int    `json:"id"`
		URL    string `json:"url"`
		Gender string `json:"gender"`
	}
	var list []avatar
	includeMale := gender == "" || gender == "male"
	includeFemale := gender == "" || gender == "female"
	if gender != "" && gender != "male" && gender != "female" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: "invalid gender"})
		return
	}

	maleEndDefault := 10
	femaleSpanDefault := 10
	var maleEnd int = maleEndDefault
	var femaleEnd int = 50 + femaleSpanDefault - 1
	if numParam != "" {
		if n, err := strconv.Atoi(numParam); err == nil && n > 0 {
			// For male example: number=30 -> 1..30
			maleEnd = n
			// For female example: number=40 -> 50..(50+40)
			femaleEnd = 50 + n
			// basic upper bounds to avoid runaway
			if maleEnd > 49 {
				maleEnd = 49
			}
			if femaleEnd > 49 {
				femaleEnd = 49
			}
		}
	}

	if includeMale {
		for i := 1; i <= maleEnd; i++ {
			list = append(list, avatar{ID: i, URL: fmt.Sprintf("%s/%d", base, i), Gender: "male"})
		}
	}
	if includeFemale {
		for i := 50; i <= femaleEnd; i++ {
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
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUnauthorized.Error()})
		return
	}
	user, err := ctrl.userUC.FindUserByID(uid)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.ToUserResponse(*user)})
}

// GetPublicUser exposes a public profile by user id (limited fields)
func (ctrl *UserController) GetPublicUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: "missing id"})
		return
	}
	user, err := ctrl.userUC.FindUserByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error(), Error: err.Error()})
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
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUnauthorized.Error()})
		return
	}

	var req dto.UserUpdateProfileRequest
	if err := c.ShouldBind(&req); err != nil { // auto-detect multipart
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	if err := validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
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
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		defer f.Close()
		data, err := io.ReadAll(f)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		avatarData = data
		fileName = fileHeader.Filename
	}

	update := domain.UserProfileUpdate{AvatarData: avatarData, FirstName: req.FirstName, LastName: req.LastName}
	updatedUser, err := ctrl.userUC.UpdateProfile(uid, update, fileName)
	if err == domain.ErrUserNotFound {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrUserNotFound.Error()})
		return
	}
	if err == domain.ErrInvalidFile {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error()})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	if err := ctrl.notificationUC.SendNotificationFromRoute(c.Request.Context(), uid, "Your profile has been updated successfully!", domain.InfoUpdate); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.ToUserResponse(*updatedUser)})
}

func (ctrl *UserController) ChangePassword(c *gin.Context) {
	var req dto.ChangePasswordRequest
	if err := c.ShouldBindBodyWithJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	if err := validate.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}
	userID := c.GetString("userId")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUnauthorized.Error()})
		return
	}

	// check password strength
	if err := dto.ValidatePasswordStrength(req.NewPassword); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	if err := ctrl.userUC.ChangePassword(userID, req.OldPassword, req.NewPassword); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}
	if err := ctrl.notificationUC.SendNotificationFromRoute(c.Request.Context(), userID, "Your password has been changed successfully!", domain.InfoUpdate); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}
