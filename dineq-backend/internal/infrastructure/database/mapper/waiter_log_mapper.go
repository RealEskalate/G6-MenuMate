package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type FoodObservationModel struct {
	ItemID             string `bson:"itemId"`
	ItemName           string `bson:"itemName"`
	ConsumptionStatus  string `bson:"consumptionStatus"`
	LeftoverPercentage int    `bson:"leftoverPercentage"`
	CustomerComment    string `bson:"customerComment,omitempty"`
	Reason             string `bson:"reason,omitempty"`
}

type WaiterLogModel struct {
	ID                  bson.ObjectID          `bson:"_id,omitempty"`
	OrderID             string                 `bson:"orderId"`
	SessionID           string                 `bson:"sessionId,omitempty"`
	RestaurantID        string                 `bson:"restaurantId"`
	WaiterID            string                 `bson:"waiterId"`
	WaiterName          string                 `bson:"waiterName,omitempty"`
	CustomerID          string                 `bson:"customerId,omitempty"`
	CustomerName        string                 `bson:"customerName,omitempty"`
	TableNumber         string                 `bson:"tableNumber"`
	Observations        []FoodObservationModel `bson:"observations,omitempty"`
	CustomerMood        string                 `bson:"customerMood"`
	ServiceRating       int                    `bson:"serviceRating"`
	WillLikelyReturn    bool                   `bson:"willLikelyReturn"`
	TableDuration       int                    `bson:"tableDuration"`
	TotalCoversCount    int                    `bson:"totalCoversCount"`
	IsComplimentary     bool                   `bson:"isComplimentary"`
	ComplimentaryReason string                 `bson:"complimentaryReason,omitempty"`
	UpsellAttempted     bool                   `bson:"upsellAttempted"`
	UpsellSucceeded     bool                   `bson:"upsellSucceeded"`
	Notes               string                 `bson:"notes,omitempty"`
	CreatedAt           time.Time              `bson:"createdAt"`
	UpdatedAt           time.Time              `bson:"updatedAt"`
}

func WaiterLogFromDomain(l *domain.WaiterLog) *WaiterLogModel {
	obs := make([]FoodObservationModel, len(l.Observations))
	for i, o := range l.Observations {
		obs[i] = FoodObservationModel{
			ItemID:             o.ItemID,
			ItemName:           o.ItemName,
			ConsumptionStatus:  string(o.ConsumptionStatus),
			LeftoverPercentage: o.LeftoverPercentage,
			CustomerComment:    o.CustomerComment,
			Reason:             o.Reason,
		}
	}
	return &WaiterLogModel{
		OrderID:             l.OrderID,
		SessionID:           l.SessionID,
		RestaurantID:        l.RestaurantID,
		WaiterID:            l.WaiterID,
		WaiterName:          l.WaiterName,
		CustomerID:          l.CustomerID,
		CustomerName:        l.CustomerName,
		TableNumber:         l.TableNumber,
		Observations:        obs,
		CustomerMood:        string(l.CustomerMood),
		ServiceRating:       l.ServiceRating,
		WillLikelyReturn:    l.WillLikelyReturn,
		TableDuration:       l.TableDuration,
		TotalCoversCount:    l.TotalCoversCount,
		IsComplimentary:     l.IsComplimentary,
		ComplimentaryReason: l.ComplimentaryReason,
		UpsellAttempted:     l.UpsellAttempted,
		UpsellSucceeded:     l.UpsellSucceeded,
		Notes:               l.Notes,
		CreatedAt:           l.CreatedAt,
		UpdatedAt:           l.UpdatedAt,
	}
}

func WaiterLogToDomain(m *WaiterLogModel) *domain.WaiterLog {
	obs := make([]domain.FoodObservation, len(m.Observations))
	for i, o := range m.Observations {
		obs[i] = domain.FoodObservation{
			ItemID:             o.ItemID,
			ItemName:           o.ItemName,
			ConsumptionStatus:  domain.FoodConsumptionStatus(o.ConsumptionStatus),
			LeftoverPercentage: o.LeftoverPercentage,
			CustomerComment:    o.CustomerComment,
			Reason:             o.Reason,
		}
	}
	return &domain.WaiterLog{
		ID:                  m.ID.Hex(),
		OrderID:             m.OrderID,
		SessionID:           m.SessionID,
		RestaurantID:        m.RestaurantID,
		WaiterID:            m.WaiterID,
		WaiterName:          m.WaiterName,
		CustomerID:          m.CustomerID,
		CustomerName:        m.CustomerName,
		TableNumber:         m.TableNumber,
		Observations:        obs,
		CustomerMood:        domain.CustomerMood(m.CustomerMood),
		ServiceRating:       m.ServiceRating,
		WillLikelyReturn:    m.WillLikelyReturn,
		TableDuration:       m.TableDuration,
		TotalCoversCount:    m.TotalCoversCount,
		IsComplimentary:     m.IsComplimentary,
		ComplimentaryReason: m.ComplimentaryReason,
		UpsellAttempted:     m.UpsellAttempted,
		UpsellSucceeded:     m.UpsellSucceeded,
		Notes:               m.Notes,
		CreatedAt:           m.CreatedAt,
		UpdatedAt:           m.UpdatedAt,
	}
}

func WaiterLogToDomainList(models []*WaiterLogModel) []*domain.WaiterLog {
	logs := make([]*domain.WaiterLog, len(models))
	for i, m := range models {
		logs[i] = WaiterLogToDomain(m)
	}
	return logs
}
