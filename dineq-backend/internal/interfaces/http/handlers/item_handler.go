package handler

import (
	"net/http"
	"time"

	"strings"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type ItemHandler struct {
	UseCase domain.IItemUseCase
	ViewEventRepo domain.IViewEventRepository
}

func NewItemHandler(uc domain.IItemUseCase, v domain.IViewEventRepository) *ItemHandler {
	return &ItemHandler{UseCase: uc, ViewEventRepo: v}
}

// CreateItem handles the creation of a new item
func (h *ItemHandler) CreateItem(c *gin.Context) {
	var itemDto dto.ItemRequest
	if err := c.ShouldBindJSON(&itemDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}

	if err := validate.Struct(&itemDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
		return
	}

	item := dto.RequestToItem(&itemDto)
	item.MenuSlug = c.Param("menu_slug")
	if err := h.UseCase.CreateItem(item); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"item": item}})
}

// GetItemByID retrieves an item by ID
func (h *ItemHandler) GetItemByID(c *gin.Context) {
	id := c.Param("id")
	item, err := h.UseCase.GetItemByID(id)
	if err != nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}
	// Increment view count and log view event
	h.ViewEventRepo.LogView(&domain.ViewEvent{
		EntityType: "item",
		EntityID:   id,
		UserID:     getUserID(c),
		Timestamp:  time.Now(),
		IP:         c.ClientIP(),
		UserAgent:  c.Request.UserAgent(),
	})
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgRetrieved, Data: gin.H{"item": item}})
}

// GetItems retrieves all items
func (h *ItemHandler) GetItems(c *gin.Context) {
	menuSlug := c.Param("menu_slug")

	items, err := h.UseCase.GetItems(menuSlug)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	// Log view event for menu
	h.ViewEventRepo.LogView(&domain.ViewEvent{
		EntityType: "menu",
		EntityID:   menuSlug,
		UserID:     getUserID(c),
		Timestamp:  time.Now(),
		IP:         c.ClientIP(),
		UserAgent:  c.Request.UserAgent(),
	})
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgRetrieved, Data: gin.H{"items": dto.ItemToResponseList(items)}})
}
// SearchItems supports advanced filtering within a menu
func (h *ItemHandler) SearchItems(c *gin.Context) {
	var q dto.ItemSearchQuery
	// Bind from query parameters
	if err := c.ShouldBindQuery(&q); err != nil {
		dto.WriteValidationError(c, "query", domain.ErrInvalidRequest.Error(), "invalid_query", err)
		return
	}
	// Support comma-separated tags fallback
	if len(q.Tags) == 0 {
		if raw := c.Query("tags"); raw != "" {
			parts := strings.Split(raw, ",")
			tmp := make([]string, 0, len(parts))
			for _, p := range parts { if s := strings.TrimSpace(p); s != "" { tmp = append(tmp, s) } }
			q.Tags = tmp
		}
	}
	// Fallback: if path param is provided as menu_slug
	if q.MenuSlug == "" {
		if ms := c.Query("menu_slug"); ms != "" { q.MenuSlug = ms }
		if ms := c.Param("menu_slug"); ms != "" { q.MenuSlug = ms }
	}
	if q.MenuSlug == "" {
		dto.WriteValidationError(c, "menu_slug", "menu_slug is required", "missing_menu_slug", nil)
		return
	}
	items, total, err := h.UseCase.SearchItems(q.ToDomain())
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	page := q.Page
	size := q.PageSize
	if page <= 0 { page = 1 }
	if size <= 0 { size = 10 }
	totalPages := (total + int64(size) - 1) / int64(size)
	c.JSON(http.StatusOK, gin.H{
		"page": page,
		"pageSize": size,
		"total": total,
		"totalPages": totalPages,
		"items": dto.ItemToResponseList(items),
	})
}
// Helper to extract user ID from context (if available)
func getUserID(c *gin.Context) string {
	if uid, ok := c.Get("user_id"); ok {
		if s, ok := uid.(string); ok {
			return s
		}
	}
	return ""
}

// UpdateItem updates an existing item's details
func (h *ItemHandler) UpdateItem(c *gin.Context) {
	id := c.Param("id")
	var itemDto dto.ItemRequest
	if err := c.Bind(&itemDto); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}

	// if err := validate.Struct(&itemDto); err != nil {
	// 	dto.WriteValidationError(c, "payload", domain.ErrInvalidInput.Error(), "invalid_input", err)
	// 	return
	// }
	item := dto.RequestToItem(&itemDto)
	if err := h.UseCase.UpdateItem(id, item); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"item": item}})
}

// AddReview adds a review to an item
func (h *ItemHandler) AddReview(c *gin.Context) {
	id := c.Param("id")
	var review dto.ReviewResponse
	if err := c.ShouldBindJSON(&review); err != nil {
		dto.WriteValidationError(c, "payload", domain.ErrInvalidRequest.Error(), "invalid_request", err)
		return
	}
	if err := h.UseCase.AddReview(id, review.UserID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: "Review added successfully"})
}

// DeleteItem marks an item as deleted
func (h *ItemHandler) DeleteItem(c *gin.Context) {
	id := c.Param("id")
	if err := h.UseCase.DeleteItem(id); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusNoContent, nil)
}
