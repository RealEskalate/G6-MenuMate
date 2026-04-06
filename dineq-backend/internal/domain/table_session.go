package domain

import (
	"context"
	"time"
)

type TableSessionStatus string

const (
	TableSessionActive    TableSessionStatus = "ACTIVE"
	TableSessionCompleted TableSessionStatus = "COMPLETED"
	TableSessionAbandoned TableSessionStatus = "ABANDONED"
)

type TableSession struct {
	ID            string
	RestaurantID  string
	TableNumber   string
	WaiterID      string
	WaiterName    string
	CustomerID    string // registered customer (optional)
	CustomerName  string
	CustomerPhone string
	CustomerEmail string
	GuestCount    int
	Status        TableSessionStatus
	StartedAt     time.Time
	EndedAt       *time.Time
	OrderIDs      []string
	TotalOrders   int
	TotalSpent    float64
	Currency      string
	Notes         string
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

type ITableSessionRepository interface {
	Create(ctx context.Context, session *TableSession) error
	GetByID(ctx context.Context, id string) (*TableSession, error)
	Update(ctx context.Context, session *TableSession) error
	UpdateStatus(ctx context.Context, id string, status TableSessionStatus) error
	List(ctx context.Context, restaurantID string, page, pageSize int) ([]*TableSession, int64, error)
	GetActiveByTable(ctx context.Context, restaurantID, tableNumber string) (*TableSession, error)
	GetByCustomer(ctx context.Context, customerID string, page, pageSize int) ([]*TableSession, int64, error)
	GetActiveByWaiter(ctx context.Context, waiterID string) ([]*TableSession, error)
}

type ITableSessionUsecase interface {
	CreateSession(ctx context.Context, session *TableSession) error
	GetSessionByID(ctx context.Context, id string) (*TableSession, error)
	UpdateSession(ctx context.Context, session *TableSession) error
	CloseSession(ctx context.Context, id string, waiterID string) error
	ListSessions(ctx context.Context, restaurantID string, page, pageSize int) ([]*TableSession, int64, error)
	GetActiveSessionByTable(ctx context.Context, restaurantID, tableNumber string) (*TableSession, error)
	GetWaiterActiveSessions(ctx context.Context, waiterID string) ([]*TableSession, error)
}
