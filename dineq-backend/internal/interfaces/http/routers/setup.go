package routers

import (
	"net/http"
	"time"
	"sort"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func Setup(env *bootstrap.Env, timeout time.Duration, db mongo.Database, router *gin.Engine) {
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:3000", "https://your-frontend.com"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
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
		NewImageSearchRoutes(env, api)
		NewReactionRoutes(env, api, db)
		NewMenuRoutes(env, api, db, notificationUseCase)
		NewQRCodeRoutes(env, api, db, notificationUseCase)
		NewUploadRoutes(env, api)
		NewItemRoutes(env, api, db, notifySvc)
		NewReviewRoutes(env, api,db)

		// Temporary route enumerator for debugging 404 issue on nested review route
		api.GET("/_routes", func(c *gin.Context) {
			// gin doesn't expose a public route listing; walking router trees manually avoided for brevity.
			// Instead, maintain a static slice mirroring registered routes (quick instrumentation approach).
			routes := []string{
				"POST /api/v1/auth/register",
				"POST /api/v1/auth/login",
				"POST /api/v1/auth/logout",
				"POST /api/v1/auth/forgot-password",
				"POST /api/v1/auth/verify-reset-token",
				"POST /api/v1/auth/reset-password",
				"POST /api/v1/auth/refresh",
				"GET /api/v1/auth/google/login",
				"GET /api/v1/auth/google/callback",
				"POST /api/v1/auth/verify-email",
				"POST /api/v1/auth/resend-otp",
				"PATCH /api/v1/auth/verify-otp",
				"PATCH /api/v1/users/update-profile",
				"PATCH /api/v1/users/change-password",
				"GET /api/v1/me",
				"GET /api/v1/users/:id",
				"GET /api/v1/users/avatar-options",
				"POST /api/v1/ocr/upload",
				"GET /api/v1/ocr/:id",
				"DELETE /api/v1/ocr/:id",
				"POST /api/v1/ocr/:id/retry",
				"POST /api/v1/notifications/",
				"GET /api/v1/notifications/:userId",
				"PUT /api/v1/notifications/:userId/read",
				"GET /api/v1/notifications/ws",
				"GET /api/v1/restaurants",
				"GET /api/v1/restaurants/search",
				"GET /api/v1/restaurants/:slug",
				"GET /api/v1/restaurants/nearby",
				"POST /api/v1/restaurants",
				"GET /api/v1/restaurants/me",
				"PATCH /api/v1/restaurants/:slug",
				"DELETE /api/v1/restaurants/:id",
				"GET /api/v1/images/search",
				"POST /api/v1/items/:item_id/reaction",
				"GET /api/v1/items/:item_id/reaction",
				"GET /api/v1/menus/:restaurant_slug",
				"GET /api/v1/menus/:restaurant_slug/:id",
				"POST /api/v1/menus/:restaurant_slug",
				"PATCH /api/v1/menus/:restaurant_slug/:id",
				"DELETE /api/v1/menus/:restaurant_slug/:id",
				"POST /api/v1/menus/:restaurant_slug/qrcode/:id",
				"POST /api/v1/menus/:restaurant_slug/publish/:id",
				"GET /api/v1/qr-code/:restaurant_slug",
				"PATCH /api/v1/qr-code/:restaurant_slug/:status",
				"DELETE /api/v1/qr-code/:restaurant_slug",
				"POST /api/v1/uploads/logo",
				"POST /api/v1/uploads/image",
				"GET /api/v1/menu-items/:menu_slug",
				"POST /api/v1/menu-items/:menu_slug/",
				"PATCH /api/v1/menu-items/:menu_slug/:id",
				"GET /api/v1/menu-items/:menu_slug/:id",
				"POST /api/v1/menu-items/:menu_slug/:id/reviews",
				"DELETE /api/v1/menu-items/:menu_slug/:id",
				"POST /api/v1/restaurants/:restaurant_id/items/:item_id/reviews", // EXPECTED NEW ROUTE
				"POST /api/v1/restaurants/:restaurant_id/items/:item_id/reviews/", // trailing variant
				"POST /api/v1/reviews", // legacy
				"PATCH /api/v1/reviews/:id",
				"DELETE /api/v1/reviews/:id",
				"GET /api/v1/reviews/:id",
				"GET /api/v1/items/:item_id/reviews",
				"GET /api/v1/items/:item_id/average-rating",
				"GET /api/v1/restaurants/v/:restaurant_id/average-rating",
				"GET /api/v1/health",
			}
			sort.Strings(routes)
			c.JSON(200, gin.H{"routes": routes})
		})
		h := handler.NewHealthHandler(db, 2*time.Second)
		api.GET("/health", h.Health)
	}
}
