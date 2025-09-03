package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewQRCodeRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database, notifUc domain.INotificationUseCase) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	qrRepo := repositories.NewQRCodeRepository(db, env.QRCodeCollection)
	qrUsecase := usecase.NewQRCodeUseCase(qrRepo, ctxTimeout)

	qrHandler := handler.NewQRCodeHandler(qrUsecase, notifUc)

	protected := group.Group("/qr-code")
	protected.Use(middleware.AuthMiddleware(*env))
	protected.Use(middleware.ManagerOnly())
	{
		protected.GET("/:restaurant_slug", qrHandler.GetQRCode)
		protected.PATCH("/:restaurant_slug/:status", qrHandler.UpdateQRCodeStatus)
		protected.DELETE("/:restaurant_slug", qrHandler.DeleteQRCode)
	}
}
