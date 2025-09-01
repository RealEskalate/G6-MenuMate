package handler

import (
<<<<<<< HEAD
	"github.com/gin-gonic/gin"
)

type MenuHandler struct{}

func NewMenuHandler() *MenuHandler { return &MenuHandler{} }

func (h *MenuHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of menus"})
=======
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type MenuHandler struct {
	UseCase             domain.IMenuUseCase
	NotificationUseCase domain.INotificationUseCase
}

func NewMenuHandler(uc domain.IMenuUseCase, nc domain.INotificationUseCase) *MenuHandler {
	return &MenuHandler{UseCase: uc, NotificationUseCase: nc}
}

// CreateMenu handles the creation of a new menu
func (h *MenuHandler) CreateMenu(c *gin.Context) {
	var menuDto dto.MenuDTO
	if err := c.ShouldBindJSON(&menuDto); err != nil {
		c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
		return
	}

	menu := dto.DTOToMenu(&menuDto)
	if err := h.UseCase.CreateMenu(menu); err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, menu)
}

// GetMenuByID retrieves a menu by ID
func (h *MenuHandler) GetMenuByID(c *gin.Context) {
	id := c.Param("id")
	menu, err := h.UseCase.GetMenuByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, map[string]string{"error": "Menu not found"})
		return
	}
	c.JSON(http.StatusOK, menu)
}

// UpdateMenu updates an existing menu's details
func (h *MenuHandler) UpdateMenu(c *gin.Context) {
	id := c.Param("id")
	var menuDto dto.MenuDTO
	if err := c.Bind(&menuDto); err != nil {
		c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
		return
	}

	menu := dto.DTOToMenu(&menuDto)
	if err := h.UseCase.UpdateMenu(id, menu); err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, menu)
}

// PublishMenu publishes a menu
func (h *MenuHandler) PublishMenu(c *gin.Context) {
	id := c.Param("id")
	userID := c.GetString("userID")
	if err := h.UseCase.PublishMenu(id, userID); err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Menu published successfully"})
}

// GenerateQRCode generates a QR code for a menu
func (h *MenuHandler) GenerateQRCode(c *gin.Context) {
	id := c.Param("id")
	qrCode, err := h.UseCase.GenerateQRCode(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, qrCode)
}

// DeleteMenu marks a menu as deleted
func (h *MenuHandler) DeleteMenu(c *gin.Context) {
	id := c.Param("id")
	if err := h.UseCase.DeleteMenu(id); err != nil {
		c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Menu deleted successfully"})
>>>>>>> Backend_develop
}
