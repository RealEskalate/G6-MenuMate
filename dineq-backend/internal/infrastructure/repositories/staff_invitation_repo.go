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

// StaffInvitationRepository implements domain.IStaffInvitationRepository backed by MongoDB.
// It holds two collection names: one for invitations, and one for users (needed by
// GetStaffByRestaurant to perform a cross-collection lookup).
type StaffInvitationRepository struct {
	DB              mongo.Database
	Collection      string // invitations collection
	UsersCollection string // users collection
}

// NewStaffInvitationRepository constructs a StaffInvitationRepository and returns it as
// the domain interface so callers depend only on the abstraction.
func NewStaffInvitationRepository(
	db mongo.Database,
	collection string,
	usersCollection string,
) domain.IStaffInvitationRepository {
	return &StaffInvitationRepository{
		DB:              db,
		Collection:      collection,
		UsersCollection: usersCollection,
	}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// Create persists a new StaffInvitation document and writes the MongoDB-generated
// ObjectID back into the domain struct.
func (r *StaffInvitationRepository) Create(ctx context.Context, inv *domain.StaffInvitation) error {
	model := mapper.StaffInvitationFromDomain(inv)
	if model == nil {
		return fmt.Errorf("staff_invitation_repo: nil invitation provided")
	}

	now := time.Now()
	model.CreatedAt = now
	model.UpdatedAt = now

	res, err := r.DB.Collection(r.Collection).InsertOne(ctx, model)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(bson.ObjectID)
	if !ok {
		return fmt.Errorf("staff_invitation_repo: unexpected inserted ID type %T", res.InsertedID)
	}
	inv.ID = oid.Hex()
	return nil
}

// UpdateStatus updates the status (and sets AcceptedAt when transitioning to
// InvitationAccepted) of the invitation identified by id.
func (r *StaffInvitationRepository) UpdateStatus(ctx context.Context, id string, status domain.InvitationStatus) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return domain.ErrInvalidInput
	}

	set := bson.M{
		"status":    string(status),
		"updatedAt": time.Now(),
	}
	if status == domain.InvitationAccepted {
		now := time.Now()
		set["acceptedAt"] = now
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

// Delete hard-deletes an invitation document by its ObjectID.
func (r *StaffInvitationRepository) Delete(ctx context.Context, id string) error {
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

// GetByID fetches a single StaffInvitation by its ObjectID hex string.
func (r *StaffInvitationRepository) GetByID(ctx context.Context, id string) (*domain.StaffInvitation, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, domain.ErrInvalidInput
	}

	var model mapper.StaffInvitationModel
	err = r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.StaffInvitationToDomain(&model), nil
}

// GetByToken looks up an invitation by its unique, one-time token string.
// Returns domain.ErrNotFound when no matching document exists.
func (r *StaffInvitationRepository) GetByToken(ctx context.Context, token string) (*domain.StaffInvitation, error) {
	if token == "" {
		return nil, domain.ErrInvalidInput
	}

	var model mapper.StaffInvitationModel
	err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"token": token}).Decode(&model)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrNotFound
		}
		return nil, err
	}
	return mapper.StaffInvitationToDomain(&model), nil
}

// GetByRestaurant returns all invitations (in any status) for the given restaurant,
// ordered most-recent first.
func (r *StaffInvitationRepository) GetByRestaurant(ctx context.Context, restaurantID string) ([]*domain.StaffInvitation, error) {
	cursor, err := r.DB.Collection(r.Collection).Find(
		ctx,
		bson.M{"restaurantId": restaurantID},
		mongo_options.Find().SetSort(bson.M{"createdAt": -1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.StaffInvitationModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}

	return mapper.StaffInvitationToDomainList(models), nil
}

// ---------------------------------------------------------------------------
// Cross-collection staff lookup
// ---------------------------------------------------------------------------

// GetStaffByRestaurant returns all User documents whose branchId matches
// restaurantID and whose role matches the supplied role string.
//
// When role is empty every staff member (regardless of role) assigned to the
// restaurant is returned.
//
// This method queries the users collection directly; the StaffInvitationRepository
// is given the users collection name at construction time for exactly this purpose.
func (r *StaffInvitationRepository) GetStaffByRestaurant(
	ctx context.Context,
	restaurantID string,
	role string,
) ([]*domain.User, error) {

	filter := bson.M{
		"branchId":  restaurantID,
		"isDeleted": false,
	}
	if role != "" {
		filter["role"] = role
	}

	cursor, err := r.DB.Collection(r.UsersCollection).Find(
		ctx,
		filter,
		mongo_options.Find().SetSort(bson.M{"firstName": 1}),
	)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var models []*mapper.UserModel
	if err := cursor.All(ctx, &models); err != nil {
		return nil, err
	}

	users := make([]*domain.User, 0, len(models))
	for _, m := range models {
		users = append(users, mapper.UserToDomain(m))
	}
	return users, nil
}
