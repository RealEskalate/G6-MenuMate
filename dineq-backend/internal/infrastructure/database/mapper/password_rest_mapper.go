package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type PasswordResetTokenDB struct {
	ID        bson.ObjectID `bson:"_id,omitempty"`
	Email     string        `bson:"email"`
	RateLimit int64         `bson:"rateLimit"`
	TokenHash string        `bson:"tokenHash"`
	ExpiresAt time.Time     `bson:"expiresAt"`
	Used      bool          `bson:"used"`
	CreatedAt time.Time     `bson:"createdAt"`
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
