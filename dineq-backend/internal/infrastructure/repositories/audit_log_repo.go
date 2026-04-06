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

// AuditLogRepository is the MongoDB-backed implementation of domain.IAuditLogRepository.
// Audit logs are append-only: there are no Update or Delete operations.
type AuditLogRepository struct {
	DB         mongo.Database
	Collection string
}

// NewAuditLogRepository constructs an AuditLogRepository and returns it as the
// domain interface so callers are decoupled from the concrete type.
func NewAuditLogRepository(db mongo.Database, collection string) domain.IAuditLogRepository {
	return &AuditLogRepository{DB: db, Collection: collection}
}

// ---------------------------------------------------------------------------
// Write
// ---------------------------------------------------------------------------

// Create persists a new audit-log entry and writes the MongoDB-generated ObjectID
// back into the domain struct's ID field.
func (r *AuditLogRepository) Create(ctx context.Context, log *domain.AuditLog) error {
	model := mapper.AuditLogFromDomain(log)
	if model == nil {
		return fmt.Errorf("audit_log_repo: nil log provided")
	}

	if model.CreatedAt.IsZero() {
		model.CreatedAt = time.Now()
	}

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("audit_log_repo: unexpected inserted ID type %T", res.InsertedID)
	}
	log.ID = oid.Hex()
	return nil
}

// ---------------------------------------------------------------------------
// Read
// ---------------------------------------------------------------------------

// List returns a paginated, reverse-chronological slice of audit-log entries
// matching the supplied filter. Passing an empty filter returns all entries.
func (r *AuditLogRepository) List(ctx context.Context, filter domain.AuditLogFilter) ([]*domain.AuditLog, int64, error) {
	query := r.buildQuery(filter)

	page := filter.Page
	pageSize := filter.PageSize
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 50
	}
	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

	// Count first so callers can build pagination metadata.
	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, query)
	if err != nil {
		return nil, 0, err
	}

	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		query,
		mongo_options.Find().
			SetSkip(skip).
			SetLimit(limit).
			SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, 0, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.AuditLogModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.AuditLogToDomainList(models), total, nil
}

// GetByEntityID returns all audit-log entries associated with the given entityID,
// ordered from most recent to oldest.
func (r *AuditLogRepository) GetByEntityID(ctx context.Context, entityID string) ([]*domain.AuditLog, error) {
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{"entityId": entityID},
		mongo_options.Find().SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.AuditLogModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}

	return mapper.AuditLogToDomainList(models), nil
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// buildQuery constructs a bson.M filter from the supplied AuditLogFilter,
// only adding non-zero fields to the query so that empty filters match everything.
func (r *AuditLogRepository) buildQuery(filter domain.AuditLogFilter) bson.M {
	query := bson.M{}

	if filter.ActorID != "" {
		query["actorId"] = filter.ActorID
	}
	if filter.EntityType != "" {
		query["entityType"] = filter.EntityType
	}
	if filter.EntityID != "" {
		query["entityId"] = filter.EntityID
	}
	if filter.Action != "" {
		query["action"] = filter.Action
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

	return query
}
