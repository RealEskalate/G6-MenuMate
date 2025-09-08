package routers

import (
	"log"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	middleware "github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewReactionRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {

	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// Get the underlying *mongo.Database from your custom db interface
	// mongoDB := db.MongoDB() // This method must return *mongo.Database

	reactionRepo := repositories.NewReactionRepo(db, env.ReactionCollection)
	reactionUsecase := usecase.NewReactionUsecase(reactionRepo, ctxTimeout)

	// review repo/usecase for deriving item & restaurant IDs
	reviewRepo := repositories.NewReviewRepository(db, env.ReviewCollection)
	reviewUsecase := usecase.NewReviewUsecase(reviewRepo, ctxTimeout)

	reactionHandler := handler.NewReactionHandler(reactionUsecase, reviewUsecase)

	// New nested route: all identifiers in path
	// POST /restaurants/:restaurant_id/items/:item_id/reviews/:review_id/reaction
	// To avoid conflict with existing /restaurants/:slug wildcard, mount under a distinct prefix /restaurants/id/:restaurant_id
	log.Println("[ROUTES] (reaction) registering nested /restaurants/id/:restaurant_id/items/:item_id/reviews/:review_id/reaction routes")
	base := group.Group("/restaurants/id/:restaurant_id/items/:item_id/reviews")
	base.Use(middleware.AuthMiddleware(*env))
	{
		base.POST("/:review_id/reaction", reactionHandler.SaveReaction)
		base.GET("/:review_id/reaction", reactionHandler.GetReactionStats)
	}

	// (Optional) Backward compatible legacy endpoint (commented out). Remove when clients migrate.
	// legacy := group.Group("/reviews")
	// legacy.Use(middleware.AuthMiddleware(*env))
	// {
	// 	legacy.POST("/:review_id/reaction", reactionHandler.SaveReaction)
	// 	legacy.GET("/:review_id/reaction", reactionHandler.GetReactionStats)
	// }
}
