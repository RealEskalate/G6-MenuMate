package handler

import (
	"github.com/gin-gonic/gin"
)

type RefreshTokenHandler struct{}

func NewRefreshTokenHandler() *RefreshTokenHandler { return &RefreshTokenHandler{} }

func (h *RefreshTokenHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "refresh successful"})
}
