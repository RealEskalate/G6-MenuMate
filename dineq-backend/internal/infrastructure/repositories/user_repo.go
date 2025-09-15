package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type UserRepository struct {
	DB         mongo.Database
	Collection string
}

func NewUserRepository(db mongo.Database, collection string) domain.IUserRepository {
	repo := &UserRepository{
		DB:         db,
		Collection: collection,
	}
	repo.createTTLIndex(context.Background())
	return repo
}
func (repo *UserRepository) createTTLIndex(ctx context.Context) {
	indexModel := mongo.IndexModel{
		Keys:    bson.M{"deletedAt": 1},
		Options: options.Index().SetExpireAfterSeconds(0),
	}
	_, err := repo.DB.Collection(repo.Collection).Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		fmt.Printf("Failed to create TTL index: %v\n", err)
	}
}

func (repo *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	userModel := mapper.UserFromDomain(user)
	res, err := repo.DB.Collection(repo.Collection).InsertOne(ctx, userModel)
	if err != nil {
		return err
	}

	if oid, ok := res.InsertedID.(bson.ObjectID); ok {
		user.ID = oid.Hex()
	}
	return nil
}

func (repo *UserRepository) GetAllUsers(ctx context.Context) ([]*domain.User, error) {
	var models []*mapper.UserModel

	cur, err := repo.DB.Collection(repo.Collection).Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cur.Close(ctx)

	for cur.Next(ctx) {
		var m mapper.UserModel
		if err := cur.Decode(&m); err != nil {
			return nil, err
		}
		models = append(models, &m)
	}
	if err := cur.Err(); err != nil {
		return nil, err
	}

	return mapper.UserToDomainList(models), nil
}

func (repo *UserRepository) UpdateUser(ctx context.Context, id string, user *domain.User) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	// Build a minimal $set map to avoid overwriting unspecified fields with zero-values
	set := bson.M{}
	if user.Email != "" {
		set["email"] = user.Email
	}
	if user.PhoneNumber != "" {
		set["phoneNumber"] = user.PhoneNumber
	}
	if user.Username != "" {
		set["username"] = user.Username
	}
	if user.Password != "" {
		set["passwordHash"] = user.Password
	}
	if user.AuthProvider != "" {
		set["authProvider"] = string(user.AuthProvider)
	}
	set["isVerified"] = user.IsVerified
	if user.FullName != "" {
		set["fullName"] = user.FullName
	}
	if user.FirstName != "" {
		set["firstName"] = user.FirstName
	}
	if user.LastName != "" {
		set["lastName"] = user.LastName
	}
	if user.ProfileImage != "" {
		set["profileImage"] = user.ProfileImage
	}
	if user.Role != "" {
		set["role"] = string(user.Role)
	}
	if user.Status != "" {
		set["status"] = string(user.Status)
	}
	if user.Preferences != nil {
		set["preferences"] = user.Preferences
	}
	set["updatedAt"] = time.Now()
	res, err := repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": oid}, bson.M{"$set": set})
	if err != nil {
		return err
	}
	_ = res
	return nil
}

func (repo *UserRepository) FindUserByID(ctx context.Context, id string) (*domain.User, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var model mapper.UserModel
	err = repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"_id": oid}).Decode(&model)
	if err != nil {
		return nil, err
	}
	return mapper.UserToDomain(&model), nil
}

func (repo *UserRepository) GetUserByUsername(ctx context.Context, username string) (*domain.User, error) {
	var model mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{
		"username": bson.M{"$regex": username, "$options": "i"},
	}).Decode(&model)
	if err != nil {
		return nil, err
	}
	return mapper.UserToDomain(&model), nil
}

func (repo *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	var model mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{
		"email": bson.M{"$regex": email, "$options": "i"},
	}).Decode(&model)
	if err != nil {
		return nil, err
	}
	return mapper.UserToDomain(&model), nil
}

func (repo *UserRepository) GetUserByPhone(ctx context.Context, phone string) (*domain.User, error) {
	var model mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"phone_number": phone}).Decode(&model)
	if err != nil {
		return nil, err
	}
	return mapper.UserToDomain(&model), nil
}

// ExistsAny checks if any user exists matching provided non-empty username/email/phone (case-insensitive for username/email).
func (repo *UserRepository) ExistsAny(ctx context.Context, username, email, phone string) (bool, error) {
	var or []bson.M
	if username != "" {
		or = append(or, bson.M{"username": bson.M{"$regex": username, "$options": "i"}})
	}
	if email != "" {
		or = append(or, bson.M{"email": bson.M{"$regex": email, "$options": "i"}})
	}
	if phone != "" {
		or = append(or, bson.M{"phone_number": phone})
	}
	if len(or) == 0 {
		return false, nil
	}
	filter := bson.M{"$or": or}
	// Use CountDocuments with limit via options? Driver v2 lacks Direct limit param; fallback to FindOne
	var tmp mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, filter).Decode(&tmp)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (repo *UserRepository) FindByUsernameOrEmail(ctx context.Context, key string) (domain.User, error) {
	var model mapper.UserModel
	filter := bson.M{"$or": []bson.M{
		{"username": key},
		{"email": key},
		{"phone_number": key},
	}}
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, filter).Decode(&model)
	if err != nil {
		return domain.User{}, err
	}
	return *mapper.UserToDomain(&model), nil
}

func (repo *UserRepository) AssignRole(ctx context.Context, branchID, targetUserID string, role domain.UserRole) error {
	oid, err := bson.ObjectIDFromHex(targetUserID)
	if err != nil {
		return err
	}
	_, err = repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": oid}, bson.M{
		"$set": bson.M{
			"role":      string(role),
			"updatedAt": time.Now(),
			"branchId":  branchID,
		},
	})
	return err
}

func (repo *UserRepository) SaveFCMToken(userID string, token string) error {
	oid, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return err
	}
	_, err = repo.DB.Collection(repo.Collection).UpdateOne(context.Background(), bson.M{"_id": oid}, bson.M{
		"$set": bson.M{
			"fcmToken":  token,
			"updatedAt": time.Now(),
		},
	})
	return err
}

func (repo *UserRepository) GetFCMToken(userID string) (string, error) {
	oid, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return "", err
	}
	var result struct {
		FCMToken string `bson:"fcmToken"`
	}
	err = repo.DB.Collection(repo.Collection).FindOne(context.Background(), bson.M{"_id": oid}).Decode(&result)
	if err != nil {
		return "", err
	}
	return result.FCMToken, nil
}

// ChangeRole implements role change with branch context (branch argument names match interface order: userID, branchID, role)
func (repo *UserRepository) ChangeRole(ctx context.Context, userID, branchID, role string) error {
	oid, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return err
	}
	_, err = repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": oid}, bson.M{"$set": bson.M{
		"role":      role,
		"branchId":  branchID,
		"updatedAt": time.Now(),
	}})
	return err
}
