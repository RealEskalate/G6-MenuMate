package handler

import (
	"github.com/gin-gonic/gin"
)

type PhotoHandler struct{}

func NewPhotoHandler() *PhotoHandler { return &PhotoHandler{} }

func (h *PhotoHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of photos"})
}
