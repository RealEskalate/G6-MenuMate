package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type PasswordResetTokenDB struct {
	ID        bson.ObjectID `bson:"_id,omitempty"`
	Email     string        `bson:"email"`
	RateLimit int64         `bson:"rate_limit"`
	TokenHash string        `bson:"token_hash"`
	ExpiresAt time.Time     `bson:"expires_at"`
	Used      bool          `bson:"used"`
	CreatedAt time.Time     `bson:"created_at"`
}

func PasswordResetTokenFromDomain(token *domain.PasswordResetToken) *PasswordResetTokenDB {
	return &PasswordResetTokenDB{
		ID:        bson.NewObjectID(),
		Email:     token.Email,
		RateLimit: int64(token.RateLimit),
		TokenHash: token.TokenHash,
		ExpiresAt: token.ExpiresAt,
		Used:      token.Used,
	}
}

func PasswordResetTokenToDomain(token *PasswordResetTokenDB) *domain.PasswordResetToken {
	return &domain.PasswordResetToken{
		ID:        token.ID.Hex(),
		Email:     token.Email,
		RateLimit: int(token.RateLimit),
		TokenHash: token.TokenHash,
		ExpiresAt: token.ExpiresAt,
		Used:      token.Used,
		CreatedAt: token.CreatedAt,
	}
}
