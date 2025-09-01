package dto

import (
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ItemDTO represents the data transfer object for an Item
type ItemDTO struct {
	ID              string    `json:"id"`
	Name            string    `json:"name"`
	NameAm          string    `json:"nameAm,omitempty"`
	Slug            string    `json:"slug"`
	CategoryID      string    `json:"categoryId"`
	Description     string    `json:"description,omitempty"`
	DescriptionAm   string    `json:"descriptionAm,omitempty"`
	Image           []string  `json:"image,omitempty"`
	Price           float64   `json:"price"`
	Currency        string    `json:"currency"`
	Allergies       []string  `json:"allergies,omitempty"`
	UserImages      []string  `json:"userImages,omitempty"`
	Calories        int       `json:"calories,omitempty"`
	Ingredients     []string  `json:"ingredients,omitempty"`
	IngredientsAm   []string  `json:"ingredientsAm,omitempty"`
	PreparationTime int       `json:"preparationTime,omitempty"`
	HowToEat        any       `json:"howToEat,omitempty"`
	HowToEatAm      any       `json:"howToEatAm,omitempty"`
	CreatedAt       time.Time `json:"createdAt"`
	UpdatedAt       time.Time `json:"updatedAt"`
	IsDeleted       bool      `json:"isDeleted"`
	ViewCount       int       `json:"viewCount"`
	AverageRating   float64   `json:"averageRating"`
	ReviewIDs       []string  `json:"reviewIds"`
}

// Validate checks the ItemDTO for required fields
func (i *ItemDTO) Validate() error {
	if i.Name == "" || i.CategoryID == "" || i.Price <= 0 {
		return fmt.Errorf("item name, categoryID, and positive price are required")
	}
	return nil
}

// ToDomain converts the ItemDTO to a domain.Item entity
func (i *ItemDTO) ToDomain() *domain.Item {
	return &domain.Item{
		ID:              i.ID,
		Name:            i.Name,
		NameAm:          i.NameAm,
		Slug:            i.Slug,
		CategoryID:      i.CategoryID,
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
		CreatedAt:       i.CreatedAt,
		UpdatedAt:       i.UpdatedAt,
		IsDeleted:       i.IsDeleted,
		ViewCount:       i.ViewCount,
		AverageRating:   i.AverageRating,
		ReviewIds:       i.ReviewIDs,
	}
}

// FromDomain converts a domain.Item entity to an ItemDTO
func (i *ItemDTO) FromDomain(item *domain.Item) *ItemDTO {
	return &ItemDTO{
		ID:              item.ID,
		Name:            item.Name,
		NameAm:          item.NameAm,
		Slug:            item.Slug,
		CategoryID:      item.CategoryID,
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
