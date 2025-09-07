package domain

import "time"

// ViewEvent logs every view of a restaurant, menu, or item
// EntityType: "restaurant", "menu", "item"
type ViewEvent struct {
	ID         string    `json:"id" bson:"_id,omitempty"`
	EntityType string    `json:"entity_type" bson:"entityType"`
	EntityID   string    `json:"entity_id" bson:"entityId"`
	UserID     string    `json:"user_id,omitempty" bson:"userId,omitempty"`
	Timestamp  time.Time `json:"timestamp" bson:"timestamp"`
	IP         string    `json:"ip,omitempty" bson:"ip,omitempty"`
	UserAgent  string    `json:"user_agent,omitempty" bson:"userAgent,omitempty"`
}

type IViewEventRepository interface {
	LogView(event *ViewEvent) error
}
