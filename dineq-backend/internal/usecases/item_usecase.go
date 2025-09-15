package usecase

import (
	"context"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ItemUseCase struct {
	repo       domain.IItemRepository
	ctxTimeout time.Duration
}

func NewItemUseCase(repo domain.IItemRepository, ctxTimeout time.Duration) domain.IItemUseCase {
	return &ItemUseCase{repo: repo, ctxTimeout: ctxTimeout}
}

func (uc *ItemUseCase) CreateItem(item *domain.Item) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	item.CreatedAt = time.Now()
	item.UpdatedAt = time.Now()
	item.Slug = utils.GenerateSlug(item.Name)
	return uc.repo.CreateItem(ctx, item)
}

func (uc *ItemUseCase) UpdateItem(id string, item *domain.Item) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	item.UpdatedAt = time.Now()
	return uc.repo.UpdateItem(ctx, id, item)
}

func (uc *ItemUseCase) GetItemByID(id string) (*domain.Item, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.GetItemByID(ctx, id)
}

func (uc *ItemUseCase) AddReview(itemID, reviewID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.AddReview(ctx, itemID, reviewID)
}

func (uc *ItemUseCase) GetItems(menuSlug string) ([]domain.Item, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.GetItems(ctx, menuSlug)
}

func (uc *ItemUseCase) DeleteItem(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()

	return uc.repo.DeleteItem(ctx, id)
}

// IncrementItemViewCount increments the view count for an item by 1
func (uc *ItemUseCase) IncrementItemViewCount(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	return uc.repo.IncrementItemViewCount(ctx, id)
}

// SearchItems returns items for a given menu using advanced filters
func (uc *ItemUseCase) SearchItems(filter domain.ItemFilter) ([]domain.Item, int64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	return uc.repo.SearchItems(ctx, filter)
}
