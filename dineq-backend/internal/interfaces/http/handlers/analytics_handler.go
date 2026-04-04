package handler

import (
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/gin-gonic/gin"
)

type AnalyticsHandler struct {
	analyticsUC domain.IAnalyticsUsecase
}

func NewAnalyticsHandler(auc domain.IAnalyticsUsecase) *AnalyticsHandler {
	return &AnalyticsHandler{analyticsUC: auc}
}

func (h *AnalyticsHandler) GetRestaurantAnalytics(c *gin.Context) {
	restaurantID := c.Param("id")
	if restaurantID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "restaurant_id required"})
		return
	}

	period := c.DefaultQuery("period", "today")
	analytics, err := h.analyticsUC.GetRestaurantAnalytics(restaurantID, period)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, analytics)
}
