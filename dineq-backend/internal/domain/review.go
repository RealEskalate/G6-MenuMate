package domain

import (
	"context"
	"time"
)

type Review struct {
    ID          string    //`bson:"_id,omitempty" json:"id"`
    ItemID      string    //`bson:"itemId" json:"item_id"`
    RestaurantID      string    //`bson:"restaurantId" json:"restaurant_id"`
    UserID      string    //`bson:"userId" json:"user_id"`
    Picture     string    //`bson:"picture,omitempty" json:"picture,omitempty"`
    Description string    //`bson:"description" json:"description"`
    Rating      float64   //`bson:"rating" json:"rating"`
    CreatedAt   time.Time //`bson:"createdAt" json:"created_at"`
    UpdatedAt   time.Time //`bson:"updatedAt" json:"updated_at"`
    // Internal fields (not exposed in API)
    IsApproved  bool      //`bson:"isApproved" json:"-"`
    IsDeleted   bool      //`bson:"isDeleted" json:"-"`
    FlagCount   int       //`bson:"flagCount" json:"-"`
    LikeCount   int       //`bson:"likeCount" json:"like_count"`
    DislikeCount int      //`bson:"dislikeCount" json:"dislike_count"`
    ReactionIDs []string  //`bson:"reactionIds" json:"reaction_ids"`
}

type ReviewRepository interface {
    Create(ctx context.Context, review *Review) error
    FindByUserAndItemWithin(ctx context.Context, userID, itemID string, since time.Time) (*Review, error)
    ListByItem(ctx context.Context, itemID string, page, limit int) ([]*Review, int, error)
}

type IReviewRepository interface {
    // Create a new review for an item
    Create(ctx context.Context, review *Review) error

    // Find a review by its ID
    FindByID(ctx context.Context, id string) (*Review, error)

    // List reviews for a specific item (with pagination)
    ListByItem(ctx context.Context, itemID string, page, limit int) ([]*Review, int64, error)

    // Update a review (by ID and user)
    Update(ctx context.Context, id string, userID string, update *Review) error

    // Soft-delete a review (by ID and user)
    Delete(ctx context.Context, id string, userID string) error

    // Calculate average rating for an item
    AverageRatingByItem(ctx context.Context, itemID string) (float64, error)

    // Calculate average rating for a restaurant (from its items' averages)
    AverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error)
}

type IReviewUsecase interface {
    // Create a new review for an item
    CreateReview(ctx context.Context, review *Review) error

    // Get a review by its ID
    GetReviewByID(ctx context.Context, id string) (*Review, error)

    // List reviews for a specific item (with pagination)
    ListReviewsByItem(ctx context.Context, itemID string, page, limit int) ([]*Review, int64, error)

    // Update a review (by ID and user)
    UpdateReview(ctx context.Context, id string, userID string, update *Review) (*Review, error)

    // Delete a review (by ID and user)
    DeleteReview(ctx context.Context, id string, userID string) error

    // Get average rating for an item
    GetAverageRatingByItem(ctx context.Context, itemID string) (float64, error)

    // Get average rating for a restaurant (from its items' averages)
    GetAverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error)
}