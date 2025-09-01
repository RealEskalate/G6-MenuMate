package mapper

import (
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// RestaurantModel represents the MongoDB model for a restaurant
type RestaurantModel struct {
	ID                 bson.ObjectID   `bson:"_id,omitempty"`
	Slug               string          `bson:"slug"`
	Name               string          `bson:"name"`
	ManagerID          bson.ObjectID   `bson:"manager_id"`
	Phone              string          `bson:"phone"`
	MenuID             bson.ObjectID   `bson:"menu_id,omitempty"`
	Location           domain.Address  `bson:"location"`
	About              string          `bson:"about"`
	LogoImage          string          `bson:"logo_image"`
	Tags               []bson.ObjectID `bson:"tags"`
	VerificationStatus string          `bson:"verification_status"`
	VerificationDocs   []bson.ObjectID `bson:"verification_docs"`
	AverageRating      float64         `bson:"average_rating"`
	ViewCount          int64           `bson:"view_count"`
	CreatedAt          bson.DateTime   `bson:"created_at"`
	UpdatedAt          bson.DateTime   `bson:"updated_at"`
	IsDeleted          bool            `bson:"is_deleted"`
}

// Parse converts domain.Restaurant → RestaurantModel
func (m *RestaurantModel) Parse(r *domain.Restaurant) error {
	managerOID, err := bson.ObjectIDFromHex(r.ManagerID)
	if err != nil {
		return err
	}

	m.ID = bson.NewObjectID()
	m.Slug = r.Slug
	m.Name = r.RestaurantName
	m.ManagerID = managerOID
	m.Phone = r.RestaurantPhone

	if r.MenuID != "" {
		menuOID, err := bson.ObjectIDFromHex(r.MenuID)
		if err != nil {
			return err
		}
		m.MenuID = menuOID
	} else {
		m.MenuID = bson.ObjectID{} // zero value
	}

	m.Location = r.Location
	m.About = ""
	if r.About != nil {
		m.About = *r.About
	}
	m.LogoImage = ""
	if r.LogoImage != nil {
		m.LogoImage = *r.LogoImage
	}

	// Convert Tags
	m.Tags = make([]bson.ObjectID, len(r.Tags))
	for i, hexID := range r.Tags {
		oid, err := bson.ObjectIDFromHex(hexID)
		if err != nil {
			return err
		}
		m.Tags[i] = oid
	}

	// Convert VerificationDocs
	m.VerificationDocs = make([]bson.ObjectID, len(r.VerificationDocs))
	for i, doc := range r.VerificationDocs {
		oid, err := bson.ObjectIDFromHex(doc.ID)
		if err != nil {
			return err
		}
		m.VerificationDocs[i] = oid
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
		LogoImage:          nil,
		Tags:               make([]string, len(m.Tags)),
		VerificationStatus: domain.VerificationStatus(m.VerificationStatus),
		VerificationDocs:   make([]domain.Document, len(m.VerificationDocs)),
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

	for i, oid := range m.Tags {
		r.Tags[i] = oid.Hex()
	}
	for i, oid := range m.VerificationDocs {
		r.VerificationDocs[i] = domain.Document{ID: oid.Hex()}
	}
	if !m.MenuID.IsZero() {
		r.MenuID = m.MenuID.Hex()
	} else {
		r.MenuID = ""
	}

	return r
}
