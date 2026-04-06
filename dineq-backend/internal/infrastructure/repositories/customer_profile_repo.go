package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	mongo_options "go.mongodb.org/mongo-driver/v2/mongo/options"
)

// CustomerProfileRepository implements domain.ICustomerProfileRepository backed by MongoDB.
type CustomerProfileRepository struct {
	DB              mongo.Database
	Collection      string
	UsersCollection string // for cross-collection search joins
}

// NewCustomerProfileRepository constructs a CustomerProfileRepository and returns it as the
// domain interface so callers depend only on the abstraction.
func NewCustomerProfileRepository(db mongo.Database, collection, usersCollection string) domain.ICustomerProfileRepository {
	return &CustomerProfileRepository{
		DB:              db,
		Collection:      collection,
		UsersCollection: usersCollection,
	}
}

// Create inserts a new CustomerRestaurantProfile and writes the MongoDB-generated ID back
// into the domain struct.
func (r *CustomerProfileRepository) Create(ctx context.Context, profile *domain.CustomerRestaurantProfile) error {
	model := mapper.CustomerProfileFromDomain(profile)
	if model.CreatedAt.IsZero() {
		model.CreatedAt = time.Now()
	}
	if model.UpdatedAt.IsZero() {
		model.UpdatedAt = time.Now()
	}

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}
	if oid, ok := res.InsertedID.(bson.ObjectID); ok {
		profile.ID = oid.Hex()
	} else {
		return fmt.Errorf("customer profile: unexpected inserted ID type %T", res.InsertedID)
	}
	return nil
}

// GetByID fetches a single profile by its ObjectID hex string.
func (r *CustomerProfileRepository) GetByID(ctx context.Context, id string) (*domain.CustomerRestaurantProfile, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}
	var model mapper.CustomerRestaurantProfileModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.CustomerProfileToDomain(&model), nil
}

// GetByUserAndRestaurant fetches the profile for a specific (userID, restaurantID) pair.
// Returns domain.ErrNotFound when no profile exists yet.
func (r *CustomerProfileRepository) GetByUserAndRestaurant(ctx context.Context, userID, restaurantID string) (*domain.CustomerRestaurantProfile, error) {
	var model mapper.CustomerRestaurantProfileModel
	err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{
		"userId":       userID,
		"restaurantId": restaurantID,
	}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.CustomerProfileToDomain(&model), nil
}

// Update replaces all mutable fields of an existing profile document identified by profile.ID.
func (r *CustomerProfileRepository) Update(ctx context.Context, profile *domain.CustomerRestaurantProfile) error {
	oid, err := bson.ObjectIDFromHex(profile.ID)
	if err != nil {
		return domain.ErrInvalidInput
	}

	profile.UpdatedAt = time.Now()
	model := mapper.CustomerProfileFromDomain(profile)

	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid},
		bson.M{"$set": model},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// List returns a paginated slice of profiles matching the provided filter.
// When filter.Search is non-empty a MongoDB $lookup is used to join the users collection
// so that filtering by name/email works correctly.
func (r *CustomerProfileRepository) List(ctx context.Context, filter domain.CustomerProfileFilter) ([]*domain.CustomerRestaurantProfile, int64, error) {
	page := filter.Page
	pageSize := filter.PageSize
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	if filter.Search == "" {
		return r.listWithFind(ctx, filter, page, pageSize)
	}
	return r.listWithAggregation(ctx, filter, page, pageSize)
}

// listWithFind handles the common case where no full-text / user-join search is required.
func (r *CustomerProfileRepository) listWithFind(
	ctx context.Context,
	filter domain.CustomerProfileFilter,
	page, pageSize int,
) ([]*domain.CustomerRestaurantProfile, int64, error) {

	query := r.buildBaseMatch(filter)

	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, query)
	if err != nil {
		return nil, 0, err
	}

	sortField := r.resolveSortField(filter.SortBy)
	sortOrder := -1
	if filter.Order == 1 {
		sortOrder = 1
	}

	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		query,
		mongo_options.Find().
			SetSkip(skip).
			SetLimit(limit).
			SetSort(bson.M{sortField: sortOrder}),
	)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.CustomerRestaurantProfileModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}
	return mapper.CustomerProfileToDomainList(models), total, nil
}

// listWithAggregation runs an aggregation pipeline that $lookups the users collection so
// that search by name / email is possible even though those fields are not stored on the profile.
func (r *CustomerProfileRepository) listWithAggregation(
	ctx context.Context,
	filter domain.CustomerProfileFilter,
	page, pageSize int,
) ([]*domain.CustomerRestaurantProfile, int64, error) {

	pipeline := []bson.M{}

	// Stage 1 – match on profile-level fields
	baseMatch := r.buildBaseMatch(filter)
	if len(baseMatch) > 0 {
		pipeline = append(pipeline, bson.M{"$match": baseMatch})
	}

	// Stage 2 – join the users collection; userId is stored as a hex string, _id is ObjectID
	pipeline = append(pipeline, bson.M{
		"$lookup": bson.M{
			"from": r.UsersCollection,
			"let":  bson.M{"uid": "$userId"},
			"pipeline": []bson.M{
				{
					"$match": bson.M{
						"$expr": bson.M{
							"$eq": []interface{}{
								bson.M{"$toString": "$_id"},
								"$$uid",
							},
						},
					},
				},
				// Limit projection to what we need for the search
				{"$project": bson.M{"firstName": 1, "lastName": 1, "email": 1, "username": 1}},
			},
			"as": "_user",
		},
	})

	// Stage 3 – filter by search text across joined user fields
	pipeline = append(pipeline, bson.M{
		"$match": bson.M{
			"$or": []bson.M{
				{"_user.firstName": bson.M{"$regex": filter.Search, "$options": "i"}},
				{"_user.lastName": bson.M{"$regex": filter.Search, "$options": "i"}},
				{"_user.email": bson.M{"$regex": filter.Search, "$options": "i"}},
				{"_user.username": bson.M{"$regex": filter.Search, "$options": "i"}},
			},
		},
	})

	// Stage 4 – remove the temporary join field
	pipeline = append(pipeline, bson.M{"$project": bson.M{"_user": 0}})

	// Count using a separate pipeline snapshot (before sort/skip/limit)
	countPipeline := make([]bson.M, len(pipeline))
	copy(countPipeline, pipeline)
	countPipeline = append(countPipeline, bson.M{"$count": "total"})

	countCursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, countPipeline)
	if err != nil {
		return nil, 0, err
	}
	defer countCursor.Close(ctx)

	var countResult []struct {
		Total int64 `bson:"total"`
	}
	if err := countCursor.All(ctx, &countResult); err != nil {
		return nil, 0, err
	}
	total := int64(0)
	if len(countResult) > 0 {
		total = countResult[0].Total
	}

	// Sort, skip, limit
	sortField := r.resolveSortField(filter.SortBy)
	sortOrder := -1
	if filter.Order == 1 {
		sortOrder = 1
	}
	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	pipeline = append(pipeline, bson.M{"$sort": bson.M{sortField: sortOrder}})
	pipeline = append(pipeline, bson.M{"$skip": skip})
	pipeline = append(pipeline, bson.M{"$limit": limit})

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.CustomerRestaurantProfileModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}
	return mapper.CustomerProfileToDomainList(models), total, nil
}

// GetTopCustomers returns the top-N profiles for a restaurant ordered by total_spent descending.
func (r *CustomerProfileRepository) GetTopCustomers(ctx context.Context, restaurantID string, limit int) ([]*domain.CustomerRestaurantProfile, error) {
	if limit <= 0 {
		limit = 10
	}
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{"restaurantId": restaurantID},
		mongo_options.Find().
			SetLimit(int64(limit)).
			SetSort(bson.M{"totalSpent": -1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.CustomerRestaurantProfileModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}
	return mapper.CustomerProfileToDomainList(models), nil
}

// GetAtRiskCustomers returns profiles for a restaurant whose lastVisitAt is older than
// daysSinceLastVisit days ago, sorted oldest-visit-first.
func (r *CustomerProfileRepository) GetAtRiskCustomers(ctx context.Context, restaurantID string, daysSinceLastVisit int) ([]*domain.CustomerRestaurantProfile, error) {
	cutoff := time.Now().AddDate(0, 0, -daysSinceLastVisit)

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{
			"restaurantId":  restaurantID,
			"lastVisitAt":   bson.M{"$lt": cutoff},
			"isBlacklisted": false,
		},
		mongo_options.Find().SetSort(bson.M{"lastVisitAt": 1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.CustomerRestaurantProfileModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}
	return mapper.CustomerProfileToDomainList(models), nil
}

// UpdateSegment performs a targeted update of only the segment and updatedAt fields.
func (r *CustomerProfileRepository) UpdateSegment(ctx context.Context, profileID string, segment domain.CustomerSegment) error {
	oid, err := bson.ObjectIDFromHex(profileID)
	if err != nil {
		return domain.ErrInvalidInput
	}
	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid},
		bson.M{"$set": bson.M{
			"segment":   string(segment),
			"updatedAt": time.Now(),
		}},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// CountBySegment aggregates profiles for a restaurant and returns a map of
// segment-name → customer count.
func (r *CustomerProfileRepository) CountBySegment(ctx context.Context, restaurantID string) (map[string]int64, error) {
	pipeline := []bson.M{
		{"$match": bson.M{"restaurantId": restaurantID}},
		{
			"$group": bson.M{
				"_id":   "$segment",
				"count": bson.M{"$sum": 1},
			},
		},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []struct {
		Segment string `bson:"_id"`
		Count   int64  `bson:"count"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	counts := make(map[string]int64, len(results))
	for _, res := range results {
		counts[res.Segment] = res.Count
	}
	return counts, nil
}

// GetCustomerGrowth returns a day-by-day breakdown of new customer registrations for a
// restaurant within [from, to], including a running cumulative total.
func (r *CustomerProfileRepository) GetCustomerGrowth(ctx context.Context, restaurantID string, from, to time.Time) ([]domain.DailyGrowthPoint, error) {
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"restaurantId": restaurantID,
				"createdAt":    bson.M{"$gte": from, "$lte": to},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateToString": bson.M{
						"format": "%Y-%m-%d",
						"date":   "$createdAt",
					},
				},
				"newCount": bson.M{"$sum": 1},
			},
		},
		{"$sort": bson.M{"_id": 1}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []struct {
		Date     string `bson:"_id"`
		NewCount int    `bson:"newCount"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	// Build growth points with a running cumulative total
	var runningTotal int64
	growth := make([]domain.DailyGrowthPoint, len(results))
	for i, res := range results {
		runningTotal += int64(res.NewCount)
		growth[i] = domain.DailyGrowthPoint{
			Date:       res.Date,
			NewCount:   res.NewCount,
			TotalCount: runningTotal,
		}
	}
	return growth, nil
}

// buildBaseMatch constructs the bson.M filter from profile-level CustomerProfileFilter fields.
func (r *CustomerProfileRepository) buildBaseMatch(filter domain.CustomerProfileFilter) bson.M {
	query := bson.M{}
	if filter.RestaurantID != "" {
		query["restaurantId"] = filter.RestaurantID
	}
	if filter.Segment != "" {
		query["segment"] = filter.Segment
	}
	if filter.LoyaltyTier != "" {
		query["loyaltyTier"] = filter.LoyaltyTier
	}
	if filter.Tag != "" {
		query["tags"] = bson.M{"$in": []string{filter.Tag}}
	}
	return query
}

// resolveSortField maps human-readable sort keys to MongoDB document field names.
func (r *CustomerProfileRepository) resolveSortField(sortBy string) string {
	switch sortBy {
	case "total_visits":
		return "totalVisits"
	case "last_visit":
		return "lastVisitAt"
	case "total_orders":
		return "totalOrders"
	case "loyalty_points":
		return "loyaltyPoints"
	case "created_at":
		return "createdAt"
	default:
		return "totalSpent"
	}
}
