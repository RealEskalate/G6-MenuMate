package domain

type VisitorPoint struct {
	Label    string `json:"label"` // e.g. "6AM", "8AM" or data group name
	Value    int    `json:"value"`
	Visitors int    `json:"visitors"` // alias for Value to match frontend
}

type PopularItem struct {
	Name  string `json:"name"`
	Views int    `json:"views"`
}

type StarDistribution struct {
	Stars int `json:"stars"`
	Count int `json:"count"`
}

type RestaurantAnalytics struct {
	TotalViews       int64              `json:"total_views"`
	AverageRating    float64            `json:"average_rating"`
	TotalReviews     int64              `json:"total_reviews"`
	VisitorsData     []VisitorPoint     `json:"visitors_data"`
	PopularItems     []PopularItem      `json:"popular_items"`
	StarDistribution []StarDistribution `json:"star_distribution"`
	TotalQRScans     int64              `json:"total_qr_scans"`
}

type IAnalyticsUsecase interface {
	GetRestaurantAnalytics(restaurantID string, period string) (*RestaurantAnalytics, error)
}

// ExtendedRestaurantAnalytics embeds RestaurantAnalytics and adds CRM/order-level metrics.
type ExtendedRestaurantAnalytics struct {
	RestaurantAnalytics // embed existing
	TotalOrders         int64
	TotalRevenue        float64
	UniqueCustomers     int64
	NewCustomers        int64
	ReturningCustomers  int64
	AvgOrderValue       float64
	RevenueByDay        []DailyOrderData
	OrdersByDay         []DailyOrderData
	PeakHours           []HourlyOrderData
	CustomerSegments    []SegmentCount
	RecentOrders        []*Order
	TopCustomers        []CustomerSummary
	SatisfactionScore   float64
	WaiterStats         []WaiterPerformanceStats
	FoodInsights        []FoodItemConsumptionStats
}

type IExtendedAnalyticsUsecase interface {
	GetExtendedRestaurantAnalytics(restaurantID, period string) (*ExtendedRestaurantAnalytics, error)
}
