package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper/utils"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type MenuRepository struct {
	database mongo.Database
	coll     string
}

func NewMenuRepository(db mongo.Database, collection string) domain.IMenuRepository {
	repo := &MenuRepository{
		database: db,
		coll:     collection,
	}
	// Create TTL index on startup (idempotent)
	repo.createTTLIndex(context.Background())
	return repo
}

func (r *MenuRepository) createTTLIndex(ctx context.Context) {
	indexModel := mongo.IndexModel{
		Keys:    bson.M{"deletedAt": 1},
		Options: options.Index().SetExpireAfterSeconds(0),
	}
	_, err := r.database.Collection(r.coll).Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		fmt.Printf("Failed to create TTL index: %v\n", err)
	}

	// Create index on restaurantId
	restaurantIndexModel := mongo.IndexModel{
		Keys: bson.M{"restaurantId": 1},
	}
	_, err = r.database.Collection(r.coll).Indexes().CreateOne(ctx, restaurantIndexModel)
	if err != nil {
		fmt.Printf("Failed to create restaurantId index: %v\n", err)
	}

	// Create index on slug (used to match menu for embedded item search)
	slugIndex := mongo.IndexModel{
		Keys:    bson.M{"slug": 1},
		Options: options.Index().SetName("ix_slug"),
	}
	if _, err = r.database.Collection(r.coll).Indexes().CreateOne(ctx, slugIndex); err != nil {
		fmt.Printf("Failed to create slug index: %v\n", err)
	}
}

func (r *MenuRepository) Create(ctx context.Context, menu *domain.Menu) error {
	dbMenu := mapper.NewMenuDBFromDomain(menu)
	res, err := r.database.Collection(r.coll).InsertOne(ctx, dbMenu)
	if err != nil {
		return err
	}
	if res.InsertedID == nil {
		return err
	}
	menu.ID = res.InsertedID.(bson.ObjectID).Hex()
	return nil
}

func (r *MenuRepository) GetByID(ctx context.Context, id string) (*domain.Menu, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}

	var dbMenu mapper.MenuDB
	filter := bson.M{
		"_id":       oid,
		"isDeleted": false,
	}
	err = r.database.Collection(r.coll).FindOne(ctx, filter).Decode(&dbMenu)
	if err != nil {
		return nil, err
	}
	return mapper.ToDomainMenu(&dbMenu), nil
}

func (r *MenuRepository) Delete(ctx context.Context, id string) error {
	fmt.Println("---------------- Debug --------------")
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}

	// Define the deletedAt timestamp (2 months from now)
	deletedAt := time.Now().AddDate(0, 2, 0)

	// Define the filter to match the Menu document
	filter := bson.M{"_id": oid}

	// Define the update to set fields for the Menu and all items
	update := bson.M{
		"$set": bson.M{
			"isDeleted": true,
			"deletedAt": deletedAt,
			"updatedAt": time.Now(),
			"items": bson.A{ // Explicitly update the items array
				bson.M{
					"$set": bson.M{
						"isDeleted": true,
						"deletedAt": deletedAt,
						"updatedAt": time.Now(),
					},
				},
			},
		},
	}

	// Perform the update
	result, err := r.database.Collection(r.coll).UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}

	// Check if the document was found
	if result.MatchedCount == 0 {
		return mongo.ErrNoDocuments()
	}

	return nil
}

func (r *MenuRepository) Update(ctx context.Context, id string, menu *domain.Menu) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}

	// Build dynamic update: allow changing name, items, and publish state.
	setFields := bson.M{
		"updatedAt": time.Now().UTC(),
		"updatedBy": menu.UpdatedBy,
	}
	if menu.Name != "" { // update name if provided
		setFields["name"] = menu.Name
	}
	// Publish state
	if menu.IsPublished {
		setFields["isPublished"] = true
		if !menu.PublishedAt.IsZero() {
			setFields["publishedAt"] = menu.PublishedAt
		}
	}

	// If items slice provided, map to DB representations (regenerating slugs left to upstream if desired)
	if len(menu.Items) > 0 {
		var dbItems []mapper.ItemDB
		for i := range menu.Items {
			dbItems = append(dbItems, *mapper.ToItemDBForUpdate(&menu.Items[i]))
		}
		setFields["items"] = dbItems
	}

	update := bson.M{"$set": setFields, "$inc": bson.M{"version": 1}}
	filter := bson.M{"_id": oid, "isDeleted": false}

	result, err := r.database.Collection(r.coll).UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return mongo.ErrNoDocuments()
	}
	return nil
}

func (r *MenuRepository) IncrementViewCount(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	_, err = r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": oid}, bson.M{"$inc": bson.M{"viewCount": 1}})
	return err
}

func (r *MenuRepository) GetByRestaurantID(ctx context.Context, restaurantID string) ([]*domain.Menu, error) {
	var dbMenus []mapper.MenuDB

	filter := bson.M{
		"restaurantId": restaurantID,
		"isDeleted":    false,
		"items": bson.M{
			"$elemMatch": bson.M{
				"isDeleted": false,
			},
		},
	}
	cursor, err := r.database.Collection(r.coll).Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var dbMenu mapper.MenuDB
		if err := cursor.Decode(&dbMenu); err != nil {
			return nil, err
		}
		dbMenus = append(dbMenus, dbMenu)
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	menus := make([]*domain.Menu, len(dbMenus))
	for i, dbMenu := range dbMenus {
		menus[i] = mapper.ToDomainMenu(&dbMenu)
	}
	return menus, nil
}

func (r *MenuRepository) MenuItemUpdate(ctx context.Context, itemSlug string, menuItem *domain.Item) error {
	filter := bson.M{
		"menu.slug": menuItem.MenuSlug,
		"items.slug": itemSlug,
	}

	fields := bson.M{}
	data, _ := bson.Marshal(menuItem)
	_ = bson.Unmarshal(data, &fields)

	update := utils.BuildNestedUpdate("menu.items.$.", fields)

	_, err := r.database.Collection(r.coll).UpdateOne(ctx, filter, update)
	return err
}

// get menu item by slug
func (r *MenuRepository) GetMenuItemBySlug(ctx context.Context, menuSlug string, itemSlug string) (*domain.Item, error) {
	filter := bson.M{
		"slug": menuSlug,
		"items": bson.M{
			"$elemMatch": bson.M{
				"slug":      itemSlug,
				"isDeleted": false,
			},
		},
	}

	var dbMenu mapper.MenuDB
	err := r.database.Collection(r.coll).FindOne(ctx, filter).Decode(&dbMenu)
	if err != nil {
		return nil, err
	}

	for _, dbItem := range dbMenu.Items {
		if dbItem.Slug == itemSlug && !dbItem.IsDeleted {
			item := mapper.ToDomainItem(&dbItem)
			return item, nil
		}
	}

	return nil, mongo.ErrNoDocuments()
}
