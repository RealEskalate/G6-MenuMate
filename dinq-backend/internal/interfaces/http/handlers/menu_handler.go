package handler

import (
	"github.com/gin-gonic/gin"
)

type MenuHandler struct{}

func NewMenuHandler() *MenuHandler { return &MenuHandler{} }

func (h *MenuHandler) Register(c *gin.Context) {
	c.JSON(200, gin.H{"message": "list of menus"})
}
