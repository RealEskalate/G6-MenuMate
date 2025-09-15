package services

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"sort"
	"strings"
	"time"
)

// PhotoMatch represents a matched photo result from Google Custom Search.
// Defined locally (not in domain) because it's an auxiliary lookup, not persisted.
type PhotoMatch struct {
	ItemName        string  `json:"item_name"`
	PhotoURL        string  `json:"photo_url"`
	ThumbnailURL    string  `json:"thumbnail_url,omitempty"`
	ConfidenceScore float64 `json:"confidence_score"`
	Source          string  `json:"source"`
	AltText         string  `json:"alt_text"`
}

type googleSearchResponse struct {
	Items []googleSearchItem `json:"items"`
}

type googleSearchItem struct {
	Title   string           `json:"title"`
	Link    string           `json:"link"`
	Snippet string           `json:"snippet"`
	Image   *googleImageInfo `json:"image,omitempty"`
	PageMap *googlePageMap   `json:"pagemap,omitempty"`
}

type googleImageInfo struct {
	ThumbnailLink string `json:"thumbnailLink"`
}

type googlePageMap struct {
	CSEThumbnail []cseThumb `json:"cse_thumbnail,omitempty"`
}

type cseThumb struct {
	Src string `json:"src"`
}

// IGoogleCustomSearchService contract for dependency injection / mocking.
type IGoogleCustomSearchService interface {
	SearchFoodImages(ctx context.Context, itemName, restaurantName string, limit int) ([]PhotoMatch, error)
	Enabled() bool
}

// GoogleCustomSearchService implements Google Custom Search image lookup.
type GoogleCustomSearchService struct {
	apiKey string
	cx     string
	client *http.Client
}

func NewGoogleCustomSearchService(apiKey, cx string) IGoogleCustomSearchService {
	return &GoogleCustomSearchService{
		apiKey: apiKey,
		cx:     cx,
		client: &http.Client{Timeout: 12 * time.Second},
	}
}

func (g *GoogleCustomSearchService) Enabled() bool { return g.apiKey != "" && g.cx != "" }

// SearchFoodImages queries Google Custom Search for food item images (image search type).
// It returns up to 'limit' (capped at 10 per API restrictions) scored matches.
func (g *GoogleCustomSearchService) SearchFoodImages(ctx context.Context, itemName, restaurantName string, limit int) ([]PhotoMatch, error) {
	if !g.Enabled() {
		return nil, fmt.Errorf("google custom search disabled: missing credentials")
	}
	if limit <= 0 || limit > 10 {
		limit = 5
	}

	query := fmt.Sprintf("%s food", itemName)
	if restaurantName != "" {
		query = fmt.Sprintf("%s %s Ethiopian food", itemName, restaurantName)
	}

	baseURL := "https://www.googleapis.com/customsearch/v1"
	params := url.Values{}
	params.Set("q", query)
	params.Set("cx", g.cx)
	params.Set("key", g.apiKey)
	params.Set("searchType", "image")
	params.Set("num", fmt.Sprintf("%d", limit))
	params.Set("imgSize", "medium")
	params.Set("imgType", "photo")
	params.Set("safe", "active")

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, baseURL+"?"+params.Encode(), nil)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	resp, err := g.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("execute search: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("search API status %d", resp.StatusCode)
	}

	var raw googleSearchResponse
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}

	matches := make([]PhotoMatch, 0, len(raw.Items))
	for _, it := range raw.Items {
		m := PhotoMatch{
			ItemName:        itemName,
			PhotoURL:        it.Link,
			ConfidenceScore: g.confidence(itemName, it.Title, it.Snippet),
			Source:          "google_custom_search",
			AltText:         fmt.Sprintf("%s - %s", itemName, strings.TrimSpace(it.Title)),
		}
		if it.Image != nil && it.Image.ThumbnailLink != "" {
			m.ThumbnailURL = it.Image.ThumbnailLink
		} else if it.PageMap != nil && len(it.PageMap.CSEThumbnail) > 0 {
			m.ThumbnailURL = it.PageMap.CSEThumbnail[0].Src
		}
		matches = append(matches, m)
	}

	// Sort descending by confidence score before returning
	sort.Slice(matches, func(i, j int) bool { return matches[i].ConfidenceScore > matches[j].ConfidenceScore })
	return matches, nil
}

// confidence heuristic borrowed from original implementation.
func (g *GoogleCustomSearchService) confidence(itemName, title, snippet string) float64 {
	itemLower := strings.ToLower(itemName)
	titleLower := strings.ToLower(title)
	snippetLower := strings.ToLower(snippet)
	score := 0.5
	if strings.Contains(titleLower, itemLower) {
		score += 0.3
	}
	for _, w := range strings.Fields(itemLower) {
		if len(w) > 2 && strings.Contains(titleLower, w) {
			score += 0.1
		}
	}
	if strings.Contains(snippetLower, itemLower) {
		score += 0.2
	}
	ethiopian := []string{"ethiopian", "injera", "berbere", "doro", "kitfo", "tibs", "shiro"}
	for _, k := range ethiopian {
		if strings.Contains(titleLower, k) || strings.Contains(snippetLower, k) {
			score += 0.15
			break
		}
	}
	if score > 1.0 {
		score = 1.0
	}
	return score
}
