package routers

import (
	"time"

	"github.com/dinq/menumate/internal/bootstrap"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/dinq/menumate/internal/infrastructure/repositories"
	services "github.com/dinq/menumate/internal/infrastructure/service"
	handler "github.com/dinq/menumate/internal/interfaces/http/handlers"
	"github.com/dinq/menumate/internal/interfaces/middleware"
	usecase "github.com/dinq/menumate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewUserRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// storage services
		cloudinaryStorage := services.NewCloudinaryStorage(
		env.CloudinaryName,
		env.CloudinaryAPIKey,
		env.CloudinarySecret,
	)

	// Notifcation
	notifyRepo := repositories.NewNotificationRepository(db, env.NotificationCollection)
	notifySvc := services.NewNotificationService()
	notificationUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	// repositories and usecases
	userRepo := repositories.NewUserRepository(db, env.UserCollection)
	userUsecase := usecase.NewUserUsecase(userRepo, cloudinaryStorage, ctxTimeout)
	userController := handler.UserHandler{UserUsecase: userUsecase, NotificationUseCase: notificationUseCase}

	group.PATCH("/users/update-profile", middleware.AuthMiddleware(*env), userController.UpdateProfile)
	group.PATCH("/users/change-password", middleware.AuthMiddleware(*env), userController.ChangePassword)

}
