package domain

import (
	"context"
	"time"
)

type Menu struct {
    ID           string
    RestaurantID string
    Version      int
    IsPublished  bool
    PublishedAt  time.Time
    Tabs         []Tab
    CreatedAt    time.Time
    UpdatedAt    time.Time
    UpdatedBy    string
    IsDeleted    bool
    ViewCount    int
}

type Tab struct {
    ID         string
    MenuID     string
    Name       string
    NameAm     string
    Categories []Category
    IsDeleted  bool
}

type Category struct {
    ID     string
    TabID  string
    Name   string
    NameAm string
    Items  []Item
}



type IMenuUseCase interface {
    CreateMenu(menu *Menu) error
    UpdateMenu(id string, menu *Menu) error
    PublishMenu(id string, userID string) error
    GetMenuByID(id string) (*Menu, error)
    GenerateQRCode(menuID string) (*QRCode, error)
    DeleteMenu(id string) error
}

type IMenuRepository interface {
    Create(ctx context.Context, menu *Menu) error
    Update(ctx context.Context, id string, menu *Menu) error
    GetByID(ctx context.Context, id string) (*Menu, error)
    Delete(ctx context.Context, id string) error
}
