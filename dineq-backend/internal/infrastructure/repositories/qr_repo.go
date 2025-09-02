package repositories

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type qrRepository struct {
	db           mongo.Database
	qrCollection string
}

func NewQRCodeRepository(db mongo.Database, qrCollection string) domain.IQRCodeRepository {
	repo := &qrRepository{
		db:           db,
		qrCollection: qrCollection,
	}
	repo.createTTLIndex(context.Background())
	return repo
}
func (r *qrRepository) createTTLIndex(ctx context.Context) {
	indexModel := mongo.IndexModel{
		Keys:    bson.M{"deletedAt": 1},
		Options: options.Index().SetExpireAfterSeconds(0),
	}
	_, err := r.db.Collection(r.qrCollection).Indexes().CreateOne(ctx, indexModel)
	if err != nil {
		fmt.Printf("Failed to create TTL index: %v\n", err)
	}
}

// create
func (r *qrRepository) Create(ctx context.Context, qr *domain.QRCode) error {
	qrModel := mapper.ToModelQRCode(qr)
	res, err := r.db.Collection(r.qrCollection).InsertOne(ctx, qrModel)
	if err != nil {
		return err
	}
	if res.InsertedID == nil {
		return errors.New("failed to insert QR code")
	}
	qr.ID = res.InsertedID.(bson.ObjectID).Hex()
	return nil
}

// getbyid
func (r *qrRepository) GetByRestaurantId(ctx context.Context, id string) (*domain.QRCode, error) {
	var qr domain.QRCode
	err := r.db.Collection(r.qrCollection).FindOne(ctx, bson.M{"restaurantId": id, "isDeleted": false}).Decode(&qr)
	if err != nil {
		return nil, err
	}
	return &qr, nil
}

// updateactivation
func (r *qrRepository) UpdateActivation(ctx context.Context, id string, isActive bool) error {
	_, err := r.db.Collection(r.qrCollection).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{"isActive": isActive}})
	return err
}

// delete
func (r *qrRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.Collection(r.qrCollection).UpdateOne(ctx, bson.M{"_id": id}, bson.M{"$set": bson.M{"isDeleted": true, "deletedAt": time.Now().AddDate(0, 2, 0)}})
	return err
}
