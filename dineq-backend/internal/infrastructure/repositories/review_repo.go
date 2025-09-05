package repositories

import (
	"context"
	"fmt"
	"os"
	"time"

	// "github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"

	// "go.mongodb.org/mongo-driver/bson/primitive"
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

    if oid, ok := result.InsertedID.(bson.ObjectID); ok {
        review.ID = oid.Hex()
    } else {
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
    err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": uid, "isDeleted": false}).Decode(&reviewModel)
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
    filter := bson.M{"itemId": itemID, "isDeleted": false}
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
    uid, err := bson.ObjectIDFromHex(id)
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

    // Prepare the filter to find the correct document using camelCase
    filter := bson.M{
        "_id":       uid,
        "userId":    userID,
        "isDeleted": false,
    }

    // Debug logs to print the inputs and filter
    fmt.Printf("[DEBUG] Update Inputs:\n")
    fmt.Printf("  id: %s\n", id)
    fmt.Printf("  userID: %s\n", userID)
    fmt.Printf("  updateFields: %+v\n", updateFields)
    fmt.Printf("[DEBUG] Update Filter: %+v\n", filter)

    updateDoc := bson.M{"$set": updateFields}

    result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, filter, updateDoc)
    if err != nil {
        fmt.Printf("[DEBUG] UpdateOne error: %v\n", err)
        return err
    }
    if result.MatchedCount == 0 {
        fmt.Printf("[DEBUG] No document matched the filter: %+v\n", filter)
        return domain.ErrUserNotFound // This error now correctly implies the review wasn't found for this user or is deleted
    }

    fmt.Printf("[DEBUG] MatchedCount: %d, ModifiedCount: %d\n", result.MatchedCount, result.ModifiedCount)
    return nil
}

func (r *ReviewRepository) Delete(ctx context.Context, id string, userID string) error {
    uid, err := bson.ObjectIDFromHex(id)
    if err != nil {
        return domain.ErrInvalidUserId
    }

    // First, check if the review exists for the user, regardless of its deletion status.
    findFilter := bson.M{"_id": uid, "userId": userID}
    var existingReview mapper.ReviewModel
    err = r.DB.Collection(r.Collection).FindOne(ctx, findFilter).Decode(&existingReview)

    if err != nil {
        // If no document is found at all, then it's a true "not found" case.
        if err == mongo.ErrNoDocuments() {
            return domain.ErrReviewNotFound
        }
        // For any other database error during the find operation.
        return err
    }

    // If the review is already marked as deleted, the operation is successful (idempotent).
    if existingReview.IsDeleted {
        fmt.Printf("[DEBUG] Review %s is already deleted. No action taken.\n", id)
        return nil
    }

    // If the review exists and is not deleted, proceed with the soft delete.
    updateFilter := bson.M{"_id": uid} // We can just use the ID now since we've verified ownership.
    update := bson.M{
        "$set": bson.M{
            "isDeleted": true,
            "updatedAt": time.Now(),
        },
    }

    result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, updateFilter, update)
    if err != nil {
        return err
    }
    if result.MatchedCount == 0 {
        // This case is unlikely now but kept as a safeguard.
        return domain.ErrReviewNotFound
    }

    return nil
}

// Calculate and update average rating for an item
func (r *ReviewRepository) AverageRatingByItem(ctx context.Context, itemID string) (float64, error) {
    pipeline := []bson.M{
        {"$match": bson.M{
            "itemId":    itemID,
            "isDeleted": false,
        }},
        {"$group": bson.M{
            "_id": "$itemId",
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

    // Update the item's averageRating field
    _, err = r.DB.Collection("items").UpdateOne(
        ctx,
        bson.M{"_id": itemID},
        bson.M{"$set": bson.M{"averageRating": avg}},
    )
    if err != nil {
        return 0, err
    }

    return avg, nil
}

func (r *ReviewRepository) AverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error) {
    pipeline := []bson.M{
        {"$match": bson.M{
            "restaurantId":    restaurantID,
            "isDeleted": false,
        }},
        {"$group": bson.M{
            "_id": "$restaurantId",
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

    // Update the menu's averageRating field
    _, err = r.DB.Collection(os.Getenv("RESTAURANT_COLLECTION")).UpdateOne(
        ctx,
        bson.M{"_id": restaurantID},
        bson.M{"$set": bson.M{"averageRating": avg}},
    )
    if err != nil {
        return 0, err
    }

    return avg, nil
}