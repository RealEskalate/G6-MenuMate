package usecase

import (
	"context"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
)

type MenuUseCase struct {
	menuRepo   domain.IMenuRepository
	qrService  services.QRService
	ctxTimeout time.Duration
}

func NewMenuUseCase(menuRepo domain.IMenuRepository, qrService services.QRService, ctxTimeout time.Duration) domain.IMenuUseCase {
	return &MenuUseCase{menuRepo: menuRepo, qrService: qrService, ctxTimeout: ctxTimeout}
}

func (uc *MenuUseCase) CreateMenu(menu *domain.Menu) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	menu.CreatedAt = time.Now()
	menu.UpdatedAt = time.Now()
	menu.Slug = utils.GenerateSlug(menu.RestaurantID)
	return uc.menuRepo.Create(ctx, menu)
}

func (uc *MenuUseCase) UpdateMenu(id string, userId string, menu *domain.Menu) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	menu.UpdatedAt = time.Now()
	menu.UpdatedBy = userId
	return uc.menuRepo.Update(ctx, id, menu)
}

func (uc *MenuUseCase) PublishMenu(id string, userID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	menu, err := uc.menuRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	menu.IsPublished = true
	menu.PublishedAt = time.Now()
	menu.UpdatedBy = userID
	return uc.menuRepo.Update(ctx, id, menu)
}

func (uc *MenuUseCase) GetByRestaurantID(id string) ([]*domain.Menu, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.menuRepo.GetByRestaurantID(ctx, id)
}

func (uc *MenuUseCase) GenerateQRCode(restaurantId string, menuId string, req *domain.QRCodeRequest) (*domain.QRCode, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	// find menu with restaurantId
	menu, err := uc.menuRepo.GetByID(ctx, menuId)
	if err != nil {
		return nil, err
	}
	// first it should be published
	if !menu.IsPublished {
		return nil, domain.ErrMenuNotPublished
	}

	res, err := uc.qrService.GenerateQRCode(restaurantId, req)
	if err != nil {
		return nil, err
	}

	qrCode := &domain.QRCode{
		ID:            res.QRCodeID,
		ImageURL:      res.ImageURL,
		PublicMenuURL: res.PublicMenuURL,
		DownloadURL:   res.DownloadURL,
		MenuID:        menu.ID,
		RestaurantID:  restaurantId,
		IsActive:      res.IsActive,
		CreatedAt:     res.CreatedAt,
		ExpiresAt:     res.ExpiresAt,
	}
	return qrCode, nil
}

func (uc *MenuUseCase) DeleteMenu(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.menuRepo.Delete(ctx, id)
}

func (uc *MenuUseCase) GetByID(id string) (*domain.Menu, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.menuRepo.GetByID(ctx, id)
}
