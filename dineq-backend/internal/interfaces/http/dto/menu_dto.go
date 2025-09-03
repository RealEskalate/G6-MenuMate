package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// MenuRequestDTO represents the structure for menu creation/update requests.
type MenuRequest struct {
	RestaurantID string        `json:"restaurant_id" validate:"required"`
	Version      int           `json:"version,omitempty"`
	IsPublished  bool          `json:"is_published,omitempty"`
	Items        []ItemRequest `json:"items"`
}

// MenuResponse represents the structure for menu responses.
type MenuResponse struct {
	ID           string         `json:"id"`
	RestaurantID string         `json:"restaurant_id"`
	Slug         string         `json:"slug"`
	Version      int            `json:"version"`
	IsPublished  bool           `json:"is_published"`
	PublishedAt  time.Time      `json:"published_at"`
	Items        []ItemResponse `json:"items"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	UpdatedBy    string         `json:"updated_by"`
	IsDeleted    bool           `json:"is_deleted"`
	ViewCount    int            `json:"view_count"`
	DeletedAt    *time.Time     `json:"deleted_at"`
}

// RequestToMenu converts a MenuRequest to a domain Menu.
func RequestToMenu(dto *MenuRequest) *domain.Menu {
	if dto == nil {
		return nil
	}
	items := make([]domain.Item, len(dto.Items))
	for i, itemDTO := range dto.Items {
		items[i] = *RequestToItem(&itemDTO)
	}
	return &domain.Menu{
		RestaurantID: dto.RestaurantID,
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
	return &MenuResponse{
		ID:           menu.ID,
		RestaurantID: menu.RestaurantID,
		Slug:         menu.Slug,
		Version:      menu.Version,
		IsPublished:  menu.IsPublished,
		PublishedAt:  menu.PublishedAt,
		Items:        items,
		CreatedAt:    menu.CreatedAt,
		UpdatedAt:    menu.UpdatedAt,
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
