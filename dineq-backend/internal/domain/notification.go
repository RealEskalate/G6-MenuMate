package domain

import (
	"context"
	"time"
)

type Notification struct {
	ID        string
	UserID    string           // Target customer
	Message   string           // Notification content
	Type      NotificationType // e.g., "menu_update", "order_status"
	IsRead    bool             // Read status
	CreatedAt time.Time        // Creation timestamp
	UpdatedAt time.Time        // Last update timestamp
}

type NotificationType string

const (
	MenuUpdate  NotificationType = "menu_update"
	InfoUpdate  NotificationType = "info_update"
	Promotional NotificationType = "promotional"
	SystemAlert NotificationType = "system_alert"
	MenuUpload  NotificationType = "menu_upload"
	FileUpload  NotificationType = "file_upload"
	Other       NotificationType = "others"
)

type INotificationUseCase interface {
	CreateNotification(ctx context.Context, notification *Notification) error
	GetNotificationsByUserID(ctx context.Context, userID string) ([]Notification, error)
	MarkAsRead(ctx context.Context, id string) error
	SendNotificationFromRoute(ctx context.Context, userID, message string, notifType NotificationType) error
}

type INotificationRepository interface {
	Create(ctx context.Context, notification *Notification) error
	GetByUserID(ctx context.Context, userID string) ([]Notification, error)
	Update(ctx context.Context, notification *Notification) error
}
