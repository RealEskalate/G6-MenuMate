package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type ReviewModel struct {
	ID               bson.ObjectID `bson:"_id,omitempty"`
	ItemID           string        `bson:"itemId"`
	UserID           string        `bson:"userId"`
	RestaurantID     string        `bson:"restaurantId"`
	ImageURLs        []string      `bson:"imageUrls,omitempty"`
	Username         string        `bson:"username,omitempty"`
	UserProfileImage string        `bson:"userProfileImage,omitempty"`
	Description      string        `bson:"description"`
	Rating           float64       `bson:"rating"`
	CreatedAt        time.Time     `bson:"createdAt"`
	UpdatedAt        time.Time     `bson:"updatedAt"`
	IsApproved       bool          `bson:"isApproved"`
	IsDeleted        bool          `bson:"isDeleted"`
	FlagCount        int           `bson:"flagCount"`
	LikeCount        int           `bson:"likeCount"`
	DislikeCount     int           `bson:"dislikeCount"`
	ReactionIDs      []string      `bson:"reactionIds"`
}

// ReviewModel → domain.Review
func ReviewToDomain(r *ReviewModel) *domain.Review {
	return &domain.Review{
		ID:               r.ID.Hex(),
		ItemID:           r.ItemID,
		UserID:           r.UserID,
		RestaurantID:     r.RestaurantID,
		ImageURLs:        r.ImageURLs,
		Username:         r.Username,
		UserProfileImage: r.UserProfileImage,
		Description:      r.Description,
		Rating:           r.Rating,
		CreatedAt:        r.CreatedAt,
		UpdatedAt:        r.UpdatedAt,
		IsApproved:       r.IsApproved,
		IsDeleted:        r.IsDeleted,
		FlagCount:        r.FlagCount,
		LikeCount:        r.LikeCount,
		DislikeCount:     r.DislikeCount,
		ReactionIDs:      r.ReactionIDs,
	}
}

// domain.Review → ReviewModel
func ReviewFromDomain(r *domain.Review) *ReviewModel {
	var oid bson.ObjectID
	if r.ID != "" {
		var err error
		oid, err = bson.ObjectIDFromHex(r.ID)
		if err != nil {
			oid = bson.NewObjectID() // fallback for invalid hex
		}
	} else {
		oid = bson.NewObjectID()
	}
	return &ReviewModel{
		ID:               oid,
		ItemID:           r.ItemID,
		UserID:           r.UserID,
		RestaurantID:     r.RestaurantID,
		ImageURLs:        r.ImageURLs,
		Username:         r.Username,
		UserProfileImage: r.UserProfileImage,
		Description:      r.Description,
		Rating:           r.Rating,
		CreatedAt:        r.CreatedAt,
		UpdatedAt:        r.UpdatedAt,
		IsApproved:       r.IsApproved,
		IsDeleted:        r.IsDeleted,
		FlagCount:        r.FlagCount,
		LikeCount:        r.LikeCount,
		DislikeCount:     r.DislikeCount,
		ReactionIDs:      r.ReactionIDs,
	}
}

// []*ReviewModel → []*domain.Review
func ReviewToDomainList(models []*ReviewModel) []*domain.Review {
	var reviews []*domain.Review
	for _, m := range models {
		reviews = append(reviews, ReviewToDomain(m))
	}
	return reviews
}
