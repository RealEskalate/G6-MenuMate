package handler

import (
	"context"
	"net/http"
	"sort"
	"time"

	applog "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/gin-gonic/gin"
)

// containsEthiopic returns true if s contains any Ethiopic (Ge'ez) script rune.
func containsEthiopic(s string) bool {
	for _, r := range s {
		if r >= 0x1200 && r <= 0x137F { // Ethiopic block
			return true
		}
		if r >= 0x1380 && r <= 0x139F { // Ethiopic Supplement
			return true
		}
		if r >= 0x2D80 && r <= 0x2DDF { // Ethiopic Extended
			return true
		}
		if r >= 0xAB00 && r <= 0xAB2F { // Ethiopic Extended-A
			return true
		}
	}
	return false
}

type ImageSearchHandler struct {
	google   services.IGoogleCustomSearchService
	unsplash *services.UnsplashSearchService
	pexels   *services.PexelsSearchService
	clf      services.EthiopianFoodClassifier
}

func NewImageSearchHandler(google services.IGoogleCustomSearchService, unsplash *services.UnsplashSearchService, pexels *services.PexelsSearchService, clf services.EthiopianFoodClassifier) *ImageSearchHandler {
	return &ImageSearchHandler{google: google, unsplash: unsplash, pexels: pexels, clf: clf}
}

// performSearch encapsulates the core image search aggregation logic.
type searchDiagnostics struct {
	GoogleEnabled   bool   `json:"google_enabled"`
	GoogleError     string `json:"google_error,omitempty"`
	UnsplashEnabled bool   `json:"unsplash_enabled"`
	UnsplashError   string `json:"unsplash_error,omitempty"`
	PexelsEnabled   bool   `json:"pexels_enabled"`
	PexelsError     string `json:"pexels_error,omitempty"`
}

func (h *ImageSearchHandler) performSearch(parent context.Context, item, restaurant string) []services.PhotoMatch {
	ctx, cancel := context.WithTimeout(parent, 12*time.Second)
	defer cancel()
	perSource := 2 // default mixed strategy

	// Strategy:
	// - If item includes Amharic (Ethiopic) letters, use Google-only (6 results)
	// - Else (Latin), if classifier exists and says yes -> Google-only (6), else mixed 2 each
	googleOnly := containsEthiopic(item)
	if !googleOnly && h.clf != nil {
		if ok, err := h.clf.IsEthiopianFoodName(ctx, item); err == nil && ok {
			googleOnly = true
		}
	}

	var googleRes, unsRes, pexRes []services.PhotoMatch
	if gr, err := h.google.SearchFoodImages(ctx, item, restaurant, func() int { if googleOnly { return 6 } else { return perSource } }()); err == nil {
		googleRes = gr
	} else {
		applog.Log.Warn().Err(err).Msg("google image search failed")
	}
	if h.unsplash != nil && !googleOnly {
		if ur, err := h.unsplash.Search(ctx, item, perSource); err == nil {
			unsRes = ur
		} else {
			applog.Log.Warn().Err(err).Msg("unsplash image search failed")
		}
	}
	if h.pexels != nil && !googleOnly {
		if pr, err := h.pexels.Search(ctx, item, perSource); err == nil {
			pexRes = pr
		} else {
			applog.Log.Warn().Err(err).Msg("pexels image search failed")
		}
	}

	// If Google-only, take top 6 from Google; else keep top 2 Google first
	if googleOnly {
		if len(googleRes) > 6 {
			googleRes = googleRes[:6]
		}
	} else {
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
	return combined
}

// performSearchWithDiagnostics runs search and returns diagnostics about providers.
func (h *ImageSearchHandler) performSearchWithDiagnostics(parent context.Context, item, restaurant string) ([]services.PhotoMatch, searchDiagnostics) {
	diag := searchDiagnostics{
		GoogleEnabled:   h.google != nil && h.google.Enabled(),
		UnsplashEnabled: h.unsplash != nil,
		PexelsEnabled:   h.pexels != nil,
	}

	ctx, cancel := context.WithTimeout(parent, 12*time.Second)
	defer cancel()
	perSource := 2

	googleOnly := containsEthiopic(item)
	if !googleOnly && h.clf != nil {
		if ok, err := h.clf.IsEthiopianFoodName(ctx, item); err == nil && ok {
			googleOnly = true
		}
	}

	var googleRes, unsRes, pexRes []services.PhotoMatch
	if diag.GoogleEnabled {
		if gr, err := h.google.SearchFoodImages(ctx, item, restaurant, func() int { if googleOnly { return 6 } else { return perSource } }()); err == nil {
			googleRes = gr
		} else {
			diag.GoogleError = err.Error()
			applog.Log.Warn().Err(err).Str("item", item).Msg("google image search failed")
		}
	}
	if h.unsplash != nil && !googleOnly {
		if ur, err := h.unsplash.Search(ctx, item, perSource); err == nil {
			unsRes = ur
		} else {
			diag.UnsplashError = err.Error()
		}
	}
	if h.pexels != nil && !googleOnly {
		if pr, err := h.pexels.Search(ctx, item, perSource); err == nil {
			pexRes = pr
		} else {
			diag.PexelsError = err.Error()
		}
	}

	if googleOnly {
		if len(googleRes) > 6 {
			googleRes = googleRes[:6]
		}
	} else {
		if len(googleRes) > 2 {
			googleRes = googleRes[:2]
		}
	}
	others := append([]services.PhotoMatch{}, unsRes...)
	others = append(others, pexRes...)
	sort.Slice(others, func(i, j int) bool { return others[i].ConfidenceScore > others[j].ConfidenceScore })
	combined := make([]services.PhotoMatch, 0, 6)
	combined = append(combined, googleRes...)
	for _, m := range others {
		if len(combined) >= 6 {
			break
		}
		combined = append(combined, m)
	}
	return combined, diag
}

// Search handles GET /images/search and reads parameters from query string.
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

	combined, diag := h.performSearchWithDiagnostics(c.Request.Context(), item, restaurant)
	resp := gin.H{"success": true, "data": gin.H{"item": item, "restaurant": restaurant, "count": len(combined), "results": combined}}
	if len(combined) == 0 {
		resp["diagnostics"] = diag
	}
	c.JSON(http.StatusOK, resp)
}

// SearchPost handles POST /images/search and reads parameters from JSON body.
func (h *ImageSearchHandler) SearchPost(c *gin.Context) {
	if !h.google.Enabled() {
		c.JSON(http.StatusServiceUnavailable, gin.H{"success": false, "error": "image search disabled"})
		return
	}
	var body struct {
		Item       string `json:"item" binding:"required"`
		Restaurant string `json:"restaurant"`
		// Limit is intentionally ignored to retain the fixed per-source policy
		Limit int `json:"limit"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || body.Item == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "item field required"})
		return
	}
	combined, diag := h.performSearchWithDiagnostics(c.Request.Context(), body.Item, body.Restaurant)
	resp := gin.H{"success": true, "data": gin.H{"item": body.Item, "restaurant": body.Restaurant, "count": len(combined), "results": combined}}
	if len(combined) == 0 {
		resp["diagnostics"] = diag
	}
	c.JSON(http.StatusOK, resp)
}
