package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewItemRoutes(env *bootstrap.Env, api *gin.RouterGroup, db mongo.Database, notifySvc services.NotificationService) {
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	itemRepo := repositories.NewItemRepository(db, env.ItemCollection)
	itemUseCase := usecase.NewItemUseCase(itemRepo, ctxTimeout)
	viewEventRepo := repositories.NewViewEventRepository(db, env.ViewEventCollection)

	handler := handler.NewItemHandler(itemUseCase, viewEventRepo)

	// Public item routes (read-only)
	public := api.Group("/menu-items")
	{
		public.GET("/:menu_slug", handler.GetItems)
		public.GET("/:menu_slug/:id", handler.GetItemByID)
		public.GET("/search/advanced", handler.SearchItems)
	public.GET("/:menu_slug/search", handler.SearchItems)
	}

	// Protected item routes (mutations)
	protected := api.Group("/menu-items")
	protected.Use(middleware.AuthMiddleware(*env))
	{
		protected.POST("/:menu_slug/", handler.CreateItem)
		protected.PATCH("/:menu_slug/:id", handler.UpdateItem)
		protected.POST("/:menu_slug/:id/reviews", handler.AddReview)
		protected.DELETE("/:menu_slug/:id", handler.DeleteItem)
	}

}
