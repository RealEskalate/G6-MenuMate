package handler

import (
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type ItemHandler struct {
	UseCase domain.IItemUseCase
}

func NewItemHandler(uc domain.IItemUseCase) *ItemHandler {
	return &ItemHandler{UseCase: uc}
}

// CreateItem handles the creation of a new item
func (h *ItemHandler) CreateItem(c *gin.Context) {
	var itemDto dto.ItemRequest
	if err := c.ShouldBindJSON(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}

	item := dto.RequestToItem(&itemDto)
	item.MenuSlug = c.Param("menu_slug")
	if err := h.UseCase.CreateItem(item); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: "Failed to create item", Error: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, dto.SuccessResponse{Message: domain.MsgCreated, Data: gin.H{"item": item}})
}

// GetItemByID retrieves an item by ID
func (h *ItemHandler) GetItemByID(c *gin.Context) {
	id := c.Param("id")
	item, err := h.UseCase.GetItemByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrCodeNotFound.Error(), Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgRetrieved, Data: gin.H{"item": item}})
}

// GetItems retrieves all items
func (h *ItemHandler) GetItems(c *gin.Context) {
	menuSlug := c.Param("menu_slug")

	items, err := h.UseCase.GetItems(menuSlug)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: "Failed to retrieve items", Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgRetrieved, Data: gin.H{"items": dto.ItemToResponseList(items)}})
}

// UpdateItem updates an existing item's details
func (h *ItemHandler) UpdateItem(c *gin.Context) {
	id := c.Param("id")
	var itemDto dto.ItemRequest
	if err := c.Bind(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}

	if err := validate.Struct(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidInput.Error(), Error: err.Error()})
		return
	}
	item := dto.RequestToItem(&itemDto)
	if err := h.UseCase.UpdateItem(id, item); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: "Failed to update item", Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated, Data: gin.H{"item": item}})
}

// AddReview adds a review to an item
func (h *ItemHandler) AddReview(c *gin.Context) {
	id := c.Param("id")
	var review dto.ReviewResponse
	if err := c.ShouldBindJSON(&review); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: err.Error()})
		return
	}
	if err := h.UseCase.AddReview(id, review.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: "Failed to add review", Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.SuccessResponse{Message: "Review added successfully"})
}

// DeleteItem marks an item as deleted
func (h *ItemHandler) DeleteItem(c *gin.Context) {
	id := c.Param("id")
	if err := h.UseCase.DeleteItem(id); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: "Failed to delete item", Error: err.Error()})
		return
	}
	c.JSON(http.StatusNoContent, nil)
}
