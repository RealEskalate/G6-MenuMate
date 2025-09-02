package domain

import (
	"context"
	"time"
)

type ItemRepository interface {
	GetByID(id string) (*Item, error)
	Create(i *Item) error
	Update(i *Item) error
	Delete(id string) error
	ListByMenu(menuID string) ([]Item, error)

}

type Item struct {
	ID              string
	Name            string
	NameAm          string
	Slug            string
	CategoryID      string
	Description     string
	DescriptionAm   string
	Image           []string
	Price           float64
	Currency        string
	Allergies       []string
	UserImages      []string
	Calories        int
	Ingredients     []string
	IngredientsAm   []string
	PreparationTime int
	HowToEat        any
	HowToEatAm      any
	CreatedAt       time.Time
	UpdatedAt       time.Time
	IsDeleted       bool
	ViewCount       int
	AverageRating   float64
	ReviewIds       []string
}

type IItemRepository interface {
	GetItemByID(ctx context.Context, id string) (*Item, error)
	CreateItem(ctx context.Context, item *Item) error
	UpdateItem(ctx context.Context, id string, item *Item) error
	DeleteItem(ctx context.Context, id string) error
	AddReview(ctx context.Context, itemID, reviewID string) error
}

type IItemUseCase interface {
	CreateItem(item *Item) error
	UpdateItem(id string, item *Item) error
	GetItemByID(id string) (*Item, error)
	AddReview(itemID, reviewID string) error
}
