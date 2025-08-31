package routers

import (
	"github.com/dinq/menumate/internal/bootstrap"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/dinq/menumate/internal/infrastructure/repositories"
	services "github.com/dinq/menumate/internal/infrastructure/service"
	handler "github.com/dinq/menumate/internal/interfaces/http/handlers"
	"github.com/dinq/menumate/internal/interfaces/middleware"
	usecase "github.com/dinq/menumate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewNotificationRoutes(env *bootstrap.Env, api *gin.RouterGroup, db mongo.Database, notifySvc services.NotificationService) {

	// Initialize repositories
	notifyRepo := repositories.NewNotificationRepository(
		db,
		env.NotificationCollection,
	)

	// Initialize use cases
	notifyUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	// Initialize handlers
	notifyHandler := handler.NewNotificationHandler(notifyUseCase, notifySvc)
	protected := api.Group("/notifications")
	protected.Use(middleware.AuthMiddleware(*env))
	{
		protected.POST("/", notifyHandler.CreateNotification)
		protected.GET("/:userId", notifyHandler.GetNotificationsByUserID)
		protected.PUT("/:userId/read", notifyHandler.MarkAsRead)
		protected.GET("/ws", notifyHandler.WSHandler)

	}
}
