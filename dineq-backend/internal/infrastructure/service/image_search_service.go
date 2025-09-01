package services

import (
	"context"
	"fmt"
	"log"
	"sort"
	"strings"
	"time"

	"google.golang.org/api/customsearch/v1"
	"google.golang.org/api/option"
)

type IImageSearchService interface {
	SearchImage(ctx context.Context, query string) (string, error)
}

type ImageSearchService struct {
	cse           *customsearch.Service
	searchEnginID string
	// openaiClient  *openai.Client
}

func NewImageSearchService(searchEngineID string, apiKey string) (IImageSearchService, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	searchService, err := customsearch.NewService(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		log.Fatal(err)
	}
	return &ImageSearchService{
		searchEnginID: searchEngineID,
		cse:           searchService,
	}, nil
}

type ImageScore struct {
	URL   string
	Score int
}

func (s *ImageSearchService) SearchImage(ctx context.Context, query string) (string, error) {
	search, err := s.cse.Cse.List().
		Q(query).
		Cx(s.searchEnginID).
		SearchType("image").
		Num(5).
		Do()
	if err != nil {
		return "https://placeholder.com/image.jpg", err
	}

	if len(search.Items) == 0 {
		return "https://placeholder.com/image.jpg", fmt.Errorf("no images found for query: %s", query)
	}

	// High and medium trust domains
	highTrustDomains := []string{
		"migrationology.com", "willflyforfood.net", "ethiopianfoodguide.com",
		".edu", ".org", ".gov",
	}
	mediumTrustDomains := []string{
		"allrecipes.com", "bbcgoodfood.com", "epicurious.com", "seriouseats.com", "foodnetwork.com",
	}
	// Stock sites to avoid
	blockedDomains := []string{
		"shutterstock.com", "gettyimages.com", "istockphoto.com", "123rf.com", "stock.adobe.com",
	}

	// Keywords
	foodKeywords := []string{
		"recipe", "dish", "food", "cuisine", "ethiopian", "injera", "doro", "shiro", "kitfo", "tibs",
		strings.ToLower(query),
	}

	var scoredImages []ImageScore
	for _, item := range search.Items {
		imageURL := item.Link
		domain := item.DisplayLink
		snippet := strings.ToLower(item.Snippet)

		// Skip blocked stock domains
		skip := false
		for _, bad := range blockedDomains {
			if strings.Contains(domain, bad) {
				skip = true
				break
			}
		}
		if skip {
			continue
		}

		// Start scoring
		score := 0

		// High-trust domains +3
		for _, trusted := range highTrustDomains {
			if strings.Contains(domain, trusted) {
				score += 3
				break
			}
		}
		// Medium-trust domains +2
		for _, trusted := range mediumTrustDomains {
			if strings.Contains(domain, trusted) {
				score += 2
				break
			}
		}
		// Keywords in snippet/title +1 each
		for _, keyword := range foodKeywords {
			if strings.Contains(snippet, keyword) {
				score++
			}
		}
		// Filetype bonus if authentic
		if strings.HasSuffix(strings.ToLower(imageURL), ".jpg") ||
			strings.HasSuffix(strings.ToLower(imageURL), ".jpeg") ||
			strings.HasSuffix(strings.ToLower(imageURL), ".png") {
			score++
		}

		scoredImages = append(scoredImages, ImageScore{URL: imageURL, Score: score})
	}

	if len(scoredImages) == 0 {
		return "https://placeholder.com/image.jpg", fmt.Errorf("all results filtered as stock/irrelevant")
	}

	// Sort by score descending
	sort.Slice(scoredImages, func(i, j int) bool {
		return scoredImages[i].Score > scoredImages[j].Score
	})

	// Select best with threshold >= 3
	for _, img := range scoredImages {
		if img.Score >= 3 {
			return img.URL, nil
		}
	}

	// If no strong match, fallback to top scored
	fmt.Println("No strong authentic image, fallback:", scoredImages[0].URL, "score:", scoredImages[0].Score)
	return scoredImages[0].URL, nil
}
