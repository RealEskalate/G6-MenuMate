package dto

import (
    "time"

    "github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ReviewRequest is used for creating or updating a review
type ReviewRequest struct {
    ItemID      string  `json:"item_id" validate:"required"`
    Picture     string  `json:"picture,omitempty" validate:"omitempty,url"`
    Description string  `json:"description" validate:"required,max=500"`
    Rating      float64 `json:"rating" validate:"required,min=1,max=5"`
}

// ReviewResponse is used for returning review data to the client
type ReviewResponse struct {
    ID           string    `json:"id"`
    ItemID       string    `json:"item_id"`
    UserID       string    `json:"user_id"`
    Picture      string    `json:"picture,omitempty"`
    Description  string    `json:"description"`
    Rating       float64   `json:"rating"`
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
    LikeCount    int       `json:"like_count"`
    DislikeCount int       `json:"dislike_count"`
    ReactionIDs  []string  `json:"reaction_ids"`
    // Optionally, embed user info for display
    User *UserResponse `json:"user,omitempty"`
}

// Mapper: ReviewRequest → domain.Review
func ToDomainReview(req ReviewRequest, userID string) *domain.Review {
    return &domain.Review{
        ItemID:      req.ItemID,
        UserID:      userID,
        Picture:     req.Picture,
        Description: req.Description,
        Rating:      req.Rating,
        CreatedAt:   time.Now(),
        UpdatedAt:   time.Now(),
    }
}

// Mapper: domain.Review → ReviewResponse
func ToReviewResponse(r *domain.Review, user *domain.User) ReviewResponse {
    var userResp *UserResponse
    if user != nil {
        ur := ToUserResponse(*user)
        userResp = &ur
    }
    return ReviewResponse{
        ID:           r.ID,
        ItemID:       r.ItemID,
        UserID:       r.UserID,
        Picture:      r.Picture,
        Description:  r.Description,
        Rating:       r.Rating,
        CreatedAt:    r.CreatedAt,
        UpdatedAt:    r.UpdatedAt,
        LikeCount:    r.LikeCount,
        DislikeCount: r.DislikeCount,
        ReactionIDs:  r.ReactionIDs,
        User:         userResp,
    }
}

// Mapper: []*domain.Review → []ReviewResponse
func ToReviewResponseList(reviews []*domain.Review, users map[string]*domain.User) []ReviewResponse {
    var responses []ReviewResponse
    for _, r := range reviews {
        var user *domain.User
        if users != nil {
            user = users[r.UserID]
        }
        responses = append(responses, ToReviewResponse(r, user))
    }
    return responses
}