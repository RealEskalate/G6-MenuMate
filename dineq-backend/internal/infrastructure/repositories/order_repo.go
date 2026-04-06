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

type OrderRepository struct {
	DB         mongo.Database
	Collection string
}

func NewOrderRepository(db mongo.Database, collection string) domain.IOrderRepository {
	return &OrderRepository{DB: db, Collection: collection}
}

func (r *OrderRepository) Create(ctx context.Context, order *domain.Order) error {
	model := mapper.OrderFromDomain(order)
	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}
	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("order: unexpected inserted ID type %T", res.InsertedID)
	}
	order.ID = oid.Hex()
	return nil
}

func (r *OrderRepository) GetByID(ctx context.Context, id string) (*domain.Order, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}
	var model mapper.OrderModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid, "isDeleted": false}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.OrderToDomain(&model), nil
}

func (r *OrderRepository) Update(ctx context.Context, order *domain.Order) error {
	oid, err := bson.ObjectIDFromHex(order.ID)
	if err != nil {
		return domain.ErrInvalidInput
	}
	model := mapper.OrderFromDomain(order)
	model.UpdatedAt = time.Now()

	set := bson.M{
		"tableNumber":  model.TableNumber,
		"sessionId":    model.SessionID,
		"customerId":   model.CustomerID,
		"customerName": model.CustomerName,
		"waiterId":     model.WaiterID,
		"waiterName":   model.WaiterName,
		"items":        model.Items,
		"status":       model.Status,
		"subTotal":     model.SubTotal,
		"taxAmount":    model.TaxAmount,
		"totalAmount":  model.TotalAmount,
		"currency":     model.Currency,
		"specialNotes": model.SpecialNotes,
		"source":       model.Source,
		"cancelReason": model.CancelReason,
		"updatedAt":    model.UpdatedAt,
	}
	if model.CompletedAt != nil {
		set["completedAt"] = model.CompletedAt
	}
	if model.CancelledAt != nil {
		set["cancelledAt"] = model.CancelledAt
	}

	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid, "isDeleted": false},
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

func (r *OrderRepository) UpdateStatus(ctx context.Context, id string, status domain.OrderStatus) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}

	now := time.Now()
	set := bson.M{
		"status":    string(status),
		"updatedAt": now,
	}
	if status == domain.OrderStatusCompleted {
		set["completedAt"] = now
	} else if status == domain.OrderStatusCancelled {
		set["cancelledAt"] = now
	}

	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid, "isDeleted": false},
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

func (r *OrderRepository) Delete(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}
	res, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"_id": oid, "isDeleted": false},
		bson.M{"$set": bson.M{"isDeleted": true, "updatedAt": time.Now()}},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrNotFound
	}
	return nil
}

func (r *OrderRepository) List(ctx context.Context, filter domain.OrderFilter) ([]*domain.Order, int64, error) {
	query := bson.M{"isDeleted": false}

	if filter.RestaurantID != "" {
		query["restaurantId"] = filter.RestaurantID
	}
	if filter.WaiterID != "" {
		query["waiterId"] = filter.WaiterID
	}
	if filter.CustomerID != "" {
		query["customerId"] = filter.CustomerID
	}
	if filter.Status != "" {
		query["status"] = filter.Status
	}
	if filter.TableNumber != "" {
		query["tableNumber"] = filter.TableNumber
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

	var models []*mapper.OrderModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.OrderListToDomain(models), total, nil
}

func (r *OrderRepository) GetBySessionID(ctx context.Context, sessionID string) ([]*domain.Order, error) {
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{"sessionId": sessionID, "isDeleted": false},
		mongo_options.Find().SetSort(bson.M{"createdAt": 1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.OrderModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}
	return mapper.OrderListToDomain(models), nil
}

func (r *OrderRepository) GetRevenueByRestaurant(ctx context.Context, restaurantID string, from, to time.Time) (float64, error) {
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"restaurantId": restaurantID,
				"isDeleted":    false,
				"status":       bson.M{"$in": []string{string(domain.OrderStatusCompleted), string(domain.OrderStatusServed)}},
				"createdAt":    bson.M{"$gte": from, "$lte": to},
			},
		},
		{
			"$group": bson.M{
				"_id":     nil,
				"revenue": bson.M{"$sum": "$totalAmount"},
			},
		},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return 0, err
	}
	defer cursor.Close(ctx)

	var result struct {
		Revenue float64 `bson:"revenue"`
	}
	if cursor.Next(ctx) {
		if err := cursor.Decode(&result); err != nil {
			return 0, err
		}
	}
	return result.Revenue, nil
}

func (r *OrderRepository) GetOrderCountByRestaurant(ctx context.Context, restaurantID string, from, to time.Time) (int64, error) {
	return r.DB.Collection(r.Collection).CountDocuments(ctx, bson.M{
		"restaurantId": restaurantID,
		"isDeleted":    false,
		"createdAt":    bson.M{"$gte": from, "$lte": to},
	})
}

func (r *OrderRepository) GetTopItemsByRestaurant(ctx context.Context, restaurantID string, limit int) ([]domain.PopularOrderItem, error) {
	if limit <= 0 {
		limit = 10
	}
	pipeline := []bson.M{
		{"$match": bson.M{
			"restaurantId": restaurantID,
			"isDeleted":    false,
			"status":       bson.M{"$ne": string(domain.OrderStatusCancelled)},
		}},
		{"$unwind": "$items"},
		{"$group": bson.M{
			"_id":        "$items.itemId",
			"itemName":   bson.M{"$first": "$items.itemName"},
			"orderCount": bson.M{"$sum": 1},
			"totalQty":   bson.M{"$sum": "$items.quantity"},
			"revenue":    bson.M{"$sum": "$items.totalPrice"},
		}},
		{"$sort": bson.M{"orderCount": -1}},
		{"$limit": int64(limit)},
	}

	cursor, err := r.DB.Collection(r.Collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []struct {
		ID         string  `bson:"_id"`
		ItemName   string  `bson:"itemName"`
		OrderCount int64   `bson:"orderCount"`
		TotalQty   int64   `bson:"totalQty"`
		Revenue    float64 `bson:"revenue"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	items := make([]domain.PopularOrderItem, len(results))
	for i, res := range results {
		items[i] = domain.PopularOrderItem{
			ItemID:     res.ID,
			ItemName:   res.ItemName,
			OrderCount: res.OrderCount,
			TotalQty:   res.TotalQty,
			Revenue:    res.Revenue,
		}
	}
	return items, nil
}

func (r *OrderRepository) GetOrdersByHour(ctx context.Context, restaurantID string, from, to time.Time) ([]domain.HourlyOrderData, error) {
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"restaurantId": restaurantID,
				"isDeleted":    false,
				"createdAt":    bson.M{"$gte": from, "$lte": to},
			},
		},
		{
			"$group": bson.M{
				"_id":        bson.M{"$hour": "$createdAt"},
				"orderCount": bson.M{"$sum": 1},
				"revenue":    bson.M{"$sum": "$totalAmount"},
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
		Hour       int     `bson:"_id"`
		OrderCount int     `bson:"orderCount"`
		Revenue    float64 `bson:"revenue"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	data := make([]domain.HourlyOrderData, len(results))
	for i, res := range results {
		data[i] = domain.HourlyOrderData{
			Hour:       res.Hour,
			OrderCount: res.OrderCount,
			Revenue:    res.Revenue,
		}
	}
	return data, nil
}

func (r *OrderRepository) GetOrdersByDay(ctx context.Context, restaurantID string, from, to time.Time) ([]domain.DailyOrderData, error) {
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"restaurantId": restaurantID,
				"isDeleted":    false,
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
				"orderCount": bson.M{"$sum": 1},
				"revenue":    bson.M{"$sum": "$totalAmount"},
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
		Date       string  `bson:"_id"`
		OrderCount int     `bson:"orderCount"`
		Revenue    float64 `bson:"revenue"`
	}
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	data := make([]domain.DailyOrderData, len(results))
	for i, res := range results {
		data[i] = domain.DailyOrderData{
			Date:       res.Date,
			OrderCount: res.OrderCount,
			Revenue:    res.Revenue,
		}
	}
	return data, nil
}
