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

func NewOrderRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	orderRepo := repositories.NewOrderRepository(db, env.OrderCollection)
	sessionRepo := repositories.NewTableSessionRepository(db, env.TableSessionCollection)
	orderUC := usecase.NewOrderUsecase(orderRepo, sessionRepo, ctxTimeout)
	h := handler.NewOrderHandler(orderUC)

	r := group.Group("/orders")
	r.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleWaiter, domain.RoleManager, domain.RoleOwner, domain.RoleSuperAdmin),
	)
	{
		r.POST("", h.Create)
		r.GET("", h.List)
		r.GET("/:orderId", h.GetByID)
		r.PUT("/:orderId", h.Update)
		r.PATCH("/:orderId/status", h.UpdateStatus)
		r.DELETE("/:orderId", h.Delete)
		r.GET("/session/:sessionId", h.GetBySession)
		r.GET("/analytics/revenue", h.GetRevenue)
		r.GET("/analytics/count", h.GetOrderCount)
	}
}
