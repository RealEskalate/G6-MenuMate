package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"

	"github.com/gin-gonic/gin"
)

func NewRestaurantRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {

	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	cloudinaryStorage := services.NewCloudinaryStorage(
		env.CloudinaryName,
		env.CloudinaryAPIKey,
		env.CloudinarySecret,
	)

	restaurantRepo := repositories.NewRestaurantRepo(db, env.RestaurantCollection)
	restaurantUsecase := usecase.NewRestaurantUsecase(restaurantRepo, ctxTimeout, cloudinaryStorage)
	restaurantHandler := handler.NewRestaurantHandler(restaurantUsecase)

	api := group.Group("/restaurants")
	api.Use(middleware.AuthMiddleware(*env))

	{
		// CRUD
		api.POST("", restaurantHandler.CreateRestaurant)
		api.GET("/:slug", restaurantHandler.GetRestaurant)
		api.PUT("/:slug", restaurantHandler.UpdateRestaurant)
		api.DELETE("/:id", restaurantHandler.DeleteRestaurant)

		// Listing
		api.GET("/:slug/branches", restaurantHandler.GetBranches) //all restaurants with a given slug
		api.GET("", restaurantHandler.GetUniqueRestaurants)       // List unique restaurants
	}

}
