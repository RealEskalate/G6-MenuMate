package handler

import (
	"context"
	"net/http"
	"time"

	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/gin-gonic/gin"
)

type HealthHandler struct {
	db      mongo.Database
	timeout time.Duration
}

func NewHealthHandler(db mongo.Database, timeout time.Duration) *HealthHandler {
	return &HealthHandler{db: db, timeout: timeout}
}

// GET /api/v1/health
func (h *HealthHandler) Health(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c.Request.Context(), h.timeout)
	defer cancel()

	start := time.Now()
	comp := gin.H{}

	if err := h.db.Client().Ping(ctx); err != nil {
		comp["database"] = gin.H{"status": "error", "error": err.Error()}
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status":     "degraded",
			"components": comp,
			"timestamp":  time.Now().UTC(),
			"latency_ms": time.Since(start).Milliseconds(),
		})
		return
	}
	comp["database"] = gin.H{"status": "ok"}

	c.JSON(http.StatusOK, gin.H{
		"status":     "ok",
		"components": comp,
		"timestamp":  time.Now().UTC(),
		"latency_ms": time.Since(start).Milliseconds(),
	})
}
