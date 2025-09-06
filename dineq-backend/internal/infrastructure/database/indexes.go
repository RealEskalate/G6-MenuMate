package mongo

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/rs/zerolog/log"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

// CreateIndexes creates the provided indexes on the given collection.
func CreateIndexes(db Database, collection string) error {
	mdb, ok := db.(*mongoDatabase)
	if !ok {
		return errors.New("unsupported database implementation for index creation")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	idxView := mdb.db.Collection(collection).Indexes()
	models := []mongo.IndexModel{
		{ // unique slug for canonical lookup
			Keys:    bson.D{{Key: "slug", Value: 1}},
			Options: options.Index().SetUnique(true).SetName("ux_slug"),
		},
		{ // previous_slugs lookup
			Keys:    bson.D{{Key: "previous_slugs", Value: 1}},
			Options: options.Index().SetName("ix_previous_slugs"),
		},
		{
			Keys:    bson.D{{Key: "location", Value: "2dsphere"}},
			Options: options.Index().SetName("ix_location_2dsphere"),
		},
	}

	names, err := idxView.CreateMany(ctx, models)
	if err != nil {
		// If index already exists, it's not a fatal error; just log debug.
		log.Debug().Err(err).Str("collection", collection).Msg("index creation (some may already exist)")
		return err
	}
	log.Info().Strs("indexes", names).Str("collection", collection).Msg("indexes ensured")
	return nil
}

// CreateUserIndexes ensures unique/partial indexes for user collection (email, phone_number, username).
func CreateUserIndexes(db Database, collection string) error {
	mdb, ok := db.(*mongoDatabase)
	if !ok {
		return errors.New("unsupported database implementation for index creation")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	idxView := mdb.db.Collection(collection).Indexes()
	models := []mongo.IndexModel{
		{ // unique email if present
			Keys:    bson.D{{Key: "email", Value: 1}},
			Options: options.Index().SetUnique(true).SetName("ux_email").SetPartialFilterExpression(bson.D{{Key: "email", Value: bson.D{{Key: "$type", Value: "string"}}}}),
		},
		{ // unique phone number if present
			Keys:    bson.D{{Key: "phone_number", Value: 1}},
			Options: options.Index().SetUnique(true).SetName("ux_phone_number").SetPartialFilterExpression(bson.D{{Key: "phone_number", Value: bson.D{{Key: "$type", Value: "string"}}}}),
		},
		{ // unique username if present (legacy)
			Keys:    bson.D{{Key: "username", Value: 1}},
			Options: options.Index().SetUnique(true).SetName("ux_username").SetPartialFilterExpression(bson.D{{Key: "username", Value: bson.D{{Key: "$type", Value: "string"}}}}),
		},
	}
	names, err := idxView.CreateMany(ctx, models)
	if err != nil {
		log.Debug().Err(err).Str("collection", collection).Msg("user index creation (some may already exist)")
		return err
	}
	log.Info().Strs("indexes", names).Str("collection", collection).Msg("user indexes ensured")
	return nil
}

// CreateRefreshTokenIndexes ensures indexes for the refresh token collection:
func CreateRefreshTokenIndexes(db Database, collection string) error {
	mdb, ok := db.(*mongoDatabase)
	if !ok {
		return errors.New("unsupported database implementation for index creation")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	idxView := mdb.db.Collection(collection).Indexes()

	_ = idxView.DropOne(ctx, "ux_token")

	models := []mongo.IndexModel{
		{Keys: bson.D{{Key: "tokenHash", Value: 1}},
			Options: options.Index().SetUnique(true).SetName("ux_tokenhash"),
		},
		{ // user id lookup
			Keys:    bson.D{{Key: "user_id", Value: 1}},
			Options: options.Index().SetName("ix_user_id"),
		},
		{ // TTL auto removal
			Keys:    bson.D{{Key: "expires_at", Value: 1}},
			Options: options.Index().SetName("ttl_expires_at").SetExpireAfterSeconds(0),
		},
	}
	names, err := idxView.CreateMany(ctx, models)
	if err != nil {
		log.Debug().Err(err).Str("collection", collection).Msg("refresh token index creation (some may already exist)")
		return err
	}
	log.Info().Strs("indexes", names).Str("collection", collection).Msg("refresh token indexes ensured")
	return nil
}

// CreateOTPIndexes ensures indexes for the OTP collection:
func CreateOTPIndexes(db Database, collection string) error {
	mdb, ok := db.(*mongoDatabase)
	if !ok {
		return errors.New("unsupported database implementation for index creation")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	idxView := mdb.db.Collection(collection).Indexes()
	models := []mongo.IndexModel{
		{Keys: bson.D{{Key: "email", Value: 1}}, Options: options.Index().SetName("ix_email")},
		{Keys: bson.D{{Key: "expires_at", Value: 1}}, Options: options.Index().SetName("ttl_expires_at").SetExpireAfterSeconds(0)},
	}
	names, err := idxView.CreateMany(ctx, models)
	if err != nil {
		log.Debug().Err(err).Str("collection", collection).Msg("otp index creation (some may already exist)")
		return err
	}
	log.Info().Strs("indexes", names).Str("collection", collection).Msg("otp indexes ensured")
	return nil
}

// CreatePasswordResetTokenIndexes ensures indexes for password reset tokens:
func CreatePasswordResetTokenIndexes(db Database, collection string) error {
	mdb, ok := db.(*mongoDatabase)
	if !ok {
		return errors.New("unsupported database implementation for index creation")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	idxView := mdb.db.Collection(collection).Indexes()
	models := []mongo.IndexModel{
		{Keys: bson.D{{Key: "email", Value: 1}}, Options: options.Index().SetName("ix_email")},
		{Keys: bson.D{{Key: "tokenhash", Value: 1}}, Options: options.Index().SetUnique(true).SetName("ux_tokenhash")},
		{Keys: bson.D{{Key: "expires_at", Value: 1}}, Options: options.Index().SetName("ttl_expires_at").SetExpireAfterSeconds(0)},
	}
	names, err := idxView.CreateMany(ctx, models)
	if err != nil {
		log.Debug().Err(err).Str("collection", collection).Msg("password reset token index creation (some may already exist)")
		return err
	}
	log.Info().Strs("indexes", names).Str("collection", collection).Msg("password reset token indexes ensured")
	return nil
}

// IndexConfig defines collection names for unified index orchestration.
type IndexConfig struct {
	RestaurantCollection    string
	UserCollection          string
	RefreshTokenCollection  string
	PasswordResetCollection string
	OtpCollection           string
}

// EnsureIndexes centralizes creation of all indexes using the given configuration.
func EnsureIndexes(client Client, dbName string, cfg IndexConfig) {
	fmt.Println("Ensuring indexes for DB:", dbName, client)
	if client == nil {
		return
	}
	if dbName == "" {
		return
	}
	db := client.Database(dbName)

	if cfg.RestaurantCollection != "" {
		if err := CreateIndexes(db, cfg.RestaurantCollection); err != nil {
			log.Warn().Err(err).Str("collection", cfg.RestaurantCollection).Msg("ensure restaurant indexes failed")
		}
	}
	if cfg.UserCollection != "" {
		if err := CreateUserIndexes(db, cfg.UserCollection); err != nil {
			log.Warn().Err(err).Str("collection", cfg.UserCollection).Msg("ensure user indexes failed")
		}
	}
	if cfg.RefreshTokenCollection != "" {
		if err := CreateRefreshTokenIndexes(db, cfg.RefreshTokenCollection); err != nil {
			log.Warn().Err(err).Str("collection", cfg.RefreshTokenCollection).Msg("ensure refresh token indexes failed")
		}
	}
	if cfg.PasswordResetCollection != "" {
		if err := CreatePasswordResetTokenIndexes(db, cfg.PasswordResetCollection); err != nil {
			log.Warn().Err(err).Str("collection", cfg.PasswordResetCollection).Msg("ensure password reset token indexes failed")
		}
	}
	if cfg.OtpCollection != "" {
		if err := CreateOTPIndexes(db, cfg.OtpCollection); err != nil {
			log.Warn().Err(err).Str("collection", cfg.OtpCollection).Msg("ensure otp indexes failed")
		}
	}
}
