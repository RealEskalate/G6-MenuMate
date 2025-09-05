package handler

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type ReviewHandler struct {
	uc domain.IReviewUsecase
}

func NewReviewHandler(uc domain.IReviewUsecase) *ReviewHandler {
	return &ReviewHandler{uc: uc}
}

// Create a new review for an item
func (h *ReviewHandler) CreateReview(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req dto.ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
		return
	}

	if req.Rating < 1 || req.Rating > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "rating must be in the range 1 to 5"})
		return
	}

	review := dto.ToDomainReview(req, userID)
	if err := h.uc.CreateReview(c.Request.Context(), review); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Use the updated review.ID directly
	createdReview, err := h.uc.GetReviewByID(c.Request.Context(), review.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch created review"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Review created successfully",
		"review":  dto.ToReviewResponse(createdReview, nil),
	})
}

// Get a review by its ID
func (h *ReviewHandler) GetReviewByID(c *gin.Context) {
	id := c.Param("id")
	review, err := h.uc.GetReviewByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Review not found"})
		return
	}
	c.JSON(http.StatusOK, dto.ToReviewResponse(review, nil))
}

// List reviews for a specific item (with pagination)
func (h *ReviewHandler) ListReviewsByItem(c *gin.Context) {
	itemID := c.Param("item_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	reviews, total, err := h.uc.ListReviewsByItem(c.Request.Context(), itemID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"total":   total,
		"page":    page,
		"limit":   limit,
		"reviews": dto.ToReviewResponseList(reviews, nil),
	})
}

// Update a review (by ID and user)
func (h *ReviewHandler) UpdateReview(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	id := c.Param("id")
	if id == "" {
		c.JSON(400, gin.H{"error": "review id is required"})
		return
	}

	var req dto.ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
		return
	}

	if req.Rating < 1 || req.Rating > 5 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "rating must be in the range 1 to 5"})
		return
	}
	review := dto.ToDomainReview(req, userID)
	updatedReview, err := h.uc.UpdateReview(c.Request.Context(), id, userID, review)
	if err != nil {
		if err == domain.ErrUserNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Review not found or permission denied"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// // Fetch the updated review to return it in the response
	// updatedReview, err := h.uc.GetReviewByID(c.Request.Context(), id)
	// if err != nil {
	//     c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch updated review"})
	//     return
	// }

	c.JSON(http.StatusOK, gin.H{
		"message": "Review updated successfully",
		"review":  dto.ToReviewResponse(updatedReview, nil),
	})
}

// Delete a review (by ID and user)
func (h *ReviewHandler) DeleteReview(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	id := c.Param("id")

	if err := h.uc.DeleteReview(c.Request.Context(), id, userID); err != nil {
		// Check if the error is because the review was not found (or already deleted).
		if err == domain.ErrUserNotFound { // Changed to check for ErrUserNotFound
			c.JSON(http.StatusNotFound, gin.H{"error": "Review not found or permission denied"})
			return
		}
		// For any other type of error, return a 500.
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Review deleted successfully"})
}

// Get average rating for an item
func (h *ReviewHandler) GetAverageRatingByItem(c *gin.Context) {
	itemID := c.Param("item_id")
	avg, err := h.uc.GetAverageRatingByItem(c.Request.Context(), itemID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"average_rating": avg})
}

// Get average rating for a restaurant
func (h *ReviewHandler) GetAverageRatingByRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	avg, err := h.uc.GetAverageRatingByRestaurant(c.Request.Context(), restaurantID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"average_rating": avg})
}
