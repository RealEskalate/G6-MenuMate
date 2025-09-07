package repositories

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type ItemRepository struct {
	database mongo.Database
	coll     string // Collection name, e.g., "menus"
}

func NewItemRepository(database mongo.Database, collection string) domain.IItemRepository {
	repo := &ItemRepository{
		database: database,
		coll:     collection,
	}
	// Create TTL index on startup (idempotent)
	repo.createTTLIndex(context.Background())
	return repo
}

func (r *ItemRepository) createTTLIndex(ctx context.Context) {
	indexModel := mongo.IndexModel{
		Keys:    bson.M{"deletedAt": 1},
		Options: options.Index().SetExpireAfterSeconds(0),
	}
	_, err := r.database.Collection(r.coll).Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		fmt.Printf("Failed to create TTL index: %v\n", err)
	}
}

func (r *ItemRepository) GetItemByID(ctx context.Context, id string) (*domain.Item, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}

	var itemDB mapper.ItemDB
	filter := bson.M{
		"_id":       oid,
		"isDeleted": false,
	}
	err = r.database.Collection(r.coll).FindOne(ctx, filter).Decode(&itemDB)

	if err == mongo.ErrNoDocuments() {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	item := mapper.ToDomainItem(&itemDB)

	return item, nil
}

func (r *ItemRepository) CreateItem(ctx context.Context, item *domain.Item) error {
	itemDB := mapper.NewItemDBFromDomain(item)
	res, err := r.database.Collection(r.coll).InsertOne(ctx, itemDB)
	if err != nil {
		return err
	}
	if res.InsertedID == nil {
		return err
	}
	item.ID = res.InsertedID.(bson.ObjectID).Hex()
	return nil
}

func (r *ItemRepository) UpdateItem(ctx context.Context, id string, item *domain.Item) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}

	update := mapper.MergeItemUpdate(item)
	fmt.Println("Update data:", update) // Debug log

	result, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": oid}, bson.M{"$set": update})
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return errors.New("menu or item not found")
	}

	return nil
}

func (r *ItemRepository) DeleteItem(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}

	// Set deletedAt to 2 months from now (consistent with your previous code)
	deletedAt := time.Now().AddDate(0, 2, 0)

	update := bson.M{
		"$set": bson.M{
			"isDeleted": true,
			"deletedAt": deletedAt,
			"updatedAt": time.Now(),
		},
	}

	result, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": oid}, update)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return errors.New("item not found")
	}

	return nil
}

func (r *ItemRepository) AddReview(ctx context.Context, itemID, reviewID string) error {
	itemOID, err := bson.ObjectIDFromHex(itemID)
	if err != nil {
		return err
	}
	reviewOID, err := bson.ObjectIDFromHex(reviewID)
	if err != nil {
		return err
	}

	update := bson.M{
		"$push": bson.M{
			"items.$[elem].reviewIds": reviewOID.Hex(),
		},
		"$set": bson.M{
			"updatedAt": time.Now(),
		},
	}

	result, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"items._id": itemOID}, update)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return errors.New("item not found")
	}

	return nil
}

func (r *ItemRepository) GetItems(ctx context.Context, menuSlug string) ([]domain.Item, error) {
	log.Println("Fetching items for menu slug:", menuSlug) // Debug log
	var itemsDB []mapper.ItemDB
	filter := bson.M{
		"menuSlug":  menuSlug,
		"isDeleted": false,
	}
	cursor, err := r.database.Collection(r.coll).Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	for cursor.Next(ctx) {
		var itemDB mapper.ItemDB
		if err := cursor.Decode(&itemDB); err != nil {
			return nil, err
		}
		itemsDB = append(itemsDB, itemDB)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}
	log.Println("Successfully fetched items for menu slug:", itemsDB)

	return mapper.ItemDBToDomainList(itemsDB), nil
}

// IncrementItemViewCount increments the view count for an item by 1
func (r *ItemRepository) IncrementItemViewCount(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	update := bson.M{"$inc": bson.M{"viewCount": 1}, "$set": bson.M{"updatedAt": time.Now()}}
	result, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": oid}, update)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return errors.New("item not found")
	}
	return nil
}
