package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ItemUseCase struct {
	repo domain.IItemRepository
}

func NewItemUseCase(repo domain.IItemRepository) *ItemUseCase {
	return &ItemUseCase{repo: repo}
}

func (uc *ItemUseCase) CreateItem(ctx context.Context, item *domain.Item) error {
	item.CreatedAt = time.Now()
	item.UpdatedAt = time.Now()
	return uc.repo.CreateItem(ctx, item)
}

func (uc *ItemUseCase) UpdateItem(ctx context.Context, id string, item *domain.Item) error {
	item.UpdatedAt = time.Now()
	return uc.repo.UpdateItem(ctx, id, item)
}

func (uc *ItemUseCase) GetItemByID(ctx context.Context, id string) (*domain.Item, error) {
	return uc.repo.GetItemByID(ctx, id)
}

func (uc *ItemUseCase) AddReview(ctx context.Context, itemID, reviewID string) error {
	return uc.repo.AddReview(ctx, itemID, reviewID)
}
