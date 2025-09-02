package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// MenuRequestDTO represents the structure for menu creation/update requests.
type MenuRequest struct {
	RestaurantID string       `json:"restaurant_id" validate:"required"`
	Version      int          `json:"version,omitempty"`
	IsPublished  bool         `json:"is_published,omitempty"`
	Tabs         []TabRequest `json:"tabs" validate:"required"`
}

// MenuResponse represents the structure for menu responses.
type MenuResponse struct {
	ID           string        `json:"id,omitempty"`
	RestaurantID string        `json:"restaurant_id,omitempty"`
	Version      int           `json:"version,omitempty"`
	IsPublished  bool          `json:"is_published,omitempty"`
	PublishedAt  time.Time     `json:"published_at,omitempty"`
	Tabs         []TabResponse `json:"tabs" validate:"required"`
	CreatedAt    time.Time     `json:"created_at,omitempty"`
	UpdatedAt    time.Time     `json:"updated_at,omitempty"`
	UpdatedBy    string        `json:"updated_by,omitempty"`
	IsDeleted    bool          `json:"is_deleted,omitempty"`
	ViewCount    int           `json:"view_count,omitempty"`
}

// TabRequestDTO represents the structure for tab creation/update requests.
type TabRequest struct {
	Name       string            `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm     string            `json:"name_am" validate:"required_without=name,omitempty"`
	Categories []CategoryRequest `json:"categories" validate:"required"`
}

// TabResponseDTO represents the structure for tab responses.
type TabResponse struct {
	ID         string             `json:"id,omitempty"`
	MenuID     string             `json:"menu_id,omitempty"`
	Name       string             `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm     string             `json:"name_am" validate:"required_without=name,omitempty"`
	Categories []CategoryResponse `json:"categories" validate:"required"`
	IsDeleted  bool               `json:"is_deleted,omitempty"`
}

// CategoryRequest represents the structure for category creation/update requests.
type CategoryRequest struct {
	Name   string        `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm string        `json:"name_am" validate:"required_without=name,omitempty"`
	Items  []ItemRequest `json:"items,omitempty"`
}

// CategoryResponse represents the structure for category responses.
type CategoryResponse struct {
	ID     string         `json:"id,omitempty"`
	TabID  string         `json:"tab_id,omitempty"`
	Name   string         `json:"name" validate:"required_without=name_am,omitempty"`
	NameAm string         `json:"name_am" validate:"required_without=name,omitempty"`
	Items  []ItemResponse `json:"items,omitempty"`
}

// RequestToMenu converts a MenuRequest to a domain Menu.
func RequestToMenu(dto *MenuRequest) *domain.Menu {
	if dto == nil {
		return nil
	}
	tabs := make([]domain.Tab, len(dto.Tabs))
	for i, tabDTO := range dto.Tabs {
		tabs[i] = *RequestToTab(&tabDTO)
	}
	return &domain.Menu{
		RestaurantID: dto.RestaurantID,
		Version:      dto.Version,
		IsPublished:  dto.IsPublished,
		Tabs:         tabs,
	}
}

// MenuToResponse converts a domain Menu to a MenuResponse.
func MenuToResponse(menu *domain.Menu) *MenuResponse {
	if menu == nil {
		return nil
	}
	tabs := make([]TabResponse, len(menu.Tabs))
	for i, tab := range menu.Tabs {
		tabs[i] = *TabToResponse(&tab)
	}
	return &MenuResponse{
		ID:           menu.ID,
		RestaurantID: menu.RestaurantID,
		Version:      menu.Version,
		IsPublished:  menu.IsPublished,
		PublishedAt:  menu.PublishedAt,
		Tabs:         tabs,
		CreatedAt:    menu.CreatedAt,
		UpdatedAt:    menu.UpdatedAt,
		UpdatedBy:    menu.UpdatedBy,
		IsDeleted:    menu.IsDeleted,
		ViewCount:    menu.ViewCount,
	}
}

// RequestToTab converts a TabRequest to a domain Tab.
func RequestToTab(dto *TabRequest) *domain.Tab {
	if dto == nil {
		return nil
	}
	categories := make([]domain.Category, len(dto.Categories))
	for i, catDTO := range dto.Categories {
		categories[i] = *RequestToCategory(&catDTO)
	}
	return &domain.Tab{
		Name:       dto.Name,
		NameAm:     dto.NameAm,
		Categories: categories,
	}
}

// TabToResponse converts a domain Tab to a TabResponse.
func TabToResponse(tab *domain.Tab) *TabResponse {
	if tab == nil {
		return nil
	}
	categories := make([]CategoryResponse, len(tab.Categories))
	for i, cat := range tab.Categories {
		categories[i] = *CategoryToResponse(&cat)
	}
	return &TabResponse{
		ID:         tab.ID,
		MenuID:     tab.MenuID,
		Name:       tab.Name,
		NameAm:     tab.NameAm,
		Categories: categories,
		IsDeleted:  tab.IsDeleted,
	}
}

// RequestToCategory converts a CategoryRequest to a domain Category.
func RequestToCategory(dto *CategoryRequest) *domain.Category {
	if dto == nil {
		return nil
	}
	items := make([]domain.Item, len(dto.Items))
	for i, itemDTO := range dto.Items {
		items[i] = *RequestToItem(&itemDTO)
	}
	return &domain.Category{
		Name:   dto.Name,
		NameAm: dto.NameAm,
		Items:  items,
	}
}

// CategoryToResponse converts a domain Category to a CategoryResponse.
func CategoryToResponse(cat *domain.Category) *CategoryResponse {
	if cat == nil {
		return nil
	}
	items := make([]ItemResponse, len(cat.Items))
	for i, item := range cat.Items {
		items[i] = *ItemToResponse(&item)
	}
	return &CategoryResponse{
		ID:     cat.ID,
		TabID:  cat.TabID,
		Name:   cat.Name,
		NameAm: cat.NameAm,
		Items:  items,
	}
}
