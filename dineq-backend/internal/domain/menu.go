package domain

import (
	"context"
	"time"
)

type Menu struct {
	ID             string
	RestaurantID   string
	Slug           string
	Version        int
	IsPublished    bool
	PublishedAt    time.Time
	Items          []Item
	CreatedAt      time.Time
	UpdatedAt      time.Time
	UpdatedBy      string
	IsDeleted      bool
	ViewCount      int
	DeletedAt      *time.Time
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
