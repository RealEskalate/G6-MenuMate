package repositories

import (
	"context"
	"fmt"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type PasswordResetRepository struct {
	DB                     mongo.Database
	Collection             string
	ResetSessionCollection string
}

func NewPasswordResetRepository(db mongo.Database, col string, resetSessionCol string) domain.IPasswordResetRepository {
	return &PasswordResetRepository{
		DB:                     db,
		Collection:             col,
		ResetSessionCollection: resetSessionCol,
	}
}

func (r *PasswordResetRepository) SaveResetToken(ctx context.Context, token *domain.PasswordResetToken) error {
	tokenModel := mapper.PasswordResetTokenFromDomain(token)
	collection := r.DB.Collection(r.Collection)
	if collection == nil {
		return fmt.Errorf("database collection is not initialized")
	}
	_, err := collection.InsertOne(ctx, tokenModel)
	if err != nil {
		return err
	}
	return nil
}

func (r *PasswordResetRepository) FindByEmail(ctx context.Context, email string) (*domain.PasswordResetToken, error) {
	var tokenModel mapper.PasswordResetTokenDB
	err := r.DB.Collection(r.Collection).FindOne(ctx, bson.M{"email": email}).Decode(&tokenModel)
	if err != nil {
		return nil, err
	}
	return mapper.PasswordResetTokenToDomain(&tokenModel), nil
}

func (r *PasswordResetRepository) MarkAsUsed(ctx context.Context, token *domain.PasswordResetToken) error {
	_, err := r.DB.Collection(r.Collection).UpdateOne(ctx, bson.M{"email": token.Email, "tokenHash": token.TokenHash}, bson.M{"$set": bson.M{"used": true}})
	if err != nil {
		return err
	}
	return nil
}
func (r *PasswordResetRepository) DeleteResetToken(ctx context.Context, email string) error {
	_, err := r.DB.Collection(r.Collection).DeleteOne(ctx, bson.M{"email": email})
	if err != nil {
		return err
	}
	return nil
}

// update reste token
func (r *PasswordResetRepository) UpdateResetToken(ctx context.Context, token *domain.PasswordResetToken) error {
	tokenModel := mapper.PasswordResetTokenFromDomain(token)
	_, err := r.DB.Collection(r.Collection).UpdateOne(
		ctx,
		bson.M{"email": token.Email},
		bson.M{"$set": bson.M{
			"tokenHash": tokenModel.TokenHash,
			"expiresAt": tokenModel.ExpiresAt,
			"used":      tokenModel.Used,
			"rateLimit": tokenModel.RateLimit,
			"createdAt": tokenModel.CreatedAt,
		}},
	)
	if err != nil {
		return err
	}
	return nil
}

// SaveResetSession saves a password reset session token
func (r *PasswordResetRepository) SaveResetSession(ctx context.Context, session *domain.PasswordResetSession) error {
	sessionModel := mapper.PasswordResetSessionFromDomain(session)
	collection := r.DB.Collection(r.ResetSessionCollection)
	if collection == nil {
		return fmt.Errorf("database collection is not initialized")
	}
	_, err := collection.InsertOne(ctx, sessionModel)
	if err != nil {
		return err
	}
	return nil
}

// GetResetSession retrieves a password reset session by its token
func (r *PasswordResetRepository) GetResetSession(ctx context.Context, sessionToken string) (*domain.PasswordResetSession, error) {
	var sessionModel mapper.PasswordResetSessionDB
	err := r.DB.Collection(r.ResetSessionCollection).FindOne(ctx, bson.M{"token": sessionToken}).Decode(&sessionModel)
	if err != nil {
		return nil, err
	}
	return mapper.PasswordResetSessionToDomain(&sessionModel), nil
}

// DeleteResetSession deletes a password reset session by its token
func (r *PasswordResetRepository) DeleteResetSession(ctx context.Context, sessionToken string) error {
	_, err := r.DB.Collection(r.ResetSessionCollection).DeleteOne(ctx, bson.M{"token": sessionToken})
	if err != nil {
		return err
	}
	return nil
}
