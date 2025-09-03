package domain

import "time"

type Review struct {
	ID           string
	ItemID       string
	UserID       string
	Picture      string
	Description  string
	Rating       float64
	ReactionIDs  []string
	LikeCount    int
	DislikeCount int
	IsApproved   bool
	CreatedAt    time.Time
	UpdatedAt    time.Time
	IsDeleted    bool
	FlagCount    int
}

type Reaction struct {
	ID        string
	ReviewID  string
	UserID    string
	Type      string
	CreatedAt time.Time
	IsDeleted bool
}

type IReviewUseCase interface {
	CreateReview(review *Review) error
	UpdateReview(id string, review *Review) error
	AddReaction(reviewID, reactionID string) error
	GetReviewByID(id string) (*Review, error)
	ModerateReview(id string, isApproved bool) error
	DeleteReview(id string) error
}

// repository
type IReviewRepository interface {
	Create(review *Review) error
	Update(id string, review *Review) error
	GetByID(id string) (*Review, error)
	Delete(id string) error
	AddReaction(reviewID, reactionID string) error
}
