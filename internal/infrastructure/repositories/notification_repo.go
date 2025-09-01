package repositories

import (
	"context"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type NotificationRepository struct {
	db  mongo.Database
	col string
}

func NewNotificationRepository(db mongo.Database, col string) domain.INotificationRepository {
	return &NotificationRepository{
		db:  db,
		col: col,
	}
}

func (r *NotificationRepository) Create(ctx context.Context, notification *domain.Notification) error {
	notf := mapper.ToNotificationDB(*notification)
	res, err := r.db.Collection(r.col).InsertOne(ctx, notf)
	if err != nil {
		return err
	}
	notification.ID = res.InsertedID.(bson.ObjectID).Hex()
	return nil
}

func (r *NotificationRepository) GetByUserID(ctx context.Context, userID string) ([]domain.Notification, error) {
	var notifications []mapper.NotificationDB
	filter := bson.M{"userId": userID}
	cursor, err := r.db.Collection(r.col).Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	for cursor.Next(ctx) {
		var notf mapper.NotificationDB
		if err := cursor.Decode(&notf); err != nil {
			return nil, err
		}
		notifications = append(notifications, notf)
	}

	if err := cursor.Err(); err != nil {
		return nil, err
	}

	return mapper.ToNotificationDomainList(notifications), nil
}

func (r *NotificationRepository) Update(ctx context.Context, notification *domain.Notification) error {
	notf := mapper.ToNotificationDB(*notification)
	_, err := r.db.Collection(r.col).UpdateOne(ctx, bson.M{"_id": notf.ID}, bson.M{"$set": notf})
	return err
}
