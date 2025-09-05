package routers

import (
	"net/http"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
	"github.com/gin-contrib/cors"
)

func Setup(env *bootstrap.Env, timeout time.Duration, db mongo.Database, router *gin.Engine) {
  router.Use(cors.New(cors.Config{
        AllowOrigins:     []string{"http://localhost:3000", "https://your-frontend.com"},
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
        MaxAge: 12 * time.Hour,
    }))



	// Notification services
	notifySvc := services.NewNotificationService()
	notifyRepo := repositories.NewNotificationRepository(db, env.NotificationCollection)
	notificationUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	router.GET("/", func(ctx *gin.Context) { ctx.Redirect(http.StatusPermanentRedirect, "/api") })

	// Fallback routes for Google OAuth if redirect URI is configured without /api/v1 prefix
	router.GET("/auth/google/login", func(c *gin.Context) { c.Redirect(http.StatusTemporaryRedirect, "/api/v1/auth/google/login") })
	router.GET("/auth/google/callback", func(c *gin.Context) { c.Redirect(http.StatusTemporaryRedirect, "/api/v1/auth/google/callback") })

	api := router.Group("/api/v1")
	{
		NewAuthRoutes(env, api, db)
		NewUserRoutes(env, api, db)
		NewOCRJobRoutes(env, api, db, notificationUseCase)
		NewNotificationRoutes(env, api, db, notifySvc, notificationUseCase)
		NewRestaurantRoutes(env, api, db)
		NewMenuRoutes(env, api, db, notificationUseCase)
		NewQRCodeRoutes(env, api, db, notificationUseCase)
		NewItemRoutes(env, api, db, notifySvc)
		h := handler.NewHealthHandler(db, 2*time.Second)
		api.GET("/health", h.Health)
	}
}
