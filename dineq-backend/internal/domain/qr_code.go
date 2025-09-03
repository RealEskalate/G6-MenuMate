package domain

import (
	"context"
	"time"
)

type QRCode struct {
	ID            string
	ImageURL      string
	PublicMenuURL string
	DownloadURL   string
	MenuID        string
	RestaurantID  string
	IsActive      bool
	CreatedAt     time.Time
	ExpiresAt     time.Time
	IsDeleted     bool
	DeletedAt     *time.Time
}

type IQRCodeUseCase interface {
	CreateQRCode(qr *QRCode) error
	GetQRCodeByRestaurantId(id string) (*QRCode, error)
	ChangeQRCodeStatus(id string, isActive bool) error
	// DeleteQRCode deletes a QR code by its restaurant ID
	DeleteQRCode(id string) error
}

// repository
type IQRCodeRepository interface {
	Create(ctx context.Context, qr *QRCode) error
	GetByRestaurantId(ctx context.Context, id string) (*QRCode, error)
	UpdateActivation(ctx context.Context, id string, isActive bool) error
	Delete(ctx context.Context, id string) error
}

type QRCodeRequest struct {
	Format        string
	Size          int
	IncludeLabel  bool
	Customization *QRCodeCustomization
}

// QRCodeCustomization represents QR code customization options
type QRCodeCustomization struct {
	BackgroundColor string
	ForegroundColor string
	Logo            string
	LogoSizePercent float64
}
