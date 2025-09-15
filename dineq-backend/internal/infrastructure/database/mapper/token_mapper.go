package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type RefreshTokenDB struct {
	TokenHash string    `bson:"tokenHash"`
	UserID    string    `bson:"userId"`
	Revoked   bool      `bson:"revoked"`
	ExpiresAt time.Time `bson:"expiresAt"`
	CreatedAt time.Time `bson:"createdAt"`
}

func FromRefreshTokenEntityToDB(token *domain.RefreshToken) *RefreshTokenDB {
	return &RefreshTokenDB{
		TokenHash: token.TokenHash,
		UserID:    token.UserID,
		Revoked:   token.Revoked,
		ExpiresAt: token.ExpiresAt,
		CreatedAt: time.Now(),
	}
}

func FromRefreshTokenDBToEntity(tokenDB *RefreshTokenDB) *domain.RefreshToken {
	return &domain.RefreshToken{
		TokenHash: tokenDB.TokenHash,
		UserID:    tokenDB.UserID,
		Revoked:   tokenDB.Revoked,
		ExpiresAt: tokenDB.ExpiresAt,
		CreatedAt: tokenDB.CreatedAt,
	}
}
