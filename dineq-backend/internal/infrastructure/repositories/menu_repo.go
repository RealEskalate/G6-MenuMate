package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
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
}

func (r *MenuRepository) Create(ctx context.Context, menu *domain.Menu) error {
	dbMenu := mapper.FromDomainMenu(menu)
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
	var dbMenu mapper.MenuDB
	err := r.database.Collection(r.coll).FindOne(ctx, bson.M{"_id": id, "isDeleted": false}).Decode(&dbMenu)
	if err != nil {
		return nil, err
	}
	return mapper.ToDomainMenu(&dbMenu), nil
}

func (r *MenuRepository) Delete(ctx context.Context, id string) error {
	_, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{"isDeleted": true, "deletedAt": time.Now().AddDate(0, 2, 0)}})
	return err
}

func (r *MenuRepository) Update(ctx context.Context, id string, menu *domain.Menu) error {
	dbMenu := mapper.FromDomainMenu(menu)
	_, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": dbMenu})
	return err
}

func (r *MenuRepository) IncrementViewCount(ctx context.Context, id string) error {
	_, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$inc": bson.M{"viewCount": 1}})
	return err
}

func (r *MenuRepository) GetByRestaurantID(ctx context.Context, restaurantID string) (*domain.Menu, error) {
	var dbMenu mapper.MenuDB
	err := r.database.Collection(r.coll).FindOne(ctx, bson.M{"restaurantId": restaurantID, "isDeleted": false}).Decode(&dbMenu)
	if err != nil {
		return nil, err
	}
	return mapper.ToDomainMenu(&dbMenu), nil
}
