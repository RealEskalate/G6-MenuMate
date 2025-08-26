package handler

import (
	"net/http"

	"github.com/dinq/menumate/internal/domain"
	"github.com/dinq/menumate/internal/interfaces/http/dto"
	// usecases "github.com/dinq/menumate/internal/usecases"
	"github.com/gin-gonic/gin"
)

type RestaurantHandler struct {
	usecase domain.IRestaurantUsecase
}

func NewRestaurantHandler(usecase domain.IRestaurantUsecase) *RestaurantHandler {
	return &RestaurantHandler{usecase: usecase}
}

// POST /restaurants
func (h *RestaurantHandler) Create(c *gin.Context) {
	var req dto.RestaurantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
    // Get authenticated user ID from context (set by AuthMiddleware)
    userID, exists := c.Get("user_id")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }

	restaurant := dto.ToDomainRestaurant(req)
    restaurant.Owner = userID.(string)
	err := h.usecase.RegisterRestaurant(c.Request.Context(), &restaurant)
	if err != nil {
		switch err {
		case domain.ErrUserAlreadyExist:
			c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
		case domain.ErrInvalidEmailFormat, domain.ErrInvalidPhoneFormat:
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		}
		return
	}
	c.JSON(http.StatusCreated, dto.ToRestaurantResponse(restaurant))
}

