package domain

import (
	"context"
	"time"
)

type Contact struct {
	Phone  string
	Email  string
	Social []string // or []Url if you have a Url type
}

type VerificationStatus string

const (

	// Verification status enum values
	VerificationStatusPending  VerificationStatus = "pending"
	VerificationStatusVerified VerificationStatus = "verified"
	VerificationStatusRejected VerificationStatus = "rejected"
	// Timeout for repository operations
	TIME_OUT = 5 * time.Second
)

type Restaurant struct {
	ID                 string
	Name               string
	About              string
	Contact            Contact
	Owner              string
	LogoImage          string
	BranchIds          []string
	AverageRating      float64
	Tags               []string
	IsOpen             bool
	CreatedAt          int64
	UpdatedAt          int64
	VerificationDocs   []string
	VerificationStatus VerificationStatus
	IsDeleted          bool
	ViewCount          int
}

type IRestaurantRepository interface {
	GetByID(ctx context.Context, id string) (*Restaurant, error)
	GetByEmail(ctx context.Context, email string) (*Restaurant, error)
	GetByPhone(ctx context.Context, phone string) (*Restaurant, error)

	Create(ctx context.Context, r *Restaurant) error
	Update(ctx context.Context, r *Restaurant) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]Restaurant, error)
}
type IRestaurantUsecase interface {
	RegisterRestaurant(ctx context.Context, request *Restaurant) error
}
