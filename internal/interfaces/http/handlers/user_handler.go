package handler

import (
	"io"
	"net/http"

	"github.com/dinq/menumate/internal/domain"
	"github.com/dinq/menumate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type UserHandler struct {
	UserUsecase       domain.IUserUsecase
	NotificationUseCase domain.INotificationUseCase
}
func (ctrl *UserHandler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("userId")
	if !exists {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Message: domain.ErrUnauthorized.Error()})
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

	file, err := c.FormFile("profileImage")
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

	updatedUser, err := ctrl.UserUsecase.UpdateProfile(userID.(string), update, fileName)
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
	if err := ctrl.NotificationUseCase.SendNotificationFromRoute(c.Request.Context(), userID.(string), "Your profile has been updated successfully!", domain.InfoUpdate); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	userDto := dto.UserDTO{}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: userDto.FromDomain(updatedUser)})
}

func (ctrl *UserHandler) ChangePassword(c *gin.Context) {
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

	if err := ctrl.UserUsecase.ChangePassword(userID, req.OldPassword, req.NewPassword); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}
	if err := ctrl.NotificationUseCase.SendNotificationFromRoute(c.Request.Context(), userID, "Your password has been changed successfully!", domain.InfoUpdate); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}
