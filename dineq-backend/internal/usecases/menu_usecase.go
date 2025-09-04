package usecase

import (
	"context"
	"strings"
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
	// Build slug from menu name (ensure contains word 'menu') plus short uuid fragment for uniqueness
	name := strings.TrimSpace(menu.Name)
	if name == "" {
		name = menu.RestaurantID + " menu"
	}
	lowerName := strings.ToLower(name)
	if !strings.Contains(lowerName, "menu") {
		name = name + " Menu"
	}
	baseSlug := utils.GenerateSlug(name)
	// append 6-char uuid segment for uniqueness
	uidPart := utils.GenerateUUID()
	if len(uidPart) > 8 { uidPart = uidPart[:8] }
	menu.Slug = baseSlug + "-" + uidPart

	// Ensure each item has slug + menu slug
	for i := range menu.Items {
		base := strings.TrimSpace(menu.Items[i].Name)
		if base == "" { base = strings.TrimSpace(menu.Items[i].NameAm) }
		if menu.Items[i].Slug == "" && base != "" {
			menu.Items[i].Slug = utils.GenerateSlug(base)
		}
		menu.Items[i].MenuSlug = menu.Slug
	}
	return uc.menuRepo.Create(ctx, menu)
}

func (uc *MenuUseCase) UpdateMenu(id string, userId string, menu *domain.Menu) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	// Load existing to preserve immutable / non-updated fields
	existing, err := uc.menuRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Only allowed fields: Name, Items. Everything else stays.
	if strings.TrimSpace(menu.Name) != "" {
		existing.Name = menu.Name
	}
	if len(menu.Items) > 0 {
		// Replace items but enrich with slugs/menu slug where missing
		for i := range menu.Items {
			base := strings.TrimSpace(menu.Items[i].Name)
			if base == "" { base = strings.TrimSpace(menu.Items[i].NameAm) }
			if menu.Items[i].Slug == "" && base != "" {
				menu.Items[i].Slug = utils.GenerateSlug(base)
			}
			menu.Items[i].MenuSlug = existing.Slug
		}
		existing.Items = menu.Items
	}
	existing.UpdatedAt = time.Now()
	existing.UpdatedBy = userId
	return uc.menuRepo.Update(ctx, id, existing)
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
