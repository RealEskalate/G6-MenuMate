package routers

import (
	"log"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewReviewRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	log.Println("[ROUTES] Entering NewReviewRoutes registration")
	// context timeout
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// repositories and usecases
	reviewRepo := repositories.NewReviewRepository(db, env.ReviewCollection)
	reviewUsecase := usecase.NewReviewUsecase(reviewRepo, ctxTimeout)
	userRepo := repositories.NewUserRepository(db, env.UserCollection)
	userUsecase := usecase.NewUserUsecase(userRepo, nil, ctxTimeout) // nil storage: not needed for read
	reviewHandler := handler.NewReviewHandler(reviewUsecase, userUsecase)

	// Temporary debug middleware for this subgroup to trace 404s
	debugGroup := group.Group("")
	debugGroup.Use(func(c *gin.Context) {
		if c.Request.Method == "POST" && strings.Contains(c.Request.URL.Path, "/restaurants/") && strings.Contains(c.Request.URL.Path, "/reviews") {
			log.Printf("[DEBUG ROUTE ENTER] method=%s path=%s", c.Request.Method, c.Request.URL.Path)
		}
		c.Next()
	})

	// Authenticated routes (new nested path adjusted to avoid conflict with /restaurants/:slug): /restaurants/id/:restaurant_id/items/:item_id/reviews
	log.Println("[ROUTES] Attempting to register POST /restaurants/id/:restaurant_id/items/:item_id/reviews (relative to /api/v1)")
	debugGroup.POST("/restaurants/id/:restaurant_id/items/:item_id/reviews", middleware.AuthMiddleware(*env), reviewHandler.CreateReview)
	// Trailing slash variant for some API clients that auto-append /
	debugGroup.POST("/restaurants/id/:restaurant_id/items/:item_id/reviews/", middleware.AuthMiddleware(*env), reviewHandler.CreateReview)
	log.Println("[ROUTES] Registered POST /api/v1/restaurants/id/:restaurant_id/items/:item_id/reviews")
	// Temporary legacy fallback for clients still using body IDs (will be removed)
	group.POST("/reviews", middleware.AuthMiddleware(*env), reviewHandler.CreateReview)
	log.Println("[ROUTES] Registered TEMP legacy POST /api/v1/reviews")
	// Legacy (comment out when deprecated):
	// group.POST("/reviews", middleware.AuthMiddleware(*env), reviewHandler.CreateReview)
	group.PATCH("/reviews/:id", middleware.AuthMiddleware(*env), reviewHandler.UpdateReview)
	group.DELETE("/reviews/:id", middleware.AuthMiddleware(*env), reviewHandler.DeleteReview)

	// Public routes
	group.GET("/reviews/:id", reviewHandler.GetReviewByID)
	group.GET("/items/:item_id/reviews", reviewHandler.ListReviewsByItem)
	group.GET("/items/:item_id/average-rating", reviewHandler.GetAverageRatingByItem)
	group.GET("/restaurants/v/:restaurant_id/average-rating", reviewHandler.GetAverageRatingByRestaurant)
}
