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
	RestaurantUseCase   domain.IRestaurantUsecase
}

func NewMenuHandler(uc domain.IMenuUseCase, qc domain.IQRCodeUseCase, rc domain.IRestaurantUsecase, nc domain.INotificationUseCase) *MenuHandler {
	return &MenuHandler{UseCase: uc, QrUseCase: qc, RestaurantUseCase: rc, NotificationUseCase: nc}
}

func (h *MenuHandler) ensureOwnership(c *gin.Context, slug string, userID string) bool {
	rest, err := h.RestaurantUseCase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil || rest == nil {
		dto.WriteError(c, domain.ErrRestaurantNotFound)
		return false
	}
	role := c.GetString("role")
	if rest.ManagerID != userID && role != string(domain.RoleOwner) {
		dto.WriteError(c, domain.ErrForbidden)
		return false
	}
	return true
}

// CreateMenu handles the creation of a new menu
func (h *MenuHandler) CreateMenu(c *gin.Context) {
	slug := c.Param("restaurant_slug")
	userId := c.GetString("user_id")

	if !h.ensureOwnership(c, slug, userId) { return }

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
	menu.CreatedBy = userId
	menu.UpdatedBy = userId // attribute creator
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

	if !h.ensureOwnership(c, slug, userId) { return }

	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	menuDto.RestaurantID = slug
	if menuDto.Name == "" && len(menuDto.Items) == 0 && len(menuDto.MenuItems) == 0 {
		dto.WriteValidationError(c, "payload", "nothing to update", "invalid_request", nil)
		return
	}
	// Normalize OCR alias
	if len(menuDto.Items) == 0 && len(menuDto.MenuItems) > 0 { menuDto.Items = menuDto.MenuItems }
	menu := dto.RequestToMenu(&menuDto)
	if err := h.UseCase.UpdateMenu(menuID, userId, menu); err != nil {
		dto.WriteError(c, err)
		return
	}
	// Reload full menu to include DB-populated fields (id, slug, version, etc.)
	updated, err := h.UseCase.GetByID(menuID)
	if err != nil {
		// fallback: respond with partial menu
		c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"menu": dto.MenuToResponse(updated)}})
}

// PublishMenu publishes a menu
func (h *MenuHandler) PublishMenu(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	userID := c.GetString("user_id")
	slug := c.Param("restaurant_slug")
	menuID := c.Param("id")
	if !h.ensureOwnership(c, slug, userID) { return }

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
	slug := c.Param("restaurant_slug")
	userID := c.GetString("user_id")
	menuID := c.Param("id")
	if !h.ensureOwnership(c, slug, userID) { return }

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
