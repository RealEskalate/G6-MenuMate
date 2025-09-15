package services

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
)

type UnsplashSearchService struct {
	apiKey string
	client *http.Client
}

func NewUnsplashSearchService(apiKey string) *UnsplashSearchService {
	if apiKey == "" {
		return nil
	}
	return &UnsplashSearchService{apiKey: apiKey, client: &http.Client{Timeout: 10 * time.Second}}
}

type unsplashSearchResponse struct {
	Results []unsplashPhoto `json:"results"`
}
type unsplashPhoto struct {
	ID   string            `json:"id"`
	Urls unsplashPhotoUrls `json:"urls"`
	Alt  string            `json:"alt_description"`
}
type unsplashPhotoUrls struct {
	Full  string `json:"full"`
	Thumb string `json:"thumb"`
}

// Search returns up to num photo matches for a query.
func (s *UnsplashSearchService) Search(ctx context.Context, itemName string, num int) ([]PhotoMatch, error) {
	if s.apiKey == "" {
		return nil, nil
	}
	if num <= 0 {
		num = 2
	}
	base := "https://api.unsplash.com/search/photos"
	params := url.Values{}
	params.Set("query", itemName)
	params.Set("per_page", fmt.Sprintf("%d", num))
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, base+"?"+params.Encode(), nil)
	if err != nil {
		return nil, fmt.Errorf("unsplash request build: %w", err)
	}
	req.Header.Set("Authorization", "Client-ID "+s.apiKey)
	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("unsplash request: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unsplash status %d", resp.StatusCode)
	}
	var out unsplashSearchResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, fmt.Errorf("unsplash decode: %w", err)
	}
	matches := make([]PhotoMatch, 0, len(out.Results))
	for _, r := range out.Results {
		matches = append(matches, PhotoMatch{ItemName: itemName, PhotoURL: r.Urls.Full, ThumbnailURL: r.Urls.Thumb, ConfidenceScore: 0.9, Source: "unsplash", AltText: r.Alt})
	}
	return matches, nil
}
