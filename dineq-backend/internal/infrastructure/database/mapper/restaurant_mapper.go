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
	Name               string         `bson:"name"`
	ManagerID          bson.ObjectID  `bson:"manager_id"`
	Phone              string         `bson:"phone"`
	Location           domain.Address `bson:"location"`
	About              string         `bson:"about"`
	LogoImage          string         `bson:"logo_image"`
	VerificationStatus string         `bson:"verification_status"`
	VerificationDocs   string         `bson:"verification_docs"`
	CoverImage         string         `bson:"cover_image"`
	AverageRating      float64        `bson:"average_rating"`
	ViewCount          int64          `bson:"view_count"`
	CreatedAt          bson.DateTime  `bson:"created_at"`
	UpdatedAt          bson.DateTime  `bson:"updated_at"`
	IsDeleted          bool           `bson:"is_deleted"`
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
	m.Name = r.RestaurantName
	m.ManagerID = managerOID
	m.Phone = r.RestaurantPhone

	m.Location = r.Location
	m.About = ""
	if r.About != nil {
		m.About = *r.About
	}
	m.LogoImage = ""
	if r.LogoImage != nil {
		m.LogoImage = *r.LogoImage
	}

	m.VerificationDocs = ""
	if r.VerificationDocs != nil {
		m.VerificationDocs = *r.VerificationDocs
	}
	m.CoverImage = ""
	if r.CoverImage != nil {
		m.CoverImage = *r.CoverImage
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
		RestaurantName:     m.Name,
		ManagerID:          m.ManagerID.Hex(),
		RestaurantPhone:    m.Phone,
		Location:           m.Location,
		About:              nil,
		LogoImage:          &m.LogoImage,
		VerificationStatus: domain.VerificationStatus(m.VerificationStatus),
		VerificationDocs:   &m.VerificationDocs,
		CoverImage:         &m.CoverImage,
		AverageRating:      m.AverageRating,
		ViewCount:          m.ViewCount,
		CreatedAt:          m.CreatedAt.Time(),
		UpdatedAt:          m.UpdatedAt.Time(),
		IsDeleted:          m.IsDeleted,
	}

	if m.About != "" {
		r.About = &m.About
	}
	if m.LogoImage != "" {
		r.LogoImage = &m.LogoImage
	}

	return r
}
