package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"

	"go.mongodb.org/mongo-driver/v2/bson"
	mongoIn "go.mongodb.org/mongo-driver/v2/mongo"
)

type ReactionRepo struct {
	db          mongo.Database
	ReactionCol string
}

func NewReactionRepo(database mongo.Database, reactionCol string) domain.IReactionRepository {
	return &ReactionRepo{
		db:          database,
		ReactionCol: reactionCol,
	}
}

func (r *ReactionRepo) GetReactionStats(ctx context.Context, itemID, userID string) (int64, int64, *domain.Reaction, error) {
	fmt.Printf("Creating index on DB: %q, Collection: %q\n", r.db, r.ReactionCol)
	coll := r.db.Collection(r.ReactionCol)

	matchStage := bson.D{
		{Key: "$match", Value: bson.D{
			{Key: "itemId", Value: itemID},
			{Key: "isDeleted", Value: false},
		}},
	}
	groupStage := bson.D{
		{Key: "$group", Value: bson.D{
			{Key: "_id", Value: "$type"},
			{Key: "count", Value: bson.D{{Key: "$sum", Value: 1}}},
		}},
	}

	cursor, err := coll.Aggregate(ctx, mongoIn.Pipeline{matchStage, groupStage})
	if err != nil {
		return 0, 0, nil, err
	}
	defer cursor.Close(ctx)

	var likeCount int64 = 0
	var dislikeCount int64 = 0
	for cursor.Next(ctx) {
		var result struct {
			ID    string `bson:"_id"`
			Count int64  `bson:"count"`
		}
		if err := cursor.Decode(&result); err != nil {
			return 0, 0, nil, err
		}
		switch result.ID {
		case string(domain.ReactionLike):
			likeCount = result.Count
		case string(domain.ReactionDislike):
			dislikeCount = result.Count
		}
	}
	if err := cursor.Err(); err != nil {
		return 0, 0, nil, err
	}

	userReaction, err := r.GetUserReaction(ctx, itemID, userID)
	if err != nil {
		return 0, 0, nil, err
	}

	return likeCount, dislikeCount, userReaction, nil
}

func (r *ReactionRepo) GetUserReaction(ctx context.Context, itemID, userID string) (*domain.Reaction, error) {
	coll := r.db.Collection(r.ReactionCol)
	filter := bson.D{
		{Key: "itemId", Value: itemID},
		{Key: "userId", Value: userID},
		// {Key: "isDeleted", Value: false},
	}
	type reactionDB struct {
		ID        bson.ObjectID `bson:"_id"`
		ReviewID  string        `bson:"reviewId,omitempty"`
		ItemID    string        `bson:"itemId"`
		UserID    string        `bson:"userId"`
		Type      string        `bson:"type"`
		CreatedAt time.Time     `bson:"createdAt"`
		UpdatedAt time.Time     `bson:"updatedAt"`
		IsDeleted bool          `bson:"isDeleted"`
	}
	var dbRec reactionDB
	err := coll.FindOne(ctx, filter).Decode(&dbRec)
	if err == mongoIn.ErrNoDocuments {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	reaction := &domain.Reaction{
		ID:        dbRec.ID.Hex(),
		ReviewID:  dbRec.ReviewID,
		ItemID:    dbRec.ItemID,
		UserID:    dbRec.UserID,
		Type:      domain.ReactionType(dbRec.Type),
		CreatedAt: dbRec.CreatedAt,
		UpdatedAt: dbRec.UpdatedAt,
		IsDeleted: dbRec.IsDeleted,
	}
	return reaction, nil
}

func (r *ReactionRepo) InsertReaction(ctx context.Context, reaction *domain.Reaction) error {
	coll := r.db.Collection(r.ReactionCol)
	doc := mapper.ToBsonReaction(reaction)
	if reaction.ID == "" {
		delete(doc, "_id")
	}
	result, err := coll.InsertOne(ctx, doc)
	if err != nil {
		return err
	}

	type reactionDB struct {
		ID        bson.ObjectID `bson:"_id"`
		ReviewID  string        `bson:"reviewId,omitempty"`
		ItemID    string        `bson:"itemId"`
		UserID    string        `bson:"userId"`
		Type      string        `bson:"type"`
		CreatedAt time.Time     `bson:"createdAt"`
		UpdatedAt time.Time     `bson:"updatedAt"`
		IsDeleted bool          `bson:"isDeleted"`
	}
	var dbRec reactionDB

	var filter bson.M
	switch id := result.InsertedID.(type) {
	case bson.ObjectID:
		filter = bson.M{"_id": id}
	case string:
		filter = bson.M{"_id": id}
	default:
		return fmt.Errorf("unknown _id type: %T", result.InsertedID)
	}
	err = coll.FindOne(ctx, filter).Decode(&dbRec)
	if err != nil {
		return err
	}
	reaction.ID = dbRec.ID.Hex()
	reaction.ReviewID = dbRec.ReviewID
	reaction.ItemID = dbRec.ItemID
	reaction.UserID = dbRec.UserID
	reaction.Type = domain.ReactionType(dbRec.Type)
	reaction.CreatedAt = dbRec.CreatedAt
	reaction.UpdatedAt = dbRec.UpdatedAt
	reaction.IsDeleted = dbRec.IsDeleted
	return nil
}

func (r *ReactionRepo) UpdateReaction(ctx context.Context, reaction *domain.Reaction) error {
	coll := r.db.Collection(r.ReactionCol)
	filter := bson.D{
		{Key: "itemId", Value: reaction.ItemID},
		{Key: "userId", Value: reaction.UserID},
		{Key: "reviewId", Value: reaction.ReviewID},
	}
	update := bson.D{
		{Key: "$set", Value: bson.D{
			{Key: "type", Value: reaction.Type},
			{Key: "isDeleted", Value: reaction.IsDeleted},
			{Key: "updatedAt", Value: reaction.UpdatedAt},
		}},
	}
	_, err := coll.UpdateOne(ctx, filter, update)
	if err != nil {
		return err
	}

	type reactionDB struct {
		ID        bson.ObjectID `bson:"_id"`
		ReviewID  string        `bson:"reviewId,omitempty"`
		ItemID    string        `bson:"itemId"`
		UserID    string        `bson:"userId"`
		Type      string        `bson:"type"`
		CreatedAt time.Time     `bson:"createdAt"`
		UpdatedAt time.Time     `bson:"updatedAt"`
		IsDeleted bool          `bson:"isDeleted"`
	}
	var dbRec reactionDB
	err = coll.FindOne(ctx, filter).Decode(&dbRec)
	if err != nil {
		return err
	}
	reaction.ID = dbRec.ID.Hex()
	reaction.ReviewID = dbRec.ReviewID
	reaction.ItemID = dbRec.ItemID
	reaction.UserID = dbRec.UserID
	reaction.Type = domain.ReactionType(dbRec.Type)
	reaction.CreatedAt = dbRec.CreatedAt
	reaction.UpdatedAt = dbRec.UpdatedAt
	reaction.IsDeleted = dbRec.IsDeleted
	return nil
}
