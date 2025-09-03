package handler

import (
	"context"
	"net/http"
	"sort"
	"time"

	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/gin-gonic/gin"
)

type ImageSearchHandler struct {
    google  services.IGoogleCustomSearchService
    unsplash *services.UnsplashSearchService
    pexels   *services.PexelsSearchService
}

func NewImageSearchHandler(google services.IGoogleCustomSearchService, unsplash *services.UnsplashSearchService, pexels *services.PexelsSearchService) *ImageSearchHandler {
    return &ImageSearchHandler{google: google, unsplash: unsplash, pexels: pexels}
}

// GET /api/v1/images/search?item=Injera&restaurant=Abugida&limit=5
func (h *ImageSearchHandler) Search(c *gin.Context) {
    if !h.google.Enabled() {
        c.JSON(http.StatusServiceUnavailable, gin.H{"success": false, "error": "image search disabled"})
        return
    }
    item := c.Query("item")
    if item == "" {
        c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "item query param required"})
        return
    }
    restaurant := c.Query("restaurant")
    // optional limit param is ignored in favor of fixed per-source count (backwards compatibility parsing retained)
    _ = c.Query("limit")
    ctx, cancel := context.WithTimeout(c.Request.Context(), 8*time.Second)
    defer cancel()
    // Force per-source limit = 2 (spec: 2 from each provider, total up to 6)
    perSource := 2

    var googleRes, unsRes, pexRes []services.PhotoMatch
    if gr, err := h.google.SearchFoodImages(ctx, item, restaurant, perSource); err == nil {
        googleRes = gr
    }
    if h.unsplash != nil {
        if ur, err := h.unsplash.Search(ctx, item, perSource); err == nil { unsRes = ur }
    }
    if h.pexels != nil {
        if pr, err := h.pexels.Search(ctx, item, perSource); err == nil { pexRes = pr }
    }

    // Always keep the first two Google results at the top (Google service already sorts by confidence)
    if len(googleRes) > 2 { googleRes = googleRes[:2] }

    // Collect non-Google results
    others := append([]services.PhotoMatch{}, unsRes...)
    others = append(others, pexRes...)

    // Sort others by confidence descending
    sort.Slice(others, func(i, j int) bool { return others[i].ConfidenceScore > others[j].ConfidenceScore })

    // Combine (Google first) then others up to 6
    combined := make([]services.PhotoMatch, 0, 6)
    combined = append(combined, googleRes...)
    for _, m := range others {
        if len(combined) >= 6 { break }
        combined = append(combined, m)
    }

    c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"item": item, "restaurant": restaurant, "count": len(combined), "results": combined}})
}

