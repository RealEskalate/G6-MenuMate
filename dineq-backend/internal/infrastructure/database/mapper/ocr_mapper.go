package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type OCRJobDB struct {
	ID               bson.ObjectID `bson:"_id,omitempty"`
	RestaurantID     string        `bson:"restaurantId"`
	ImageURL         string        `bson:"imageUrl"`
	UserID           string        `bson:"userId"`
	Status           string        `bson:"status"`
	ResultText       string        `bson:"resultText"`
	StructuredMenuID string        `bson:"structuredMenuId"`
	Error            string        `bson:"error"`
	CreatedAt        time.Time     `bson:"createdAt"`
	UpdatedAt        time.Time     `bson:"updatedAt"`
}

func ToDomainOCRJob(m *OCRJobDB) *domain.OCRJob {
	return &domain.OCRJob{
		ID:               m.ID.Hex(),
		RestaurantID:     m.RestaurantID,
		UserID:           m.UserID,
		ImageURL:         m.ImageURL,
		Status:           domain.OCRJobStatus(m.Status),
		ResultText:       m.ResultText,
		StructuredMenuID: m.StructuredMenuID,
		Error:            m.Error,
		CreatedAt:        m.CreatedAt,
		UpdatedAt:        m.UpdatedAt,
	}
}

func FromDomainOCRJob(d *domain.OCRJob) *OCRJobDB {
	return &OCRJobDB{
		RestaurantID:     d.RestaurantID,
		UserID:           d.UserID,
		ImageURL:         d.ImageURL,
		Status:           string(d.Status),
		ResultText:       d.ResultText,
		StructuredMenuID: d.StructuredMenuID,
		Error:            d.Error,
		CreatedAt:        d.CreatedAt,
		UpdatedAt:        d.UpdatedAt,
	}
}
