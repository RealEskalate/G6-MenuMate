package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type qrCodeUseCase struct {
	repo       domain.IQRCodeRepository
	ctxTimeout time.Duration
}

func NewQRCodeUseCase(repo domain.IQRCodeRepository, ctxTimeout time.Duration) domain.IQRCodeUseCase {
	return &qrCodeUseCase{
		repo:       repo,
		ctxTimeout: ctxTimeout,
	}
}

// create
func (uc *qrCodeUseCase) CreateQRCode(qrCode *domain.QRCode) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	// enforce defaults
	if qrCode.CreatedAt.IsZero() {
		qrCode.CreatedAt = time.Now()
	}
	if qrCode.ExpiresAt.IsZero() {
		qrCode.ExpiresAt = time.Now().Add(365 * 24 * time.Hour)
	}
	// default to active on creation
	qrCode.IsActive = true
	return uc.repo.Create(ctx, qrCode)
}

// Activate QR Code
func (uc *qrCodeUseCase) ChangeQRCodeStatus(id string, isActive bool) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.UpdateActivation(ctx, id, isActive)
}

// get qr code by restaurant id
func (uc *qrCodeUseCase) GetQRCodeByRestaurantId(id string) (*domain.QRCode, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.GetByRestaurantId(ctx, id)
}

// delete qr code
func (uc *qrCodeUseCase) DeleteQRCode(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.Delete(ctx, id)
}
