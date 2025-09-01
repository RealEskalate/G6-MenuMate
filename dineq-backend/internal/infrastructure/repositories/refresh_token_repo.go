package repositories

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type RefreshTokenRepository struct {
	DB         mongo.Database
	Collection string
}

func NewRefreshTokenRepository(db mongo.Database, collection string) domain.IRefreshTokenRepository {
	return &RefreshTokenRepository{
		DB:         db,
		Collection: collection,
	}
}

func (repo *RefreshTokenRepository) Save(ctx context.Context, token *domain.RefreshToken) error {
	if token.TokenHash == "" && token.Token != "" { token.TokenHash = hashToken(token.Token) }
	tokenDb := mapper.FromRefreshTokenEntityToDB(token)
	res, err := repo.DB.Collection(repo.Collection).InsertOne(ctx, tokenDb)
	if err != nil {
		return err
	}
	if res == nil {
		return domain.ErrFailedToSaveToken
	}
	return nil
}

func (repo *RefreshTokenRepository) FindByToken(ctx context.Context, rawToken string) (*domain.RefreshToken, error) {
	var tokenDB mapper.RefreshTokenDB
	tokenHash := hashToken(rawToken)
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"tokenhash": tokenHash}).Decode(&tokenDB)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrRefreshTokenNotFound
		}
		return nil, err
	}
	return mapper.FromRefreshTokenDBToEntity(&tokenDB), nil
}

func (repo *RefreshTokenRepository) DeleteByUserID(ctx context.Context, userID string) error {
	res, err := repo.DB.Collection(repo.Collection).DeleteOne(ctx, bson.M{"user_id": userID})
	if err != nil {
		return err
	}
	if res == 0 {
		return domain.ErrFailedToDeleteToken
	}
	return nil
}

func (repo *RefreshTokenRepository) ReplaceTokenByUserID(ctx context.Context, token *domain.RefreshToken) error {
	if token.TokenHash == "" && token.Token != "" { token.TokenHash = hashToken(token.Token) }
	tokenDB := mapper.FromRefreshTokenEntityToDB(token)
	fmt.Println("Replacing token for user ID:", token.UserID, tokenDB)
	_, err := repo.DB.Collection(repo.Collection).UpdateOne(
		ctx,
		bson.M{"user_id": token.UserID},
		bson.M{"$set": tokenDB},
	)
	if err != nil {
		return err
	}
	return nil
}

// revoke refresh token
func (repo *RefreshTokenRepository) RevokeToken(ctx context.Context, rawToken string) error {
	tokenHash := hashToken(rawToken)
	res, err := repo.DB.Collection(repo.Collection).UpdateOne(
		ctx,
		bson.M{"tokenhash": tokenHash},
		bson.M{"$set": bson.M{"revoked": true}},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrFailedToRevokeToken
	}
	return nil
}

// RevokeTokenByUserID revokes the refresh token associated with a user id
func (repo *RefreshTokenRepository) RevokeTokenByUserID(ctx context.Context, userID string) error {
	res, err := repo.DB.Collection(repo.Collection).UpdateOne(
		ctx,
		bson.M{"user_id": userID},
		bson.M{"$set": bson.M{"revoked": true}},
	)
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return domain.ErrFailedToRevokeToken
	}
	return nil
}

// find token by user id
func (repo *RefreshTokenRepository) FindTokenByUserID(ctx context.Context, userID string) (*domain.RefreshToken, error) {
	var tokenDB mapper.RefreshTokenDB
	err := repo.DB.Collection(repo.Collection).FindOne(ctx, bson.M{"user_id": userID}).Decode(&tokenDB)
	if err != nil {
		if err == mongo.ErrNoDocuments() {
			return nil, domain.ErrRefreshTokenNotFound
		}
		return nil, err
	}
	return mapper.FromRefreshTokenDBToEntity(&tokenDB), nil
}

// hashToken derives a hex SHA-256 digest of a refresh token string.
func hashToken(t string) string {
	h := sha256.Sum256([]byte(t))
	return hex.EncodeToString(h[:])
}
