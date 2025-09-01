package routers

import (
	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
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
