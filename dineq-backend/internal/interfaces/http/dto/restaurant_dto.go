package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type RestaurantResponse struct {
	ID                 string    `json:"id"`
	Slug               string    `json:"slug"`
	Name               string    `json:"name"`
	ManagerID          string    `json:"manager_id"`
	Phone              string    `json:"phone"`
	MenuID             string    `json:"menu_id"`
	About              *string   `json:"about,omitempty"`
	LogoImage          *string   `json:"logo_image,omitempty"`
	VerificationStatus string    `json:"verification_status"`
	VerificationDocs   *string   `json:"verification_docs,omitempty"`
	CoverImage         *string   `json:"cover_image,omitempty"`
	AverageRating      float64   `json:"average_rating"`
	ViewCount          int64     `json:"view_count"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}

func ToRestaurantResponse(r *domain.Restaurant) *RestaurantResponse {
	return &RestaurantResponse{
		ID:                 r.ID,
		Slug:               r.Slug,
		Name:               r.RestaurantName,
		ManagerID:          r.ManagerID,
		Phone:              r.RestaurantPhone,
		About:              r.About,
		LogoImage:          r.LogoImage,
		VerificationStatus: string(r.VerificationStatus),
		VerificationDocs:   r.VerificationDocs,
		CoverImage:         r.CoverImage,
		AverageRating:      r.AverageRating,
		ViewCount:          r.ViewCount,
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
}

func ToDomainRestaurant(r *RestaurantResponse) *domain.Restaurant {
	if r == nil {
		return nil
	}

	return &domain.Restaurant{
		ID:                 r.ID,
		Slug:               r.Slug,
		RestaurantName:     r.Name,
		ManagerID:          r.ManagerID,
		RestaurantPhone:    r.Phone,
		About:              r.About,
		LogoImage:          r.LogoImage,
		VerificationStatus: domain.VerificationStatus(r.VerificationStatus),
		VerificationDocs:   r.VerificationDocs,
		CoverImage:         r.CoverImage,
		AverageRating:      r.AverageRating,
		ViewCount:          r.ViewCount,
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
}

// Map a slice of domain.Restaurant to DTOs
func ToRestaurantResponseList(restaurants []*domain.Restaurant) []*RestaurantResponse {
	dtos := make([]*RestaurantResponse, len(restaurants))
	for i, r := range restaurants {
		dtos[i] = ToRestaurantResponse(r)
	}
	return dtos
}
