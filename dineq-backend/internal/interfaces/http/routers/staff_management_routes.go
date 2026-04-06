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

func NewStaffManagementRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	invitationRepo := repositories.NewStaffInvitationRepository(db, env.StaffInvitationCollection, env.UserCollection)
	userRepo := repositories.NewUserRepository(db, env.UserCollection)
	restaurantRepo := repositories.NewRestaurantRepo(db, env.RestaurantCollection)

	staffUC := usecase.NewStaffManagementUsecase(invitationRepo, userRepo, restaurantRepo, ctxTimeout)
	h := handler.NewStaffManagementHandler(staffUC)

	management := group.Group("/staff")
	management.Use(
		middleware.AuthMiddleware(*env),
		middleware.RolesAllowed(domain.RoleOwner, domain.RoleManager, domain.RoleSuperAdmin),
	)
	{
		management.POST("/invitations", h.InviteStaff)
		management.POST("/invitations/:invitationId/revoke", h.RevokeInvitation)
		management.GET("/invitations", h.ListInvitations)
		management.DELETE("/restaurants/:restaurantId/members/:staffId", h.RemoveStaff)
		management.GET("/restaurants/:restaurantId/members", h.GetRestaurantStaff)
	}

	common := group.Group("/staff")
	common.Use(middleware.AuthMiddleware(*env))
	{
		common.POST("/invitations/accept", h.AcceptInvitation)
		common.GET("/my-assignments", h.GetMyAssignments)
	}
}
