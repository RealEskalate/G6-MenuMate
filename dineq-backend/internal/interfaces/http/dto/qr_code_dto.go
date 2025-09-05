package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)


// QRCodeResponse represents a QR code generation response
type QRCodeResponse struct {
	QRCodeID      string    `json:"qr_code_id"`
	ImageURL      string    `json:"image_url"`
	PublicMenuURL string    `json:"public_menu_url"`
	DownloadURL   string    `json:"download_url"`
	IsActive      bool      `json:"is_active"`
	ExpiresAt     time.Time `json:"expires_at"`
	CreatedAt     time.Time `json:"created_at"`
}

// DomainToQRCodeResponse converts a QRCodeResponse DTO to a domain model
func DomainToQRCodeResponse(qr *domain.QRCode) *QRCodeResponse {
	if qr == nil {
		return nil
	}
	return &QRCodeResponse{
		QRCodeID:      qr.ID,
		ImageURL:      qr.ImageURL,
		PublicMenuURL: qr.PublicMenuURL,
		DownloadURL:   qr.DownloadURL,
		IsActive:      qr.IsActive,
		ExpiresAt:     qr.ExpiresAt,
		CreatedAt:     qr.CreatedAt,
	}
}

type QRConfig struct {
	Format    string  `json:"format"`     // png, jpg, svg
	Size      int     `json:"size"`
	Start     string  `json:"start"`      // gradient start
	End       string  `json:"end"`        // gradient end
	LogoURL   string  `json:"logo_url"`   // remote image URL, leave empty to use LogoPath
	LogoScale float64 `json:"logo_scale"` // fraction of QR size, 0.0 uses 0.20
	WhiteBg   bool    `json:"white_bg"`   // draw white rectangle behind logo
}

// QRConfigToDomain converts a QRConfig DTO to a domain model
func QRConfigToDomain(cfg *QRConfig) *domain.QRConfig {
	if cfg == nil {
		return nil
	}
	return &domain.QRConfig{
		Format:    cfg.Format,
		Size:      cfg.Size,
		Start:     cfg.Start,
		End:       cfg.End,
		LogoURL:   cfg.LogoURL,
		LogoScale: cfg.LogoScale,
		WhiteBg:   cfg.WhiteBg,
	}
}



