package domain

import (
	"context"
	"time"
)

type PlatformOverview struct {
	TotalUsers          int64
	TotalRestaurants    int64
	TotalOrders         int64
	TotalRevenue        float64
	ActiveUsers         int64
	PendingApprovals    int64
	NewUsersToday       int64
	NewRestaurantsToday int64
	OrdersToday         int64
	RevenueToday        float64
	SuspendedUsers      int64
	VerifiedRestaurants int64
	PendingRestaurants  int64
	TotalReviews        int64
}

type UserGrowthPoint struct {
	Date       string
	NewUsers   int
	TotalUsers int64
	ByRole     map[string]int
}

type RestaurantLeaderboard struct {
	RestaurantID  string
	Name          string
	Slug          string
	TotalOrders   int64
	Revenue       float64
	AverageRating float64
	CustomerCount int64
	ViewCount     int64
	Status        string
	CreatedAt     time.Time
}

type PlatformAnalytics struct {
	Overview            PlatformOverview
	UserGrowth          []UserGrowthPoint
	RestaurantGrowth    []DailyGrowthPoint
	TopRestaurants      []RestaurantLeaderboard
	RevenueByDay        []DailyOrderData
	OrdersByDay         []DailyOrderData
	UsersByRole         map[string]int64
	RestaurantsByStatus map[string]int64
	PendingApprovalList []*ApprovalRequest
	RecentRegistrations []*User
	SystemHealth        SystemHealthStats
}

type SystemHealthStats struct {
	DatabaseStatus   string
	CacheStatus      string
	TotalAPIRequests int64
	ErrorRate        float64
	AvgResponseMs    float64
	UptimeHours      float64
}

type ISuperAdminUsecase interface {
	GetPlatformAnalytics(ctx context.Context, period string) (*PlatformAnalytics, error)
	GetAllUsers(ctx context.Context, filter UserFilter) ([]*User, int64, error)
	GetAllRestaurants(ctx context.Context, page, pageSize int, status, search string) ([]*Restaurant, int64, error)
	UpdateUserStatus(ctx context.Context, userID string, status UserStatus, reason string) error
	UpdateUserRole(ctx context.Context, userID string, role UserRole) error
	ApproveRestaurant(ctx context.Context, restaurantID, adminID, comment string) error
	RejectRestaurant(ctx context.Context, restaurantID, adminID, reason string) error
	GetPendingApprovals(ctx context.Context, page, pageSize int) ([]*ApprovalRequest, int64, error)
	DeleteUser(ctx context.Context, adminID, targetUserID, reason string) error
	GetAuditLogs(ctx context.Context, filter AuditLogFilter) ([]*AuditLog, int64, error)
}
