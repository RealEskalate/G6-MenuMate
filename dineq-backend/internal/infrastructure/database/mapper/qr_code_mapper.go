package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type QRCodeModel struct {
	ID            bson.ObjectID `bson:"_id,omitempty"`
	ImageURL      string        `bson:"imageUrl,omitempty"`
	PublicMenuURL string        `bson:"publicMenuUrl,omitempty"`
	DownloadURL   string        `bson:"downloadUrl,omitempty"`
	MenuID        string        `bson:"menuId,omitempty"`
	RestaurantID  string        `bson:"restaurantId,omitempty"`
	IsActive      bool          `bson:"isActive,omitempty"`
	CreatedAt     time.Time     `bson:"createdAt,omitempty"`
	ExpiresAt     time.Time     `bson:"expiresAt,omitempty"`
	IsDeleted     bool          `bson:"isDeleted,omitempty"`
	DeletedAt     *time.Time    `bson:"deletedAt,omitempty"`
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
