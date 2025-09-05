package routers

import (
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

    ReactionRepo := repositories.NewReactionRepo(db, env.ReactionCollection)
    ReactionUsecase := usecase.NewReactionUsecase(ReactionRepo, ctxTimeout)
    ReactionHandler := handler.NewReactionHandler(ReactionUsecase)

    reactions := group.Group("/items")
    reactions.Use(middleware.AuthMiddleware(*env))
    {
        reactions.POST("/:item_id/reaction", ReactionHandler.SaveReaction)
        reactions.GET("/:item_id/reaction", ReactionHandler.GetReactionStats)
    }
}