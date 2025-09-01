package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserRepository struct {
	DB         mongo.Database
	Collection string
}

func NewUserRepository(db mongo.Database, collection string) domain.IUserRepository {
	return &UserRepository{
		DB:         db,
		Collection: collection,
	}
}

func (repo *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	// user.ID = bson.NewObjectID()
	usermodel := mapper.UserFromDomain(user)
	result, err := repo.DB.Collection(repo.Collection).InsertOne(ctx, usermodel)
	if err != nil {
		return err
	}
	// Set the domain user ID to the generated ObjectID
	if oid, ok := result.InsertedID.(interface{ Hex() string }); ok {
		user.ID = oid.Hex()
	}
	return nil
}

func (repo *UserRepository) GetAllUsers(ctx context.Context) ([]*domain.User, error) {
	var users []*mapper.UserModel
	cursor, err := repo.DB.Collection(repo.Collection).Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	for cursor.Next(ctx) {
		var user *mapper.UserModel
		if err := cursor.Decode(&user); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}

	return mapper.UserToDomainList(users), nil
}

func (repo *UserRepository) UpdateUser(ctx context.Context, id string, user *domain.User) error {
	userModel := mapper.UserFromDomain(user)
	userModel.ID, _ = bson.ObjectIDFromHex(id)
	_, err := repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": userModel.ID}, bson.M{"$set": userModel})
	return err
}

func (repo *UserRepository) FindUserByID(ctx context.Context, id string) (*domain.User, error) {
	uid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID: %v", err)
	}
	var userModel *mapper.UserModel
	err = repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"_id": uid}).Decode(&userModel)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}
	return mapper.UserToDomain(userModel), nil
}

func (repo *UserRepository) GetUserByUsername(ctx context.Context, username string) (*domain.User, error) {
	var userModel *mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"username": bson.M{"$regex": username, "$options": "i"}}).Decode(&userModel)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}
	return mapper.UserToDomain(userModel), nil
}

func (repo *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	var userModel *mapper.UserModel
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"email": bson.M{"$regex": email, "$options": "i"}}).Decode(&userModel)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}
	return mapper.UserToDomain(userModel), nil
}

func (repo *UserRepository) FindByUsernameOrEmail(ctx context.Context, key string) (domain.User, error) {
	var userModel mapper.UserModel
	filter := bson.M{"$or": []bson.M{{"username": key}, {"email": key}, {"phone_number": key}}}
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, filter).Decode(&userModel)
	if err != nil {
		return domain.User{}, err
	}
	return *mapper.UserToDomain(&userModel), nil
}

func (repo *UserRepository) InvalidateTokens(ctx context.Context, userID string) error {
	_, err := repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": userID}, bson.M{"$set": bson.M{"tokens": []string{}}})
	return err
}

func (repo *UserRepository) ChangeRole(ctx context.Context, targetUserID string, role string, username string) error {
	objID, err := bson.ObjectIDFromHex(targetUserID)
	if err != nil {
		return fmt.Errorf("invalid user ID: %v", err)
	}
	_, err = repo.DB.Collection(repo.Collection).UpdateOne(ctx, bson.M{"_id": objID}, bson.M{
		"$set": bson.M{
			"role":       role,
			"updated_at": time.Now(),
			"username":   username,
		},
	})
	return err
}
