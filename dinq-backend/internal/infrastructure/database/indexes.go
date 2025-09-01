package mongo

import (
	"context"
	"errors"
	"time"

	"github.com/rs/zerolog/log"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

// CreateIndexes creates the provided indexes on the given collection.
// Safe to call multiple times (MongoDB ensures idempotency for same definitions).
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
            Keys: bson.D{{Key: "email", Value: 1}},
            Options: options.Index().SetUnique(true).SetName("ux_email").SetPartialFilterExpression(bson.D{{Key: "email", Value: bson.D{{Key: "$type", Value: "string"}}}}),
        },
        { // unique phone number if present
            Keys: bson.D{{Key: "phone_number", Value: 1}},
            Options: options.Index().SetUnique(true).SetName("ux_phone_number").SetPartialFilterExpression(bson.D{{Key: "phone_number", Value: bson.D{{Key: "$type", Value: "string"}}}}),
        },
        { // unique username if present (legacy)
            Keys: bson.D{{Key: "username", Value: 1}},
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
