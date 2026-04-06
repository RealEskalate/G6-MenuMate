package domain

import (
	"context"
	"time"
)

type CRMDashboard struct {
	RestaurantID         string
	Period               string
	TotalCustomers       int64
	NewCustomers         int64
	ReturningCustomers   int64
	AtRiskCustomers      int64
	LostCustomers        int64
	TotalRevenue         float64
	AvgOrderValue        float64
	AvgVisitsPerCustomer float64
	RetentionRate        float64
	CustomersBySegment   []SegmentCount
	CustomersByLoyalty   []LoyaltyCount
	TopSpenders          []CustomerSummary
	RecentVisitors       []CustomerSummary
	CustomerGrowth       []DailyGrowthPoint
	TopItems             []PopularOrderItem
	SatisfactionOverview SatisfactionOverview
	FoodInsights         []FoodItemConsumptionStats
	WaiterPerformance    []WaiterPerformanceStats
	PeakHours            []HourlyOrderData
	RevenueByDay         []DailyOrderData
}

type SegmentCount struct {
	Segment string
	Count   int64
	Pct     float64
}

type LoyaltyCount struct {
	Tier  string
	Count int64
}

type CustomerSummary struct {
	UserID      string
	ProfileID   string
	Name        string
	Email       string
	Phone       string
	TotalSpent  float64
	TotalVisits int
	LastVisitAt *time.Time
	Segment     string
	LoyaltyTier string
	AvatarURL   string
}

type SatisfactionOverview struct {
	HappyPct         float64
	NeutralPct       float64
	DissatisfiedPct  float64
	AvgMoodScore     float64
	NetPromoterScore float64 // NPS estimate
}

type ICRMUsecase interface {
	GetDashboard(ctx context.Context, restaurantID, period string) (*CRMDashboard, error)
	GetCustomerList(ctx context.Context, filter CustomerProfileFilter) ([]*CustomerRestaurantProfile, int64, error)
	GetCustomerDetail(ctx context.Context, profileID string) (*CustomerRestaurantProfile, error)
	ExportCustomerData(ctx context.Context, restaurantID string) ([]*CustomerSummary, error)
}
