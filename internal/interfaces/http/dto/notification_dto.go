package dto

import (
	"errors"
	"time"

	"github.com/dinq/menumate/internal/domain"
)

type NotificationDTO struct {
	ID        string    `json:"id"`
	UserID    string    `json:"userId"`
	Message   string    `json:"message"`
	Type      string    `json:"type"`
	IsRead    bool      `json:"isRead"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func (n *NotificationDTO) Validate() error {
	if n.UserID == "" {
		return errors.New("userId is required")
	}
	if n.Message == "" {
		return errors.New("message is required")
	}
	if n.Type == "" {
		return errors.New("type is required")
	}
	return nil
}

func (n *NotificationDTO) ToDomain() *domain.Notification {
	return &domain.Notification{
		ID:        n.ID,
		UserID:    n.UserID,
		Message:   n.Message,
		Type:      domain.NotificationType(n.Type),
		IsRead:    n.IsRead,
		CreatedAt: n.CreatedAt,
		UpdatedAt: n.UpdatedAt,
	}
}

func (n *NotificationDTO) FromDomain(notification *domain.Notification) *NotificationDTO {
	return &NotificationDTO{
		ID:        notification.ID,
		UserID:    notification.UserID,
		Message:   notification.Message,
		Type:      string(notification.Type),
		IsRead:    notification.IsRead,
		CreatedAt: notification.CreatedAt,
		UpdatedAt: notification.UpdatedAt,
	}
}
