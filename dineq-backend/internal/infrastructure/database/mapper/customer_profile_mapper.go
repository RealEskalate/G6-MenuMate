package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// CustomerRestaurantProfileModel is the MongoDB representation of a customer's
// per-restaurant profile.
type CustomerRestaurantProfileModel struct {
	ID              bson.ObjectID             `bson:"_id,omitempty"`
	UserID          string                    `bson:"userId"`
	RestaurantID    string                    `bson:"restaurantId"`
	TotalVisits     int                       `bson:"totalVisits"`
	TotalOrders     int                       `bson:"totalOrders"`
	TotalSpent      float64                   `bson:"totalSpent"`
	AverageSpent    float64                   `bson:"averageSpent"`
	LastVisitAt     *time.Time                `bson:"lastVisitAt,omitempty"`
	FirstVisitAt    *time.Time                `bson:"firstVisitAt,omitempty"`
	FavoriteItems   []string                  `bson:"favoriteItems,omitempty"`
	FavoriteMenus   []string                  `bson:"favoriteMenus,omitempty"`
	DietaryPrefs    domain.DietaryPreferences `bson:"dietaryPrefs"`
	Behavior        domain.CustomerBehavior   `bson:"behavior"`
	Segment         string                    `bson:"segment"`
	LoyaltyTier     string                    `bson:"loyaltyTier"`
	LoyaltyPoints   int                       `bson:"loyaltyPoints"`
	Tags            []string                  `bson:"tags,omitempty"`
	InternalNotes   string                    `bson:"internalNotes,omitempty"`
	IsBlacklisted   bool                      `bson:"isBlacklisted"`
	BlacklistReason string                    `bson:"blacklistReason,omitempty"`
	CreatedAt       time.Time                 `bson:"createdAt"`
	UpdatedAt       time.Time                 `bson:"updatedAt"`
}

// CustomerProfileFromDomain converts a domain.CustomerRestaurantProfile to its
// MongoDB model. The ID field is intentionally omitted so that MongoDB
// auto-generates it on insert; repositories that perform updates must resolve
// the ObjectID from the domain ID string themselves.
func CustomerProfileFromDomain(p *domain.CustomerRestaurantProfile) *CustomerRestaurantProfileModel {
	if p == nil {
		return nil
	}
	return &CustomerRestaurantProfileModel{
		UserID:          p.UserID,
		RestaurantID:    p.RestaurantID,
		TotalVisits:     p.TotalVisits,
		TotalOrders:     p.TotalOrders,
		TotalSpent:      p.TotalSpent,
		AverageSpent:    p.AverageSpent,
		LastVisitAt:     p.LastVisitAt,
		FirstVisitAt:    p.FirstVisitAt,
		FavoriteItems:   p.FavoriteItems,
		FavoriteMenus:   p.FavoriteMenus,
		DietaryPrefs:    p.DietaryPrefs,
		Behavior:        p.Behavior,
		Segment:         string(p.Segment),
		LoyaltyTier:     string(p.LoyaltyTier),
		LoyaltyPoints:   p.LoyaltyPoints,
		Tags:            p.Tags,
		InternalNotes:   p.InternalNotes,
		IsBlacklisted:   p.IsBlacklisted,
		BlacklistReason: p.BlacklistReason,
		CreatedAt:       p.CreatedAt,
		UpdatedAt:       p.UpdatedAt,
	}
}

// CustomerProfileToDomain converts a CustomerRestaurantProfileModel to the
// domain representation.
func CustomerProfileToDomain(m *CustomerRestaurantProfileModel) *domain.CustomerRestaurantProfile {
	if m == nil {
		return nil
	}
	return &domain.CustomerRestaurantProfile{
		ID:              m.ID.Hex(),
		UserID:          m.UserID,
		RestaurantID:    m.RestaurantID,
		TotalVisits:     m.TotalVisits,
		TotalOrders:     m.TotalOrders,
		TotalSpent:      m.TotalSpent,
		AverageSpent:    m.AverageSpent,
		LastVisitAt:     m.LastVisitAt,
		FirstVisitAt:    m.FirstVisitAt,
		FavoriteItems:   m.FavoriteItems,
		FavoriteMenus:   m.FavoriteMenus,
		DietaryPrefs:    m.DietaryPrefs,
		Behavior:        m.Behavior,
		Segment:         domain.CustomerSegment(m.Segment),
		LoyaltyTier:     domain.LoyaltyTier(m.LoyaltyTier),
		LoyaltyPoints:   m.LoyaltyPoints,
		Tags:            m.Tags,
		InternalNotes:   m.InternalNotes,
		IsBlacklisted:   m.IsBlacklisted,
		BlacklistReason: m.BlacklistReason,
		CreatedAt:       m.CreatedAt,
		UpdatedAt:       m.UpdatedAt,
	}
}

// CustomerProfileToDomainList converts a slice of CustomerRestaurantProfileModel
// to a slice of domain.CustomerRestaurantProfile pointers.
func CustomerProfileToDomainList(models []*CustomerRestaurantProfileModel) []*domain.CustomerRestaurantProfile {
	profiles := make([]*domain.CustomerRestaurantProfile, 0, len(models))
	for _, m := range models {
		profiles = append(profiles, CustomerProfileToDomain(m))
	}
	return profiles
}
