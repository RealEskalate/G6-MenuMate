package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// MenuRequestDTO represents the structure for menu creation/update requests.
type MenuRequest struct {
	Name            string        `json:"name" validate:"required,min=2"`
	RestaurantSlug  string        `json:"restaurant_slug" validate:"required"`
	Version         int           `json:"version,omitempty"`
	IsPublished     bool          `json:"is_published,omitempty"`
	Items           []ItemRequest `json:"items"`
	MenuItems      []ItemRequest `json:"menu_items,omitempty"`
}

// MenuResponse represents the structure for menu responses.
type MenuResponse struct {
	ID           string         `json:"id"`
	Name         string         `json:"name"`
	RestaurantSlug string         `json:"restaurant_slug"`
	Slug         string         `json:"slug"`
	Version      int            `json:"version"`
	IsPublished  bool           `json:"is_published"`
	PublishedAt  *time.Time     `json:"published_at,omitempty"`
	Items        []ItemResponse `json:"items"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	CreatedBy    string         `json:"created_by"`
	UpdatedBy    string         `json:"updated_by"`
	IsDeleted    bool           `json:"is_deleted,omitempty"`
	ViewCount    int            `json:"view_count,omitempty"`
	DeletedAt    *time.Time     `json:"deleted_at,omitempty"`
}

// RequestToMenu converts a MenuRequest to a domain Menu.
func RequestToMenu(dto *MenuRequest) *domain.Menu {
	if dto == nil {
		return nil
	}
	// Normalize OCR alias
	if len(dto.Items) == 0 && len(dto.MenuItems) > 0 {
		dto.Items = dto.MenuItems
	}
	items := make([]domain.Item, len(dto.Items))
	for i, itemDTO := range dto.Items {
		items[i] = *RequestToItem(&itemDTO)
	}
	return &domain.Menu{
		Name:         dto.Name,
		RestaurantSlug: dto.RestaurantSlug,
		Version:      dto.Version,
		IsPublished:  dto.IsPublished,
		Items:        items,
	}
}

// MenuToResponse converts a domain Menu to a MenuResponse.
func MenuToResponse(menu *domain.Menu) *MenuResponse {
	if menu == nil {
		return nil
	}
	items := make([]ItemResponse, len(menu.Items))
	for i, item := range menu.Items {
		items[i] = *ItemToResponse(&item)
	}
	var publishedAtPtr *time.Time
	if menu.IsPublished && !menu.PublishedAt.IsZero() {
		pa := menu.PublishedAt
		publishedAtPtr = &pa
	}
	return &MenuResponse{
		ID:           menu.ID,
		Name:         menu.Name,
		RestaurantSlug: menu.RestaurantSlug,
		Slug:         menu.Slug,
		Version:      menu.Version,
		IsPublished:  menu.IsPublished,
		PublishedAt:  publishedAtPtr,
		Items:        items,
		CreatedAt:    menu.CreatedAt,
		UpdatedAt:    menu.UpdatedAt,
		CreatedBy:    menu.CreatedBy,
		UpdatedBy:    menu.UpdatedBy,
		IsDeleted:    menu.IsDeleted,
		ViewCount:    menu.ViewCount,
		DeletedAt:    menu.DeletedAt,
	}
}

func MenuResponseList(menus []*domain.Menu) []*MenuResponse {
	if menus == nil {
		return nil
	}
	res := make([]*MenuResponse, len(menus))
	for i, menu := range menus {
		res[i] = MenuToResponse(menu)
	}
	return res
}
