package handler

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

// helper to send standardized error responses
func reviewError(c *gin.Context, status int, code, message string, field string, internal error) {
	resp := dto.ErrorResponse{Message: message, Code: code}
	if field != "" {
		resp.Field = field
	}
	if internal != nil {
		resp.Error = internal.Error()
	}
	c.JSON(status, resp)
}

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
		reviewError(c, http.StatusUnauthorized, "unauthorized", "Unauthorized", "", nil)
		return
	}
	itemID := c.Param("item_id")
	restaurantID := c.Param("restaurant_id")
	if itemID == "" || restaurantID == "" {
		reviewError(c, http.StatusBadRequest, "path_params_required", "restaurant_id and item_id are required in path", "", nil)
		return
	}
	var req dto.ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		reviewError(c, http.StatusBadRequest, "invalid_request", "Invalid request", "", err)
		return
	}
	if req.Rating < 1 || req.Rating > 5 {
		reviewError(c, http.StatusBadRequest, "rating_out_of_range", "rating must be in the range 1 to 5", "rating", nil)
		return
	}
	review := dto.ToDomainReview(req, userID, itemID, restaurantID)
	if err := h.uc.CreateReview(c.Request.Context(), review); err != nil {
		reviewError(c, http.StatusInternalServerError, "create_review_failed", "Failed to create review", "", err)
		return
	}
	createdReview, err := h.uc.GetReviewByID(c.Request.Context(), review.ID)
	if err != nil {
		reviewError(c, http.StatusInternalServerError, "fetch_review_failed", "Failed to fetch created review", "", err)
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
		reviewError(c, http.StatusNotFound, "review_not_found", "Review not found", "id", err)
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
		reviewError(c, http.StatusInternalServerError, "list_reviews_failed", "Failed to list reviews", "", err)
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
		reviewError(c, http.StatusUnauthorized, "unauthorized", "Unauthorized", "", nil)
		return
	}
	id := c.Param("id")
	if id == "" {
		reviewError(c, http.StatusBadRequest, "missing_review_id", "review id is required", "id", nil)
		return
	}

	var req dto.ReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		reviewError(c, http.StatusBadRequest, "invalid_request", "Invalid request", "", err)
		return
	}

	if req.Rating < 1 || req.Rating > 5 {
		reviewError(c, http.StatusBadRequest, "rating_out_of_range", "rating must be in the range 1 to 5", "rating", nil)
		return
	}
	// Load existing to preserve item & restaurant IDs
	existing, _ := h.uc.GetReviewByID(c.Request.Context(), id)
	itemID := ""
	restaurantID := ""
	if existing != nil {
		itemID = existing.ItemID
		restaurantID = existing.RestaurantID
	}
	review := dto.ToDomainReview(req, userID, itemID, restaurantID)
	updatedReview, err := h.uc.UpdateReview(c.Request.Context(), id, userID, review)
	if err != nil {
		if err == domain.ErrUserNotFound {
			reviewError(c, http.StatusNotFound, "review_not_found_or_forbidden", "Review not found or permission denied", "id", err)
			return
		}
		reviewError(c, http.StatusInternalServerError, "update_review_failed", "Failed to update review", "", err)
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
		reviewError(c, http.StatusUnauthorized, "unauthorized", "Unauthorized", "", nil)
		return
	}
	id := c.Param("id")

	if err := h.uc.DeleteReview(c.Request.Context(), id, userID); err != nil {
		if err == domain.ErrUserNotFound {
			reviewError(c, http.StatusNotFound, "review_not_found_or_forbidden", "Review not found or permission denied", "id", err)
			return
		}
		reviewError(c, http.StatusInternalServerError, "delete_review_failed", "Failed to delete review", "", err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Review deleted successfully"})
}

// Get average rating for an item
func (h *ReviewHandler) GetAverageRatingByItem(c *gin.Context) {
	itemID := c.Param("item_id")
	avg, err := h.uc.GetAverageRatingByItem(c.Request.Context(), itemID)
	if err != nil {
		reviewError(c, http.StatusInternalServerError, "get_item_average_failed", "Failed to get item average rating", "item_id", err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"average_rating": avg})
}

// Get average rating for a restaurant
func (h *ReviewHandler) GetAverageRatingByRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	avg, err := h.uc.GetAverageRatingByRestaurant(c.Request.Context(), restaurantID)
	if err != nil {
		reviewError(c, http.StatusInternalServerError, "get_restaurant_average_failed", "Failed to get restaurant average rating", "restaurant_id", err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"average_rating": avg})
}
