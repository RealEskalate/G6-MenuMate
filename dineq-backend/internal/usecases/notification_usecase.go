package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
)

type NotificationUseCase struct {
	repo      domain.INotificationRepository
	notifySvc services.NotificationService
}

func NewNotificationUseCase(repo domain.INotificationRepository, notifySvc services.NotificationService) domain.INotificationUseCase {
	return &NotificationUseCase{repo: repo, notifySvc: notifySvc}
}

func (uc *NotificationUseCase) CreateNotification(ctx context.Context, notification *domain.Notification) error {
	notification.CreatedAt = time.Now()
	notification.UpdatedAt = time.Now()
	if err := uc.repo.Create(ctx, notification); err != nil {
		return err
	}
	// Notify the customer
	if err := uc.notifySvc.SendNotification(ctx, notification.UserID, notification); err != nil {
		fmt.Printf("Warning: Failed to send notification to %s: %v\n", notification.UserID, err)
		return err
	}
	return nil
}
func (uc *NotificationUseCase) SendNotificationFromRoute(ctx context.Context, userID, message string, notifType domain.NotificationType) error {
	notification := domain.Notification{
		UserID:  userID,
		Message: message,
		Type:    notifType,
	}
	return uc.CreateNotification(ctx, &notification)
}

func (uc *NotificationUseCase) GetNotificationsByUserID(ctx context.Context, userID string) ([]domain.Notification, error) {
	return uc.repo.GetByUserID(ctx, userID)
}

func (uc *NotificationUseCase) MarkAsRead(ctx context.Context, id string) error {
	notifications, err := uc.repo.GetByUserID(ctx, id)
	if err != nil {
		return err
	}
	for i := range notifications {
		notifications[i].IsRead = true
		notifications[i].UpdatedAt = time.Now()
		if err := uc.repo.Update(ctx, &notifications[i]); err != nil {
			return err
		}
	}
	return nil
}
