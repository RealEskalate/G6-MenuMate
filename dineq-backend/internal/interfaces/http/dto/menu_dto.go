package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type MenuDTO struct {
	ID           string    `json:"id"`
	RestaurantID string    `json:"restaurantId"`
	Version      int       `json:"version"`
	IsPublished  bool      `json:"isPublished"`
	PublishedAt  time.Time `json:"publishedAt"`
	Tabs         []TabDTO  `json:"tabs"`
	CreatedAt    time.Time `json:"createdAt"`
	UpdatedAt    time.Time `json:"updatedAt"`
	UpdatedBy    string    `json:"updatedBy"`
	IsDeleted    bool      `json:"isDeleted"`
	ViewCount    int       `json:"viewCount"`
}

type TabDTO struct {
	ID         string        `json:"id"`
	MenuID     string        `json:"menuId"`
	Name       string        `json:"name"`
	NameAm     string        `json:"nameAm"`
	Categories []CategoryDTO `json:"categories"`
	IsDeleted  bool          `json:"isDeleted"`
}

type CategoryDTO struct {
	ID     string    `json:"id"`
	TabID  string    `json:"tabId"`
	Name   string    `json:"name"`
	NameAm string    `json:"nameAm"`
	Items  []ItemDTO `json:"items"`
}

// MenuToDTO converts a domain Menu to a MenuDTO.
func MenuToDTO(menu *domain.Menu) *MenuDTO {
	if menu == nil {
		return nil
	}
	tabs := make([]TabDTO, len(menu.Tabs))
	for i, tab := range menu.Tabs {
		tabs[i] = *TabToDTO(&tab)
	}
	return &MenuDTO{
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

// DTOToMenu converts a MenuDTO to a domain Menu.
func DTOToMenu(dto *MenuDTO) *domain.Menu {
	if dto == nil {
		return nil
	}
	tabs := make([]domain.Tab, len(dto.Tabs))
	for i, tabDTO := range dto.Tabs {
		tabs[i] = *DTOToTab(&tabDTO)
	}
	return &domain.Menu{
		ID:           dto.ID,
		RestaurantID: dto.RestaurantID,
		Version:      dto.Version,
		IsPublished:  dto.IsPublished,
		PublishedAt:  dto.PublishedAt,
		Tabs:         tabs,
		CreatedAt:    dto.CreatedAt,
		UpdatedAt:    dto.UpdatedAt,
		UpdatedBy:    dto.UpdatedBy,
		IsDeleted:    dto.IsDeleted,
		ViewCount:    dto.ViewCount,
	}
}

// TabToDTO converts a domain Tab to a TabDTO.
func TabToDTO(tab *domain.Tab) *TabDTO {
	if tab == nil {
		return nil
	}
	categories := make([]CategoryDTO, len(tab.Categories))
	for i, cat := range tab.Categories {
		categories[i] = *CategoryToDTO(&cat)
	}
	return &TabDTO{
		ID:         tab.ID,
		MenuID:     tab.MenuID,
		Name:       tab.Name,
		NameAm:     tab.NameAm,
		Categories: categories,
		IsDeleted:  tab.IsDeleted,
	}
}

// DTOToTab converts a TabDTO to a domain Tab.
func DTOToTab(dto *TabDTO) *domain.Tab {
	if dto == nil {
		return nil
	}
	categories := make([]domain.Category, len(dto.Categories))
	for i, catDTO := range dto.Categories {
		categories[i] = *DTOToCategory(&catDTO)
	}
	return &domain.Tab{
		ID:         dto.ID,
		MenuID:     dto.MenuID,
		Name:       dto.Name,
		NameAm:     dto.NameAm,
		Categories: categories,
		IsDeleted:  dto.IsDeleted,
	}
}

// CategoryToDTO converts a domain Category to a CategoryDTO.
func CategoryToDTO(cat *domain.Category) *CategoryDTO {
	if cat == nil {
		return nil
	}
	items := make([]ItemDTO, len(cat.Items))
	for i, item := range cat.Items {
		items[i] = *ItemToDTO(&item)
	}
	return &CategoryDTO{
		ID:     cat.ID,
		TabID:  cat.TabID,
		Name:   cat.Name,
		NameAm: cat.NameAm,
		Items:  items,
	}
}

// DTOToCategory converts a CategoryDTO to a domain Category.
func DTOToCategory(dto *CategoryDTO) *domain.Category {
	if dto == nil {
		return nil
	}
	items := make([]domain.Item, len(dto.Items))
	for i, itemDTO := range dto.Items {
		items[i] = *DTOToItem(&itemDTO)
	}
	return &domain.Category{
		ID:     dto.ID,
		TabID:  dto.TabID,
		Name:   dto.Name,
		NameAm: dto.NameAm,
		Items:  items,
	}
}

func ItemToDTO(item *domain.Item) *ItemDTO {
	if item == nil {
		return nil
	}
	dto := ItemDTO{}
	return dto.FromDomain(item)
}

func DTOToItem(dto *ItemDTO) *domain.Item {
	if dto == nil {
		return nil
	}
	return dto.ToDomain()
}
