package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type ItemDB struct {
	ID              bson.ObjectID `bson:"_id,omitempty"`
	Name            string        `bson:"name"`
	NameAm          string        `bson:"nameAm"`
	Slug            string        `bson:"slug"`
	MenuSlug       string        `bson:"menuSlug"`
	Description     string        `bson:"description"`
	DescriptionAm   string        `bson:"descriptionAm"`
	Image           []string      `bson:"image"`
	Price           float64       `bson:"price"`
	CategoryTags    []string      `bson:"categoryTags"`
	Currency        string        `bson:"currency"`
	Allergies       []string      `bson:"allergies"`
	AllergiesAm     string    `bson:"allergiesAm"`
	UserImages      []string      `bson:"userImages"`
	Calories        int           `bson:"calories"`
	Protein         int       `bson:"protein"`
	Carbs           int       `bson:"carbs"`
	Fat             int       `bson:"fat"`
	NutritionalInfo *domain.NutritionalInfo `bson:"nutritionalInfo,omitempty"`
	TabTags         []string  `bson:"tabTags"`
	TabTagsAm       []string  `bson:"tabTagsAm"`
	Ingredients     []string      `bson:"ingredients"`
	IngredientsAm   []string      `bson:"ingredientsAm"`
	PreparationTime int           `bson:"preparationTime"`
	HowToEat        string        `bson:"howToEat"`
	HowToEatAm      string        `bson:"howToEatAm"`
	CreatedAt       time.Time     `bson:"createdAt"`
	UpdatedAt       time.Time     `bson:"updatedAt"`
	IsDeleted       bool          `bson:"isDeleted"`
	ViewCount       int           `bson:"viewCount"`
	AverageRating   float64       `bson:"averageRating"`
	ReviewIDs       []string      `bson:"reviewIds"`
	DeletedAt       *time.Time    `bson:"deletedAt,omitempty"`
}

// ---------- Creation ----------

func NewItemDBFromDomain(item *domain.Item) *ItemDB {
	now := time.Now().UTC()
	itemId := idempotentID(item.ID)
	item.ID = itemId.Hex()

	return &ItemDB{
		ID:              itemId,
		Name:            item.Name,
		NameAm:          item.NameAm,
		Slug:            item.Slug,
		MenuSlug:       item.MenuSlug,
		Description:     item.Description,
		DescriptionAm:   item.DescriptionAm,
		Image:           item.Image,
		Price:           item.Price,
		CategoryTags:    item.CategoryTags,
		Currency:        item.Currency,
		Allergies:       item.Allergies,
		AllergiesAm:     item.AllergiesAm,
		UserImages:      item.UserImages,
		Calories:        item.Calories,
		Protein:         item.Protein,
		Carbs:           item.Carbs,
		Fat:             item.Fat,
		NutritionalInfo: item.NutritionalInfo,
		TabTags:         item.TabTags,
		TabTagsAm:       item.TabTagsAm,
		Ingredients:     item.Ingredients,
		IngredientsAm:   item.IngredientsAm,
		PreparationTime: item.PreparationTime,
		HowToEat:        item.HowToEat,
		HowToEatAm:      item.HowToEatAm,
		CreatedAt:       now,
		UpdatedAt:       now,
		IsDeleted:       false,
		ViewCount:       0,
		AverageRating:   0,
		ReviewIDs:       []string{},
		DeletedAt:       nil,
	}
}

// ---------- Update ----------

func MergeItemUpdate(updated *domain.Item) *ItemDB {
	return &ItemDB{
		ID:              idempotentID(updated.ID),
		Name:            updated.Name,
		NameAm:          updated.NameAm,
		Slug:            updated.Slug,
		MenuSlug:       updated.MenuSlug,
		Description:     updated.Description,
		DescriptionAm:   updated.DescriptionAm,
		Image:           updated.Image,
		Price:           updated.Price,
		TabTags:         updated.TabTags,
		CategoryTags:    updated.CategoryTags,
		Currency:        updated.Currency,
		Allergies:       updated.Allergies,
		UserImages:      updated.UserImages,
		Calories:        updated.Calories,
		Ingredients:     updated.Ingredients,
		IngredientsAm:   updated.IngredientsAm,
		PreparationTime: updated.PreparationTime,
		HowToEat:        updated.HowToEat,
		HowToEatAm:      updated.HowToEatAm,
		CreatedAt:       time.Now().UTC(),
		UpdatedAt:       time.Now().UTC(),
		IsDeleted:       updated.IsDeleted,
		ViewCount:       updated.ViewCount,
		AverageRating:   updated.AverageRating,
		ReviewIDs:       updated.ReviewIds,
	}
}


// ---------- Conversion ----------

func ToDomainItem(item *ItemDB) *domain.Item {
	return &domain.Item{
		ID:              item.ID.Hex(),
		Name:            item.Name,
		NameAm:          item.NameAm,
		Slug:            item.Slug,
		Description:     item.Description,
		DescriptionAm:   item.DescriptionAm,
		Image:           item.Image,
		Price:           item.Price,
		Currency:        item.Currency,
		TabTags:         item.TabTags,
		CategoryTags:    item.CategoryTags,
		Allergies:       item.Allergies,
		AllergiesAm:     item.AllergiesAm,
		UserImages:      item.UserImages,
		Calories:        item.Calories,
		Protein:         item.Protein,
		Carbs:           item.Carbs,
		Fat:             item.Fat,
		NutritionalInfo: item.NutritionalInfo,
		TabTagsAm:       item.TabTagsAm,
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

func ItemDBToDomainList(items []ItemDB) []domain.Item {
	var domains []domain.Item
	for _, item := range items {
		domains = append(domains, *ToDomainItem(&item))
	}
	return domains
}
