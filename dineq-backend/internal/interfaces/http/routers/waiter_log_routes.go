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

func NewWaiterLogRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	waiterLogRepo := repositories.NewWaiterLogRepository(db, env.WaiterLogCollection)
	customerProfileRepo := repositories.NewCustomerProfileRepository(db, env.CustomerProfileCollection, env.UserCollection)
	waiterLogUC := usecase.NewWaiterLogUsecase(waiterLogRepo, customerProfileRepo, ctxTimeout)

	h := handler.NewWaiterLogHandler(waiterLogUC)

	r := group.Group("/waiter/logs")
	r.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleWaiter, domain.RoleManager, domain.RoleOwner, domain.RoleSuperAdmin),
	)
	{
		r.POST("", h.CreateLog)
		r.PUT("/:logId", h.UpdateLog)
		r.GET("", h.List)
		r.GET("/:logId", h.GetByID)
		r.GET("/orders/:orderId", h.GetByOrderID)
		r.GET("/restaurants/:restaurantId/insights/food", h.GetFoodInsights)
		r.GET("/waiters/:waiterId/stats", h.GetWaiterStats)
	}
}
