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

// TableSessionRepository is the MongoDB-backed implementation of domain.ITableSessionRepository.
type TableSessionRepository struct {
	DB         mongo.Database
	Collection string
}

// NewTableSessionRepository constructs a TableSessionRepository and returns it as the
// domain interface so callers are decoupled from the concrete type.
func NewTableSessionRepository(db mongo.Database, collection string) domain.ITableSessionRepository {
	return &TableSessionRepository{DB: db, Collection: collection}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// Create persists a new session document and writes the Mongo-generated ID back
// into the domain object.
func (r *TableSessionRepository) Create(ctx context.Context, session *domain.TableSession) error {
	model := mapper.TableSessionFromDomain(session)
	if model == nil {
		return fmt.Errorf("nil session provided")
	}

	now := time.Now()
	model.CreatedAt = now
	model.UpdatedAt = now
	if model.StartedAt.IsZero() {
		model.StartedAt = now
	}

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("failed to convert inserted ID to ObjectID, got type: %T", res.InsertedID)
	}
	session.ID = oid.Hex()
	return nil
}

// Update replaces the mutable fields of an existing session.
func (r *TableSessionRepository) Update(ctx context.Context, session *domain.TableSession) error {
	oid, err := bson.ObjectIDFromHex(session.ID)
	if err != nil {
		return domain.ErrInvalidInput
	}

	set := bson.M{
		"waiterId":      session.WaiterID,
		"waiterName":    session.WaiterName,
		"customerId":    session.CustomerID,
		"customerName":  session.CustomerName,
		"customerPhone": session.CustomerPhone,
		"customerEmail": session.CustomerEmail,
		"guestCount":    session.GuestCount,
		"status":        string(session.Status),
		"orderIds":      session.OrderIDs,
		"totalOrders":   session.TotalOrders,
		"totalSpent":    session.TotalSpent,
		"currency":      session.Currency,
		"notes":         session.Notes,
		"updatedAt":     time.Now(),
	}
	if session.EndedAt != nil {
		set["endedAt"] = session.EndedAt
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

// UpdateStatus changes only the status field (and sets endedAt when closing).
func (r *TableSessionRepository) UpdateStatus(ctx context.Context, id string, status domain.TableSessionStatus) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}

	set := bson.M{
		"status":    string(status),
		"updatedAt": time.Now(),
	}
	if status == domain.TableSessionCompleted || status == domain.TableSessionAbandoned {
		now := time.Now()
		set["endedAt"] = now
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
// Read operations
// ---------------------------------------------------------------------------

// GetByID fetches a single session by its MongoDB ObjectID hex string.
func (r *TableSessionRepository) GetByID(ctx context.Context, id string) (*domain.TableSession, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}

	var model mapper.TableSessionModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.TableSessionToDomain(&model), nil
}

// List returns a paginated, reverse-chronological list of sessions for a restaurant.
func (r *TableSessionRepository) List(ctx context.Context, restaurantID string, page, pageSize int) ([]*domain.TableSession, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := bson.M{"restaurantId": restaurantID}
	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		filter,
		mongo_options.Find().
			SetSkip(skip).
			SetLimit(limit).
			SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.TableSessionModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.TableSessionToDomainList(models), total, nil
}

// GetActiveByTable returns the single active (ACTIVE status) session for a
// specific table in a restaurant, or domain.ErrNotFound if none exists.
func (r *TableSessionRepository) GetActiveByTable(ctx context.Context, restaurantID, tableNumber string) (*domain.TableSession, error) {
	var model mapper.TableSessionModel
	err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{
		"restaurantId": restaurantID,
		"tableNumber":  tableNumber,
		"status":       string(domain.TableSessionActive),
	}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.TableSessionToDomain(&model), nil
}

// GetByCustomer returns a paginated list of sessions linked to a registered customer.
func (r *TableSessionRepository) GetByCustomer(ctx context.Context, customerID string, page, pageSize int) ([]*domain.TableSession, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := bson.M{"customerId": customerID}
	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		filter,
		mongo_options.Find().
			SetSkip(skip).
			SetLimit(limit).
			SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.TableSessionModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.TableSessionToDomainList(models), total, nil
}

// GetActiveByWaiter returns all currently active sessions assigned to a waiter.
func (r *TableSessionRepository) GetActiveByWaiter(ctx context.Context, waiterID string) ([]*domain.TableSession, error) {
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{
			"waiterId": waiterID,
			"status":   string(domain.TableSessionActive),
		},
		mongo_options.Find().SetSort(bson.M{"startedAt": 1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.TableSessionModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}

	return mapper.TableSessionToDomainList(models), nil
}
