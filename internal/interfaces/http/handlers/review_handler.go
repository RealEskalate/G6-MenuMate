package handler

import (
	"github.com/gin-gonic/gin"
)

type ReviewHandler struct{}

func NewReviewHandler() *ReviewHandler { return &ReviewHandler{} }

func (h *ReviewHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of reviews"})
}
