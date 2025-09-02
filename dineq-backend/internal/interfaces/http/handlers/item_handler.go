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
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validate.Struct(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	item := dto.RequestToItem(&itemDto)
	if err := h.UseCase.CreateItem(item); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, dto.ItemToResponse(item))
}

// GetItemByID retrieves an item by ID
func (h *ItemHandler) GetItemByID(c *gin.Context) {
	id := c.Param("id")
	item, err := h.UseCase.GetItemByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}
	c.JSON(http.StatusOK, dto.ItemToResponse(item))
}

// UpdateItem updates an existing item's details
func (h *ItemHandler) UpdateItem(c *gin.Context) {
	id := c.Param("id")
	var itemDto dto.ItemRequest
	if err := c.Bind(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validate.Struct(&itemDto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	item := dto.RequestToItem(&itemDto)
	if err := h.UseCase.UpdateItem(id, item); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ItemToResponse(item))
}

// AddReview adds a review to an item
func (h *ItemHandler) AddReview(c *gin.Context) {
	id := c.Param("id")
	var review dto.ReviewDTO
	if err := c.ShouldBindJSON(&review); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := h.UseCase.AddReview(id, review.UserID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Review added successfully"})
}
