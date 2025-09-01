package dto

import (
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ContactDTO struct {
	Phone  string   `json:"phone,omitempty"`
	Email  string   `json:"email,omitempty"`
	Social []string `json:"social,omitempty"`
}

// RestaurantDTO represents the data transfer object for a Restaurant.
type RestaurantDTO struct {
	ID            string     `json:"id"`
	Name          string     `json:"name"`
	About         string     `json:"about,omitempty"`
	Contact       ContactDTO `json:"contact"`
	OwnerID       string     `json:"ownerId"`
	LogoImage     string     `json:"logoImage,omitempty"`
	BranchIDs     []string   `json:"branchIds"`
	AverageRating float64    `json:"averageRating"`
	Tags          []string   `json:"tags,omitempty"`
	IsOpen        bool       `json:"isOpen"`
	CreatedAt     time.Time  `json:"createdAt"`
	UpdatedAt     time.Time  `json:"updatedAt"`
	// VerificationDocs in DTO are represented as URLs (strings).
	VerificationDocs []string `json:"verificationDocs,omitempty"`
	// VerificationStatus is represented as a string.
	VerificationStatus string `json:"verificationStatus"`
	IsDeleted          bool   `json:"isDeleted"`
	ViewCount          int    `json:"viewCount"`
}

// Validate checks the RestaurantDTO for required fields.
func (r *RestaurantDTO) Validate() error {
	if r.Name == "" || r.OwnerID == "" {
		return fmt.Errorf("name and ownerID are required")
	}
	return nil
}

// ToDomain converts the RestaurantDTO to a domain.Restaurant entity.
func (r *RestaurantDTO) ToDomain() *domain.Restaurant {
	// Convert verification document URLs to domain.Document objects.
	docs := make([]domain.Document, len(r.VerificationDocs))
	for i, docURL := range r.VerificationDocs {
		docs[i] = domain.Document{URL: docURL}
	}
	// Convert contact social URLs from string to domain.URL.
	socials := make([]domain.URL, len(r.Contact.Social))
	for i, s := range r.Contact.Social {
		socials[i] = domain.URL(s)
	}

	return &domain.Restaurant{
		ID:                 r.ID,
		Name:               r.Name,
		About:              r.About,
		VerificationDocs:   docs,
		VerificationStatus: domain.VerificationStatus(r.VerificationStatus),
		Contact: domain.Contact{
			Phone:  r.Contact.Phone,
			Email:  r.Contact.Email,
			Social: socials,
		},
		Owner:         r.OwnerID,
		LogoImage:     r.LogoImage,
		BranchIDs:     r.BranchIDs,
		AverageRating: r.AverageRating,
		Tags:          r.Tags,
		IsOpen:        r.IsOpen,
		CreatedAt:     r.CreatedAt,
		UpdatedAt:     r.UpdatedAt,
		IsDeleted:     r.IsDeleted,
		ViewCount:     r.ViewCount,
	}
}

// FromDomain converts a domain.Restaurant entity to a RestaurantDTO.
func (r *RestaurantDTO) FromDomain(restaurant *domain.Restaurant) *RestaurantDTO {
	// Convert domain.Document objects to verification document URLs.
	docs := make([]string, len(restaurant.VerificationDocs))
	for i, doc := range restaurant.VerificationDocs {
		docs[i] = doc.URL
	}
	// Convert domain.URL objects to string for contact social URLs.
	socials := make([]string, len(restaurant.Contact.Social))
	for i, s := range restaurant.Contact.Social {
		socials[i] = string(s)
	}

	return &RestaurantDTO{
		ID:                 restaurant.ID,
		Name:               restaurant.Name,
		About:              restaurant.About,
		VerificationDocs:   docs,
		VerificationStatus: string(restaurant.VerificationStatus),
		Contact: ContactDTO{
			Phone:  restaurant.Contact.Phone,
			Email:  restaurant.Contact.Email,
			Social: socials,
		},
		OwnerID:       restaurant.Owner,
		LogoImage:     restaurant.LogoImage,
		BranchIDs:     restaurant.BranchIDs,
		AverageRating: restaurant.AverageRating,
		Tags:          restaurant.Tags,
		IsOpen:        restaurant.IsOpen,
		CreatedAt:     restaurant.CreatedAt,
		UpdatedAt:     restaurant.UpdatedAt,
		IsDeleted:     restaurant.IsDeleted,
		ViewCount:     restaurant.ViewCount,
	}
}
