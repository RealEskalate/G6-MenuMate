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
	Quality       int // optional JPEG quality 1-100
	Customization *QRCodeCustomization
}

// QRCodeCustomization represents QR code customization options
type QRCodeCustomization struct {
	BackgroundColor string
	ForegroundColor string
	Logo            string
	LogoSizePercent float64
	GradientFrom     string
	GradientTo       string
	GradientDirection string // horizontal or vertical
	Margin           int
	ErrorCorrection  string // L,M,Q,H
	LabelText        string
	LabelColor       string
	LabelFontSize    int
	LabelFontURL     string // optional remote/local TTF font
	LogoBackground        bool   // draw background rectangle behind logo
	LogoBackgroundColor   string // override background color for logo box
	LogoBackgroundPadding int    // extra padding pixels (default 4)
	LogoTintGradient      bool   // recolor logo pixels to match QR gradient
	LogoOpacity           int    // 0-100 overall logo opacity (default 100)
	LogoBlendMode         string // replace|multiply|overlay (default replace)
	LogoTintStrength      int    // 0-100 how much gradient replaces original (default 100)
	LogoAutoRemoveWhite   bool   // if true, removes near-white pixels (makes them transparent)
	LogoWhiteThreshold    int    // 0-255 threshold for white removal (default 245)
}
