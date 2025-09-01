package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	middleware "github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewRestaurantRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {

	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	restaurantRepo := repositories.NewRestaurantRepo(db, env.RestaurantCollection)
	restaurantUsecase := usecase.NewRestaurantUsecase(restaurantRepo, ctxTimeout)
	restaurantHandler := handler.NewRestaurantHandler(restaurantUsecase)

	// Public endpoints (no auth required)
	pub := group.Group("/restaurants")
	{
		pub.GET("", restaurantHandler.GetUniqueRestaurants)
		pub.GET("/:slug", restaurantHandler.GetRestaurant)
		pub.GET("/:slug/branches", restaurantHandler.GetBranches)
	}

	// Protected endpoints (auth required)
	admin := group.Group("/restaurants")
	admin.Use(middleware.AuthMiddleware(*env))
	{
		admin.POST("", restaurantHandler.CreateRestaurant)
		admin.PUT("/:slug", restaurantHandler.UpdateRestaurant)
		admin.DELETE("/:id", restaurantHandler.DeleteRestaurant)
	}

}
