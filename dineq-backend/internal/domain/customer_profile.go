package domain

import (
	"context"
	"time"
)

type CustomerSegment string

const (
	SegmentNew     CustomerSegment = "NEW"
	SegmentRegular CustomerSegment = "REGULAR"
	SegmentLoyal   CustomerSegment = "LOYAL"
	SegmentVIP     CustomerSegment = "VIP"
	SegmentAtRisk  CustomerSegment = "AT_RISK"
	SegmentLost    CustomerSegment = "LOST"
)

type LoyaltyTier string

const (
	LoyaltyBronze   LoyaltyTier = "BRONZE"
	LoyaltySilver   LoyaltyTier = "SILVER"
	LoyaltyGold     LoyaltyTier = "GOLD"
	LoyaltyPlatinum LoyaltyTier = "PLATINUM"
)

type DietaryPreferences struct {
	IsVegetarian bool
	IsVegan      bool
	IsGlutenFree bool
	IsHalal      bool
	IsKosher     bool
	Allergies    []string
	Restrictions []string
	Preferences  []string // liked cuisines, flavors
}

type CustomerBehavior struct {
	PreferredVisitDays    []string // e.g., ["Saturday", "Sunday"]
	PreferredVisitTimes   []string // e.g., ["12:00-14:00", "19:00-21:00"]
	AvgTimeSpentMinutes   int
	AvgOrderValue         float64
	PreferredItems        []string // item IDs
	PreferredCategories   []string
	ReviewCount           int
	AvgRatingGiven        float64
	ComplaintCount        int
	SocialInfluenceScore  int // reviews written, QR scans shared, etc.
	LastBehaviorUpdatedAt time.Time
}

type CustomerRestaurantProfile struct {
	ID              string
	UserID          string
	RestaurantID    string
	TotalVisits     int
	TotalOrders     int
	TotalSpent      float64
	AverageSpent    float64
	LastVisitAt     *time.Time
	FirstVisitAt    *time.Time
	FavoriteItems   []string
	FavoriteMenus   []string
	DietaryPrefs    DietaryPreferences
	Behavior        CustomerBehavior
	Segment         CustomerSegment
	LoyaltyTier     LoyaltyTier
	LoyaltyPoints   int
	Tags            []string // "VIP", "Birthday", "Corporate", etc.
	InternalNotes   string   // private staff notes
	IsBlacklisted   bool
	BlacklistReason string
	CreatedAt       time.Time
	UpdatedAt       time.Time
}

type CustomerProfileFilter struct {
	RestaurantID string
	Segment      string
	LoyaltyTier  string
	Search       string // name/email
	Tag          string
	Page         int
	PageSize     int
	SortBy       string // total_spent, total_visits, last_visit
	Order        int    // 1 asc, -1 desc
}

type ICustomerProfileRepository interface {
	Create(ctx context.Context, profile *CustomerRestaurantProfile) error
	GetByID(ctx context.Context, id string) (*CustomerRestaurantProfile, error)
	GetByUserAndRestaurant(ctx context.Context, userID, restaurantID string) (*CustomerRestaurantProfile, error)
	Update(ctx context.Context, profile *CustomerRestaurantProfile) error
	List(ctx context.Context, filter CustomerProfileFilter) ([]*CustomerRestaurantProfile, int64, error)
	GetTopCustomers(ctx context.Context, restaurantID string, limit int) ([]*CustomerRestaurantProfile, error)
	GetAtRiskCustomers(ctx context.Context, restaurantID string, daysSinceLastVisit int) ([]*CustomerRestaurantProfile, error)
	UpdateSegment(ctx context.Context, profileID string, segment CustomerSegment) error
	CountBySegment(ctx context.Context, restaurantID string) (map[string]int64, error)
	GetCustomerGrowth(ctx context.Context, restaurantID string, from, to time.Time) ([]DailyGrowthPoint, error)
}

type ICustomerProfileUsecase interface {
	GetOrCreateProfile(ctx context.Context, userID, restaurantID string) (*CustomerRestaurantProfile, error)
	UpdateProfile(ctx context.Context, profile *CustomerRestaurantProfile) error
	GetProfileByID(ctx context.Context, id string) (*CustomerRestaurantProfile, error)
	ListCustomers(ctx context.Context, filter CustomerProfileFilter) ([]*CustomerRestaurantProfile, int64, error)
	GetTopCustomers(ctx context.Context, restaurantID string, limit int) ([]*CustomerRestaurantProfile, error)
	GetAtRiskCustomers(ctx context.Context, restaurantID string) ([]*CustomerRestaurantProfile, error)
	RecordVisit(ctx context.Context, userID, restaurantID string, orderAmount float64) error
	UpdateCustomerSegments(ctx context.Context, restaurantID string) error
	AddCustomerNote(ctx context.Context, profileID, note, staffID string) error
	UpdateDietaryPreferences(ctx context.Context, userID string, prefs DietaryPreferences) error
	GetCustomerHistory(ctx context.Context, userID string, page, pageSize int) ([]*CustomerRestaurantProfile, int64, error)
}

type DailyGrowthPoint struct {
	Date       string
	NewCount   int
	TotalCount int64
}
