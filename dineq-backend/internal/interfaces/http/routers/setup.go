package routers

import (
	"net/http"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func Setup(env *bootstrap.Env, timeout time.Duration, db mongo.Database, router *gin.Engine) {
	// Notification services
	notifySvc := services.NewNotificationService()
	notifyRepo := repositories.NewNotificationRepository(db, env.NotificationCollection)
	notificationUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	router.GET("/", func(ctx *gin.Context) { ctx.Redirect(http.StatusPermanentRedirect, "/api") })
	api := router.Group("/api/v1")
	{
		NewAuthRoutes(env, api, db)
		NewUserRoutes(env, api, db)
		NewOCRJobRoutes(env, api, db, notificationUseCase)
		NewNotificationRoutes(env, api, db, notifySvc, notificationUseCase)
		NewRestaurantRoutes(env, api, db)
		NewMenuRoutes(env, api, db, notificationUseCase)
		NewQRCodeRoutes(env, api, db, notificationUseCase)
	}
}
