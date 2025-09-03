package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type QRCodeModel struct {
	ID            bson.ObjectID `bson:"_id,omitempty"`
	ImageURL      string        `bson:"imageUrl"`
	PublicMenuURL string        `bson:"publicMenuUrl"`
	DownloadURL   string        `bson:"downloadUrl"`
	MenuID        string        `bson:"menuId"`
	RestaurantID  string        `bson:"restaurantId"`
	IsActive      bool          `bson:"isActive"`
	CreatedAt     time.Time     `bson:"createdAt"`
	ExpiresAt     time.Time     `bson:"expiresAt"`
	IsDeleted     bool          `bson:"isDeleted"`
	DeletedAt     *time.Time    `bson:"deletedAt"`
}

// mapper
func ToDomainQRCode(m *QRCodeModel) *domain.QRCode {
	return &domain.QRCode{
		ID:            m.ID.Hex(),
		ImageURL:      m.ImageURL,
		PublicMenuURL: m.PublicMenuURL,
		DownloadURL:   m.DownloadURL,
		MenuID:        m.MenuID,
		RestaurantID:  m.RestaurantID,
		IsActive:      m.IsActive,
		CreatedAt:     m.CreatedAt,
		ExpiresAt:     m.ExpiresAt,
		IsDeleted:     m.IsDeleted,
		DeletedAt:     m.DeletedAt,
	}
}

func ToModelQRCode(d *domain.QRCode) *QRCodeModel {
	return &QRCodeModel{
		ImageURL:      d.ImageURL,
		PublicMenuURL: d.PublicMenuURL,
		DownloadURL:   d.DownloadURL,
		MenuID:        d.MenuID,
		RestaurantID:  d.RestaurantID,
		IsActive:      d.IsActive,
		CreatedAt:     d.CreatedAt,
		ExpiresAt:     d.ExpiresAt,
		IsDeleted:     d.IsDeleted,
		DeletedAt:     d.DeletedAt,
	}
}
