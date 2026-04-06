package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewSuperAdminRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	userRepo := repositories.NewUserRepository(db, env.UserCollection)
	restaurantRepo := repositories.NewRestaurantRepo(db, env.RestaurantCollection)
	orderRepo := repositories.NewOrderRepository(db, env.OrderCollection)
	reviewRepo := repositories.NewReviewRepository(db, env.ReviewCollection)
	approvalRepo := repositories.NewApprovalRequestRepository(db, env.ApprovalRequestCollection)
	auditRepo := repositories.NewAuditLogRepository(db, env.AuditLogCollection)
	customerProfileRepo := repositories.NewCustomerProfileRepository(db, env.CustomerProfileCollection, env.UserCollection)

	superAdminUC := usecase.NewSuperAdminUsecase(
		userRepo,
		restaurantRepo,
		orderRepo,
		reviewRepo,
		approvalRepo,
		auditRepo,
		customerProfileRepo,
		ctxTimeout,
	)

	h := handler.NewSuperAdminHandler(superAdminUC)

	r := group.Group("/super-admin")
	r.Use(middleware.AuthMiddleware(*env), middleware.SuperAdminOnly())
	{
		r.GET("/dashboard", h.GetPlatformAnalytics)

		r.GET("/users", h.ListUsers)
		r.PATCH("/users/:userId/status", h.UpdateUserStatus)
		r.PATCH("/users/:userId/role", h.UpdateUserRole)
		r.DELETE("/users/:userId", h.DeleteUser)

		r.GET("/restaurants", h.ListRestaurants)
		r.POST("/restaurants/:restaurantId/approve", h.ApproveRestaurant)
		r.POST("/restaurants/:restaurantId/reject", h.RejectRestaurant)

		r.GET("/approvals/pending", h.GetPendingApprovals)
		r.GET("/audit-logs", h.GetAuditLogs)
	}
}
