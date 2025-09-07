package dto

import "time"

// ReactionDTO represents a reaction in snake_case for API responses.
type ReactionDTO struct {
	ID        string    `json:"id"`
	ReviewID  string    `json:"review_id,omitempty"`
	ItemID    string    `json:"item_id"`
	UserID    string    `json:"user_id"`
	Type      string    `json:"type"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	IsDeleted bool      `json:"is_deleted"`
}

// ReactionRequest represents the request payload to create/toggle a reaction.
// user_id is now explicitly required to ensure reactions are user-specific.
type ReactionRequest struct {
	Type string `json:"type"` // like | dislike (case-insensitive)
	// All other identifiers (user_id, item_id, restaurant_id) are now derived server-side.
}

// ReactionStatsDTO represents the aggregated stats and user's reaction in snake_case.
type ReactionStatsDTO struct {
	ReviewID      string  `json:"review_id"`
	ItemID        string  `json:"item_id,omitempty"`
	LikeCounts    int64   `json:"like_count"`
	DislikeCounts int64   `json:"dislike_count"`
	Me            *string `json:"me,omitempty"`
}
