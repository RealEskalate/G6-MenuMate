package usecase

import (
	"context"
	"fmt"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
)

type MenuUseCase struct {
	menuRepo   domain.IMenuRepository
	qrService  services.QRGeneratorService
	strgService services.StorageService
	ctxTimeout time.Duration
}

func NewMenuUseCase(menuRepo domain.IMenuRepository, qrService services.QRGeneratorService, strgService services.StorageService, ctxTimeout time.Duration) domain.IMenuUseCase {
	return &MenuUseCase{menuRepo: menuRepo, qrService: qrService, strgService: strgService, ctxTimeout: ctxTimeout}
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

func (uc *MenuUseCase) GenerateQRCode(restaurantId string, menuId string, req *domain.QRConfig) (*domain.QRCode, error) {
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

	img, err := uc.qrService.GenerateGradientQRWithLogo(req)
	if err != nil {
		return nil, err
	}

buf, err := uc.qrService.SaveImageAsUserFormat(img, req.Format)
if err != nil {
	return nil, err
}

// Upload the bytes to storage
res, _, err := uc.strgService.UploadFile(ctx, restaurantId, buf.Bytes(), "qr-codes")
if err != nil {
	return nil, err
}
fmt.Println("QR code generated at:", res)

	// fmt.Println("QR code generated at:", res)
	qrCode := &domain.QRCode{
		ImageURL:      res,
		PublicMenuURL: "http://localhost:8080/menu/the-italian-corner-742a0969",
		DownloadURL:   res + "?download=true",
		MenuID:        menu.ID,
		RestaurantID:  restaurantId,
		IsActive:      true,
		CreatedAt:     time.Now(),
		ExpiresAt:     time.Now().AddDate(5, 0 , 0),
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
