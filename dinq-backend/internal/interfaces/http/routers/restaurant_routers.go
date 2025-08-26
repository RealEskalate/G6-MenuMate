package routers

import (
	"time"

	"github.com/dinq/menumate/internal/bootstrap"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/dinq/menumate/internal/infrastructure/repositories"
	"github.com/dinq/menumate/internal/infrastructure/storage"
	handler "github.com/dinq/menumate/internal/interfaces/http/handlers"
	"github.com/dinq/menumate/internal/interfaces/middleware"
	usecase "github.com/dinq/menumate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewRestaurantRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// storage services
	imageKitStorageService := storage.NewImageKitStorage(
		env.ImageKitPrivateKey,
		env.ImageKitPrivateKey,
		env.ImageKitEndpoint,
	)

	// repositories and usecases
	restaurantRepo := repositories.NewRestaurantRepository(db, env.RestaurantCollection)
	restaurantUsecase := usecase.NewRestaurantUsecase(restaurantRepo, imageKitStorageService, ctxTimeout)
	RestaurantHandler := handler.NewRestaurantHandler(restaurantUsecase)

	// Define restaurant routes
	group.POST("/restaurants", middleware.AuthMiddleware(*env), middleware.OwnerOrAdminOnly(), RestaurantHandler.Create)
}
