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

func NewTableSessionRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	sessionRepo := repositories.NewTableSessionRepository(db, env.TableSessionCollection)
	orderRepo := repositories.NewOrderRepository(db, env.OrderCollection)
	sessionUC := usecase.NewTableSessionUsecase(sessionRepo, orderRepo, ctxTimeout)
	h := handler.NewTableSessionHandler(sessionUC)

	r := group.Group("/table-sessions")
	r.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleWaiter, domain.RoleManager, domain.RoleOwner, domain.RoleSuperAdmin),
	)
	{
		r.POST("", h.Create)
		r.GET("", h.List)
		r.GET("/:sessionId", h.GetByID)
		r.PUT("/:sessionId", h.Update)
		r.POST("/:sessionId/close", h.Close)
		r.GET("/active", h.GetActiveByTable)
		r.GET("/waiters/:waiterId/active", h.GetWaiterActive)
	}
}
