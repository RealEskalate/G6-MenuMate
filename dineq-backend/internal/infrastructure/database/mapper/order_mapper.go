package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type OrderItemModel struct {
	ItemID         string   `bson:"itemId"`
	ItemName       string   `bson:"itemName"`
	ItemImage      string   `bson:"itemImage,omitempty"`
	MenuSlug       string   `bson:"menuSlug,omitempty"`
	Quantity       int      `bson:"quantity"`
	UnitPrice      float64  `bson:"unitPrice"`
	TotalPrice     float64  `bson:"totalPrice"`
	Notes          string   `bson:"notes,omitempty"`
	Customizations []string `bson:"customizations,omitempty"`
	Status         string   `bson:"status"`
}

type OrderModel struct {
	ID           bson.ObjectID    `bson:"_id,omitempty"`
	RestaurantID string           `bson:"restaurantId"`
	TableNumber  string           `bson:"tableNumber"`
	SessionID    string           `bson:"sessionId,omitempty"`
	CustomerID   string           `bson:"customerId,omitempty"`
	CustomerName string           `bson:"customerName,omitempty"`
	WaiterID     string           `bson:"waiterId"`
	WaiterName   string           `bson:"waiterName,omitempty"`
	Items        []OrderItemModel `bson:"items"`
	Status       string           `bson:"status"`
	SubTotal     float64          `bson:"subTotal"`
	TaxAmount    float64          `bson:"taxAmount"`
	TotalAmount  float64          `bson:"totalAmount"`
	Currency     string           `bson:"currency"`
	SpecialNotes string           `bson:"specialNotes,omitempty"`
	Source       string           `bson:"source,omitempty"`
	CancelReason string           `bson:"cancelReason,omitempty"`
	CreatedAt    time.Time        `bson:"createdAt"`
	UpdatedAt    time.Time        `bson:"updatedAt"`
	CompletedAt  *time.Time       `bson:"completedAt,omitempty"`
	CancelledAt  *time.Time       `bson:"cancelledAt,omitempty"`
	IsDeleted    bool             `bson:"isDeleted"`
}

func OrderFromDomain(o *domain.Order) *OrderModel {
	items := make([]OrderItemModel, len(o.Items))
	for i, it := range o.Items {
		items[i] = OrderItemModel{
			ItemID:         it.ItemID,
			ItemName:       it.ItemName,
			ItemImage:      it.ItemImage,
			MenuSlug:       it.MenuSlug,
			Quantity:       it.Quantity,
			UnitPrice:      it.UnitPrice,
			TotalPrice:     it.TotalPrice,
			Notes:          it.Notes,
			Customizations: it.Customizations,
			Status:         string(it.Status),
		}
	}
	return &OrderModel{
		RestaurantID: o.RestaurantID,
		TableNumber:  o.TableNumber,
		SessionID:    o.SessionID,
		CustomerID:   o.CustomerID,
		CustomerName: o.CustomerName,
		WaiterID:     o.WaiterID,
		WaiterName:   o.WaiterName,
		Items:        items,
		Status:       string(o.Status),
		SubTotal:     o.SubTotal,
		TaxAmount:    o.TaxAmount,
		TotalAmount:  o.TotalAmount,
		Currency:     o.Currency,
		SpecialNotes: o.SpecialNotes,
		Source:       o.Source,
		CancelReason: o.CancelReason,
		CreatedAt:    o.CreatedAt,
		UpdatedAt:    o.UpdatedAt,
		CompletedAt:  o.CompletedAt,
		CancelledAt:  o.CancelledAt,
		IsDeleted:    o.IsDeleted,
	}
}

func OrderToDomain(m *OrderModel) *domain.Order {
	items := make([]domain.OrderItem, len(m.Items))
	for i, it := range m.Items {
		items[i] = domain.OrderItem{
			ItemID:         it.ItemID,
			ItemName:       it.ItemName,
			ItemImage:      it.ItemImage,
			MenuSlug:       it.MenuSlug,
			Quantity:       it.Quantity,
			UnitPrice:      it.UnitPrice,
			TotalPrice:     it.TotalPrice,
			Notes:          it.Notes,
			Customizations: it.Customizations,
			Status:         domain.OrderItemStatus(it.Status),
		}
	}
	return &domain.Order{
		ID:           m.ID.Hex(),
		RestaurantID: m.RestaurantID,
		TableNumber:  m.TableNumber,
		SessionID:    m.SessionID,
		CustomerID:   m.CustomerID,
		CustomerName: m.CustomerName,
		WaiterID:     m.WaiterID,
		WaiterName:   m.WaiterName,
		Items:        items,
		Status:       domain.OrderStatus(m.Status),
		SubTotal:     m.SubTotal,
		TaxAmount:    m.TaxAmount,
		TotalAmount:  m.TotalAmount,
		Currency:     m.Currency,
		SpecialNotes: m.SpecialNotes,
		Source:       m.Source,
		CancelReason: m.CancelReason,
		CreatedAt:    m.CreatedAt,
		UpdatedAt:    m.UpdatedAt,
		CompletedAt:  m.CompletedAt,
		CancelledAt:  m.CancelledAt,
		IsDeleted:    m.IsDeleted,
	}
}

func OrderListToDomain(models []*OrderModel) []*domain.Order {
	orders := make([]*domain.Order, len(models))
	for i, m := range models {
		orders[i] = OrderToDomain(m)
	}
	return orders
}
