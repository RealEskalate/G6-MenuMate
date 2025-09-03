package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ItemRequest represents the data transfer object for creating or updating an Item
type ItemRequest struct {
	Name            string   `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm          string   `json:"name_am" validate:"required_without=name,omitempty"`
	Slug            string   `json:"slug,omitempty"`
	CategoryID      string   `json:"category_id"`
	Description     string   `json:"description,omitempty"`
	DescriptionAm   string   `json:"description_am,omitempty"`
	Image           []string `json:"image,omitempty"`
	Price           float64  `json:"price" validate:"required,gt=0"`
	Currency        string   `json:"currency" validate:"required"`
	Allergies       []string `json:"allergies,omitempty"`
	UserImages      []string `json:"user_images,omitempty"`
	Calories        int      `json:"calories,omitempty" validate:"gte=0"`
	Ingredients     []string `json:"ingredients,omitempty"`
	IngredientsAm   []string `json:"ingredients_am,omitempty"`
	PreparationTime int      `json:"preparation_time,omitempty" validate:"gte=0"`
	HowToEat        any      `json:"how_to_eat,omitempty"`
	HowToEatAm      any      `json:"how_to_eat_am,omitempty"`
}

// ItemResponse represents the data transfer object for returning an Item
type ItemResponse struct {
	ID              string    `json:"id"`
	Name            string    `json:"name" validate:"required_without=name_am"`
	NameAm          string    `json:"name_am" validate:"required_without=name"`
	Slug            string    `json:"slug"`
	MenuSlug        string    `json:"menu_slug"`
	Description     string    `json:"description"`
	DescriptionAm   string    `json:"description_am"`
	Image           []string  `json:"image"`
	Price           float64   `json:"price" validate:"required,gt=0"`
	Currency        string    `json:"currency" validate:"required"`
	TabTags         []string  `json:"tab_tags"`
	CategoryTags	[]string  `json:"category_tags"`
	Allergies       []string  `json:"allergies"`
	UserImages      []string  `json:"user_images"`
	Calories        int       `json:"calories" validate:"gte=0"`
	Ingredients     []string  `json:"ingredients"`
	IngredientsAm   []string  `json:"ingredients_am"`
	PreparationTime int       `json:"preparation_time" validate:"gte=0"`
	HowToEat        any       `json:"how_to_eat"`
	HowToEatAm      any       `json:"how_to_eat_am"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	IsDeleted       bool      `json:"is_deleted"`
	ViewCount       int       `json:"view_count" validate:"gte=0"`
	AverageRating   float64   `json:"average_rating" validate:"gte=0,lte=5"`
	ReviewIDs       []string  `json:"review_ids"`
}

// ToDomain converts the ItemRequest to a domain.Item entity
func RequestToItem(i *ItemRequest) *domain.Item {
	return &domain.Item{
		Name:            i.Name,
		NameAm:          i.NameAm,
		Slug:            i.Slug,
		Description:     i.Description,
		DescriptionAm:   i.DescriptionAm,
		Image:           i.Image,
		Price:           i.Price,
		Currency:        i.Currency,
		Allergies:       i.Allergies,
		UserImages:      i.UserImages,
		Calories:        i.Calories,
		Ingredients:     i.Ingredients,
		IngredientsAm:   i.IngredientsAm,
		PreparationTime: i.PreparationTime,
		HowToEat:        i.HowToEat,
		HowToEatAm:      i.HowToEatAm,
	}
}

// FromDomain converts a domain.Item entity to an ItemResponse
func ItemToResponse(item *domain.Item) *ItemResponse {
	return &ItemResponse{
		ID:              item.ID,
		Name:            item.Name,
		NameAm:          item.NameAm,
		Slug:            item.Slug,
		MenuSlug:        item.MenuSlug,
		Description:     item.Description,
		DescriptionAm:   item.DescriptionAm,
		Image:           item.Image,
		Price:           item.Price,
		Currency:        item.Currency,
		Allergies:       item.Allergies,
		UserImages:      item.UserImages,
		Calories:        item.Calories,
		Ingredients:     item.Ingredients,
		IngredientsAm:   item.IngredientsAm,
		PreparationTime: item.PreparationTime,
		HowToEat:        item.HowToEat,
		HowToEatAm:      item.HowToEatAm,
		CreatedAt:       item.CreatedAt,
		UpdatedAt:       item.UpdatedAt,
		IsDeleted:       item.IsDeleted,
		ViewCount:       item.ViewCount,
		AverageRating:   item.AverageRating,
		ReviewIDs:       item.ReviewIds,
	}
}

// ItemToResponseList converts a slice of domain.Item entities to a slice of ItemResponse
func ItemToResponseList(items []domain.Item) []ItemResponse {
	var responses []ItemResponse
	for _, item := range items {
		responses = append(responses, *ItemToResponse(&item))
	}
	return responses
}
