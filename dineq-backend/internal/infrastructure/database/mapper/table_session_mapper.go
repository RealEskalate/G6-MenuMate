package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type TableSessionModel struct {
	ID            bson.ObjectID `bson:"_id,omitempty"`
	RestaurantID  string        `bson:"restaurantId"`
	TableNumber   string        `bson:"tableNumber"`
	WaiterID      string        `bson:"waiterId"`
	WaiterName    string        `bson:"waiterName,omitempty"`
	CustomerID    string        `bson:"customerId,omitempty"`
	CustomerName  string        `bson:"customerName,omitempty"`
	CustomerPhone string        `bson:"customerPhone,omitempty"`
	CustomerEmail string        `bson:"customerEmail,omitempty"`
	GuestCount    int           `bson:"guestCount"`
	Status        string        `bson:"status"`
	StartedAt     time.Time     `bson:"startedAt"`
	EndedAt       *time.Time    `bson:"endedAt,omitempty"`
	OrderIDs      []string      `bson:"orderIds,omitempty"`
	TotalOrders   int           `bson:"totalOrders"`
	TotalSpent    float64       `bson:"totalSpent"`
	Currency      string        `bson:"currency,omitempty"`
	Notes         string        `bson:"notes,omitempty"`
	CreatedAt     time.Time     `bson:"createdAt"`
	UpdatedAt     time.Time     `bson:"updatedAt"`
}

func TableSessionFromDomain(s *domain.TableSession) *TableSessionModel {
	if s == nil {
		return nil
	}
	return &TableSessionModel{
		RestaurantID:  s.RestaurantID,
		TableNumber:   s.TableNumber,
		WaiterID:      s.WaiterID,
		WaiterName:    s.WaiterName,
		CustomerID:    s.CustomerID,
		CustomerName:  s.CustomerName,
		CustomerPhone: s.CustomerPhone,
		CustomerEmail: s.CustomerEmail,
		GuestCount:    s.GuestCount,
		Status:        string(s.Status),
		StartedAt:     s.StartedAt,
		EndedAt:       s.EndedAt,
		OrderIDs:      s.OrderIDs,
		TotalOrders:   s.TotalOrders,
		TotalSpent:    s.TotalSpent,
		Currency:      s.Currency,
		Notes:         s.Notes,
		CreatedAt:     s.CreatedAt,
		UpdatedAt:     s.UpdatedAt,
	}
}

func TableSessionToDomain(m *TableSessionModel) *domain.TableSession {
	if m == nil {
		return nil
	}
	return &domain.TableSession{
		ID:            m.ID.Hex(),
		RestaurantID:  m.RestaurantID,
		TableNumber:   m.TableNumber,
		WaiterID:      m.WaiterID,
		WaiterName:    m.WaiterName,
		CustomerID:    m.CustomerID,
		CustomerName:  m.CustomerName,
		CustomerPhone: m.CustomerPhone,
		CustomerEmail: m.CustomerEmail,
		GuestCount:    m.GuestCount,
		Status:        domain.TableSessionStatus(m.Status),
		StartedAt:     m.StartedAt,
		EndedAt:       m.EndedAt,
		OrderIDs:      m.OrderIDs,
		TotalOrders:   m.TotalOrders,
		TotalSpent:    m.TotalSpent,
		Currency:      m.Currency,
		Notes:         m.Notes,
		CreatedAt:     m.CreatedAt,
		UpdatedAt:     m.UpdatedAt,
	}
}

func TableSessionToDomainList(models []*TableSessionModel) []*domain.TableSession {
	sessions := make([]*domain.TableSession, 0, len(models))
	for _, m := range models {
		sessions = append(sessions, TableSessionToDomain(m))
	}
	return sessions
}
