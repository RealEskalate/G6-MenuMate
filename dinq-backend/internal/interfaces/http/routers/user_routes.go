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

func NewUserRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// storage services
	imageKitStorageService := storage.NewImageKitStorage(
		env.ImageKitPrivateKey,
		env.ImageKitPrivateKey,
		env.ImageKitEndpoint,
	)
	// repositories and usecases
	userRepo := repositories.NewUserRepository(db, env.UserCollection)
	userUsecase := usecase.NewUserUsecase(userRepo, imageKitStorageService, ctxTimeout)
	userController := handler.NewUserController(userUsecase)

	group.PATCH("/users/update-profile", middleware.AuthMiddleware(*env), userController.UpdateProfile)
	group.PATCH("/users/change-password", middleware.AuthMiddleware(*env), userController.ChangePassword)

}
