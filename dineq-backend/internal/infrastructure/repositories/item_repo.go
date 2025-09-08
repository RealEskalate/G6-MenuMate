package repositories

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
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
	repo.createQueryIndexes(context.Background())
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

// createQueryIndexes ensures indexes used by advanced search
func (r *ItemRepository) createQueryIndexes(ctx context.Context) {
	idx := r.database.Collection(r.coll).Indexes()
	// create individually to support our IndexView wrapper
	toCreate := []mongo.IndexModel{
		{Keys: bson.D{{Key: "menuSlug", Value: 1}, {Key: "isDeleted", Value: 1}}, Options: options.Index().SetName("ix_menuSlug_isDeleted")},
		{Keys: bson.D{{Key: "price", Value: 1}}, Options: options.Index().SetName("ix_price")},
		{Keys: bson.D{{Key: "averageRating", Value: 1}}, Options: options.Index().SetName("ix_averageRating")},
		{Keys: bson.D{{Key: "viewCount", Value: 1}}, Options: options.Index().SetName("ix_viewCount")},
		{Keys: bson.D{{Key: "name", Value: 1}}, Options: options.Index().SetName("ix_name")},
		{Keys: bson.D{{Key: "tabTags", Value: 1}}, Options: options.Index().SetName("ix_tabTags")},
	}
	for _, m := range toCreate {
		if _, err := idx.CreateOne(ctx, m); err != nil {
			log.Printf("ensure index failed: %v", err)
		}
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

// SearchItems returns items for a given menu using advanced filters with pagination and sorting
func (r *ItemRepository) SearchItems(ctx context.Context, filter domain.ItemFilter) ([]domain.Item, int64, error) {
	// Search inside menus collection's embedded items array
	menuCollName := os.Getenv("MENU_COLLECTION")
	if menuCollName == "" { menuCollName = "menus" }
	coll := r.database.Collection(menuCollName)

	// Validate menu slug
	if filter.MenuSlug == "" {
		return nil, 0, fmt.Errorf("menu_slug is required")
	}

	// pagination
	page := filter.Page
	size := filter.PageSize
	if page <= 0 { page = 1 }
	if size <= 0 { size = 10 }
	if size > 100 { size = 100 }

	// sorting
	sortField := "createdAt"
	switch filter.SortBy {
	case "price":
		sortField = "price"
	case "rating":
		sortField = "averageRating"
	case "popularity":
		sortField = "viewCount"
	case "updated":
		sortField = "updatedAt"
	}
	order := -1
	if filter.Order == 1 { order = 1 }

	// Build item-level match
	itemMatch := bson.M{"isDeleted": false}
	if len(filter.Tags) > 0 { itemMatch["tabTags"] = bson.M{"$in": filter.Tags} }
	if filter.MinPrice != nil || filter.MaxPrice != nil {
		pr := bson.M{}
		if filter.MinPrice != nil { pr["$gte"] = *filter.MinPrice }
		if filter.MaxPrice != nil { pr["$lte"] = *filter.MaxPrice }
		itemMatch["price"] = pr
	}
	if filter.MinRating != nil { itemMatch["averageRating"] = bson.M{"$gte": *filter.MinRating} }
	if filter.Query != "" { itemMatch["name"] = bson.M{"$regex": filter.Query, "$options": "i"} }

	// Aggregation pipeline over menus -> items
	matchMenu := bson.M{"slug": filter.MenuSlug, "isDeleted": false}
	pipeline := []bson.D{
		bson.D{{Key: "$match", Value: matchMenu}},
		bson.D{{Key: "$project", Value: bson.M{"items": 1, "menuSlug": "$slug"}}},
		bson.D{{Key: "$unwind", Value: "$items"}},
		bson.D{{Key: "$replaceRoot", Value: bson.M{
			"newRoot": bson.M{"$mergeObjects": bson.A{"$items", bson.M{"menuSlug": "$menuSlug"}}},
		}}},
		bson.D{{Key: "$match", Value: itemMatch}},
		bson.D{{Key: "$sort", Value: bson.D{{Key: sortField, Value: order}, {Key: "_id", Value: 1}}}},
		bson.D{{Key: "$facet", Value: bson.M{
			"totalData": bson.A{
				bson.D{{Key: "$skip", Value: (page - 1) * size}},
				bson.D{{Key: "$limit", Value: size}},
			},
			"totalCount": bson.A{
				bson.D{{Key: "$count", Value: "count"}},
			},
		}}},
	}

	cur, err := coll.Aggregate(ctx, pipeline)
	if err != nil { return nil, 0, err }
	defer cur.Close(ctx)

	var facet []struct {
		TotalData  []mapper.ItemDB `bson:"totalData"`
		TotalCount []struct{ Count int64 `bson:"count"` } `bson:"totalCount"`
	}
	if err := cur.All(ctx, &facet); err != nil { return nil, 0, err }
	if len(facet) == 0 { return []domain.Item{}, 0, nil }
	total := int64(0)
	if len(facet[0].TotalCount) > 0 { total = facet[0].TotalCount[0].Count }
	items := mapper.ItemDBToDomainList(facet[0].TotalData)
	return items, total, nil
}
