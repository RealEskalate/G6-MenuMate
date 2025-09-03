package mapper

import (
	"fmt"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// RestaurantModel represents the MongoDB model for a restaurant
type RestaurantModel struct {
	ID                 bson.ObjectID   `bson:"_id,omitempty"`
	Slug               string          `bson:"slug"`
	PreviousSlugs      []string        `bson:"previousSlugs,omitempty"`
	Name               string          `bson:"name"`
	ManagerID          bson.ObjectID   `bson:"managerId"`
	Phone              string          `bson:"phone"`
	Location           *domain.Address `bson:"location"`
	About              *string         `bson:"about"`
	LogoImage          *string         `bson:"logoImage"`
	VerificationStatus string          `bson:"verificationStatus"`
	VerificationDocs   *string         `bson:"verificationDocs"`
	CoverImage         *string         `bson:"coverImage"`
	AverageRating      float64         `bson:"averageRating"`
	ViewCount          int64           `bson:"viewCount"`
	CreatedAt          bson.DateTime   `bson:"createdAt"`
	UpdatedAt          bson.DateTime   `bson:"updatedAt"`
	IsDeleted          bool            `bson:"isDeleted"`
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
	m.About = nil
	if r.About != nil {
		m.About = r.About
	}
	m.LogoImage = nil
	if r.LogoImage != nil {
		m.LogoImage = r.LogoImage
	}
	m.CoverImage = nil
	if r.CoverImage != nil {
		m.CoverImage = r.CoverImage
	}
	// Convert VerificationDocs (skip empty/invalid)
	m.VerificationDocs = nil
	if r.VerificationDocs != nil {
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
		VerificationDocs:   nil,
		CoverImage:         nil,
		AverageRating:      m.AverageRating,
		ViewCount:          m.ViewCount,
		CreatedAt:          m.CreatedAt.Time(),
		UpdatedAt:          m.UpdatedAt.Time(),
		IsDeleted:          m.IsDeleted,
	}

	if m.About != nil {
		r.About = m.About
	}
	if m.LogoImage != nil {
		r.LogoImage = m.LogoImage
	}
	if m.VerificationDocs != nil {
		r.VerificationDocs = m.VerificationDocs
	}
	if m.CoverImage != nil {
		r.CoverImage = m.CoverImage
	}

	return r
}

// FacetRestaurant represents a restaurant returned in a $facet query
type FacetRestaurant struct {
	ID                 bson.ObjectID  `bson:"_id"`
	Slug               string         `bson:"slug"`
	PreviousSlugs      []string       `bson:"previousSlugs"`
	Name               string         `bson:"name"`
	ManagerID          bson.ObjectID  `bson:"managerId"`
	Phone              string         `bson:"phone"`
	Location           domain.Address `bson:"location"`
	About              *string        `bson:"about"`
	LogoImage          *string        `bson:"logoImage"`
	VerificationStatus string         `bson:"verificationStatus"`
	VerificationDocs   *string        `bson:"verificationDocs"`
	CoverImage         *string        `bson:"coverImage"`
	AverageRating      float64        `bson:"averageRating"`
	ViewCount          int64          `bson:"viewCount"`
	CreatedAt          bson.DateTime  `bson:"createdAt"`
	UpdatedAt          bson.DateTime  `bson:"updatedAt"`
	IsDeleted          bool           `bson:"isDeleted"`
}

// Parse converts FacetRestaurant → domain.Restaurant
func (f *FacetRestaurant) ToDomain() *domain.Restaurant {
	return &domain.Restaurant{
		ID:                 f.ID.Hex(),
		Slug:               f.Slug,
		PreviousSlugs:      f.PreviousSlugs,
		RestaurantName:     f.Name,
		ManagerID:          f.ManagerID.Hex(),
		RestaurantPhone:    f.Phone,
		Location:           &f.Location,
		About:              f.About,
		LogoImage:          f.LogoImage,
		VerificationStatus: domain.VerificationStatus(f.VerificationStatus),
		VerificationDocs:   f.VerificationDocs,
		CoverImage:         f.CoverImage,
		AverageRating:      f.AverageRating,
		ViewCount:          f.ViewCount,
		CreatedAt:          f.CreatedAt.Time(),
		UpdatedAt:          f.UpdatedAt.Time(),
		IsDeleted:          f.IsDeleted,
	}
}

// Helper Struct for the Facet Result
type FacetResultModel struct {
	TotalData  []FacetRestaurant `bson:"totalData"`
	TotalCount []struct {
		Count int64 `bson:"count"`
	} `bson:"totalCount"`
}

func (f *FacetResultModel) Parse() ([]*domain.Restaurant, int64) {
	restaurants := make([]*domain.Restaurant, len(f.TotalData))
	for i, r := range f.TotalData {
		restaurants[i] = r.ToDomain()
	}

	var total int64
	if len(f.TotalCount) > 0 {
		total = f.TotalCount[0].Count
	}

	return restaurants, total
}
