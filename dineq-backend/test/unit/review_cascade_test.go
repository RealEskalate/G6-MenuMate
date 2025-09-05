package unit

import (
	"context"
	"testing"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// NOTE: This is a lightweight integration-style unit test that directly hits the real Mongo instance
// configured by environment variables. If env vars are missing it will skip.
func TestReviewSimpleAsyncCascade(t *testing.T) {
	app, err := bootstrap.InitApp()
	if err != nil {
		t.Skipf("init app failed: %v", err)
	}
	defer app.CloseDBConnection()
	env := app.Env
	if env.DB_Name == "" || env.DB_Uri == "" {
		t.Skip("missing DB env")
	}

	db := app.Mongo.Database(env.DB_Name)

	// Collections
	// reviewsColl not needed directly here (repository handles inserts)
	itemsColl := db.Collection("items")
	menusColl := db.Collection("menus")
	restCollName := env.RestaurantCollection
	if restCollName == "" {
		restCollName = "restaurants"
	}
	restColl := db.Collection(restCollName)

	// Create minimal restaurant
	restID := bson.NewObjectID().Hex()
	_, err = restColl.InsertOne(context.Background(), bson.M{"_id": restID, "averageRating": 0})
	if err != nil {
		t.Fatalf("insert restaurant failed: %v", err)
	}

	// Create menu with embedded item placeholder
	itemID := bson.NewObjectID().Hex()
	menuID := bson.NewObjectID().Hex()
	_, err = menusColl.InsertOne(context.Background(), bson.M{
		"_id":          menuID,
		"restaurantId": restID,
		"items":        []bson.M{{"_id": itemID, "averageRating": 0}},
	})
	if err != nil {
		t.Fatalf("insert menu failed: %v", err)
	}

	// Create separate item document
	_, err = itemsColl.InsertOne(context.Background(), bson.M{"_id": itemID, "averageRating": 0})
	if err != nil {
		t.Fatalf("insert item failed: %v", err)
	}

	// db already satisfies mongo.Database interface; just pass through
	repo := repositories.NewReviewRepository(db, "reviews")

	// Insert multiple reviews with ratings
	ratings := []float64{4, 5, 3, 5}
	for _, r := range ratings {
		rv := &domain.Review{ItemID: itemID, RestaurantID: restID, Rating: r, UserID: bson.NewObjectID().Hex(), CreatedAt: time.Now(), UpdatedAt: time.Now()}
		if err := repo.Create(context.Background(), rv); err != nil {
			t.Fatalf("create review failed: %v", err)
		}
	}

	// Allow async goroutines to finish
	time.Sleep(1 * time.Second)

	// Check item average
	var itemDoc struct {
		Avg float64 `bson:"averageRating"`
	}
	if err := itemsColl.FindOne(context.Background(), bson.M{"_id": itemID}).Decode(&itemDoc); err != nil {
		t.Fatalf("fetch item failed: %v", err)
	}
	expectedAvg := (4 + 5 + 3 + 5) / 4.0
	if itemDoc.Avg != expectedAvg {
		t.Fatalf("item avg mismatch got %v want %v", itemDoc.Avg, expectedAvg)
	}

	// Check embedded menu item updated
	var menuDoc struct {
		Items []struct {
			ID  string  `bson:"_id"`
			Avg float64 `bson:"averageRating"`
		} `bson:"items"`
	}
	if err := menusColl.FindOne(context.Background(), bson.M{"_id": menuID}).Decode(&menuDoc); err != nil {
		t.Fatalf("fetch menu failed: %v", err)
	}
	if len(menuDoc.Items) == 0 || menuDoc.Items[0].Avg != expectedAvg {
		t.Fatalf("menu embedded item avg mismatch got %#v want %v", menuDoc.Items, expectedAvg)
	}

	// Check restaurant average
	var restDoc struct {
		Avg float64 `bson:"averageRating"`
	}
	if err := restColl.FindOne(context.Background(), bson.M{"_id": restID}).Decode(&restDoc); err != nil {
		t.Fatalf("fetch restaurant failed: %v", err)
	}
	if restDoc.Avg != expectedAvg {
		t.Fatalf("restaurant avg mismatch got %v want %v", restDoc.Avg, expectedAvg)
	}
}
