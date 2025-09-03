package services

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
)

type PexelsSearchService struct {
	apiKey string
	client *http.Client
}

func NewPexelsSearchService(apiKey string) *PexelsSearchService {
	return &PexelsSearchService{apiKey: apiKey, client: &http.Client{Timeout: 10 * time.Second}}
}

type pexelsSearchResponse struct {
	Photos []pexelsPhoto `json:"photos"`
}
type pexelsPhoto struct {
	ID  int            `json:"id"`
	Src pexelsPhotoSrc `json:"src"`
	Alt string         `json:"alt"`
}
type pexelsPhotoSrc struct {
	Original string `json:"original"`
	Small    string `json:"small"`
	Medium   string `json:"medium"`
	Large    string `json:"large"`
	Tiny     string `json:"tiny"`
}

// Search returns up to num photo matches for a query.
func (s *PexelsSearchService) Search(ctx context.Context, itemName string, num int) ([]PhotoMatch, error) {
	if s.apiKey == "" {
		return nil, nil
	}
	if num <= 0 {
		num = 2
	}
	base := "https://api.pexels.com/v1/search"
	params := url.Values{}
	params.Set("query", itemName)
	params.Set("per_page", fmt.Sprintf("%d", num))
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, base+"?"+params.Encode(), nil)
	if err != nil {
		return nil, fmt.Errorf("pexels request build: %w", err)
	}
	req.Header.Set("Authorization", s.apiKey)
	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("pexels request: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("pexels status %d", resp.StatusCode)
	}
	var out pexelsSearchResponse
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, fmt.Errorf("pexels decode: %w", err)
	}
	matches := make([]PhotoMatch, 0, len(out.Photos))
	for _, r := range out.Photos {
		matches = append(matches, PhotoMatch{ItemName: itemName, PhotoURL: r.Src.Original, ThumbnailURL: r.Src.Small, ConfidenceScore: 0.85, Source: "pexels", AltText: r.Alt})
	}
	return matches, nil
}
