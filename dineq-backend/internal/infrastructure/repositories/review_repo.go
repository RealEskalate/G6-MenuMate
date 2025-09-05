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

	// Async cascade (simple): item average -> embedded menu item -> restaurant average
	if review.ItemID != "" { // fire and forget
		go r.simpleAsyncCascade(review.ItemID, review.RestaurantID)
	}
	return nil
}

// Find a review by its ID
func (r *ReviewRepository) FindByID(ctx context.Context, id string) (*domain.Review, error) {
	uid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidReviewId
	}
	var reviewModel *mapper.ReviewModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": uid, "isDeleted": false}).Decode(&reviewModel)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrReviewNotFound
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
		return domain.ErrInvalidReviewId
	}
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
	updateDoc := bson.M{"$set": updateFields}

	result, err := r.DB.Collection(r.Collection).UpdateOne(ctx, filter, updateDoc)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return domain.ErrReviewNotFound
	}
	// Fetch to get item & restaurant IDs
	var updated mapper.ReviewModel
	if err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": uid}).Decode(&updated); err == nil {
		if updated.ItemID != "" {
			go r.simpleAsyncCascade(updated.ItemID, updated.RestaurantID)
		}
	}
	return nil
}

func (r *ReviewRepository) Delete(ctx context.Context, id string, userID string) error {
	uid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidReviewId
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
		return domain.ErrReviewNotFound
	}
	// fire async cascade using existingReview data
	if existingReview.ItemID != "" {
		go r.simpleAsyncCascade(existingReview.ItemID, existingReview.RestaurantID)
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
	// First attempt: aggregate over menus' stored averageRating values
	menuPipeline := []bson.M{
		{"$match": bson.M{"restaurantId": restaurantID}},
		{"$group": bson.M{"_id": "$restaurantId", "avg": bson.M{"$avg": "$averageRating"}}},
	}
	cursor, err := r.DB.Collection("menus").Aggregate(ctx, menuPipeline)
	if err != nil {
		return 0, err
	}
	var avg float64
	var menuResult struct {
		Avg *float64 `bson:"avg"`
	}
	if cursor.Next(ctx) {
		if err := cursor.Decode(&menuResult); err == nil && menuResult.Avg != nil {
			avg = *menuResult.Avg
		}
	}
	cursor.Close(ctx)

	// Fallback to reviews aggregation if menu average not available
	if avg == 0 {
		reviewPipeline := []bson.M{
			{"$match": bson.M{"restaurantId": restaurantID, "isDeleted": false}},
			{"$group": bson.M{"_id": "$restaurantId", "avg": bson.M{"$avg": "$rating"}}},
		}
		rc, err := r.DB.Collection(r.Collection).Aggregate(ctx, reviewPipeline)
		if err == nil {
			var res struct {
				Avg float64 `bson:"avg"`
			}
			if rc.Next(ctx) {
				if err := rc.Decode(&res); err == nil {
					avg = res.Avg
				}
			}
			rc.Close(ctx)
		}
	}

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

// AverageRatingByMenu computes average rating for a menu based on its items' average ratings.
func (r *ReviewRepository) AverageRatingByMenu(ctx context.Context, menuID string) (float64, error) {
	if menuID == "" {
		return 0, fmt.Errorf("menuID required")
	}
	// Fetch menu items
	var menu struct {
		Items []struct {
			ID string `bson:"_id"`
		} `bson:"items"`
		RestaurantID string `bson:"restaurantId"`
	}
	if err := r.DB.Collection("menus").FindOne(ctx, bson.M{"_id": menuID}).Decode(&menu); err != nil {
		return 0, err
	}
	if len(menu.Items) == 0 {
		// No items -> average 0
		_, _ = r.DB.Collection("menus").UpdateOne(ctx, bson.M{"_id": menuID}, bson.M{"$set": bson.M{"averageRating": 0}})
		return 0, nil
	}
	var total float64
	var count int
	for _, it := range menu.Items {
		// Try to read entire item doc then extract averageRating (projection not supported in wrapper)
		var itemDoc map[string]any
		if err := r.DB.Collection("items").FindOne(ctx, bson.M{"_id": it.ID}).Decode(&itemDoc); err == nil {
			if v, ok := itemDoc["averageRating"].(float64); ok {
				total += v
				count++
				continue
			}
		}
		// Fallback compute
		if v, err := r.AverageRatingByItem(ctx, it.ID); err == nil {
			total += v
			count++
		}
	}
	avg := 0.0
	if count > 0 {
		avg = total / float64(count)
	}
	_, _ = r.DB.Collection("menus").UpdateOne(ctx, bson.M{"_id": menuID}, bson.M{"$set": bson.M{"averageRating": avg}})
	return avg, nil
}

// findMenuIDByItem finds a menu containing the given itemID.
func (r *ReviewRepository) findMenuIDByItem(ctx context.Context, itemID string) (string, string) {
	var doc map[string]any
	if err := r.DB.Collection("menus").FindOne(ctx, bson.M{"items._id": itemID}).Decode(&doc); err != nil {
		return "", ""
	}
	id, _ := doc["_id"].(string)
	rid, _ := doc["restaurantId"].(string)
	return id, rid
}

// CascadeItemMenuRestaurant recomputes averages for item, its menu, and restaurant.
// simpleAsyncCascade recomputes and persists averages with minimal logic.
func (r *ReviewRepository) simpleAsyncCascade(itemID, restaurantID string) {
	// Background context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if itemID == "" {
		return
	}

	// 1. Recompute item average (and persist in items collection)
	avg, err := r.AverageRatingByItem(ctx, itemID)
	if err != nil {
		fmt.Printf("[WARN] item avg failed: %v\n", err)
		return
	}

	// 2. Update embedded item inside its menu document
	if oid, err := bson.ObjectIDFromHex(itemID); err == nil {
		_, _ = r.DB.Collection("menus").UpdateOne(ctx,
			bson.M{"items._id": oid},
			bson.M{"$set": bson.M{"items.$.averageRating": avg}},
		)
	} else {
		// Fallback: try string id
		_, _ = r.DB.Collection("menus").UpdateOne(ctx,
			bson.M{"items._id": itemID},
			bson.M{"$set": bson.M{"items.$.averageRating": avg}},
		)
	}

	// 3. Recompute restaurant average. If restaurantID missing, derive via menu lookup.
	if restaurantID == "" {
		_, derived := r.findMenuIDByItem(ctx, itemID)
		if derived != "" {
			restaurantID = derived
		}
	}
	if restaurantID != "" {
		restLookup := restaurantID
		pipeline := []bson.M{
			{"$match": bson.M{"restaurantId": restLookup}},
			{"$unwind": "$items"},
			{"$match": bson.M{"items.averageRating": bson.M{"$ne": nil}}},
			{"$group": bson.M{"_id": "$restaurantId", "avg": bson.M{"$avg": "$items.averageRating"}}},
		}
		cur, err := r.DB.Collection("menus").Aggregate(ctx, pipeline)
		var restaurantAvg float64
		if err == nil {
			var ag struct {
				Avg float64 `bson:"avg"`
			}
			if cur.Next(ctx) {
				_ = cur.Decode(&ag)
			}
			cur.Close(ctx)
			restaurantAvg = ag.Avg
		}
		// Fallback: compute directly from reviews tied to restaurantId if menu-based avg is zero
		if restaurantAvg == 0 {
			rPipeline := []bson.M{
				{"$match": bson.M{"restaurantId": restaurantID, "isDeleted": false}},
				{"$group": bson.M{"_id": "$restaurantId", "avg": bson.M{"$avg": "$rating"}}},
			}
			if rc, err := r.DB.Collection(r.Collection).Aggregate(ctx, rPipeline); err == nil {
				var rr struct {
					Avg float64 `bson:"avg"`
				}
				if rc.Next(ctx) {
					_ = rc.Decode(&rr)
				}
				rc.Close(ctx)
				if rr.Avg > 0 {
					restaurantAvg = rr.Avg
				}
			}
		}
		if restaurantAvg < 0 {
			restaurantAvg = 0
		}
		restColl := os.Getenv("RESTAURANT_COLLECTION")
		if restColl == "" {
			restColl = "restaurants"
		}
		if roid, err := bson.ObjectIDFromHex(restaurantID); err == nil {
			_, _ = r.DB.Collection(restColl).UpdateOne(ctx, bson.M{"_id": roid}, bson.M{"$set": bson.M{"averageRating": restaurantAvg}})
		}
		_, _ = r.DB.Collection(restColl).UpdateOne(ctx, bson.M{"_id": restaurantID}, bson.M{"$set": bson.M{"averageRating": restaurantAvg}})
	}
}
