package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ItemDB struct {
	ID              string    `bson:"_id"`
	Name            string    `bson:"name"`
	NameAm          string    `bson:"nameAm"`
	Slug            string    `bson:"slug"`
	CategoryID      string    `bson:"categoryId"`
	Description     string    `bson:"description"`
	DescriptionAm   string    `bson:"descriptionAm"`
	Image           []string  `bson:"image"`
	Price           float64   `bson:"price"`
	Currency        string    `bson:"currency"`
	Allergies       []string  `bson:"allergies"`
	UserImages      []string  `bson:"userImages"`
	Calories        int       `bson:"calories"`
	Ingredients     []string  `bson:"ingredients"`
	IngredientsAm   []string  `bson:"ingredientsAm"`
	PreparationTime int       `bson:"preparationTime"`
	HowToEat        any       `bson:"howToEat"`
	HowToEatAm      any       `bson:"howToEatAm"`
	CreatedAt       time.Time `bson:"createdAt"`
	UpdatedAt       time.Time `bson:"updatedAt"`
	IsDeleted       bool      `bson:"isDeleted"`
	ViewCount       int       `bson:"viewCount"`
	AverageRating   float64   `bson:"averageRating"`
	ReviewIDs       []string  `bson:"reviewIds"`
}

func FromDomainItem(item *domain.Item) *ItemDB {
	return &ItemDB{
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

func ToDomainItem(item *ItemDB) *domain.Item {
	return &domain.Item{
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
		ReviewIds:       item.ReviewIDs,
	}
}
