package domain

import (
	"context"
	"time"
)

type Restaurant struct {
	ID                 string
	Slug               string
	PreviousSlugs      []string
	RestaurantName     string
	ManagerID          string
	RestaurantPhone    string
	Location           *Address
	About              *string
	LogoImage          *string
	Tags               []string
	VerificationStatus VerificationStatus
	VerificationDocs   *string
	CoverImage         *string
	AverageRating      float64
	ViewCount          int64
	CreatedAt          time.Time
	UpdatedAt          time.Time
	IsDeleted          bool
}

type Address struct {
	Type        string
	Coordinates [2]float64 // [longitude, latitude]
}

type VerificationStatus string

const (
	VerificationPending  VerificationStatus = "pending"
	VerificationVerified VerificationStatus = "verified"
	VerificationRejected VerificationStatus = "rejected"
)

type IRestaurantRepo interface {
	GetBySlug(ctx context.Context, slug string) (*Restaurant, error)
	GetByOldSlug(ctx context.Context, oldSlug string) (*Restaurant, error)
	Create(ctx context.Context, r *Restaurant) error
	Update(ctx context.Context, r *Restaurant) error
	Delete(ctx context.Context, id string, manager string) error
	ListAllBranches(ctx context.Context, slug string, page, pageSize int) ([]*Restaurant, int64, error)
	ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*Restaurant, int64, error)
	FindNearby(ctx context.Context, lat, lng float64, maxDistance int, page, pageSize int) ([]*Restaurant, int64, error)
	GetByRestaurantName(ctx context.Context, Name string) (*Restaurant, error)
	GetByManagerId(ctx context.Context, manager string) (*Restaurant, error)
}

type IRestaurantUsecase interface {
	CreateRestaurant(ctx context.Context, r *Restaurant, files map[string][]byte) error
	UpdateRestaurant(ctx context.Context, r *Restaurant, files map[string][]byte) error
	DeleteRestaurant(ctx context.Context, id string, manager string) error
	GetRestaurantBySlug(ctx context.Context, slug string) (*Restaurant, error)
	GetRestaurantByOldSlug(ctx context.Context, slug string) (*Restaurant, error)
	ListBranchesBySlug(ctx context.Context, slug string, page, pageSize int) ([]*Restaurant, int64, error)
	ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*Restaurant, int64, error)
	FindNearby(ctx context.Context, lng, lat float64, maxDistance int, page, pageSize int) ([]*Restaurant, int64, error)
	GetRestaurantByName(ctx context.Context, name string) (*Restaurant, error)
	GetRestaurantByManagerId(ctx context.Context, manager string) (*Restaurant, error)
}
