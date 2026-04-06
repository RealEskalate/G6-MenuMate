package domain

import (
	"context"
	"time"
)

type OrderStatus string

const (
	OrderStatusPending   OrderStatus = "PENDING"
	OrderStatusConfirmed OrderStatus = "CONFIRMED"
	OrderStatusPreparing OrderStatus = "PREPARING"
	OrderStatusReady     OrderStatus = "READY"
	OrderStatusServed    OrderStatus = "SERVED"
	OrderStatusCompleted OrderStatus = "COMPLETED"
	OrderStatusCancelled OrderStatus = "CANCELLED"
)

type OrderItemStatus string

const (
	OrderItemStatusPending   OrderItemStatus = "PENDING"
	OrderItemStatusPreparing OrderItemStatus = "PREPARING"
	OrderItemStatusReady     OrderItemStatus = "READY"
	OrderItemStatusServed    OrderItemStatus = "SERVED"
)

type OrderItem struct {
	ItemID         string
	ItemName       string
	ItemImage      string
	MenuSlug       string
	Quantity       int
	UnitPrice      float64
	TotalPrice     float64
	Notes          string
	Customizations []string
	Status         OrderItemStatus
}

type Order struct {
	ID           string
	RestaurantID string
	TableNumber  string
	SessionID    string
	CustomerID   string // optional (empty for walk-in)
	CustomerName string
	WaiterID     string
	WaiterName   string
	Items        []OrderItem
	Status       OrderStatus
	SubTotal     float64
	TaxAmount    float64
	TotalAmount  float64
	Currency     string
	SpecialNotes string
	CreatedAt    time.Time
	UpdatedAt    time.Time
	CompletedAt  *time.Time
	CancelledAt  *time.Time
	CancelReason string
	IsDeleted    bool
	Source       string // "waiter", "qr_scan", "online"
}

type OrderFilter struct {
	RestaurantID string
	WaiterID     string
	CustomerID   string
	Status       string
	TableNumber  string
	DateFrom     *time.Time
	DateTo       *time.Time
	Page         int
	PageSize     int
}

type IOrderRepository interface {
	Create(ctx context.Context, order *Order) error
	GetByID(ctx context.Context, id string) (*Order, error)
	Update(ctx context.Context, order *Order) error
	UpdateStatus(ctx context.Context, id string, status OrderStatus) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, filter OrderFilter) ([]*Order, int64, error)
	GetBySessionID(ctx context.Context, sessionID string) ([]*Order, error)
	GetRevenueByRestaurant(ctx context.Context, restaurantID string, from, to time.Time) (float64, error)
	GetOrderCountByRestaurant(ctx context.Context, restaurantID string, from, to time.Time) (int64, error)
	GetTopItemsByRestaurant(ctx context.Context, restaurantID string, limit int) ([]PopularOrderItem, error)
	GetOrdersByHour(ctx context.Context, restaurantID string, from, to time.Time) ([]HourlyOrderData, error)
	GetOrdersByDay(ctx context.Context, restaurantID string, from, to time.Time) ([]DailyOrderData, error)
}

type IOrderUsecase interface {
	CreateOrder(ctx context.Context, order *Order) error
	GetOrderByID(ctx context.Context, id string) (*Order, error)
	UpdateOrder(ctx context.Context, order *Order) error
	UpdateOrderStatus(ctx context.Context, id string, status OrderStatus, waiterID string) error
	DeleteOrder(ctx context.Context, id string, requesterID string) error
	ListOrders(ctx context.Context, filter OrderFilter) ([]*Order, int64, error)
	GetSessionOrders(ctx context.Context, sessionID string) ([]*Order, error)
	GetRestaurantRevenue(ctx context.Context, restaurantID string, period string) (float64, error)
	GetRestaurantOrderCount(ctx context.Context, restaurantID string, period string) (int64, error)
}

type PopularOrderItem struct {
	ItemID     string
	ItemName   string
	OrderCount int64
	TotalQty   int64
	Revenue    float64
}

type HourlyOrderData struct {
	Hour       int
	OrderCount int
	Revenue    float64
}

type DailyOrderData struct {
	Date       string // "2006-01-02"
	OrderCount int
	Revenue    float64
}
