package dto

import "time"

// ReactionDTO represents a reaction in snake_case for API responses.
type ReactionDTO struct {
    ID         string    `json:"id"`
    ReviewID   string    `json:"review_id,omitempty"`
    ItemID     string    `json:"item_id"`
    UserID     string    `json:"user_id"`
    Type       string    `json:"type"`
    CreatedAt  time.Time `json:"created_at"`
    UpdatedAt  time.Time `json:"updated_at"`
    IsDeleted  bool      `json:"is_deleted"`
}

// ReactionStatsDTO represents the aggregated stats and user's reaction in snake_case.
type ReactionStatsDTO struct {
    ItemID string            `json:"item_id"`
    Counts map[string]int64  `json:"counts"`
    Total  int64             `json:"total"`
    Me     *string           `json:"me,omitempty"`
}