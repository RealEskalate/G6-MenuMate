package repositories

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type RestaurantRepo struct {
	db            mongo.Database
	restaurantCol string
}

func NewRestaurantRepo(database mongo.Database, restaurantCol string) domain.IRestaurantRepo {
	return &RestaurantRepo{
		db:            database,
		restaurantCol: restaurantCol,
	}
}

func (repo *RestaurantRepo) Create(ctx context.Context, r *domain.Restaurant) error {
	model := &mapper.RestaurantModel{}

	if err := model.Parse(r); err != nil {
		return err
	}

	model.CreatedAt = bson.NewDateTimeFromTime(time.Now())
	model.UpdatedAt = bson.NewDateTimeFromTime(time.Now())

	res, err := repo.db.Collection(repo.restaurantCol).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	// update the domain object with Mongo-generated ID
	r.ID = res.InsertedID.(bson.ObjectID).Hex()
	r.CreatedAt = model.CreatedAt.Time()
	r.UpdatedAt = model.UpdatedAt.Time()

	return nil
}

func (repo *RestaurantRepo) GetBySlug(ctx context.Context, slug string) (*domain.Restaurant, error) {
	filter := bson.M{"slug": slug, "is_deleted": false}
	var model mapper.RestaurantModel

	err := repo.db.Collection(repo.restaurantCol).FindOne(ctx, filter).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrRestaurantNotFound
		}
		return nil, err
	}

	return model.ToDomain(), nil
}

func (repo *RestaurantRepo) Update(ctx context.Context, r *domain.Restaurant) error {
	model := &mapper.RestaurantModel{}
	if err := model.Parse(r); err != nil {
		return err
	}

	model.UpdatedAt = bson.NewDateTimeFromTime(time.Now())

	oid, err := bson.ObjectIDFromHex(r.ID)
	if err != nil {
		return err
	}

	update := bson.M{
		"$set": bson.M{
			"name":                model.Name,
			"phone":               model.Phone,
			"about":               model.About,
			"logo_image":          model.LogoImage,
			"tags":                model.Tags,
			"verification_status": model.VerificationStatus,
			"menu_id":             model.MenuID,
			"updated_at":          model.UpdatedAt,
		},
	}

	_, err = repo.db.Collection(repo.restaurantCol).UpdateOne(ctx, bson.M{"_id": oid}, update)
	return err
}

func (repo *RestaurantRepo) Delete(ctx context.Context, id string, manager string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	m_oid, err := bson.ObjectIDFromHex(manager)
	if err != nil {
		return err
	}

	_, err = repo.db.Collection(repo.restaurantCol).UpdateOne(ctx,
		bson.M{"_id": oid, "manager_id": m_oid, "is_deleted": false},
		bson.M{"$set": bson.M{"is_deleted": true}},
	)
	return err
}

func (repo *RestaurantRepo) ListAllBranches(ctx context.Context, slug string, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	restCol := repo.db.Collection(repo.restaurantCol)
	filter := bson.M{"slug": slug, "is_deleted": false}

	total, err := restCol.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	opts := options.Find().
		SetSkip(int64((page - 1) * pageSize)).
		SetLimit(int64(pageSize)).
		SetSort(bson.D{{Key: "created_at", Value: -1}})

	cursor, err := restCol.Find(ctx, filter, opts)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []mapper.RestaurantModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	result := make([]*domain.Restaurant, len(models))
	for i, m := range models {
		result[i] = m.ToDomain()
	}
	return result, total, nil
}

// one restaurant per slug
func (repo *RestaurantRepo) ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	restCol := repo.db.Collection(repo.restaurantCol)

	pipeline := []bson.D{
		{{Key: "$match", Value: bson.M{"is_deleted": false}}},
		{{Key: "$sort", Value: bson.D{{Key: "created_at", Value: -1}}}},
		{{Key: "$group", Value: bson.M{"_id": "$slug", "doc": bson.M{"$first": "$$ROOT"}}}},
		{{Key: "$replaceRoot", Value: bson.M{"new_root": "$doc"}}},
		{{Key: "$skip", Value: (page - 1) * pageSize}},
		{{Key: "$limit", Value: pageSize}},
	}

	cursor, err := restCol.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []mapper.RestaurantModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	// Count unique slugs
	countPipeline := []bson.D{
		{{Key: "$match", Value: bson.M{"is_deleted": false}}},
		{{Key: "$group", Value: bson.M{"_id": "$slug"}}},
		{{Key: "$count", Value: "total"}},
	}

	countCursor, err := restCol.Aggregate(ctx, countPipeline)
	if err != nil {
		return nil, 0, err
	}
	defer countCursor.Close(ctx)

	var countResult []struct{ Total int64 }
	if err := countCursor.All(ctx, &countResult); err != nil {
		return nil, 0, err
	}

	total := int64(0)
	if len(countResult) > 0 {
		total = countResult[0].Total
	}

	result := make([]*domain.Restaurant, len(models))
	for i, m := range models {
		result[i] = m.ToDomain()
	}
	return result, total, nil
}
