package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type NotificationDB struct {
	ID        string    `bson:"_id,omitempty"`
	UserID    string    `bson:"userId"`
	Message   string    `bson:"message"`
	Type      string    `bson:"type"`
	IsRead    bool      `bson:"isRead"`
	CreatedAt time.Time `bson:"createdAt"`
	UpdatedAt time.Time `bson:"updatedAt"`
}

func ToNotificationDB(notf domain.Notification) NotificationDB {
	return NotificationDB{
		UserID:    notf.UserID,
		Message:   notf.Message,
		Type:      string(notf.Type),
		IsRead:    notf.IsRead,
		CreatedAt: notf.CreatedAt,
		UpdatedAt: notf.UpdatedAt,
	}
}

func ToNotificationDomain(db NotificationDB) domain.Notification {
	return domain.Notification{
		ID:        db.ID,
		UserID:    db.UserID,
		Message:   db.Message,
		Type:      domain.NotificationType(db.Type),
		IsRead:    db.IsRead,
		CreatedAt: db.CreatedAt,
		UpdatedAt: db.UpdatedAt,
	}
}

func ToNotificationDomainList(dbs []NotificationDB) []domain.Notification {
	var notifications []domain.Notification
	for _, db := range dbs {
		notifications = append(notifications, ToNotificationDomain(db))
	}
	return notifications
}
