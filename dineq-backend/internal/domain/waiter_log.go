package domain

import (
	"context"
	"time"
)

type FoodConsumptionStatus string

const (
	ConsumptionComplete FoodConsumptionStatus = "COMPLETE"
	ConsumptionPartial  FoodConsumptionStatus = "PARTIAL"
	ConsumptionNotEaten FoodConsumptionStatus = "NOT_EATEN"
	ConsumptionReturned FoodConsumptionStatus = "RETURNED"
)

type CustomerMood string

const (
	MoodHappy        CustomerMood = "HAPPY"
	MoodNeutral      CustomerMood = "NEUTRAL"
	MoodDissatisfied CustomerMood = "DISSATISFIED"
	MoodAngry        CustomerMood = "ANGRY"
)

type FoodObservation struct {
	ItemID             string
	ItemName           string
	ConsumptionStatus  FoodConsumptionStatus
	LeftoverPercentage int    // 0-100
	CustomerComment    string // verbal feedback heard
	Reason             string // if NOT_EATEN or PARTIAL: "allergic", "too_spicy", "too_much", "didn't_like"
}

type WaiterLog struct {
	ID                  string
	OrderID             string
	SessionID           string
	RestaurantID        string
	WaiterID            string
	WaiterName          string
	CustomerID          string // optional
	CustomerName        string
	TableNumber         string
	Observations        []FoodObservation
	CustomerMood        CustomerMood
	ServiceRating       int   // waiter's observation 1-5 (how the meal went)
	WillLikelyReturn    bool  // waiter's assessment
	TableDuration       int   // minutes spent at table
	TotalCoversCount    int   // how many people at table
	IsComplimentary     bool  // was anything comped
	ComplimentaryReason string
	UpsellAttempted     bool
	UpsellSucceeded     bool
	Notes               string
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

type WaiterLogFilter struct {
	RestaurantID string
	WaiterID     string
	OrderID      string
	DateFrom     *time.Time
	DateTo       *time.Time
	CustomerMood string
	Page         int
	PageSize     int
}

type IWaiterLogRepository interface {
	Create(ctx context.Context, log *WaiterLog) error
	GetByID(ctx context.Context, id string) (*WaiterLog, error)
	Update(ctx context.Context, log *WaiterLog) error
	List(ctx context.Context, filter WaiterLogFilter) ([]*WaiterLog, int64, error)
	GetByOrderID(ctx context.Context, orderID string) (*WaiterLog, error)
	GetFoodConsumptionStats(ctx context.Context, restaurantID string, from, to time.Time) ([]FoodItemConsumptionStats, error)
	GetCustomerMoodStats(ctx context.Context, restaurantID string, from, to time.Time) (map[string]int, error)
	GetWaiterPerformance(ctx context.Context, waiterID string, from, to time.Time) (*WaiterPerformanceStats, error)
}

type IWaiterLogUsecase interface {
	CreateLog(ctx context.Context, log *WaiterLog) error
	GetLogByID(ctx context.Context, id string) (*WaiterLog, error)
	UpdateLog(ctx context.Context, log *WaiterLog) error
	ListLogs(ctx context.Context, filter WaiterLogFilter) ([]*WaiterLog, int64, error)
	GetOrderLog(ctx context.Context, orderID string) (*WaiterLog, error)
	GetFoodInsights(ctx context.Context, restaurantID, period string) ([]FoodItemConsumptionStats, error)
	GetWaiterStats(ctx context.Context, waiterID, period string) (*WaiterPerformanceStats, error)
}

type FoodItemConsumptionStats struct {
	ItemID            string
	ItemName          string
	TotalServed       int
	CompleteCount     int
	PartialCount      int
	NotEatenCount     int
	ReturnedCount     int
	AvgLeftoverPct    float64
	SatisfactionScore float64 // derived from mood & consumption
	TopReasons        []string
}

type WaiterPerformanceStats struct {
	WaiterID          string
	WaiterName        string
	TotalSessions     int
	TotalOrders       int
	AvgServiceRating  float64
	HappyCustomerPct  float64
	UpsellSuccessRate float64
	AvgTableDuration  float64
	ReturnLikelihood  float64 // % of tables waiter believes will return
}
