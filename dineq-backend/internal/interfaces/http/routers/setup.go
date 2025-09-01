package routers

import (
	"net/http"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/gin-gonic/gin"
)

func Setup(env *bootstrap.Env, timeout time.Duration, db mongo.Database, router *gin.Engine) {
	// Notification services
	notifySvc := services.NewNotificationService()

	router.GET("/", func(ctx *gin.Context) { ctx.Redirect(http.StatusPermanentRedirect, "/api") })
	// Fallback routes for Google OAuth if redirect URI is configured without /api/v1 prefix
	router.GET("/auth/google/login", func(c *gin.Context) { c.Redirect(http.StatusTemporaryRedirect, "/api/v1/auth/google/login") })
	router.GET("/auth/google/callback", func(c *gin.Context) { c.Redirect(http.StatusTemporaryRedirect, "/api/v1/auth/google/callback") })
	api := router.Group("/api/v1")
	{
		NewAuthRoutes(env, api, db)
		NewUserRoutes(env, api, db)
		NewOCRJobRoutes(env, api, db, notifySvc)
		NewNotificationRoutes(env, api, db, notifySvc)
		NewRestaurantRoutes(env, api, db)
	}
}
