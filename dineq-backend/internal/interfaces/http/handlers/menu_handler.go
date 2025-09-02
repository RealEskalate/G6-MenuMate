package handler

import (
	"fmt"
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type MenuHandler struct {
	UseCase             domain.IMenuUseCase
	QrUseCase           domain.IQRCodeUseCase
	NotificationUseCase domain.INotificationUseCase
}

func NewMenuHandler(uc domain.IMenuUseCase, qc domain.IQRCodeUseCase, nc domain.INotificationUseCase) *MenuHandler {
	return &MenuHandler{UseCase: uc, QrUseCase: qc, NotificationUseCase: nc}
}

// CreateMenu handles the creation of a new menu
func (h *MenuHandler) CreateMenu(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")

	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	menuDto.RestaurantID = restaurantID
	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.CreateMenu(menu); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	fmt.Println("Created Menu ID:", menu)
	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// GetMenuByID retrieves a menu by ID
func (h *MenuHandler) GetMenu(c *gin.Context) {
	id := c.Param("restaurant_id")
	menu, err := h.UseCase.GetByRestaurantID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrNotFound.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// UpdateMenu updates an existing menu's details
func (h *MenuHandler) UpdateMenu(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.UpdateMenu(restaurantID, menu); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// PublishMenu publishes a menu
func (h *MenuHandler) PublishMenu(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	userID := c.GetString("user_id")
	if err := h.UseCase.PublishMenu(restaurantID, userID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// GenerateQRCode generates a QR code for a menu
func (h *MenuHandler) GenerateQRCode(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")

	var req dto.QRCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	qrCodeRequest := dto.DTOToQRCodeRequest(&req)

	qrCode, err := h.UseCase.GenerateQRCode(restaurantID, qrCodeRequest)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	if err := h.QrUseCase.CreateQRCode(qrCode); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"qr_code": dto.DomainToQRCodeResponse(qrCode)}})
}

// DeleteMenu marks a menu as deleted
func (h *MenuHandler) DeleteMenu(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")

	if err := h.UseCase.DeleteMenu(restaurantID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}
