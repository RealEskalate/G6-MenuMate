package domain

import (
	"context"
	"time"
)

type Item struct {
	ID              string           `json:"id"`
	Name            string           `json:"name"`
	NameAm          string           `json:"name_am"`
	Slug            string           `json:"slug"`
	MenuSlug        string           `json:"menu_slug"`
	Description     string           `json:"description"`
	DescriptionAm   string           `json:"description_am"`
	Image           []string         `json:"image"`
	ThumbnailImages []string         `json:"thumbnail_images"`
	Price           float64          `json:"price"`
	Currency        string           `json:"currency"`
	Allergies       []string         `json:"allergies"`
	AllergiesAm     string           `json:"allergies_am"`
	UserImages      []string         `json:"user_images"`
	TabTags         []string         `json:"tab_tags"`
	TabTagsAm       []string         `json:"tab_tags_am"`
	Calories        int              `json:"calories"`
	Protein         int              `json:"protein"`
	Carbs           int              `json:"carbs"`
	Fat             int              `json:"fat"`
	NutritionalInfo *NutritionalInfo `json:"nutritional_info,omitempty"`
	Ingredients     []string         `json:"ingredients"`
	IngredientsAm   []string         `json:"ingredients_am"`
	PreparationTime int              `json:"preparation_time"`
	HowToEat        string           `json:"how_to_eat"`
	HowToEatAm      string           `json:"how_to_eat_am"`
	CreatedAt       time.Time        `json:"created_at"`
	UpdatedAt       time.Time        `json:"updated_at"`
	IsDeleted       bool             `json:"is_deleted"`
	ViewCount       int              `json:"view_count"`
	AverageRating   float64          `json:"average_rating"`
	ReviewIds       []string         `json:"review_ids"`
}

type NutritionalInfo struct {
	Calories  int `json:"calories"`
	Protein   int `json:"protein"`
	Carbs     int `json:"carbs"`
	Fat       int `json:"fat"`
	DeletedAt *time.Time
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
