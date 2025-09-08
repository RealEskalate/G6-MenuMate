package repositories

import (
	"context"
	"fmt"
	"os"
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
		fmt.Println("Error parsing restaurant:", err)
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
	filter := bson.M{"slug": slug, "isDeleted": false} // BEGIN:
	var model mapper.RestaurantModel

	err := repo.db.Collection(repo.restaurantCol).FindOne(ctx, filter).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			// Check if it exists but marked deleted to return 410 scenario
			deletedFilter := bson.M{"slug": slug, "isDeleted": true} // END:
			var deleted mapper.RestaurantModel
			derr := repo.db.Collection(repo.restaurantCol).FindOne(ctx, deletedFilter).Decode(&deleted)
			if derr == nil { // exists but deleted
				return nil, domain.ErrRestaurantDeleted
			}
			return nil, domain.ErrRestaurantNotFound
		}
		return nil, err
	}

	return model.ToDomain(), nil
}

// GetByOldSlug searches in previous_slugs array
func (repo *RestaurantRepo) GetByOldSlug(ctx context.Context, oldSlug string) (*domain.Restaurant, error) {
	filter := bson.M{"previousSlugs": oldSlug, "isDeleted": false} // BEGIN:
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

	set := bson.M{
		"slug":               model.Slug,
		"previousSlugs":      model.PreviousSlugs,
		"restaurantName":     model.Name,
		"managerId":          model.ManagerID,
		"restaurantPhone":    model.Phone,
		"location":           model.Location,
		"about":              model.About,
		"logoImage":          model.LogoImage,
		"tags":               model.Tags,
		"verificationStatus": model.VerificationStatus,
		"verificationDocs":   model.VerificationDocs,
		"schedule":           model.Schedule,    // ✅ now persisted
		"specialDays":        model.SpecialDays, // ✅ now persisted
		"primaryColor":       model.PrimaryColor,
		"accentColor":        model.AccentColor,
		"defaultCurrency":    model.DefaultCurrency,
		"defaultLanguage":    model.DefaultLanguage,
		"defaultVat":         model.DefaultVat,
		"taxId":              model.TaxId,
		"coverImage":         model.CoverImage,
		"averageRating":      model.AverageRating,
		"viewCount":          model.ViewCount,
		"updatedAt":          model.UpdatedAt,
		"isDeleted":          model.IsDeleted,
	}

	// If slug changed, push old slug to previous_slugs and set new slug
	if r.Slug != "" { // domain object carries current slug
		set["slug"] = model.Slug
		if len(r.PreviousSlugs) > 0 {
			set["previousSlugs"] = r.PreviousSlugs // BEGIN:
		}
	}
	update := bson.M{"$set": set}

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
		bson.M{"_id": oid, "managerId": m_oid, "isDeleted": false}, // BEGIN:
		bson.M{"$set": bson.M{"isDeleted": true}},                  // END:
	)
	return err
}

func (repo *RestaurantRepo) ListAllBranches(ctx context.Context, slug string, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	restCol := repo.db.Collection(repo.restaurantCol)
	filter := bson.M{"slug": slug, "isDeleted": false} // BEGIN:

	total, err := restCol.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	opts := options.Find().
		SetSkip(int64((page - 1) * pageSize)).
		SetLimit(int64(pageSize)).
		SetSort(bson.D{{Key: "createdAt", Value: -1}}) // END:

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
		{{Key: "$match", Value: bson.M{"isDeleted": false}}},           // BEGIN:
		{{Key: "$sort", Value: bson.D{{Key: "createdAt", Value: -1}}}}, // END:
		{{Key: "$group", Value: bson.M{"_id": "$slug", "doc": bson.M{"$first": "$$ROOT"}}}},
		{{Key: "$replaceRoot", Value: bson.M{"newRoot": "$doc"}}},
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
		{{Key: "$match", Value: bson.M{"isDeleted": false}}}, // BEGIN:
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

func (repo *RestaurantRepo) FindNearby(ctx context.Context, lat, lng float64, maxDistance int, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	restCol := repo.db.Collection(repo.restaurantCol)

	// Ensure 2dsphere index on location exists (defensive in case startup index creation didn't run)
	_, _ = restCol.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys:    bson.D{{Key: "location", Value: "2dsphere"}},
		Options: options.Index().SetName("ix_location_2dsphere"),
	})

	geoNearStage := bson.D{{
		Key: "$geoNear", Value: bson.M{
			"near": bson.M{
				"type":        "Point",
				"coordinates": []float64{lng, lat},
			},
			"distanceField": "distance",
			"maxDistance":   maxDistance,
			"key":           "location",
			"spherical":     true,
			"query":         bson.M{"isDeleted": false},
		},
	}}

	facetStage := bson.D{{
		Key: "$facet", Value: bson.M{
			"totalData": bson.A{
				bson.D{{Key: "$skip", Value: (page - 1) * pageSize}},
				bson.D{{Key: "$limit", Value: pageSize}},
			},
			"totalCount": bson.A{
				bson.D{{Key: "$count", Value: "count"}},
			},
		},
	}}

	pipeline := []bson.D{geoNearStage, facetStage}

	cursor, err := restCol.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var facetResults []mapper.FacetResultModel
	if err := cursor.All(ctx, &facetResults); err != nil {
		return nil, 0, err
	}

	if len(facetResults) == 0 {
		return []*domain.Restaurant{}, 0, nil
	}

	restaurants, total := facetResults[0].Parse()
	return restaurants, total, nil

}

// func (repo *RestaurantRepo) GetByRestaurantName(ctx context.Context, name string) (*domain.Restaurant, error) {
// 	filter := bson.M{"name": bson.M{
// 		"$regex":   name, // partial match
// 		"$options": "i",  // case-insensitive
// 	}, "isDeleted": false}
// 	var model mapper.RestaurantModel

// 	err := repo.db.Collection(repo.restaurantCol).Find(ctx, filter).Decode(&model)
// 	if err != nil {
// 		if err == mongo.ErrNoDocuments() {
// 			// Check if it exists but marked deleted to return 410 scenario
// 			deletedFilter := bson.M{"name": name, "isDeleted": true} // END:
// 			var deleted mapper.RestaurantModel
// 			derr := repo.db.Collection(repo.restaurantCol).FindOne(ctx, deletedFilter).Decode(&deleted)
// 			if derr == nil { // exists but deleted
// 				return nil, domain.ErrRestaurantDeleted
// 			}
// 			return nil, domain.ErrRestaurantNotFound
// 		}
// 		return nil, err
// 	}

// 	return model.ToDomain(), nil
// }

func (repo *RestaurantRepo) ListRestaurantsByName(ctx context.Context, name string, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	restCol := repo.db.Collection(repo.restaurantCol)
	filter := bson.M{"name": bson.M{
		"$regex":   name, // partial match
		"$options": "i",  // case-insensitive
	}, "isDeleted": false}

	total, err := restCol.CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	opts := options.Find().
		SetSkip(int64((page - 1) * pageSize)).
		SetLimit(int64(pageSize)).
		SetSort(bson.D{{Key: "createdAt", Value: -1}}) // END:

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

func (repo *RestaurantRepo) GetByManagerId(ctx context.Context, manager string) (*domain.Restaurant, error) {
	oid, err := bson.ObjectIDFromHex(manager)

	if err != nil {
		return nil, domain.ErrServerIssue
	}
	filter := bson.M{"managerId": oid, "isDeleted": false} // BEGIN:
	var model mapper.RestaurantModel

	err = repo.db.Collection(repo.restaurantCol).FindOne(ctx, filter).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			// Check if it exists but marked deleted to return 410 scenario
			deletedFilter := bson.M{"managerId": oid, "isDeleted": true} // END:
			var deleted mapper.RestaurantModel
			derr := repo.db.Collection(repo.restaurantCol).FindOne(ctx, deletedFilter).Decode(&deleted)
			if derr == nil { // exists but deleted
				return nil, domain.ErrRestaurantDeleted
			}
			return nil, domain.ErrRestaurantNotFound
		}
		return nil, err
	}

	return model.ToDomain(), nil
}


// IncrementRestaurantViewCount increments the view count for a restaurant by 1
func (repo *RestaurantRepo) IncrementRestaurantViewCount(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	update := bson.M{"$inc": bson.M{"viewCount": 1}, "$set": bson.M{"updatedAt": time.Now()}}
	result, err := repo.db.Collection(repo.restaurantCol).UpdateOne(ctx, bson.M{"_id": oid}, update)
	if err != nil {
		return err
	}
	if result.MatchedCount == 0 {
		return fmt.Errorf("restaurant not found")
	}
	return nil
}

// SearchRestaurants performs advanced filtering and sorting with pagination
func (repo *RestaurantRepo) SearchRestaurants(ctx context.Context, f domain.RestaurantFilter) ([]*domain.Restaurant, int64, error) {
	col := repo.db.Collection(repo.restaurantCol)
	// Base match
	match := bson.M{"isDeleted": false}
	if f.Slug != "" { match["slug"] = f.Slug }
	if f.Name != "" { match["name"] = bson.M{"$regex": f.Name, "$options": "i"} }
	if len(f.Tags) > 0 { match["tags"] = bson.M{"$all": f.Tags} }
	if f.MinRating != nil || f.MaxRating != nil {
		rr := bson.M{}
		if f.MinRating != nil { rr["$gte"] = *f.MinRating }
		if f.MaxRating != nil { rr["$lte"] = *f.MaxRating }
		match["averageRating"] = rr
	}
	if f.MinViews != nil { match["viewCount"] = bson.M{"$gte": *f.MinViews} }

	page := f.Page
	size := f.PageSize
	if page <= 0 { page = 1 }
	if size <= 0 { size = 10 }
	if size > 100 { size = 100 }

	order := -1
	if f.Order == 1 { order = 1 }

	// If sorting by popularity, compute a weighted score via aggregation.
	if f.SortBy == "popularity" {
		reviewsColl := os.Getenv("REVIEW_COLLECTION")
		if reviewsColl == "" { reviewsColl = "reviews" }
		// Popularity components:
		// - normalized averageRating (0..1) assuming 5-star scale
		// - log-scaled viewCount
		// - normalized positiveReviewCount (reviews with rating > 3.5)
		// Weights can be tuned; start with rating:0.5, views:0.2, positives:0.3

		// Build pipeline
		pipeline := []bson.D{
			bson.D{{Key: "$match", Value: match}},
			bson.D{{Key: "$lookup", Value: bson.M{
				"from": reviewsColl,
				"let": bson.M{"rid": "$_id"},
				"pipeline": bson.A{
					bson.D{{Key: "$match", Value: bson.M{
						"$expr": bson.M{"$and": bson.A{
							bson.M{"$eq": bson.A{"$restaurantId", "$$rid"}},
							bson.M{"$gt": bson.A{"$rating", 3.5}},
							bson.M{"$eq": bson.A{"$isDeleted", false}},
						}},
					}}},
					bson.D{{Key: "$count", Value: "count"}},
				},
				"as": "posReviewsAgg",
			}}},
			bson.D{{Key: "$addFields", Value: bson.M{
				"posReviewCount": bson.M{
					"$cond": bson.A{
						bson.M{"$gt": bson.A{bson.M{"$size": "$posReviewsAgg"}, 0}},
						bson.M{"$arrayElemAt": bson.A{"$posReviewsAgg.count", 0}},
						0,
					},
				},
			}}},
			bson.D{{Key: "$addFields", Value: bson.M{
				"popularityScore": bson.M{"$add": bson.A{
					bson.M{"$multiply": bson.A{0.5, bson.M{"$divide": bson.A{"$averageRating", 5}}}},
					bson.M{"$multiply": bson.A{0.2, bson.M{"$log10": bson.M{"$add": bson.A{"$viewCount", 1}}}}},
					bson.M{"$multiply": bson.A{0.3, bson.M{"$min": bson.A{1, bson.M{"$divide": bson.A{"$posReviewCount", 50}}}}}},
				}},
			}}},
			bson.D{{Key: "$sort", Value: bson.D{{Key: "popularityScore", Value: order}, {Key: "_id", Value: 1}}}},
			bson.D{{Key: "$skip", Value: (page - 1) * size}},
			bson.D{{Key: "$limit", Value: size}},
		}

		// facet for total count without pagination
		countPipeline := []bson.D{
			bson.D{{Key: "$match", Value: match}},
			bson.D{{Key: "$count", Value: "total"}},
		}

		// Execute pipelines
		cur, err := col.Aggregate(ctx, pipeline)
		if err != nil { return nil, 0, err }
		defer cur.Close(ctx)
		var models []mapper.RestaurantModel
		if err := cur.All(ctx, &models); err != nil { return nil, 0, err }

		// total
	var total int64
	ccur, err := col.Aggregate(ctx, countPipeline)
		if err == nil {
			var ct []struct{ Total int64 `bson:"total"` }
			if err := ccur.All(ctx, &ct); err == nil && len(ct) > 0 { total = ct[0].Total }
		}

		out := make([]*domain.Restaurant, len(models))
		for i := range models { out[i] = models[i].ToDomain() }
		return out, total, nil
	}

	// Default simple find/sort path
	total, err := col.CountDocuments(ctx, match)
	if err != nil { return nil, 0, err }

	sortField := "createdAt"
	switch f.SortBy {
	case "rating":
		sortField = "averageRating"
	case "updated":
		sortField = "updatedAt"
	case "name":
		sortField = "name"
	}

	opts := options.Find().
		SetSkip(int64((page-1)*size)).
		SetLimit(int64(size)).
		SetSort(bson.D{{Key: sortField, Value: order}})

	cur, err := col.Find(ctx, match, opts)
	if err != nil { return nil, 0, err }
	defer cur.Close(ctx)

	var models []mapper.RestaurantModel
	if err := cur.All(ctx, &models); err != nil { return nil, 0, err }

	out := make([]*domain.Restaurant, len(models))
	for i := range models { out[i] = models[i].ToDomain() }
	return out, total, nil
}