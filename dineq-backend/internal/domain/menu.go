package domain

import (
	"context"
	"time"
)

type Menu struct {
	ID           string    `json:"id"`
	RestaurantID string    `json:"restaurant_id"`
	Slug         string    `json:"slug"`
	Version      int       `json:"version"`
	IsPublished  bool      `json:"is_published"`
	PublishedAt  time.Time `json:"published_at"`
	Tabs         []Tab     `json:"tabs"`
	Items          []Item
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
	UpdatedBy    string    `json:"updated_by"`
	IsDeleted    bool      `json:"is_deleted"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty"`
	ViewCount    int       `json:"view_count"`
}

type Tab struct {
	ID         string     `json:"id"`
	MenuID     string     `json:"menu_id"`
	Name       string     `json:"name"`
	NameAm     string     `json:"name_am"`
	Categories []Category `json:"categories"`
	IsDeleted  bool       `json:"is_deleted"`
}

type Category struct {
	ID     string `json:"id"`
	TabID  string `json:"tab_id"`
	Name   string `json:"name"`
	NameAm string `json:"name_am"`
	Items  []Item `json:"items"`
}

type IMenuUseCase interface {
	CreateMenu(menu *Menu) error
	UpdateMenu(id string, userId string, menu *Menu) error
	PublishMenu(id string, userID string) error
	GetByID(id string) (*Menu, error)
	GetByRestaurantID(id string) ([]*Menu, error)
	GenerateQRCode(restaurantID string, menuId string, req *QRCodeRequest) (*QRCode, error)
	DeleteMenu(id string) error
}

type IMenuRepository interface {
	Create(ctx context.Context, menu *Menu) error
	Update(ctx context.Context, id string, menu *Menu) error
	GetByID(ctx context.Context, id string) (*Menu, error)
	Delete(ctx context.Context, id string) error
	GetByRestaurantID(ctx context.Context, restaurantId string) ([]*Menu, error)
	IncrementViewCount(ctx context.Context, id string) error
}
