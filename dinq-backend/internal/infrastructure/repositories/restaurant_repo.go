package repositories

import (
	"context"
	"errors"

	"github.com/dinq/menumate/internal/domain"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	mongoBuiltin "go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type RestaurantRepository struct {
	DB         mongo.Database
	Collection string
}

func NewRestaurantRepository(db mongo.Database, collection string) domain.IRestaurantRepository {
	return &RestaurantRepository{
		DB:         db,
		Collection: collection,
	}
}

func (repo *RestaurantRepository) GetByID(ctx context.Context, id string) (*domain.Restaurant, error) {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	var restaurant domain.Restaurant
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"id": id, "isDeleted": false}).Decode(&restaurant)
	if err != nil {
		if errors.Is(err, mongoBuiltin.ErrNoDocuments) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &restaurant, nil
}

func (repo *RestaurantRepository) GetByPhone(ctx context.Context, phone string) (*domain.Restaurant, error) {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	var restaurant domain.Restaurant
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"contact.phone": phone, "isDeleted": false}).Decode(&restaurant)
	if err != nil {
		if errors.Is(err, mongoBuiltin.ErrNoDocuments) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &restaurant, nil
}

func (repo *RestaurantRepository) GetByEmail(ctx context.Context, email string) (*domain.Restaurant, error) {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	var restaurant domain.Restaurant
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"contact.email": email, "isdeleted": false}).Decode(&restaurant)
	if err != nil {
		if errors.Is(err, mongoBuiltin.ErrNoDocuments) {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return &restaurant, nil
}

func (repo *RestaurantRepository) Create(ctx context.Context, r *domain.Restaurant) error {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	_, err := repo.DB.Collection(repo.Collection).InsertOne(ctx, r)
	if err != nil {
		return err
	}
	return nil
}

func (repo *RestaurantRepository) Update(ctx context.Context, r *domain.Restaurant) error {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	filter := bson.M{"id": r.ID, "isDeleted": false}
	update := bson.M{"$set": r}
	_, err := repo.DB.Collection(repo.Collection).UpdateOne(ctx, filter, update)
	return err
}

func (repo *RestaurantRepository) Delete(ctx context.Context, id string) error {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	filter := bson.M{"id": id, "isDeleted": false}
	update := bson.M{"$set": bson.M{"isDeleted": true}}
	_, err := repo.DB.Collection(repo.Collection).UpdateOne(ctx, filter, update)
	return err
}

func (repo *RestaurantRepository) List(ctx context.Context) ([]domain.Restaurant, error) {
	ctx, cancel := context.WithTimeout(ctx, domain.TIME_OUT)
	defer cancel()

	cursor, err := repo.DB.Collection(repo.Collection).Find(ctx, bson.M{"isDeleted": false})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var restaurants []domain.Restaurant
	for cursor.Next(ctx) {
		var restaurant domain.Restaurant
		if err := cursor.Decode(&restaurant); err != nil {
			return nil, err
		}
		restaurants = append(restaurants, restaurant)
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return restaurants, nil
}
