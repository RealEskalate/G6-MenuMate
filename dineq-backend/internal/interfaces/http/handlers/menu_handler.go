package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type MenuHandler struct {
	UseCase             domain.IMenuUseCase
	QrUseCase           domain.IQRCodeUseCase
	NotificationUseCase domain.INotificationUseCase
	RestaurantUseCase   domain.IRestaurantUsecase
	ViewEventRepo       domain.IViewEventRepository
}

func NewMenuHandler(uc domain.IMenuUseCase, qc domain.IQRCodeUseCase, rc domain.IRestaurantUsecase, nc domain.INotificationUseCase, v domain.IViewEventRepository) *MenuHandler {
	return &MenuHandler{UseCase: uc, QrUseCase: qc, RestaurantUseCase: rc, NotificationUseCase: nc, ViewEventRepo: v}
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

	if !h.ensureOwnership(c, slug, userId) {
		return
	}

	var menuDto dto.MenuRequest
	contentType := c.ContentType()
	if strings.HasPrefix(contentType, "multipart/form-data") {
		if err := c.Request.ParseMultipartForm(10 << 20); err != nil {
			dto.WriteValidationError(c, "form", "failed to parse multipart form", "multipart_parse_failed", err)
			return
		}
		menuDto.Name = c.PostForm("name")
		menuDto.RestaurantSlug = slug
		menuDto.Version, _ = strconv.Atoi(c.PostForm("version"))
		menuDto.IsPublished = c.PostForm("is_published") == "true"
		// Handle images for menu items
		formItems := c.PostFormArray("items")
		for _, itemJson := range formItems {
			var item dto.ItemRequest
			if err := json.Unmarshal([]byte(itemJson), &item); err == nil {
				// Read image files for each item
				imageHeaders := c.Request.MultipartForm.File[item.Name+"_image"]
				for _, fh := range imageHeaders {
					file, err := fh.Open()
					if err == nil {
						// You should upload the image and get a URL here
						// For now, just append the filename
						item.Image = append(item.Image, fh.Filename)
						file.Close()
					}
				}
				menuDto.Items = append(menuDto.Items, item)
			}
		}
	} else {
		if err := c.ShouldBindJSON(&menuDto); err != nil {
			dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
			return
		}
		// Normalize possible OCR field alias
		if len(menuDto.Items) == 0 && len(menuDto.MenuItems) > 0 {
			menuDto.Items = menuDto.MenuItems
		}
		menuDto.RestaurantSlug = slug
	}
	// Normalize possible OCR field alias
	if len(menuDto.Items) == 0 && len(menuDto.MenuItems) > 0 {
		menuDto.Items = menuDto.MenuItems
	}
	menuDto.RestaurantSlug = slug
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
	slug := c.Param("restaurant_slug")
	rest, err := h.RestaurantUseCase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil || rest == nil {
		dto.WriteError(c, domain.ErrRestaurantNotFound)
		return
	}
	menus, err := h.UseCase.GetByRestaurantID(rest.ID)
	if err != nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	// Increment view count for restaurant and all menus, log view events
	if rest.ID != "" {
		_ = h.RestaurantUseCase.IncrementRestaurantViewCount(rest.ID)
		h.ViewEventRepo.LogView(&domain.ViewEvent{
			EntityType: "restaurant",
			EntityID:   rest.ID,
			UserID:     getUserID(c),
			Timestamp:  time.Now(),
			IP:         c.ClientIP(),
			UserAgent:  c.Request.UserAgent(),
		})
	}
	for _, m := range menus {
		h.UseCase.IncrementMenuViewCount(m.ID)
		h.ViewEventRepo.LogView(&domain.ViewEvent{
			EntityType: "menu",
			EntityID:   m.ID,
			UserID:     getUserID(c),
			Timestamp:  time.Now(),
			IP:         c.ClientIP(),
			UserAgent:  c.Request.UserAgent(),
		})
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuResponseList(menus)}})
}

// UpdateMenu updates an existing menu's details
func (h *MenuHandler) UpdateMenu(c *gin.Context) {
	userId := c.GetString("user_id")
	slug := c.Param("restaurant_slug")
	menuID := c.Param("id")

	if !h.ensureOwnership(c, slug, userId) {
		return
	}

	var menuDto dto.MenuRequest
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	menuDto.RestaurantSlug = slug
	if menuDto.Name == "" && len(menuDto.Items) == 0 && len(menuDto.MenuItems) == 0 {
		dto.WriteValidationError(c, "payload", "nothing to update", "invalid_request", nil)
		return
	}
	// Normalize OCR alias
	if len(menuDto.Items) == 0 && len(menuDto.MenuItems) > 0 {
		menuDto.Items = menuDto.MenuItems
	}
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
	if !h.ensureOwnership(c, slug, userID) {
		return
	}

	if err := h.UseCase.PublishMenu(menuID, userID); err != nil {
		dto.WriteError(c, err)
		return
	}
	updated, err := h.UseCase.GetByID(menuID)
	if err != nil {
		c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuToResponse(updated)}})
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
	if !h.ensureOwnership(c, slug, userID) {
		return
	}

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

// MenuItemUpdate updates a specific menu item within a menu
func (h *MenuHandler) MenuItemUpdate(c *gin.Context) {
	restaurantSlug := c.Param("restaurant_slug")
	userID := c.GetString("user_id")
	menuSlug := c.Param("menu_slug")

	if !h.ensureOwnership(c, restaurantSlug, userID) {
		return
	}

	var itemDto dto.ItemRequest
	if err := c.ShouldBindJSON(&itemDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if itemDto.Name == "" && itemDto.Description == "" && itemDto.Price == 0 {
		dto.WriteValidationError(c, "payload", "nothing to update", "invalid_request", nil)
		return
	}
	item := dto.RequestToItem(&itemDto)
	if err := h.UseCase.MenuItemUpdate(menuSlug, item); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"item": dto.ItemToResponse(item)}})
}

// GetMenuItemBySlug retrieves a menu item by its slug
func (h *MenuHandler) GetMenuItemBySlug(c *gin.Context) {
	_ = c.Param("restaurant_slug")
	menuSlug := c.Param("menu_slug")
	itemSlug := c.Param("item_slug")

	item, err := h.UseCase.GetMenuItemBySlug(menuSlug, itemSlug)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	// Increment view count for item and parent menu, log view events
	h.UseCase.IncrementMenuViewCount(menuSlug)
	h.ViewEventRepo.LogView(&domain.ViewEvent{
		EntityType: "menu",
		EntityID:   menuSlug,
		UserID:     getUserID(c),
		Timestamp:  time.Now(),
		IP:         c.ClientIP(),
		UserAgent:  c.Request.UserAgent(),
	})
	// If item has an ID
	if item != nil && item.ID != "" {
		// You may want to add an IncrementItemViewCount method
		h.ViewEventRepo.LogView(&domain.ViewEvent{
			EntityType: "item",
			EntityID:   item.ID,
			UserID:     getUserID(c),
			Timestamp:  time.Now(),
			IP:         c.ClientIP(),
			UserAgent:  c.Request.UserAgent(),
		})
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"item": dto.ItemToResponse(item)}})
}

// PublicGetPublishedMenus lists published menus for a restaurant (by slug) without auth.
func (h *MenuHandler) PublicGetPublishedMenus(c *gin.Context) {
	restSlug := c.Param("restaurant_slug")
	menus, err := h.UseCase.GetByRestaurantID(restSlug)
	if err != nil || len(menus) == 0 {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	// filter only published
	var published []*domain.Menu
	for _, m := range menus {
		if m.IsPublished && !m.IsDeleted {
			published = append(published, m)
		}
	}
	if len(published) == 0 {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menus": dto.MenuResponseList(published)}})
}

// PublicGetPublishedMenuByID returns a single published menu & increments view count.
func (h *MenuHandler) PublicGetPublishedMenuByID(c *gin.Context) {
	restSlug := c.Param("restaurant_slug")
	menuID := c.Param("id")
	menu, err := h.UseCase.GetByID(menuID)
	if err != nil || menu == nil || menu.IsDeleted || !menu.IsPublished {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	// best-effort guard: ensure requested restaurant matches
	if strings.TrimSpace(restSlug) != "" && strings.TrimSpace(menu.RestaurantSlug) != "" && restSlug != menu.RestaurantSlug {
		// allow either slug or id style match; if mismatch, hide existence
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	_ = h.UseCase.IncrementMenuViewCount(menuID) // best-effort
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"menu": dto.MenuToResponse(menu)}})
}
