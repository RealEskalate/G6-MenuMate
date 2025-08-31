package usecase

import (
	"context"
	"time"

	"github.com/dinq/menumate/internal/domain"
)

type MenuUseCase struct {
	menuRepo domain.IMenuRepository
	ctxTimeout time.Duration
}

func NewMenuUseCase(menuRepo domain.IMenuRepository, ctxTimeout time.Duration) domain.IMenuUseCase {
	return &MenuUseCase{menuRepo: menuRepo, ctxTimeout: ctxTimeout}
}

func (uc *MenuUseCase) CreateMenu(menu *domain.Menu) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	menu.CreatedAt = time.Now()
	menu.UpdatedAt = time.Now()
	return uc.menuRepo.Create(ctx, menu)
}

func (uc *MenuUseCase) UpdateMenu(id string, menu *domain.Menu) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	menu.UpdatedAt = time.Now()
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

func (uc *MenuUseCase) GetMenuByID(id string) (*domain.Menu, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.menuRepo.GetByID(ctx, id)
}

func (uc *MenuUseCase) GenerateQRCode(menuID string) (*domain.QRCode, error) {
	// Placeholder: Implement QR code generation
	return &domain.QRCode{}, nil
}

func (uc *MenuUseCase) DeleteMenu(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	menu, err := uc.menuRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	menu.IsDeleted = true
	return uc.menuRepo.Update(ctx, id, menu)
}
