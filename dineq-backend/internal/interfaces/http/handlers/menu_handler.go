package handler

import (
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
	slug := c.Param("restaurant_slug")

	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	// Normalize possible OCR field alias
	if len(menuDto.Items) == 0 && len(menuDto.MenuItems) > 0 {
		menuDto.Items = menuDto.MenuItems
	}
	menuDto.RestaurantID = slug
	if err := validate.Struct(menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}

	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.CreateMenu(menu); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// GetMenuByID retrieves a menu by ID
func (h *MenuHandler) GetMenus(c *gin.Context) {
	id := c.Param("restaurant_slug")
	menu, err := h.UseCase.GetByRestaurantID(id)
	if err != nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuResponseList(menu)}})
}

// UpdateMenu updates an existing menu's details
func (h *MenuHandler) UpdateMenu(c *gin.Context) {
	userId := c.GetString("user_id")
	slug := c.Param("restaurant_slug")
	menuID := c.Param("id")

	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	menuDto.RestaurantID = slug

	if err := validate.Struct(menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.UpdateMenu(menuID, userId, menu); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// PublishMenu publishes a menu
func (h *MenuHandler) PublishMenu(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	userID := c.GetString("user_id")
	menuID := c.Param("id")

	if err := h.UseCase.PublishMenu(menuID, userID); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// GenerateQRCode generates a QR code for a menu
func (h *MenuHandler) GenerateQRCode(c *gin.Context) {
	restaurantID := c.Param("restaurant_slug")
	menuID := c.Param("id")

	var req dto.QRCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}

	qrCodeRequest := dto.DTOToQRCodeRequest(&req)

	qrCode, err := h.UseCase.GenerateQRCode(restaurantID, menuID, qrCodeRequest)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	if err := h.QrUseCase.CreateQRCode(qrCode); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"qr_code": dto.DomainToQRCodeResponse(qrCode)}})
}

// DeleteMenu marks a menu as deleted
func (h *MenuHandler) DeleteMenu(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	menuID := c.Param("id")

	if err := h.UseCase.DeleteMenu(menuID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusNoContent, dto.SuccessResponse{Message: domain.MsgDeleted})
}

// get menu by id
func (h *MenuHandler) GetMenuByID(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	menuID := c.Param("id")
	menu, err := h.UseCase.GetByID(menuID)
	if err != nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}
