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
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	menuDto.RestaurantID = slug
	if validate.Struct(menuDto) != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: validate.Struct(menuDto).Error()})
		return
	}

	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.CreateMenu(menu); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}

// GetMenuByID retrieves a menu by ID
func (h *MenuHandler) GetMenus(c *gin.Context) {
	id := c.Param("restaurant_slug")
	menu, err := h.UseCase.GetByRestaurantID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrNotFound.Error(), Error: err.Error()})
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
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	menuDto.RestaurantID = slug

	if validate.Struct(menuDto) != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: validate.Struct(menuDto).Error()})
		return
	}
	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.UpdateMenu(menuID, userId, menu); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
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
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
}

// GenerateQRCode generates a QR code for a menu
func (h *MenuHandler) GenerateQRCode(c *gin.Context) {
	restaurantID := c.Param("restaurant_slug")
	menuID := c.Param("id")

	var req dto.QRConfig
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	domainReq := dto.QRConfigToDomain(&req)
	if validate.Struct(domainReq) != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: validate.Struct(domainReq).Error()})
		return
	}

	qrCode, err := h.UseCase.GenerateQRCode(restaurantID, menuID, domainReq)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	if err := h.QrUseCase.CreateQRCode(qrCode); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"qr_code": dto.DomainToQRCodeResponse(qrCode)}})
}

// DeleteMenu marks a menu as deleted
func (h *MenuHandler) DeleteMenu(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	menuID := c.Param("id")

	if err := h.UseCase.DeleteMenu(menuID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusNoContent, dto.SuccessResponse{Message: domain.MsgDeleted})
}

//get menu by id
func (h *MenuHandler) GetMenuByID(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	menuID := c.Param("id")
	menu, err := h.UseCase.GetByID(menuID)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrNotFound.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}
