package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// QRCodeRequest represents a QR code generation request
type QRCodeRequest struct {
	Format        string               `json:"format"` // png, jpg, svg
	Size          int                  `json:"size"`   // size in pixels
	IncludeLabel  bool                 `json:"include_label"`
	Quality       int                  `json:"quality,omitempty"`
	Customization *QRCodeCustomization `json:"customization,omitempty"`
}

// QRCodeCustomization represents QR code customization options
type QRCodeCustomization struct {
	BackgroundColor   string  `json:"background_color"`
	ForegroundColor   string  `json:"foreground_color"`
	Logo              string  `json:"logo,omitempty"`
	LogoSizePercent   float64 `json:"logo_size_percent,omitempty"`
	GradientFrom      string  `json:"gradient_from,omitempty"`
	GradientTo        string  `json:"gradient_to,omitempty"`
	GradientDirection string  `json:"gradient_direction,omitempty"`
	Margin            int     `json:"margin,omitempty"`
	LabelText         string  `json:"label_text,omitempty"`
	LabelColor        string  `json:"label_color,omitempty"`
	LabelFontSize     int     `json:"label_font_size,omitempty"`
	LabelFontURL      string  `json:"label_font_url,omitempty"`
}

// QRCodeResponse represents a QR code generation response
type QRCodeResponse struct {
	QRCodeID         string    `json:"qr_code_id"`
	ImageURL         string    `json:"image_url"`
	CloudImageURL    string    `json:"cloud_image_url,omitempty"`
	PublicMenuURL    string    `json:"public_menu_url"`
	DownloadURL      string    `json:"download_url"`
	IsActive         bool      `json:"is_active"`
	ExpiresAt        time.Time `json:"expires_at"`
	CreatedAt        time.Time `json:"created_at"`
	LabelFontApplied bool      `json:"label_font_applied,omitempty"`
}

func DTOToQRCodeRequest(req *QRCodeRequest) *domain.QRCodeRequest {
	if req == nil {
		return nil
	}
	return &domain.QRCodeRequest{
		Format:        req.Format,
		Size:          req.Size,
		IncludeLabel:  req.IncludeLabel,
		Quality:       req.Quality,
		Customization: DTOToQRCodeCustomization(req.Customization),
	}
}

func DTOToQRCodeCustomization(cust *QRCodeCustomization) *domain.QRCodeCustomization {
	if cust == nil {
		return nil
	}
	return &domain.QRCodeCustomization{
		BackgroundColor:   cust.BackgroundColor,
		ForegroundColor:   cust.ForegroundColor,
		Logo:              cust.Logo,
		LogoSizePercent:   cust.LogoSizePercent,
		GradientFrom:      cust.GradientFrom,
		GradientTo:        cust.GradientTo,
		GradientDirection: cust.GradientDirection,
		Margin:            cust.Margin,
		LabelText:         cust.LabelText,
		LabelColor:        cust.LabelColor,
		LabelFontSize:     cust.LabelFontSize,
		LabelFontURL:      cust.LabelFontURL,
	}
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
