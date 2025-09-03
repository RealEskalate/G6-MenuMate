package handler

import (
	"io"
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

// UserController aggregates all user related handlers.
type UserController struct {
	userUC         domain.IUserUsecase
	notificationUC domain.INotificationUseCase
}

func NewUserController(userUC domain.IUserUsecase, notificationUC domain.INotificationUseCase) *UserController {
	return &UserController{userUC: userUC, notificationUC: notificationUC}
}

func (ctrl *UserController) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": domain.ErrUnauthorized.Error()})
		return
	}

	var req dto.UserUpdateProfileRequest
	if err := c.ShouldBindWith(&req, binding.FormMultipart); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	// validate
	if err := validate.Struct(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	var avatarData []byte
	var fileName string

	file, err := c.FormFile("profile_image")
	if err == nil {
		f, err := file.Open()
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		defer f.Close()

		avatarData, err = io.ReadAll(f)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		fileName = file.Filename
	} else if err != http.ErrMissingFile {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
		return
	} else {
		// No file uploaded, use default avatar or leave it empty
		avatarData = nil
		fileName = ""
	}

	update := domain.UserProfileUpdate{
		AvatarData: avatarData,
		FirstName:  req.FirstName,
		LastName:   req.LastName,
	}

	updatedUser, err := ctrl.userUC.UpdateProfile(userID.(string), update, fileName)
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

	// send notifcation
	if err := ctrl.notificationUC.SendNotificationFromRoute(c.Request.Context(), userID.(string), "Your profile has been updated successfully!", domain.InfoUpdate); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	// build response directly
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
