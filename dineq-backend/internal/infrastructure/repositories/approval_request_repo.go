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

// ApprovalRequestRepository is the MongoDB-backed implementation of
// domain.IApprovalRequestRepository.
type ApprovalRequestRepository struct {
	DB         mongo.Database
	Collection string
}

// NewApprovalRequestRepository constructs an ApprovalRequestRepository and returns it
// typed as the domain interface so callers are decoupled from the concrete type.
func NewApprovalRequestRepository(db mongo.Database, collection string) domain.IApprovalRequestRepository {
	return &ApprovalRequestRepository{DB: db, Collection: collection}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// Create inserts a new ApprovalRequest document and writes the MongoDB-generated
// ObjectID back into the domain struct.
func (r *ApprovalRequestRepository) Create(ctx context.Context, request *domain.ApprovalRequest) error {
	model := mapper.ApprovalRequestFromDomain(request)
	if model == nil {
		return fmt.Errorf("approval_request_repo: nil request provided")
	}

	now := time.Now()
	if model.CreatedAt.IsZero() {
		model.CreatedAt = now
	}

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("approval_request_repo: unexpected inserted ID type %T", res.InsertedID)
	}
	request.ID = oid.Hex()
	return nil
}

// UpdateStatus changes the status of an approval request and records who reviewed it.
// The id parameter must be a valid hex-encoded ObjectID string.
func (r *ApprovalRequestRepository) UpdateStatus(ctx context.Context, id, status string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}

	now := time.Now()
	set := bson.M{
		"status":     status,
		"reviewedAt": now,
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

// Delete performs a hard delete of the approval request identified by id.
func (r *ApprovalRequestRepository) Delete(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}

	deleted, err := r.DB.Collection(r.Collection).DeleteOne(ctx, bson.M{"_id": oid})
	if err != nil {
		return err
	}
	if deleted == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// ---------------------------------------------------------------------------
// Read operations
// ---------------------------------------------------------------------------

// GetByID fetches a single approval request by its ObjectID hex string.
func (r *ApprovalRequestRepository) GetByID(ctx context.Context, id string) (*domain.ApprovalRequest, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}

	var model mapper.ApprovalRequestModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.ApprovalRequestToDomain(&model), nil
}

// List returns a paginated slice of approval requests. When status is non-empty only
// requests matching that status value are returned; pass an empty string to retrieve
// all requests regardless of status.
func (r *ApprovalRequestRepository) List(ctx context.Context, page, pageSize int, status string) ([]*domain.ApprovalRequest, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := bson.M{}
	if status != "" {
		filter["status"] = status
	}

	total, err := r.DB.Collection(r.Collection).CountDocuments(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	skip := int64((page - 1) * pageSize)
	limit := int64(pageSize)

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

	var models []*mapper.ApprovalRequestModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, 0, err
	}

	return mapper.ApprovalRequestToDomainList(models), total, nil
}

// GetByEntityID returns the most recent approval request associated with the given
// entity ID (e.g. a restaurant's ObjectID hex string), or domain.ErrNotFound when
// no such request exists.
func (r *ApprovalRequestRepository) GetByEntityID(ctx context.Context, entityID string) (*domain.ApprovalRequest, error) {
	// FindOne does not support sort options in the Collection interface, so we use
	// Find with a limit of 1 and a descending sort on createdAt to get the latest.
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{"entityId": entityID},
		mongo_options.Find().SetSort(bson.M{"createdAt": -1}).SetLimit(1),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.ApprovalRequestModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}
	if len(models) == 0 {
		return nil, domain.ErrNotFound
	}
	return mapper.ApprovalRequestToDomain(models[0]), nil
}
