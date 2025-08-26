package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type OtpDB struct {
	ID        bson.ObjectID `bson:"_id,omitempty"`
	Email     string        `bson:"email"`
	CodeHash  string        `bson:"code_hash"`
	ExpiresAt time.Time     `bson:"expires_at"`
	Attempts  int           `bson:"attempts"`
	CreatedAt time.Time     `bson:"created_at"`
}

// from otp to db model
func OtpFromDomain(otp *domain.OTP) *OtpDB {
	id := bson.NewObjectID()
	if otp.ID != "" {
		var err error
		id, err = bson.ObjectIDFromHex(otp.ID)
		if err != nil {
			return nil // or handle error appropriately
		}
	}
	return &OtpDB{
		ID:        id,
		Email:     otp.Email,
		CodeHash:  otp.CodeHash,
		ExpiresAt: otp.ExpiresAt,
		Attempts:  otp.Attempts,
		CreatedAt: time.Now(),
	}
}

// from db model to otp
func OtpToDomain(otp *OtpDB) *domain.OTP {
	return &domain.OTP{
		ID:        otp.ID.Hex(),
		Email:     otp.Email,
		CodeHash:  otp.CodeHash,
		ExpiresAt: otp.ExpiresAt,
		Attempts:  otp.Attempts,
		CreatedAt: otp.CreatedAt,
	}
}
