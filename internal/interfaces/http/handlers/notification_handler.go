package handler

import (
	"fmt"
	"net/http"

	"github.com/dinq/menumate/internal/domain"
	services "github.com/dinq/menumate/internal/infrastructure/service"
	"github.com/dinq/menumate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

type NotificationHandler struct {
	UseCase   domain.INotificationUseCase
	NotifySvc services.NotificationService
	Upgrader  websocket.Upgrader // For WebSocket upgrade
}

func NewNotificationHandler(uc domain.INotificationUseCase, notifySvc services.NotificationService) *NotificationHandler {
	return &NotificationHandler{
		UseCase:   uc,
		NotifySvc: notifySvc,
		Upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool { return true },
		},
	}
}

// CreateNotification handles the creation of a new notification
func (h *NotificationHandler) CreateNotification(c *gin.Context) {
	var notf_dto dto.NotificationDTO
	if err := c.ShouldBindJSON(&notf_dto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := notf_dto.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	notification := notf_dto.ToDomain()
	if err := h.UseCase.CreateNotification(c.Request.Context(), notification); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, notf_dto.FromDomain(notification))
}

// GetNotificationsByUserID retrieves notifications for a user
func (h *NotificationHandler) GetNotificationsByUserID(c *gin.Context) {
	userID := c.Param("userId")
	notifications, err := h.UseCase.GetNotificationsByUserID(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Notifications not found"})
		return
	}
	var dtos []dto.NotificationDTO
	for _, n := range notifications {
		var notf_dto dto.NotificationDTO
		dtos = append(dtos, *notf_dto.FromDomain(&n))
	}
	c.JSON(http.StatusOK, dtos)

}

// MarkAsRead marks a notification as read (placeholder for specific ID)
func (h *NotificationHandler) MarkAsRead(c *gin.Context) {
	userID := c.Param("userId")
	if err := h.UseCase.MarkAsRead(c.Request.Context(), userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
}

// WSHandler upgrades HTTP to WebSocket for real-time updates
func (h *NotificationHandler) WSHandler(c *gin.Context) {
	userID := c.GetString("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID is required"})
		return
	}

	conn, err := h.Upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upgrade to WebSocket"})
		return
	}
	defer conn.Close()

	h.NotifySvc.RegisterClient(userID, conn)
	fmt.Println("Client registered:", userID) // Debug log

	go h.NotifySvc.StartPing(conn, userID) // Start ping loop

	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			fmt.Println("Disconnected:", userID, err)
			h.NotifySvc.UnregisterClient(userID)
			break
		}
	}
	c.JSON(http.StatusOK, gin.H{"message": "WebSocket connection established"})
}
