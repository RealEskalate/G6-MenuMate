package domain

import (
	"context"
	"time"
)

type Restaurant struct {
	ID                 string
	Slug               string
	RestaurantName     string
	ManagerID          string
	RestaurantPhone    string
	MenuID             string
	Location           Address
	About              *string
	LogoImage          *string
	Tags               []string
	VerificationStatus VerificationStatus
	VerificationDocs   []Document
	AverageRating      float64
	ViewCount          int64
	CreatedAt          time.Time
	UpdatedAt          time.Time
	IsDeleted          bool
}

type Address struct {
	Street     string
	City       string
	State      string
	PostalCode string
	Country    string
	Latitude   *float64
	Longitude  *float64
}

type Document struct {
	ID         string
	Type       string
	URL        string
	UploadedAt time.Time
}

type VerificationStatus string

const (
	VerificationPending  VerificationStatus = "pending"
	VerificationVerified VerificationStatus = "verified"
	VerificationRejected VerificationStatus = "rejected"
)

type IRestaurantRepo interface {
	GetBySlug(ctx context.Context, slug string) (*Restaurant, error)
	Create(ctx context.Context, r *Restaurant) error
	Update(ctx context.Context, r *Restaurant) error
	Delete(ctx context.Context, id string, manager string) error
	ListAllBranches(ctx context.Context, slug string, page, pageSize int) ([]*Restaurant, int64, error)
	ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*Restaurant, int64, error)
}

type IRestaurantUsecase interface {
	CreateRestaurant(ctx context.Context, r *Restaurant) error
	UpdateRestaurant(ctx context.Context, r *Restaurant) error
	DeleteRestaurant(ctx context.Context, id string, manager string) error
	GetRestaurantBySlug(ctx context.Context, slug string) (*Restaurant, error)
	ListBranchesBySlug(ctx context.Context, slug string, page, pageSize int) ([]*Restaurant, int64, error)
	ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*Restaurant, int64, error)
}
