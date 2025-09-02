package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type MenuDB struct {
	ID           bson.ObjectID `bson:"_id"`
	RestaurantID string        `bson:"restaurantId"`
	Version      int           `bson:"version"`
	IsPublished  bool          `bson:"isPublished"`
	PublishedAt  time.Time     `bson:"publishedAt"`
	Tabs         []Tab         `bson:"tabs"`
	CreatedAt    time.Time     `bson:"createdAt"`
	UpdatedAt    time.Time     `bson:"updatedAt"`
	UpdatedBy    string        `bson:"updatedBy"`
	IsDeleted    bool          `bson:"isDeleted"`
	DeletedAt    *time.Time    `bson:"deletedAt,omitempty"`
	ViewCount    int           `bson:"viewCount"`
}

type Tab struct { // Tab Food, drink, etc.
	ID         bson.ObjectID `bson:"_id"`
	MenuID     string        `bson:"menuId"`
	Name       string        `bson:"name"`
	NameAm     string        `bson:"nameAm"`
	Categories []Category    `bson:"categories"`
	IsDeleted  bool          `bson:"isDeleted"`
}

type Category struct { // Category for food breakfast, lunch, dinner, dessert etc.
	ID     bson.ObjectID `bson:"_id"`
	TabID  string        `bson:"tabId"`
	Name   string        `bson:"name"`
	NameAm string        `bson:"nameAm"`
	Items  []ItemDB      `bson:"items"`
}

func FromDomainMenu(menu *domain.Menu) *MenuDB {
	menuId := idempotentID(menu.ID)
	menu.ID = menuId.Hex()
	var tabs []Tab
	for _, t := range menu.Tabs {
		t.MenuID = menuId.Hex()

		// id generate if tab is new
		tabId := idempotentID(t.ID)

		var categories []Category
		for _, c := range t.Categories {
			categoryId := idempotentID(c.ID)
			var items []ItemDB
			for _, i := range c.Items {
				i.CategoryID = categoryId.Hex()
				items = append(items, *FromDomainItem(&i))
			}
			categories = append(categories, Category{
				ID:     categoryId,
				TabID:  tabId.Hex(),
				Name:   c.Name,
				NameAm: c.NameAm,
				Items:  items,
			})
		}
		tabs = append(tabs, Tab{
			ID:         tabId,
			MenuID:     t.MenuID,
			Name:       t.Name,
			NameAm:     t.NameAm,
			Categories: categories,
			IsDeleted:  t.IsDeleted,
		})
	}

	return &MenuDB{
		ID:           menuId,
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
				ID:     c.ID.Hex(),
				TabID:  c.TabID,
				Name:   c.Name,
				NameAm: c.NameAm,
				Items:  items,
			})
		}
		tabs = append(tabs, domain.Tab{
			ID:         t.ID.Hex(),
			MenuID:     t.MenuID,
			Name:       t.Name,
			NameAm:     t.NameAm,
			Categories: categories,
			IsDeleted:  t.IsDeleted,
		})
	}

	return &domain.Menu{
		ID:           menu.ID.Hex(),
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

func idempotentID(id string) bson.ObjectID {
	if id == "" {
		return bson.NewObjectID()
	}
	objID, _ := bson.ObjectIDFromHex(id)
	return objID
}
