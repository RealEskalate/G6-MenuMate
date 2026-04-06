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

func NewCustomerProfileRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second
	customerProfileRepo := repositories.NewCustomerProfileRepository(db, env.CustomerProfileCollection, env.UserCollection)
	customerProfileUC := usecase.NewCustomerProfileUsecase(customerProfileRepo, ctxTimeout)

	h := handler.NewCustomerProfileHandler(customerProfileUC)

	manage := group.Group("/customer-profiles")
	manage.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleOwner, domain.RoleManager, domain.RoleWaiter, domain.RoleStaff, domain.RoleSuperAdmin),
	)
	{
		manage.GET("/:profileId", h.GetByID)
		manage.PUT("/:profileId", h.UpdateProfile)
		manage.POST("/:profileId/notes", h.AddNote)
		manage.GET("/restaurants/:restaurantId/customers", h.ListCustomers)
		manage.GET("/restaurants/:restaurantId/top", h.GetTopCustomers)
		manage.GET("/restaurants/:restaurantId/at-risk", h.GetAtRiskCustomers)
		manage.POST("/restaurants/:restaurantId/users/:userId/visits", h.RecordVisit)
		manage.GET("/restaurants/:restaurantId/users/:userId", h.GetOrCreate)
	}

	self := group.Group("/customer-profiles")
	self.Use(middleware.AuthMiddleware(*env))
	{
		self.PATCH("/me/preferences", h.UpdateDietaryPreferences)
		self.GET("/me/history", h.GetMyHistory)
	}
}
