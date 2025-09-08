package repositories

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database/mapper"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type OCRRepository struct {
	db    mongo.Database
	ocrCl string
}

func NewOCRJobRepository(db mongo.Database, ocrCl string) domain.IOCRJobRepository {
	return &OCRRepository{
		db:    db,
		ocrCl: ocrCl,
	}
}

// create ocr
func (r *OCRRepository) Create(ctx context.Context, job *domain.OCRJob) error {
	dbocr := mapper.FromDomainOCRJob(job)
	if dbocr.CreatedAt.IsZero() {
		dbocr.CreatedAt = time.Now()
	}
	if dbocr.UpdatedAt.IsZero() {
		dbocr.UpdatedAt = time.Now()
	}
	if dbocr.Status == "" {
		dbocr.Status = string(domain.OCRProcessing)
	}
	res, err := r.db.Collection(r.ocrCl).InsertOne(ctx, dbocr)
	if err != nil {
		return err
	}
	if res.InsertedID == nil {
		return err
	}
	if oid, ok := res.InsertedID.(bson.ObjectID); ok {
		job.ID = oid.Hex()
	}
	return nil
}

// update
func (r *OCRRepository) Update(ctx context.Context, id string, job *domain.OCRJob) error {
	dbocr := mapper.FromDomainOCRJob(job)
	dbocr.UpdatedAt = time.Now()
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	update := bson.M{"$set": dbocr}
	_, err = r.db.Collection(r.ocrCl).UpdateOne(ctx, bson.M{"_id": oid}, update)
	return err
}

// getbyid
func (r *OCRRepository) GetByID(ctx context.Context, id string) (*domain.OCRJob, error) {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return nil, err
	}
	var dbocr mapper.OCRJobDB
	err = r.db.Collection(r.ocrCl).FindOne(ctx, bson.M{"_id": oid}).Decode(&dbocr)
	if err != nil {
		return nil, err
	}
	return mapper.ToDomainOCRJob(&dbocr), nil
}

// delete
func (r *OCRRepository) Delete(ctx context.Context, id string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	_, err = r.db.Collection(r.ocrCl).DeleteOne(ctx, bson.M{"_id": oid})
	return err
}

// update status
func (r *OCRRepository) UpdateStatus(ctx context.Context, id, status string) error {
	oid, err := bson.ObjectIDFromHex(id)
	if err != nil {
		return err
	}
	update := bson.M{
		"$set": bson.M{
			"status":    status,
			"updatedAt": time.Now(),
		},
	}
	_, err = r.db.Collection(r.ocrCl).UpdateOne(ctx, bson.M{"_id": oid}, update)
	return err
}

// get pending jobs
func (r *OCRRepository) GetPendingJobs(ctx context.Context) ([]*domain.OCRJob, error) {
	filter := bson.M{"status": string(domain.OCRProcessing)}
	cursor, err := r.db.Collection(r.ocrCl).Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var jobs []*domain.OCRJob
	for cursor.Next(ctx) {
		var dbocr mapper.OCRJobDB
		if err := cursor.Decode(&dbocr); err != nil {
			return nil, err
		}
		jobs = append(jobs, mapper.ToDomainOCRJob(&dbocr))
	}
	if err := cursor.Err(); err != nil {
		return nil, err
	}
	return jobs, nil
}

// getFCM Token
func (r *OCRRepository) GetUserFCMToken(userID string) string {
	var user struct {
		FCMToken string `bson:"fcmToken"`
	}
	err := r.db.Collection("users").FindOne(context.Background(), bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		return ""
	}
	return user.FCMToken
}
