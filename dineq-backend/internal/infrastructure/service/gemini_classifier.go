package services

import (
	"context"
	"fmt"
	"strings"
	"time"

	"google.golang.org/genai"
)

// EthiopianFoodClassifier determines if a given term is an Ethiopian dish/staple.
type EthiopianFoodClassifier interface {
	IsEthiopianFoodName(ctx context.Context, name string) (bool, error)
}

type geminiFoodClassifier struct {
	client *genai.Client
	model  string
}

// NewGeminiFoodClassifier creates a classifier using Gemini API.
// Returns nil if apiKey is empty (classifier disabled).
func NewGeminiFoodClassifier(apiKey, model string) EthiopianFoodClassifier {
	if apiKey == "" {
		return nil
	}
	if strings.TrimSpace(model) == "" {
		model = "gemini-1.5-flash"
	}
	client, err := genai.NewClient(context.Background(), &genai.ClientConfig{APIKey: apiKey})
	if err != nil {
		return nil
	}
	return &geminiFoodClassifier{client: client, model: model}
}

func (g *geminiFoodClassifier) IsEthiopianFoodName(ctx context.Context, name string) (bool, error) {
	// Tight timeout to avoid delaying search too long
	c, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	prompt := fmt.Sprintf("Answer strictly with yes or no. Is '%s' a traditional or commonly recognized Ethiopian dish or staple?", strings.TrimSpace(name))
	resp, err := g.client.Models.GenerateContent(c, g.model, genai.Text(prompt), nil)
	if err != nil {
		return false, err
	}
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return false, fmt.Errorf("empty classifier response")
	}
	var out string
	for _, p := range resp.Candidates[0].Content.Parts {
		out += fmt.Sprintf("%v", p)
	}
	answer := strings.ToLower(strings.TrimSpace(out))
	if strings.HasPrefix(answer, "yes") {
		return true, nil
	}
	if strings.HasPrefix(answer, "no") {
		return false, nil
	}
	// Unknown -> default to false (mixed strategy)
	return false, nil
}
