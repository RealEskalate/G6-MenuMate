package dto

import (
	"errors"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type NotificationDTO struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Message   string    `json:"message"`
	Type      string    `json:"type"`
	IsRead    bool      `json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (n *NotificationDTO) Validate() error {
	if n.UserID == "" {
		return errors.New("user_id is required")
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
