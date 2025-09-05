package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewMenuRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database, notifUc domain.INotificationUseCase) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	qrService := services.NewQRGenerator(env.QRCodeContent)

	qrRepo := repositories.NewQRCodeRepository(db, env.QRCodeCollection)
	qrUsecase := usecase.NewQRCodeUseCase(qrRepo, ctxTimeout)

	// storage services
	cloudinaryStorage := services.NewCloudinaryStorage(
		env.CloudinaryName,
		env.CloudinaryAPIKey,
		env.CloudinarySecret,
	)

	menuRepo := repositories.NewMenuRepository(db, env.MenuCollection)
	menuUsecase := usecase.NewMenuUseCase(menuRepo, *qrService, cloudinaryStorage, ctxTimeout)

	menuHandler := handler.NewMenuHandler(menuUsecase, qrUsecase, notifUc)

	protected := group.Group("/menus")
	protected.Use(middleware.AuthMiddleware(*env))
	protected.Use(middleware.ManagerOnly())
	{
		protected.GET("/:restaurant_slug", menuHandler.GetMenus)
		protected.GET("/:restaurant_slug/:id", menuHandler.GetMenuByID)
		protected.POST("/:restaurant_slug", menuHandler.CreateMenu)
		protected.PATCH("/:restaurant_slug/:id", menuHandler.UpdateMenu)
		protected.DELETE("/:restaurant_slug/:id", menuHandler.DeleteMenu)
		protected.POST("/:restaurant_slug/qrcode/:id", menuHandler.GenerateQRCode)
		protected.POST("/:restaurant_slug/publish/:id", menuHandler.PublishMenu)
	}

}
