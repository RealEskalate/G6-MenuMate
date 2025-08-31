package repositories

import (
	"context"

	"github.com/dinq/menumate/internal/domain"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/dinq/menumate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type MenuRepository struct {
	database mongo.Database
	coll     string
}

func NewMenuRepository(db mongo.Database, collection string) domain.IMenuRepository {
	return &MenuRepository{
		database: db,
		coll:     collection,
	}
}

func (r *MenuRepository) Create(ctx context.Context, menu *domain.Menu) error {
	if menu.ID == "" {
		menu.ID = bson.NewObjectID().Hex()
	}
	dbMenu := mapper.FromDomainMenu(menu)
	res, err := r.database.Collection(r.coll).InsertOne(ctx, dbMenu)
	if err != nil {
		return err
	}
	if res.InsertedID == nil {
		return err
	}
	menu.ID = res.InsertedID.(string)
	return nil
}

func (r *MenuRepository) GetByID(ctx context.Context, id string) (*domain.Menu, error) {
	var dbMenu mapper.MenuDB
	err := r.database.Collection(r.coll).FindOne(ctx, bson.M{"_id": id}).Decode(&dbMenu)
	if err != nil {
		return nil, err
	}
	return mapper.ToDomainMenu(&dbMenu), nil
}

func (r *MenuRepository) Delete(ctx context.Context, id string) error {
	_, err := r.database.Collection(r.coll).DeleteOne(ctx, bson.M{"_id": id})
	return err
}

func (r *MenuRepository) Update(ctx context.Context, id string, menu *domain.Menu) error {
	dbMenu := mapper.FromDomainMenu(menu)
	_, err := r.database.Collection(r.coll).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": dbMenu})
	return err
}
