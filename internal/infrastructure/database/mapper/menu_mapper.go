package mapper

import (
	"time"

	"github.com/dinq/menumate/internal/domain"
)

type MenuDB struct {
	ID           string    `bson:"_id"`
	RestaurantID string    `bson:"restaurantId"`
	Version      int       `bson:"version"`
	IsPublished  bool      `bson:"isPublished"`
	PublishedAt  time.Time `bson:"publishedAt"`
	Tabs         []Tab     `bson:"tabs"`
	CreatedAt    time.Time `bson:"createdAt"`
	UpdatedAt    time.Time `bson:"updatedAt"`
	UpdatedBy    string    `bson:"updatedBy"`
	IsDeleted    bool      `bson:"isDeleted"`
	ViewCount    int       `bson:"viewCount"`
}

type Tab struct { // Tab Food, drink, etc.
	ID         string     `bson:"_id"`
	MenuID     string     `bson:"menuId"`
	Name       string     `bson:"name"`
	NameAm     string     `bson:"nameAm"`
	Categories []Category `bson:"categories"`
	IsDeleted  bool       `bson:"isDeleted"`
}

type Category struct { // Category for food breakfast, lunch, dinner, dessert etc.
	ID     string   `bson:"_id"`
	TabID  string   `bson:"tabId"`
	Name   string   `bson:"name"`
	NameAm string   `bson:"nameAm"`
	Items  []ItemDB `bson:"items"`
}

func FromDomainMenu(menu *domain.Menu) *MenuDB {
	var tabs []Tab
	for _, t := range menu.Tabs {
		var categories []Category
		for _, c := range t.Categories {
			var items []ItemDB
			for _, i := range c.Items {
				items = append(items, *FromDomainItem(&i))
			}
			categories = append(categories, Category{
				ID:     c.ID,
				TabID:  c.TabID,
				Name:   c.Name,
				NameAm: c.NameAm,
				Items:  items,
			})
		}
		tabs = append(tabs, Tab{
			ID:         t.ID,
			MenuID:     t.MenuID,
			Name:       t.Name,
			NameAm:     t.NameAm,
			Categories: categories,
			IsDeleted:  t.IsDeleted,
		})
	}

	return &MenuDB{
		ID:           menu.ID,
		RestaurantID: menu.RestaurantID,
		Version:      menu.Version,
		IsPublished:  menu.IsPublished,
		PublishedAt:  menu.PublishedAt,
		Tabs:         tabs,
		CreatedAt:    menu.CreatedAt,
		UpdatedAt:    menu.UpdatedAt,
		IsDeleted:    menu.IsDeleted,
		ViewCount:    menu.ViewCount,
	}
}

func ToDomainMenu(menu *MenuDB) *domain.Menu {
	var tabs []domain.Tab
	for _, t := range menu.Tabs {
		var categories []domain.Category
		for _, c := range t.Categories {
			var items []domain.Item
			for _, i := range c.Items {
				items = append(items, *ToDomainItem(&i))
			}
			categories = append(categories, domain.Category{
				ID:     c.ID,
				TabID:  c.TabID,
				Name:   c.Name,
				NameAm: c.NameAm,
				Items:  items,
			})
		}
		tabs = append(tabs, domain.Tab{
			ID:         t.ID,
			MenuID:     t.MenuID,
			Name:       t.Name,
			NameAm:     t.NameAm,
			Categories: categories,
			IsDeleted:  t.IsDeleted,
		})
	}

	return &domain.Menu{
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
