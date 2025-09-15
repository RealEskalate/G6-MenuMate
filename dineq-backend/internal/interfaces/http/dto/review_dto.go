package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ReviewRequest is used for creating or updating a review
type ReviewRequest struct {
	ImageURLs   []string `json:"image_urls,omitempty" validate:"omitempty,dive,url"`
	Description string   `json:"description" validate:"required,max=500"`
	Rating      float64  `json:"rating" validate:"required,min=1,max=5"`
}

// ReviewResponse is used for returning review data to the client
type ReviewResponse struct {
	ID           string    `json:"id"`
	ItemID       string    `json:"item_id"`
	RestaurantID string    `json:"restaurant_id"`
	UserID       string    `json:"user_id"`
	ImageURLs    []string  `json:"image_urls,omitempty"`
	Description  string    `json:"description"`
	Rating       float64   `json:"rating"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
	LikeCount    int       `json:"like_count"`
	DislikeCount int       `json:"dislike_count"`
	ReactionIDs  []string  `json:"reaction_ids"`
	// Optionally, embed user info for display
	User         *UserResponse `json:"user,omitempty"`
	Username     string        `json:"username,omitempty"`
	ProfileImage string        `json:"profile_image,omitempty"`
}

// Mapper: ReviewRequest → domain.Review
func ToDomainReview(req ReviewRequest, userID string, itemID string, restaurantID string) *domain.Review {
	return &domain.Review{
		ItemID:       itemID,
		RestaurantID: restaurantID,
		UserID:       userID,
		ImageURLs:    req.ImageURLs,
		Description:  req.Description,
		Rating:       req.Rating,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
}

// Mapper: domain.Review → ReviewResponse
func ToReviewResponse(r *domain.Review, user *domain.User) ReviewResponse {
	var userResp *UserResponse
	if user != nil {
		ur := ToUserResponse(*user)
		userResp = &ur
	}
	username := r.Username
	profileImg := r.UserProfileImage
	if username == "" && user != nil {
		username = user.Username
	}
	if profileImg == "" && user != nil {
		profileImg = user.ProfileImage
	}
	return ReviewResponse{
		ID:           r.ID,
		ItemID:       r.ItemID,
		RestaurantID: r.RestaurantID,
		UserID:       r.UserID,
		ImageURLs:    r.ImageURLs,
		Description:  r.Description,
		Rating:       r.Rating,
		CreatedAt:    r.CreatedAt,
		UpdatedAt:    r.UpdatedAt,
		LikeCount:    r.LikeCount,
		DislikeCount: r.DislikeCount,
		ReactionIDs:  r.ReactionIDs,
		User:         userResp,
		Username:     username,
		ProfileImage: profileImg,
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
