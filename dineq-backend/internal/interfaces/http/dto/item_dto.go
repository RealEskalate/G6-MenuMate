package dto

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// NutritionalInfoDTO mirrors domain.NutritionalInfo for transport
type NutritionalInfoDTO struct {
	Calories int `json:"calories"`
	Protein  int `json:"protein"`
	Carbs    int `json:"carbs"`
	Fat      int `json:"fat"`
}

// ItemRequest represents data needed to create/update an item
type ItemRequest struct {
	ID              string              `json:"id,omitempty"`
	Name            string              `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm          string              `json:"name_am" validate:"required_without=name,omitempty"`
	Slug            string              `json:"slug,omitempty"`
	MenuSlug        string              `json:"menu_slug,omitempty"`
	Description     string              `json:"description,omitempty"`
	DescriptionAm   string              `json:"description_am,omitempty"`
	Image           []string            `json:"image,omitempty"`
	Price           float64             `json:"price" validate:"required,gt=0"`
	Currency        string              `json:"currency" validate:"required"`
	Allergies       FlexibleAllergies   `json:"allergies,omitempty"`
	AllergiesAm     string              `json:"allergies_am,omitempty"`
	UserImages      []string            `json:"user_images,omitempty"`
	TabTags         []string            `json:"tab_tags,omitempty"`
	TabTagsAm       []string            `json:"tab_tags_am,omitempty"`
	Calories        int                 `json:"calories,omitempty" validate:"gte=0"` // backward compatibility (flattened)
	Protein         int                 `json:"protein,omitempty" validate:"gte=0"`
	Carbs           int                 `json:"carbs,omitempty" validate:"gte=0"`
	Fat             int                 `json:"fat,omitempty" validate:"gte=0"`
	NutritionalInfo *NutritionalInfoDTO `json:"nutritional_info,omitempty"`
	Ingredients     []string            `json:"ingredients,omitempty"`
	IngredientsAm   []string            `json:"ingredients_am,omitempty"`
	PreparationTime int                 `json:"preparation_time,omitempty" validate:"gte=0"`
	HowToEat        string              `json:"how_to_eat,omitempty"`
	HowToEatAm      string              `json:"how_to_eat_am,omitempty"`
}

// ItemResponse represents the outward facing item payload
type ItemResponse struct {
	ID              string              `json:"id"`
	Name            string              `json:"name"`
	NameAm          string              `json:"name_am"`
	Slug            string              `json:"slug"`
	MenuSlug        string              `json:"menu_slug"`
	Description     string              `json:"description,omitempty"`
	DescriptionAm   string              `json:"description_am,omitempty"`
	Image           []string            `json:"image,omitempty"`
	Price           float64             `json:"price"`
	Currency        string              `json:"currency"`
	Allergies       []string            `json:"allergies,omitempty"`
	AllergiesAm     string              `json:"allergies_am,omitempty"`
	UserImages      []string            `json:"user_images,omitempty"`
	TabTags         []string            `json:"tab_tags,omitempty"`
	TabTagsAm       []string            `json:"tab_tags_am,omitempty"`
	Calories        int                 `json:"calories,omitempty"`
	Protein         int                 `json:"protein,omitempty"`
	Carbs           int                 `json:"carbs,omitempty"`
	Fat             int                 `json:"fat,omitempty"`
	NutritionalInfo *NutritionalInfoDTO `json:"nutritional_info,omitempty"`
	Ingredients     []string            `json:"ingredients,omitempty"`
	IngredientsAm   []string            `json:"ingredients_am,omitempty"`
	PreparationTime int                 `json:"preparation_time,omitempty"`
	HowToEat        string              `json:"how_to_eat,omitempty"`
	HowToEatAm      string              `json:"how_to_eat_am,omitempty"`
	CreatedAt       time.Time           `json:"created_at"`
	UpdatedAt       time.Time           `json:"updated_at"`
	IsDeleted       bool                `json:"is_deleted"`
	ViewCount       int                 `json:"view_count"`
	AverageRating   float64             `json:"average_rating"`
	ReviewIDs       []string            `json:"review_ids"`
}

// ItemDTO consolidated struct (camelCase variant if needed by other layers)
type ItemDTO struct {
	ID              string              `json:"id"`
	Name            string              `json:"name"`
	NameAm          string              `json:"name_am,omitempty"`
	Slug            string              `json:"slug"`
	MenuSlug        string              `json:"menu_slug"`
	Description     string              `json:"description,omitempty"`
	DescriptionAm   string              `json:"description_am,omitempty"`
	Image           []string            `json:"image,omitempty"`
	Price           float64             `json:"price"`
	Currency        string              `json:"currency"`
	Allergies       []string            `json:"allergies,omitempty"`
	AllergiesAm     string              `json:"allergies_am,omitempty"`
	TabTags         []string            `json:"tab_tags,omitempty"`
	TabTagsAm       []string            `json:"tab_tags_am,omitempty"`
	UserImages      []string            `json:"user_images,omitempty"`
	Calories        int                 `json:"calories,omitempty"`
	Protein         int                 `json:"protein,omitempty"`
	Carbs           int                 `json:"carbs,omitempty"`
	Fat             int                 `json:"fat,omitempty"`
	NutritionalInfo *NutritionalInfoDTO `json:"nutritional_info,omitempty"`
	Ingredients     []string            `json:"ingredients,omitempty"`
	IngredientsAm   []string            `json:"ingredients_am,omitempty"`
	PreparationTime int                 `json:"preparation_time,omitempty"`
	HowToEat        string              `json:"how_to_eat,omitempty"`
	HowToEatAm      string              `json:"how_to_eat_am,omitempty"`
	CreatedAt       time.Time           `json:"created_at"`
	UpdatedAt       time.Time           `json:"updated_at"`
	IsDeleted       bool                `json:"is_deleted"`
	ViewCount       int                 `json:"view_count"`
	AverageRating   float64             `json:"average_rating"`
	ReviewIDs       []string            `json:"review_ids"`
}

// Validate basic required fields for ItemDTO
func (i *ItemDTO) Validate() error {
	if i.Name == "" || i.MenuSlug == "" || i.Price <= 0 {
		return fmt.Errorf("item name, menu_slug, and positive price are required")
	}
	return nil
}

// ToDomain converts ItemDTO to domain.Item
func (i *ItemDTO) ToDomain() *domain.Item {
	var nutri *domain.NutritionalInfo
	if i.NutritionalInfo != nil {
		nutri = &domain.NutritionalInfo{Calories: i.NutritionalInfo.Calories, Protein: i.NutritionalInfo.Protein, Carbs: i.NutritionalInfo.Carbs, Fat: i.NutritionalInfo.Fat}
	}
	return &domain.Item{
		ID:              i.ID,
		Name:            i.Name,
		NameAm:          i.NameAm,
		Slug:            i.Slug,
		MenuSlug:        i.MenuSlug,
		Description:     i.Description,
		DescriptionAm:   i.DescriptionAm,
		Image:           i.Image,
		Price:           i.Price,
		Currency:        i.Currency,
		Allergies:       i.Allergies,
		AllergiesAm:     i.AllergiesAm,
		TabTags:         i.TabTags,
		TabTagsAm:       i.TabTagsAm,
		UserImages:      i.UserImages,
		Calories:        i.Calories,
		Protein:         i.Protein,
		Carbs:           i.Carbs,
		Fat:             i.Fat,
		NutritionalInfo: nutri,
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

// FromDomain populates ItemDTO from domain.Item
func (i *ItemDTO) FromDomain(item *domain.Item) *ItemDTO {
	if item == nil {
		return nil
	}
	var nutri *NutritionalInfoDTO
	if item.NutritionalInfo != nil {
		nutri = &NutritionalInfoDTO{Calories: item.NutritionalInfo.Calories, Protein: item.NutritionalInfo.Protein, Carbs: item.NutritionalInfo.Carbs, Fat: item.NutritionalInfo.Fat}
	}
	return &ItemDTO{
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
		AllergiesAm:     item.AllergiesAm,
		TabTags:         item.TabTags,
		TabTagsAm:       item.TabTagsAm,
		UserImages:      item.UserImages,
		Calories:        item.Calories,
		Protein:         item.Protein,
		Carbs:           item.Carbs,
		Fat:             item.Fat,
		NutritionalInfo: nutri,
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

// RequestToItem converts creation request to domain.Item
func RequestToItem(r *ItemRequest) *domain.Item {
	if r == nil {
		return nil
	}
	var nutri *domain.NutritionalInfo

	if r.NutritionalInfo != nil {
		nutri = &domain.NutritionalInfo{Calories: r.NutritionalInfo.Calories, Protein: r.NutritionalInfo.Protein, Carbs: r.NutritionalInfo.Carbs, Fat: r.NutritionalInfo.Fat}
	} else if r.Calories != 0 || r.Protein != 0 || r.Carbs != 0 || r.Fat != 0 {
		nutri = &domain.NutritionalInfo{Calories: r.Calories, Protein: r.Protein, Carbs: r.Carbs, Fat: r.Fat}
	}
	return &domain.Item{
		ID:              r.ID,
		Name:            r.Name,
		NameAm:          r.NameAm,
		Slug:            r.Slug,
		MenuSlug:        r.MenuSlug,
		Description:     r.Description,
		DescriptionAm:   r.DescriptionAm,
		Image:           r.Image,
		Price:           r.Price,
		Currency:        r.Currency,
		Allergies:       r.Allergies.ToSlice(),
		AllergiesAm:     r.AllergiesAm,
		UserImages:      r.UserImages,
		TabTags:         r.TabTags,
		TabTagsAm:       r.TabTagsAm,
		Calories:        r.Calories,
		Protein:         r.Protein,
		Carbs:           r.Carbs,
		Fat:             r.Fat,
		NutritionalInfo: nutri,
		Ingredients:     r.Ingredients,
		IngredientsAm:   r.IngredientsAm,
		PreparationTime: r.PreparationTime,
		HowToEat:        r.HowToEat,
		HowToEatAm:      r.HowToEatAm,
	}
}

// FlexibleAllergies allows a JSON field to be either a string sentence or an array of strings
type FlexibleAllergies []string

func (fa *FlexibleAllergies) UnmarshalJSON(data []byte) error {
	// If it's a quoted string treat as single element
	var single string
	if err := json.Unmarshal(data, &single); err == nil {
		if single == "" {
			*fa = nil
		} else {
			*fa = []string{single}
		}
		return nil
	}
	// Try slice
	var arr []string
	if err := json.Unmarshal(data, &arr); err == nil {
		*fa = FlexibleAllergies(arr)
		return nil
	}
	// Fallback: ignore invalid type
	*fa = nil
	return nil
}

func (fa FlexibleAllergies) ToSlice() []string { return []string(fa) }

// ItemToResponse converts a domain item to response DTO
func ItemToResponse(item *domain.Item) *ItemResponse {
	if item == nil {
		return nil
	}
	var nutri *NutritionalInfoDTO
	if item.NutritionalInfo != nil {
		nutri = &NutritionalInfoDTO{Calories: item.NutritionalInfo.Calories, Protein: item.NutritionalInfo.Protein, Carbs: item.NutritionalInfo.Carbs, Fat: item.NutritionalInfo.Fat}
	}
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
		AllergiesAm:     item.AllergiesAm,
		UserImages:      item.UserImages,
		TabTags:         item.TabTags,
		TabTagsAm:       item.TabTagsAm,
		Calories:        item.Calories,
		Protein:         item.Protein,
		Carbs:           item.Carbs,
		Fat:             item.Fat,
		NutritionalInfo: nutri,
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

// ItemToResponseList converts slice domain -> slice response
func ItemToResponseList(items []domain.Item) []ItemResponse {
	out := make([]ItemResponse, 0, len(items))
	for i := range items {
		out = append(out, *ItemToResponse(&items[i]))
	}
	return out
}

// ItemSearchQuery represents query params for filtering items within a menu
type ItemSearchQuery struct {
	MenuSlug  string   `form:"menu_slug" binding:"required"`
	Tags      []string `form:"tags[]"`
	MinPrice  *float64 `form:"min_price"`
	MaxPrice  *float64 `form:"max_price"`
	MinRating *float64 `form:"min_rating"`
	Q         string   `form:"q"`
	SortBy    string   `form:"sort_by"`
	Order     int      `form:"order"`
	Page      int      `form:"page"`
	PageSize  int      `form:"pageSize"`
}

func (q *ItemSearchQuery) ToDomain() domain.ItemFilter {
	return domain.ItemFilter{
		MenuSlug:  q.MenuSlug,
		Tags:      q.Tags,
		MinPrice:  q.MinPrice,
		MaxPrice:  q.MaxPrice,
		MinRating: q.MinRating,
		Query:     q.Q,
		SortBy:    q.SortBy,
		Order:     q.Order,
		Page:      q.Page,
		PageSize:  q.PageSize,
	}
}
