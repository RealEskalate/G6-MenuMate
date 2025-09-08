package handler

import (
	"context"
	"fmt"
	"net/http"
	"sort"
	"time"

	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/gin-gonic/gin"
)

type ImageSearchHandler struct {
	google   services.IGoogleCustomSearchService
	unsplash *services.UnsplashSearchService
	pexels   *services.PexelsSearchService
	ai       services.IAIService
}

func NewImageSearchHandler(google services.IGoogleCustomSearchService, unsplash *services.UnsplashSearchService, pexels *services.PexelsSearchService, ai services.IAIService) *ImageSearchHandler {
	return &ImageSearchHandler{google: google, unsplash: unsplash, pexels: pexels, ai: ai}
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
	// Default per-source limit = 2 (total up to 6). If AI says item is Ethiopian
	// food, prefer Google search only and request up to 6 Google results.
	googlePer := 2
	unsPer := 2
	pexPer := 2

	// Ask AI if available. If AI is configured and returns yes, switch to
	// google-only path (6 results); on error fall back to multi-source.
	if h.ai != nil {
		if isE, err := h.ai.IsEthiopianFood(ctx, item); err == nil {
			if isE {
				googlePer = 6
				unsPer = 0
				pexPer = 0
			}
		} else {
			// log but continue with default multi-source
			fmt.Printf("[ImageSearch] AI decision failed: %v\n", err)
		}
	}

	var googleRes, unsRes, pexRes []services.PhotoMatch
	if gr, err := h.google.SearchFoodImages(ctx, item, restaurant, googlePer); err == nil {
		googleRes = gr
	}
	if h.unsplash != nil && unsPer > 0 {
		if ur, err := h.unsplash.Search(ctx, item, unsPer); err == nil {
			unsRes = ur
		}
	}
	if h.pexels != nil && pexPer > 0 {
		if pr, err := h.pexels.Search(ctx, item, pexPer); err == nil {
			pexRes = pr
		}
	}

	// If we are using multiple sources (unsplash or pexels) keep the first two
	// Google results at the top (Google service already sorts by confidence).
	// If this is the google-only path (unsPer == 0 && pexPer == 0) we should
	// keep up to the requested googlePer results (e.g. 6) and not truncate here.
	if unsPer > 0 || pexPer > 0 {
		if len(googleRes) > 2 {
			googleRes = googleRes[:2]
		}
	}

	// Collect non-Google results
	others := append([]services.PhotoMatch{}, unsRes...)
	others = append(others, pexRes...)

	// Sort others by confidence descending
	sort.Slice(others, func(i, j int) bool { return others[i].ConfidenceScore > others[j].ConfidenceScore })

	// Combine (Google first) then others up to 6
	combined := make([]services.PhotoMatch, 0, 6)
	combined = append(combined, googleRes...)
	for _, m := range others {
		if len(combined) >= 6 {
			break
		}
		combined = append(combined, m)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"item": item, "restaurant": restaurant, "count": len(combined), "results": combined}})
}
