package handler

import (
	"github.com/gin-gonic/gin"
)

type ItemHandler struct{}

func NewItemHandler() *ItemHandler { return &ItemHandler{} }

func (h *ItemHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of items"})
}
