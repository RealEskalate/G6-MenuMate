package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type MenuDB struct {
	ID             bson.ObjectID `bson:"_id,omitempty"`
	Name           string        `bson:"name"`
	RestaurantID   string        `bson:"restaurantId"`
	RestaurantSlug string        `bson:"RestaurantSlug"`
	Slug           string        `bson:"slug"`
	Version        int           `bson:"version"`
	IsPublished    bool          `bson:"isPublished"`
	PublishedAt    time.Time     `bson:"publishedAt"`
	Items          []ItemDB      `bson:"items"`
	CreatedAt      time.Time     `bson:"createdAt"`
	UpdatedAt      time.Time     `bson:"updatedAt"`
	CreatedBy      string        `bson:"createdBy"`
	UpdatedBy      string        `bson:"updatedBy"`
	IsDeleted      bool          `bson:"isDeleted"`
	DeletedAt      *time.Time    `bson:"deletedAt,omitempty"`
	ViewCount      int           `bson:"viewCount"`
}

// ---------- Creation ----------

// NewMenuDBFromDomain is used when creating a new Menu.
func NewMenuDBFromDomain(menu *domain.Menu) *MenuDB {
	now := time.Now().UTC()

	menuId := idempotentID(menu.ID)
	menu.ID = menuId.Hex()

	var items []ItemDB
	for i := range menu.Items {
		items = append(items, *NewItemDBFromDomain(&menu.Items[i]))
	}

	return &MenuDB{
		ID:             menuId,
		Name:           menu.Name,
		RestaurantID:   menu.RestaurantID,
		RestaurantSlug: menu.RestaurantSlug,
		Slug:           menu.Slug,
		Version:        1, // start at version 1
		IsPublished:    menu.IsPublished,
		PublishedAt:    menu.PublishedAt,
		Items:          items,
		CreatedAt:      now,
		UpdatedAt:      now,
		CreatedBy:      menu.CreatedBy,
		UpdatedBy:      menu.UpdatedBy,
		IsDeleted:      false,
		ViewCount:      0,
	}
}

// ---------- Update ----------

// MergeMenuUpdate merges new domain data into an existing MenuDB.
// It reuses the existing _id, increments version, and updates timestamps.
func MergeMenuUpdate(updated *domain.Menu) *MenuDB {
	var items []ItemDB
	for i := range updated.Items {
		items = append(items, *MergeItemUpdate(&updated.Items[i]))
	}

	return &MenuDB{
		RestaurantID:   updated.RestaurantID,
		RestaurantSlug: updated.RestaurantSlug,
		Slug:           updated.Slug,
		Name:           updated.Name,
		IsPublished:    updated.IsPublished,
		PublishedAt:    updated.PublishedAt,
		Items:          items,
		CreatedAt:      time.Now().UTC(),
		UpdatedAt:      time.Now().UTC(),
		CreatedBy:      updated.CreatedBy,
		UpdatedBy:      updated.UpdatedBy,
		IsDeleted:      updated.IsDeleted,
		ViewCount:      updated.ViewCount,
		DeletedAt:      updated.DeletedAt,
		Version:        updated.Version + 1,
	}
}

// ---------- Conversion ----------

func ToDomainMenu(menu *MenuDB) *domain.Menu {
	var items []domain.Item
	for _, item := range menu.Items {
		items = append(items, *ToDomainItem(&item))
	}

	return &domain.Menu{
		ID:             menu.ID.Hex(),
		Name:           menu.Name,
		RestaurantID:   menu.RestaurantID,
		RestaurantSlug: menu.RestaurantSlug,
		Slug:           menu.Slug,
		Version:        menu.Version,
		IsPublished:    menu.IsPublished,
		PublishedAt:    menu.PublishedAt,
		Items:          items,
		CreatedAt:      menu.CreatedAt,
		UpdatedAt:      menu.UpdatedAt,
		CreatedBy:      menu.CreatedBy,
		UpdatedBy:      menu.UpdatedBy,
		IsDeleted:      menu.IsDeleted,
		ViewCount:      menu.ViewCount,
		DeletedAt:      menu.DeletedAt,
	}
}

func idempotentID(id string) bson.ObjectID {
	if id == "" {
		return bson.NewObjectID()
	}
	objID, _ := bson.ObjectIDFromHex(id)
	return objID
}
