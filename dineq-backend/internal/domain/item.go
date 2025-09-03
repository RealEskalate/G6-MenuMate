package domain

import (
	"context"
	"time"
)

type Item struct {
	ID              string
	Name            string
	NameAm          string
	Slug            string
	MenuSlug        string
	Description     string
	DescriptionAm   string
	TabTags        []string   // e.g. Drinks, Pizza, Pasta
	CategoryTags   []string   // e.g. Appetizers, Main Course, Desserts
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
	DeletedAt       *time.Time
}

type IItemRepository interface {
	GetItemByID(ctx context.Context, id string) (*Item, error)
	CreateItem(ctx context.Context, item *Item) error
	UpdateItem(ctx context.Context, id string, item *Item) error
	DeleteItem(ctx context.Context, id string) error
	AddReview(ctx context.Context, itemID, reviewID string) error
	GetItems(ctx context.Context, menuSlug string) ([]Item, error)
}

type IItemUseCase interface {
	CreateItem(item *Item) error
	UpdateItem(id string, item *Item) error
	GetItems(menuSlug string) ([]Item, error)
	GetItemByID(id string) (*Item, error)
	AddReview(itemID, reviewID string) error
	DeleteItem(id string) error
}
