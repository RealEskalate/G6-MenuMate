package handler

import (
	"github.com/gin-gonic/gin"
)

type RestaurantHandler struct{}

func NewRestaurantHandler() *RestaurantHandler { return &RestaurantHandler{} }

func (h *RestaurantHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of restaurants"})
}
