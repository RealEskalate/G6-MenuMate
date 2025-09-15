package routers

import (
	"context"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	"github.com/gin-gonic/gin"
)

func NewImageSearchRoutes(env *bootstrap.Env, group *gin.RouterGroup) {
	googleSvc := services.NewGoogleCustomSearchService(env.SearchAPIKey, env.SearchEngineID)
	unsplashSvc := services.NewUnsplashSearchService(env.UnsplashAPIKey)
	pexelsSvc := services.NewPexelsSearchService(env.PexelsAPIKey)
	var aiSvc services.IAIService
	if env.GeminiAPIKey != "" {
		if svc, err := services.NewAIService(context.Background(), env.GeminiAPIKey, env.GeminiModelName, nil); err == nil {
			aiSvc = svc
		}
	}
	h := handler.NewImageSearchHandler(googleSvc, unsplashSvc, pexelsSvc, aiSvc)
	g := group.Group("/images")
	g.Use(middleware.AuthMiddleware(*env))
	{
		g.GET("/search", h.Search)
		g.POST("/search", h.SearchPost)
	}
}
