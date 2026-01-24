package domain

import (
	"context"
	"strings"
	"time"
)

type ReactionType string

const (
	ReactionLike    ReactionType = "LIKE"
	ReactionDislike ReactionType = "DISLIKE"
)

// Parse from API value ("like"/"dislike"), returns empty string on invalid/empty
func ParseReactionType(api string) ReactionType {
	switch strings.ToLower(strings.TrimSpace(api)) {
	case "like":
		return ReactionLike
	case "dislike":
		return ReactionDislike
	default:
		return ""
	}
}

// ToAPI returns "like" or "dislike" for use in JSON responses (empty if unknown)
func (rt ReactionType) ToAPI() string {
	switch rt {
	case ReactionLike:
		return "like"
	case ReactionDislike:
		return "dislike"
	default:
		return ""
	}
}

type Reaction struct {
	ID        string
	ReviewID  string       //`bson:"reviewId,omitempty" json:"reviewId,omitempty"`
	ItemID    string       //`bson:"itemId" json:"itemId"`
	UserID    string       //`bson:"userId" json:"userId"`
	Type      ReactionType //`bson:"type" json:"type"`
	CreatedAt time.Time    //`bson:"createdAt" json:"createdAt"`
	UpdatedAt time.Time    //`bson:"updatedAt" json:"updatedAt"`
	IsDeleted bool         //`bson:"isDeleted" json:"isDeleted"`
}

// ...existing code...

type IReactionRepository interface {
	// Reactions are now per review (user can react separately to different reviews of same item)
	GetUserReaction(ctx context.Context, reviewID, userID string) (*Reaction, error)
	InsertReaction(ctx context.Context, reaction *Reaction) error
	UpdateReaction(ctx context.Context, reaction *Reaction) error
	GetReactionStats(ctx context.Context, reviewID, userID string) (int64, int64, *Reaction, error)
}
type IReactionUsecase interface {
	SaveReaction(ctx context.Context, reviewID, userID string, rtype ReactionType) (*Reaction, error)
	GetReactionStats(ctx context.Context, reviewID, userID string) (int64, int64, *Reaction, error)
}
