package services

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/dinq/menumate/internal/domain"
	"github.com/gorilla/websocket"
)

type NotificationService interface {
	SendNotification(ctx context.Context, userID string, notification *domain.Notification) error
	RegisterClient(userID string, conn *websocket.Conn)
	UnregisterClient(userID string)
	StartPing(conn *websocket.Conn, userID string)
}

type notificationService struct {
	clients sync.Map                          // Use sync.Map for active connections (read-heavy)
	queues  map[string][]*domain.Notification // Use map for queued notifications
	mutex   sync.Mutex                        // Mutex for queues
}

func NewNotificationService() NotificationService {
	return &notificationService{
		clients: sync.Map{},
		queues:  make(map[string][]*domain.Notification),
	}
}

func (s *notificationService) SendNotification(ctx context.Context, userID string, notification *domain.Notification) error {
	data, err := json.Marshal(notification)
	if err != nil {
		return err
	}

	// Check if the user has an active connection
	if conn, ok := s.clients.Load(userID); ok {
		if conn != nil {
			fmt.Println("Sending notification to", userID)
			if err := conn.(*websocket.Conn).WriteMessage(websocket.TextMessage, data); err != nil {
				fmt.Println("Write error:", err)
				s.clients.Delete(userID)                  // Remove invalid connection
				s.queueNotification(userID, notification) // Queue on failure
				return err
			}
			return nil
		}
	}

	// User is offline, queue the notification
	fmt.Println("User", userID, "is offline, queuing notification type:", notification.Type)
	s.queueNotification(userID, notification)
	s.mutex.Lock()
	if queued, ok := s.queues[userID]; ok {
		fmt.Println("Queue for", userID, "size:", len(queued))
	}
	s.mutex.Unlock()
	return nil
}

// queueNotification adds a notification to the user's queue
func (s *notificationService) queueNotification(userID string, notification *domain.Notification) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if queued, ok := s.queues[userID]; ok {
		s.queues[userID] = append(queued, notification)
	} else {
		s.queues[userID] = []*domain.Notification{notification}
	}
}

// RegisterClient registers a WebSocket connection and delivers queued notifications
func (s *notificationService) RegisterClient(userID string, conn *websocket.Conn) {
	s.clients.Store(userID, conn)
	fmt.Println("Client registered in service:", userID)
	// Deliver queued notifications
	s.mutex.Lock()
	defer s.mutex.Unlock()
	if queued, ok := s.queues[userID]; ok {
		for _, notif := range queued {
			s.SendNotification(context.Background(), userID, notif)
		}
		delete(s.queues, userID) // Clear queue after delivery
	}
}

// UnregisterClient removes a WebSocket connection
func (s *notificationService) UnregisterClient(userID string) {
	s.clients.Delete(userID)
}

// startPing keeps the connection alive
func (s *notificationService) StartPing(conn *websocket.Conn, userID string) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()
	for range ticker.C {
		if err := conn.WriteMessage(websocket.PingMessage, []byte{}); err != nil {
			fmt.Println("Ping failed:", userID, err)
			s.UnregisterClient(userID)
			return
		}
	}
}
