package routers

import (
	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	"github.com/gin-gonic/gin"
)

func NewNotificationRoutes(env *bootstrap.Env, api *gin.RouterGroup, db mongo.Database, notifySvc services.NotificationService, notifUc domain.INotificationUseCase) {

	// Initialize handlers
	notifyHandler := handler.NewNotificationHandler(notifUc, notifySvc)
	protected := api.Group("/notifications")
	protected.Use(middleware.AuthMiddleware(*env))
	{
		protected.POST("/", notifyHandler.CreateNotification)
		protected.GET("/:userId", notifyHandler.GetNotificationsByUserID)
		protected.PUT("/:userId/read", notifyHandler.MarkAsRead)
		protected.GET("/ws", notifyHandler.WSHandler)

	}
}
