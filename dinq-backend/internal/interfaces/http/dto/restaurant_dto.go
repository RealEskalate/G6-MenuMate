package dto

import "github.com/dinq/menumate/internal/domain"

type Contact struct {
	Phone  string
	Email  string
	Social []string // or []Url if you have a Url type
}

type RestaurantRequest struct {
	ID                 string   `json:"id"`
	Name               string   `json:"name"`
	About              string   `json:"about,omitempty"`
	Contact            Contact  `json:"contact"`
	Owner              string   `json:"owner"`
	LogoImage          string   `json:"logoImage,omitempty"`
	BranchIds          []string `json:"branchIds,omitempty"`
	AverageRating      float64  `json:"averageRating,omitempty"`
	Tags               []string `json:"tags,omitempty"`
	IsOpen             bool     `json:"isOpen"`
	CreatedAt          int64    `json:"createdAt,omitempty"`
	UpdatedAt          int64    `json:"updatedAt,omitempty"`
	VerificationDocs   []string `json:"verificationDocs,omitempty"`
	VerificationStatus string   `json:"verificationStatus"`
	IsDeleted          bool     `json:"isDeleted"`
	ViewCount          int      `json:"viewCount,omitempty"`
}

type RestaurantResponse struct {
	ID                 string   `json:"id"`
	Name               string   `json:"name"`
	About              string   `json:"about,omitempty"`
	Contact            Contact  `json:"contact"`
	Owner              string   `json:"owner"`
	LogoImage          string   `json:"logoImage,omitempty"`
	BranchIds          []string `json:"branchIds,omitempty"`
	AverageRating      float64  `json:"averageRating,omitempty"`
	Tags               []string `json:"tags,omitempty"`
	IsOpen             bool     `json:"isOpen"`
	CreatedAt          int64    `json:"createdAt,omitempty"`
	UpdatedAt          int64    `json:"updatedAt,omitempty"`
	VerificationDocs   []string `json:"verificationDocs,omitempty"`
	VerificationStatus string   `json:"verificationStatus"`
	IsDeleted          bool     `json:"isDeleted"`
	ViewCount          int      `json:"viewCount,omitempty"`
}

func toDomainContact(c Contact) domain.Contact {
	return domain.Contact{
		Phone:  c.Phone,
		Email:  c.Email,
		Social: c.Social,
	}
}

func fromDomainContact(c domain.Contact) Contact {
	return Contact{
		Phone:  c.Phone,
		Email:  c.Email,
		Social: c.Social,
	}
}

func ToDomainRestaurant(req RestaurantRequest) domain.Restaurant {
	return domain.Restaurant{
		ID:                 req.ID,
		Name:               req.Name,
		About:              req.About,
		Contact:            toDomainContact(req.Contact),
		Owner:              req.Owner,
		LogoImage:          req.LogoImage,
		BranchIds:          req.BranchIds,
		AverageRating:      req.AverageRating,
		Tags:               req.Tags,
		IsOpen:             req.IsOpen,
		CreatedAt:          req.CreatedAt,
		UpdatedAt:          req.UpdatedAt,
		VerificationDocs:   req.VerificationDocs,
		VerificationStatus: domain.VerificationStatus(req.VerificationStatus),
		IsDeleted:          req.IsDeleted,
		ViewCount:          req.ViewCount,
	}
}

func ToRestaurantResponse(res domain.Restaurant) RestaurantResponse {
	return RestaurantResponse{
		ID:                 res.ID,
		Name:               res.Name,
		About:              res.About,
		Contact:            fromDomainContact(res.Contact),
		Owner:              res.Owner,
		LogoImage:          res.LogoImage,
		BranchIds:          res.BranchIds,
		AverageRating:      res.AverageRating,
		Tags:               res.Tags,
		IsOpen:             res.IsOpen,
		CreatedAt:          res.CreatedAt,
		UpdatedAt:          res.UpdatedAt,
		VerificationDocs:   res.VerificationDocs,
		VerificationStatus: string(res.VerificationStatus),
		IsDeleted:          res.IsDeleted,
		ViewCount:          res.ViewCount,
	}
}
