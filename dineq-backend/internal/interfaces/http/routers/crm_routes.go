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

func NewCRMRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	customerProfileRepo := repositories.NewCustomerProfileRepository(db, env.CustomerProfileCollection, env.UserCollection)
	orderRepo := repositories.NewOrderRepository(db, env.OrderCollection)
	waiterLogRepo := repositories.NewWaiterLogRepository(db, env.WaiterLogCollection)
	sessionRepo := repositories.NewTableSessionRepository(db, env.TableSessionCollection)

	crmUC := usecase.NewCRMUsecase(customerProfileRepo, orderRepo, waiterLogRepo, sessionRepo, ctxTimeout)
	h := handler.NewCRMHandler(crmUC)

	r := group.Group("/crm")
	r.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleOwner, domain.RoleManager, domain.RoleSuperAdmin),
	)
	{
		r.GET("/restaurants/:restaurantId/dashboard", h.GetDashboard)
		r.GET("/restaurants/:restaurantId/customers", h.GetCustomerList)
		r.GET("/customers/:profileId", h.GetCustomerDetail)
		r.GET("/restaurants/:restaurantId/customers/export", h.ExportCustomerData)
	}
}
