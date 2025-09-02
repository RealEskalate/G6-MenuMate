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

func NewReviewRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database) {
    // context timeout
    ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

    // repositories and usecases
    reviewRepo := repositories.NewReviewRepository(db, env.ReviewCollection)
    reviewUsecase := usecase.NewReviewUsecase(reviewRepo, ctxTimeout)
    reviewHandler := handler.NewReviewHandler(reviewUsecase)

    // Authenticated routes
    group.POST("/reviews", middleware.AuthMiddleware(*env), reviewHandler.CreateReview)
    group.PATCH("/reviews/:id", middleware.AuthMiddleware(*env), reviewHandler.UpdateReview)
    group.DELETE("/reviews/:id", middleware.AuthMiddleware(*env), reviewHandler.DeleteReview)

    // Public routes
    group.GET("/reviews/:id", reviewHandler.GetReviewByID)
    group.GET("/items/:item_id/reviews", reviewHandler.ListReviewsByItem)
    group.GET("/items/:item_id/average-rating", reviewHandler.GetAverageRatingByItem)
    group.GET("/restaurants/v/:restaurant_id/average-rating", reviewHandler.GetAverageRatingByRestaurant)
}