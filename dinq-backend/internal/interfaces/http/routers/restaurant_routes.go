package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"

	"github.com/gin-gonic/gin"
)

func NewRestaurantRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {

	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	restaurantRepo := repositories.NewRestaurantRepo(db, env.RestaurantCollection)
	restaurantUsecase := usecase.NewRestaurantUsecase(restaurantRepo, ctxTimeout)
	restaurantHandler := handler.NewRestaurantHandler(restaurantUsecase)

	api := group.Group("/restaurants")
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
