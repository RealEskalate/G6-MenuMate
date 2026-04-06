package repositories

import (
	"context"
	"fmt"
	"sort"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	mongo_options "go.mongodb.org/mongo-driver/v2/mongo/options"
)

// WaiterLogRepository handles persistence for WaiterLog documents.
type WaiterLogRepository struct {
	DB         mongo.Database
	Collection string
}

// NewWaiterLogRepository constructs a WaiterLogRepository and returns it as the
// domain interface so callers are decoupled from the concrete type.
func NewWaiterLogRepository(db mongo.Database, collection string) domain.IWaiterLogRepository {
	return &WaiterLogRepository{DB: db, Collection: collection}
}

// ---------------------------------------------------------------------------
// CRUD
// ---------------------------------------------------------------------------

func (r *WaiterLogRepository) Create(ctx context.Context, log *domain.WaiterLog) error {
	model := mapper.WaiterLogFromDomain(log)
	model.CreatedAt = time.Now()
	model.UpdatedAt = time.Now()

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("waiter_log_repo: failed to cast inserted ID to ObjectID, got %T", res.InsertedID)
	}
	log.ID = oid.Hex()
	return nil
}

func (r *WaiterLogRepository) GetByID(ctx context.Context, id string) (*domain.WaiterLog, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}

	var model mapper.WaiterLogModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.WaiterLogToDomain(&model), nil
}

func (r *WaiterLogRepository) Update(ctx context.Context, log *domain.WaiterLog) error {
	oid, err := bson.ObjectIDFromHex(log.ID)
	if err != nil {
		return domain.ErrInvalidInput
	}

	model := mapper.WaiterLogFromDomain(log)
	model.UpdatedAt = time.Now()

	set := bson.M{
		"observations":        model.Observations,
		"customerMood":        model.CustomerMood,
		"serviceRating":       model.ServiceRating,
		"willLikelyReturn":    model.WillLikelyReturn,
		"tableDuration":       model.TableDuration,
		"totalCoversCount":    model.TotalCoversCount,
		"isComplimentary":     model.IsComplimentary,
		"complimentaryReason": model.ComplimentaryReason,
		"upsellAttempted":     model.UpsellAttempted,
		"upsellSucceeded":     model.UpsellSucceeded,
		"notes":               model.Notes,
		"updatedAt":           model.UpdatedAt,
	}

	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid},
		bson.M{"$set": set},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// ---------------------------------------------------------------------------
// Query helpers
// ---------------------------------------------------------------------------

func (r *WaiterLogRepository) List(ctx context.Context, filter domain.WaiterLogFilter) ([]*domain.WaiterLog, int64, error) {
	query := bson.M{}

	if filter.RestaurantID != "" {
		query["restaurantId"] = filter.RestaurantID
	}
	if filter.WaiterID != "" {
		query["waiterId"] = filter.WaiterID
	}
	if filter.OrderID != "" {
		query["orderId"] = filter.OrderID
	}
	if filter.CustomerMood != "" {
		query["customerMood"] = filter.CustomerMood
	}
	if filter.DateFrom != nil || filter.DateTo != nil {
		dateFilter := bson.M{}
		if filter.DateFrom != nil {
			dateFilter["$gte"] = *filter.DateFrom
		}
		if filter.DateTo != nil {
			dateFilter["$lte"] = *filter.DateTo
		}
		query["createdAt"] = dateFilter
	}

	page := filter.Page
	pageSize := filter.PageSize
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}
	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, query)
	if err != nil {
		return nil, 0, err
	}

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		query,
		mongo_options.Find().SetSkip(skip).SetLimit(limit).SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.WaiterLogModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.WaiterLogToDomainList(models), total, nil
}

func (r *WaiterLogRepository) GetByOrderID(ctx context.Context, orderID string) (*domain.WaiterLog, error) {
	var model mapper.WaiterLogModel
	err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"orderId": orderID}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.WaiterLogToDomain(&model), nil
}

// ---------------------------------------------------------------------------
// Analytics – food consumption
// ---------------------------------------------------------------------------

// GetFoodConsumptionStats returns per-item consumption statistics for a given
// restaurant and time window by unwinding the observations sub-array and
// grouping the results.
func (r *WaiterLogRepository) GetFoodConsumptionStats(
	ctx context.Context,
	restaurantID string,
	from, to time.Time,
) ([]domain.FoodItemConsumptionStats, error) {

	pipeline := []bson.M{
		// Stage 1 – filter logs
		{"$match": bson.M{
			"restaurantId": restaurantID,
			"createdAt":    bson.M{"$gte": from, "$lte": to},
		}},
		// Stage 2 – flatten observations
		{"$unwind": "$observations"},
		// Stage 3 – group per item
		{"$group": bson.M{
			"_id":         "$observations.itemId",
			"itemName":    bson.M{"$first": "$observations.itemName"},
			"totalServed": bson.M{"$sum": 1},
			"completeCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$observations.consumptionStatus", string(domain.ConsumptionComplete)}},
					1, 0,
				},
			}},
			"partialCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$observations.consumptionStatus", string(domain.ConsumptionPartial)}},
					1, 0,
				},
			}},
			"notEatenCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$observations.consumptionStatus", string(domain.ConsumptionNotEaten)}},
					1, 0,
				},
			}},
			"returnedCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$observations.consumptionStatus", string(domain.ConsumptionReturned)}},
					1, 0,
				},
			}},
			"avgLeftoverPct": bson.M{"$avg": "$observations.leftoverPercentage"},
			"reasons":        bson.M{"$push": "$observations.reason"},
		}},
		// Stage 4 – sort by most served
		{"$sort": bson.M{"totalServed": -1}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	type rawStat struct {
		ID             string   `bson:"_id"`
		ItemName       string   `bson:"itemName"`
		TotalServed    int      `bson:"totalServed"`
		CompleteCount  int      `bson:"completeCount"`
		PartialCount   int      `bson:"partialCount"`
		NotEatenCount  int      `bson:"notEatenCount"`
		ReturnedCount  int      `bson:"returnedCount"`
		AvgLeftoverPct float64  `bson:"avgLeftoverPct"`
		Reasons        []string `bson:"reasons"`
	}

	var raws []rawStat
	if err := cursor.All(ctx, &raws); err != nil {
		return nil, err
	}

	stats := make([]domain.FoodItemConsumptionStats, 0, len(raws))
	for _, raw := range raws {
		satisfactionScore := 0.0
		if raw.TotalServed > 0 {
			// Score 0-5: complete=1pt, partial=0.5pt
			score := float64(raw.CompleteCount) + 0.5*float64(raw.PartialCount)
			satisfactionScore = (score / float64(raw.TotalServed)) * 5.0
		}

		stats = append(stats, domain.FoodItemConsumptionStats{
			ItemID:            raw.ID,
			ItemName:          raw.ItemName,
			TotalServed:       raw.TotalServed,
			CompleteCount:     raw.CompleteCount,
			PartialCount:      raw.PartialCount,
			NotEatenCount:     raw.NotEatenCount,
			ReturnedCount:     raw.ReturnedCount,
			AvgLeftoverPct:    raw.AvgLeftoverPct,
			SatisfactionScore: satisfactionScore,
			TopReasons:        topReasons(raw.Reasons, 3),
		})
	}
	return stats, nil
}

// ---------------------------------------------------------------------------
// Analytics – customer mood
// ---------------------------------------------------------------------------

// GetCustomerMoodStats aggregates customer mood observations for a restaurant
// over the supplied period and returns a frequency map keyed by mood string.
func (r *WaiterLogRepository) GetCustomerMoodStats(
	ctx context.Context,
	restaurantID string,
	from, to time.Time,
) (map[string]int, error) {

	pipeline := []bson.M{
		{"$match": bson.M{
			"restaurantId": restaurantID,
			"createdAt":    bson.M{"$gte": from, "$lte": to},
			"customerMood": bson.M{"$ne": ""},
		}},
		{"$group": bson.M{
			"_id":   "$customerMood",
			"count": bson.M{"$sum": 1},
		}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []struct {
		Mood  string `bson:"_id"`
		Count int    `bson:"count"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	moodMap := make(map[string]int, len(results))
	for _, res := range results {
		moodMap[res.Mood] = res.Count
	}
	return moodMap, nil
}

// ---------------------------------------------------------------------------
// Analytics – waiter performance
// ---------------------------------------------------------------------------

// GetWaiterPerformance aggregates WaiterLog documents for a single waiter over
// the supplied time window and derives a WaiterPerformanceStats summary.
func (r *WaiterLogRepository) GetWaiterPerformance(
	ctx context.Context,
	waiterID string,
	from, to time.Time,
) (*domain.WaiterPerformanceStats, error) {

	pipeline := []bson.M{
		// Stage 1 – filter by waiter and date
		{"$match": bson.M{
			"waiterId":  waiterID,
			"createdAt": bson.M{"$gte": from, "$lte": to},
		}},
		// Stage 2 – group all logs for this waiter
		{"$group": bson.M{
			"_id":        "$waiterId",
			"waiterName": bson.M{"$first": "$waiterName"},
			"totalLogs":  bson.M{"$sum": 1},
			// Collect unique session IDs for TotalSessions
			"sessionIds": bson.M{"$addToSet": "$sessionId"},
			// Collect unique order IDs for TotalOrders
			"orderIds": bson.M{"$addToSet": "$orderId"},
			// Service quality metrics
			"avgServiceRating": bson.M{"$avg": "$serviceRating"},
			"happyCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$customerMood", string(domain.MoodHappy)}},
					1, 0,
				},
			}},
			"upsellAttemptCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{"$upsellAttempted", 1, 0},
			}},
			"upsellSuccessCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{"$upsellSucceeded", 1, 0},
			}},
			"avgTableDuration": bson.M{"$avg": "$tableDuration"},
			"returnCount": bson.M{"$sum": bson.M{
				"$cond": []interface{}{"$willLikelyReturn", 1, 0},
			}},
		}},
		// Stage 3 – compute derived percentage fields
		{"$addFields": bson.M{
			"totalSessions": bson.M{"$size": "$sessionIds"},
			"totalOrders":   bson.M{"$size": "$orderIds"},
			"happyCustomerPct": bson.M{"$multiply": []interface{}{
				bson.M{"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$totalLogs", 0}},
					0,
					bson.M{"$divide": []interface{}{"$happyCount", "$totalLogs"}},
				}},
				100,
			}},
			"upsellSuccessRate": bson.M{"$multiply": []interface{}{
				bson.M{"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$upsellAttemptCount", 0}},
					0,
					bson.M{"$divide": []interface{}{"$upsellSuccessCount", "$upsellAttemptCount"}},
				}},
				100,
			}},
			"returnLikelihood": bson.M{"$multiply": []interface{}{
				bson.M{"$cond": []interface{}{
					bson.M{"$eq": []interface{}{"$totalLogs", 0}},
					0,
					bson.M{"$divide": []interface{}{"$returnCount", "$totalLogs"}},
				}},
				100,
			}},
		}},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	type rawPerf struct {
		WaiterName        string  `bson:"waiterName"`
		TotalSessions     int     `bson:"totalSessions"`
		TotalOrders       int     `bson:"totalOrders"`
		AvgServiceRating  float64 `bson:"avgServiceRating"`
		HappyCustomerPct  float64 `bson:"happyCustomerPct"`
		UpsellSuccessRate float64 `bson:"upsellSuccessRate"`
		AvgTableDuration  float64 `bson:"avgTableDuration"`
		ReturnLikelihood  float64 `bson:"returnLikelihood"`
	}

	var raw rawPerf
	if cursor.Next(ctx) {
		if err := cursor.Decode(&raw); err != nil {
			return nil, err
		}
	} else {
		// No logs found – return a zero-value stats record
		return &domain.WaiterPerformanceStats{WaiterID: waiterID}, nil
	}

	return &domain.WaiterPerformanceStats{
		WaiterID:          waiterID,
		WaiterName:        raw.WaiterName,
		TotalSessions:     raw.TotalSessions,
		TotalOrders:       raw.TotalOrders,
		AvgServiceRating:  raw.AvgServiceRating,
		HappyCustomerPct:  raw.HappyCustomerPct,
		UpsellSuccessRate: raw.UpsellSuccessRate,
		AvgTableDuration:  raw.AvgTableDuration,
		ReturnLikelihood:  raw.ReturnLikelihood,
	}, nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// topReasons returns the top-n most frequently occurring non-empty reason
// strings from the supplied slice.
func topReasons(reasons []string, n int) []string {
	freq := make(map[string]int)
	for _, r := range reasons {
		if r != "" {
			freq[r]++
		}
	}
	if len(freq) == 0 {
		return nil
	}

	type kv struct {
		Key   string
		Count int
	}
	pairs := make([]kv, 0, len(freq))
	for k, v := range freq {
		pairs = append(pairs, kv{k, v})
	}
	sort.Slice(pairs, func(i, j int) bool { return pairs[i].Count > pairs[j].Count })

	top := make([]string, 0, n)
	for i, p := range pairs {
		if i >= n {
			break
		}
		top = append(top, p.Key)
	}
	return top
}
