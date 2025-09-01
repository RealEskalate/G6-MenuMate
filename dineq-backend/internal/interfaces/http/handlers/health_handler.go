package handler

import (
	"context"
	"net/http"
	"time"

	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/ocr"
	"github.com/gin-gonic/gin"
)

type HealthHandler struct {
    db mongo.Database
    ocrClient *ocr.Client // may be nil if not configured
    ocrBase string
    timeout time.Duration
    httpClient *http.Client
}

func NewHealthHandler(db mongo.Database, ocrClient *ocr.Client, ocrBase string, timeout time.Duration) *HealthHandler {
    return &HealthHandler{db: db, ocrClient: ocrClient, ocrBase: ocrBase, timeout: timeout, httpClient: &http.Client{Timeout: 4 * time.Second}}
}

// GET /api/v1/health
func (h *HealthHandler) Health(c *gin.Context) {
    ctx, cancel := context.WithTimeout(c.Request.Context(), h.timeout)
    defer cancel()

    status := gin.H{"database": "ok"}
    if err := h.db.Client().Ping(ctx); err != nil { status["database"] = "error" }

    if h.ocrClient != nil && h.ocrBase != "" {
        ocrCtx, cancelO := context.WithTimeout(ctx, 3*time.Second)
        defer cancelO()
        url := h.ocrBase + "/health"
        req, _ := http.NewRequestWithContext(ocrCtx, http.MethodGet, url, nil)
        resp, err := h.httpClient.Do(req)
        if err != nil || (resp != nil && resp.StatusCode >= 400) {
            status["ocr_service"] = "error"
        } else if resp != nil {
            status["ocr_service"] = "ok"
            resp.Body.Close()
        }
    } else {
        status["ocr_service"] = "disabled"
    }

    overall := "ok"
    if status["database"] != "ok" || (status["ocr_service"] == "error") {
        overall = "degraded"
    }

    c.JSON(http.StatusOK, gin.H{"status": overall, "components": status, "timestamp": time.Now().UTC()})
}
