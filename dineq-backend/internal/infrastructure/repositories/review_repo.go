package repositories

import (
	"context"
	"fmt"
	// "errors"

	"go.mongodb.org/mongo-driver/bson/primitive"

	// "fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"

	// "github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	mongo_options "go.mongodb.org/mongo-driver/v2/mongo/options"
)

type ReviewRepository struct {
	DB         mongo.Database
	Collection string
}

func NewReviewRepository(db mongo.Database, collection string) *ReviewRepository {
	return &ReviewRepository{
		DB:         db,
		Collection: collection,
	}
}

func (r *ReviewRepository) Create(ctx context.Context, review *domain.Review) error {
    reviewModel := mapper.ReviewFromDomain(review)
    result, err := r.DB.Collection(r.Collection).InsertOne(ctx, reviewModel)
    if err != nil {
        return err
    }

    // Handle both bson.ObjectID and primitive.ObjectID
    switch oid := result.InsertedID.(type) {
    case primitive.ObjectID:
        review.ID = oid.Hex()
    case bson.ObjectID:
        review.ID = oid.Hex()
    default:
        return fmt.Errorf("failed to convert inserted ID to ObjectID, got type: %T", result.InsertedID)
    }

    return nil
}
// Find a review by its ID
func (r *ReviewRepository) FindByID(ctx context.Context, id string) (*domain.Review, error) {
	uid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidUserId
	}
	var reviewModel *mapper.ReviewModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": uid}).Decode(&reviewModel)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrUserNotFound
		}
		return nil, err
	}
	return mapper.ReviewToDomain(reviewModel), nil
}

// List reviews for a specific item (with pagination)
func (r *ReviewRepository) ListByItem(ctx context.Context, itemID string, page, limit int) ([]*domain.Review, int64, error) {
	filter := bson.M{"item_id": itemID, "is_deleted": false}
	skip := (page - 1) * limit

	skip64 := int64(skip)
	limit64 := int64(limit)

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		filter,
		mongo_options.Find().SetSkip(skip64).SetLimit(limit64),
	)

	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var reviewModels []*mapper.ReviewModel
	if err := cursor.All(ctx, &reviewModels); err != nil {
		return nil, 0, err
	}

	var reviews []*domain.Review
	for _, reviewModel := range reviewModels {
		reviews = append(reviews, mapper.ReviewToDomain(reviewModel))
	}

	count, err := r.DB.Collection(r.Collection).CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	return reviews, count, nil
}

func (r *ReviewRepository) Update(ctx context.Context, id string, userID string, update *domain.Review) error {
    // Convert the `id` to a primitive.ObjectID
    uid, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        fmt.Printf("[DEBUG] Invalid ObjectID: %s\n", id)
        return domain.ErrInvalidUserId
    }
    fmt.Printf("[DEBUG] Converted ObjectID: %v\n", uid)

    // Prepare the fields to update
    updateFields := bson.M{}
    if update.Picture != "" {
        updateFields["picture"] = update.Picture
    }
    if update.Description != "" {
        updateFields["description"] = update.Description
    }
    if update.Rating != 0 {
        updateFields["rating"] = update.Rating
    }
    updateFields["updatedAt"] = time.Now()

    // Prepare the filter using the correct field names
    filter := bson.M{
        "_id":    uid,       // Match by review ID
        // "userId": userID,    // Correct field name from the database
        // "isDeleted": false,  // Correct field name from the database
    }

    // Debug logs to print the inputs and filter
    fmt.Printf("[DEBUG] Update Inputs:\n")
    fmt.Printf("  id: %s\n", id)
    fmt.Printf("  userID: %s\n", userID)
    fmt.Printf("  updateFields: %+v\n", updateFields)
    fmt.Printf("[DEBUG] Update Filter: %+v\n", filter)

    // Prepare the update document
    updateDoc := bson.M{"$set": updateFields}

    // Perform the update operation
    result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, filter, updateDoc)
    if err != nil {
        fmt.Printf("[DEBUG] UpdateOne error: %v\n", err)
        return err
    }
    if result.MatchedCount == 0 {
        fmt.Printf("[DEBUG] No document matched the filter: %+v\n", filter)
        return domain.ErrUserNotFound
    }

    // Debug logs for the result
    fmt.Printf("[DEBUG] MatchedCount: %d, ModifiedCount: %d\n", result.MatchedCount, result.ModifiedCount)
    return nil
}

func (r *ReviewRepository) Delete(ctx context.Context, id string, userID string) error {
    uid, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        return domain.ErrInvalidUserId
    }

    // userObjectID, err := primitive.ObjectIDFromHex(userID)
    // if err != nil {
    //     return domain.ErrInvalidUserId
    // }

    filter := bson.M{
        "_id":        uid,
        // "user_id":    userObjectID,
        // "is_deleted": false,
    }

    fmt.Printf("[DEBUG] Delete filter: %+v\n", filter)

    update := bson.M{
        "$set": bson.M{
            "is_deleted": true,
            "updated_at": time.Now(),
        },
    }

    result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, filter, update)
    if err != nil {
        return err
    }
    if result.MatchedCount == 0 {
        return domain.ErrUserNotFound
    }
    return nil
}

// // Soft-delete a review (by ID and user)
// func (r *ReviewRepository) Delete(ctx context.Context, id string, userID string) error {
// 	uid, err := bson.ObjectIDFromHex(id)
// 	if err != nil {
// 		return domain.ErrInvalidUserId
// 	}

// 	filter := bson.M{
// 		"_id":        uid,
// 		"user_id":    userID,
// 		"is_deleted": false,
// 	}

// 	update := bson.M{
// 		"$set": bson.M{
// 			"is_deleted": true,
// 			"updated_at": time.Now(),
// 		},
// 	}

// 	result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, filter, update)
// 	if err != nil {
// 		return err
// 	}
// 	if result.MatchedCount == 0 {
// 		return domain.ErrUserNotFound
// 	}
// 	return nil
// }

// Calculate and update average rating for an item
func (r *ReviewRepository) AverageRatingByItem(ctx context.Context, itemID string) (float64, error) {
	pipeline := []bson.M{
		{"$match": bson.M{
			"item_id":    itemID,
			"is_deleted": false,
		}},
		{"$group": bson.M{
			"_id": "$item_id",
			"avg": bson.M{"$avg": "$rating"},
		}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return 0, err
	}
	defer cursor.Close(ctx)

	var result struct {
		Avg float64 `bson:"avg"`
	}
	avg := 0.0
	if cursor.Next(ctx) {
		if err := cursor.Decode(&result); err != nil {
			return 0, err
		}
		avg = result.Avg
	}

	// Update the item's average_rating field
	_, err = r.DB.Collection("items").UpdateOne(
		ctx,
		bson.M{"_id": itemID},
		bson.M{"$set": bson.M{"average_rating": avg}},
	)
	if err != nil {
		return 0, err
	}

	return avg, nil
}

// Calculate and update average rating for a restaurant (from its items' averages)
func (r *ReviewRepository) AverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error) {
	pipeline := []bson.M{
		{"$match": bson.M{
			"restaurant_id": restaurantID,
			"is_deleted":    false,
		}},
		{"$group": bson.M{
			"_id":      "$item_id",
			"item_avg": bson.M{"$avg": "$rating"},
		}},
		{"$group": bson.M{
			"_id":            nil,
			"restaurant_avg": bson.M{"$avg": "$item_avg"},
		}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return 0, err
	}
	defer cursor.Close(ctx)

	var result struct {
		RestaurantAvg float64 `bson:"restaurant_avg"`
	}
	restaurantAvg := 0.0
	if cursor.Next(ctx) {
		if err := cursor.Decode(&result); err != nil {
			return 0, err
		}
		restaurantAvg = result.RestaurantAvg
	}

	// Update the restaurant's average_rating field
	_, err = r.DB.Collection("restaurants").UpdateOne(
		ctx,
		bson.M{"_id": restaurantID},
		bson.M{"$set": bson.M{"average_rating": restaurantAvg}},
	)
	if err != nil {
		return 0, err
	}

	return restaurantAvg, nil
}
