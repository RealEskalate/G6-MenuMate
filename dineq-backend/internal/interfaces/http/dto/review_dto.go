package dto

import (
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ReviewDTO represents the data transfer object for a Review
type ReviewDTO struct {
	ID           string    `json:"id"`
	ItemID       string    `json:"itemId"`
	UserID       string    `json:"user"`
	Picture      string    `json:"picture,omitempty"`
	Description  string    `json:"description"`
	Rating       float64   `json:"rating"`
	ReactionIDs  []string  `json:"reactionIds"`
	LikeCount    int       `json:"likeCount"`
	DislikeCount int       `json:"dislikeCount"`
	IsApproved   bool      `json:"isApproved"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
	IsDeleted    bool      `json:"isDeleted"`
	FlagCount    int       `json:"flagCount"`
}

// // ReactionDTO represents the data transfer object for a Reaction
// type ReactionDTO struct {
// 	ID        string    `json:"id"`
// 	ReviewID  string    `json:"reviewId"`
// 	UserID    string    `json:"userId"`
// 	Type      string    `json:"type"` // e.g., "LIKE", "DISLIKE"
// 	CreatedAt time.Time `json:"createdAt"`
// 	IsDeleted bool      `json:"isDeleted"`
// }

// Validate checks the ReviewDTO for required fields
func (r *ReviewDTO) Validate() error {
	if r.ItemID == "" || r.UserID == "" || r.Rating < 1 || r.Rating > 5 {
		return fmt.Errorf("itemID, userID, and rating (1-5) are required")
	}
	return nil
}

// ToDomain converts the ReviewDTO to a domain.Review entity
func (r *ReviewDTO) ToDomain() *domain.Review {
	return &domain.Review{
		ID:           r.ID,
		ItemID:       r.ItemID,
		UserID:       r.UserID,
		Picture:      r.Picture,
		Description:  r.Description,
		Rating:       r.Rating,
		ReactionIDs:  r.ReactionIDs,
		LikeCount:    r.LikeCount,
		DislikeCount: r.DislikeCount,
		IsApproved:   r.IsApproved,
		CreatedAt:    r.CreatedAt,
		UpdatedAt:    r.UpdatedAt,
		IsDeleted:    r.IsDeleted,
		FlagCount:    r.FlagCount,
	}
}

// FromDomain converts a domain.Review entity to a ReviewDTO
func (r *ReviewDTO) FromDomain(review *domain.Review) *ReviewDTO {
	return &ReviewDTO{
		ID:           review.ID,
		ItemID:       review.ItemID,
		UserID:       review.UserID,
		Picture:      review.Picture,
		Description:  review.Description,
		Rating:       review.Rating,
		ReactionIDs:  review.ReactionIDs,
		LikeCount:    review.LikeCount,
		DislikeCount: review.DislikeCount,
		IsApproved:   review.IsApproved,
		CreatedAt:    review.CreatedAt,
		UpdatedAt:    review.UpdatedAt,
		IsDeleted:    review.IsDeleted,
		FlagCount:    review.FlagCount,
	}
}
