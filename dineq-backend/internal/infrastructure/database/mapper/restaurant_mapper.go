package mapper

import (
	"fmt"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// RestaurantModel represents the MongoDB model for a restaurant
type RestaurantModel struct {
	ID                 bson.ObjectID  `bson:"_id,omitempty"`
	Slug               string         `bson:"slug"`
	PreviousSlugs      []string       `bson:"previousSlugs,omitempty"`
	Name               string         `bson:"name"`
	ManagerID          bson.ObjectID  `bson:"managerId"`
	Phone              string         `bson:"phone"`
	Location           domain.Address `bson:"location"`
	About              string         `bson:"about"`
	LogoImage          string         `bson:"logoImage"`
	VerificationStatus string         `bson:"verificationStatus"`
	VerificationDocs   string         `bson:"verificationDocs"`
	AverageRating      float64        `bson:"averageRating"`
	CoverImage         string         `bson:"coverImage"`
	ViewCount          int64          `bson:"viewCount"`
	CreatedAt          bson.DateTime  `bson:"createdAt"`
	UpdatedAt          bson.DateTime  `bson:"updatedAt"`
	IsDeleted          bool           `bson:"isDeleted"`
}

// Parse converts domain.Restaurant → RestaurantModel
func (m *RestaurantModel) Parse(r *domain.Restaurant) error {
	managerOID, err := bson.ObjectIDFromHex(r.ManagerID)
	fmt.Println("manager", r.ManagerID)
	if err != nil {
		return err
	}

	m.ID = bson.NewObjectID()
	m.Slug = r.Slug
	m.PreviousSlugs = r.PreviousSlugs
	m.Name = r.RestaurantName
	m.ManagerID = managerOID
	m.Phone = r.RestaurantPhone

	m.Location = r.Location
	m.About = ""
	if r.About != "" {
		m.About = r.About
	}
	m.LogoImage = ""
	if r.LogoImage != "" {
		m.LogoImage = r.LogoImage
	}
	m.CoverImage = ""
	if r.CoverImage != "" {
		m.CoverImage = r.CoverImage
	}
	// Convert VerificationDocs (skip empty/invalid)
	m.VerificationDocs = ""
	if r.VerificationDocs != "" {
		m.VerificationDocs = r.VerificationDocs
	}

	m.VerificationStatus = string(r.VerificationStatus)
	m.AverageRating = r.AverageRating
	m.ViewCount = r.ViewCount
	m.CreatedAt = bson.NewDateTimeFromTime(r.CreatedAt)
	m.UpdatedAt = bson.NewDateTimeFromTime(r.UpdatedAt)
	m.IsDeleted = r.IsDeleted

	return nil
}

// ToDomain converts RestaurantModel → domain.Restaurant
func (m *RestaurantModel) ToDomain() *domain.Restaurant {
	r := &domain.Restaurant{
		ID:                 m.ID.Hex(),
		Slug:               m.Slug,
		PreviousSlugs:      m.PreviousSlugs,
		RestaurantName:     m.Name,
		ManagerID:          m.ManagerID.Hex(),
		RestaurantPhone:    m.Phone,
		Location:           m.Location,
		About:              m.About,
		LogoImage:          m.LogoImage,
		VerificationStatus: domain.VerificationStatus(m.VerificationStatus),
		VerificationDocs:   m.VerificationDocs,
		CoverImage:         m.CoverImage,
		AverageRating:      m.AverageRating,
		ViewCount:          m.ViewCount,
		CreatedAt:          m.CreatedAt.Time(),
		UpdatedAt:          m.UpdatedAt.Time(),
		IsDeleted:          m.IsDeleted,
	}

	if m.About != "" {
		r.About = m.About
	}
	if m.LogoImage != "" {
		r.LogoImage = m.LogoImage
	}

	if m.CoverImage != "" {
		r.CoverImage = m.CoverImage
	}

	// Convert VerificationDocs (skip empty/invalid)
	if m.VerificationDocs != "" {
		r.VerificationDocs = m.VerificationDocs
	}
	return r
}
