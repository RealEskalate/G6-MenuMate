package routers

import (
	"context"
	"time"

	"github.com/dinq/menumate/internal/bootstrap"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/dinq/menumate/internal/infrastructure/logger"
	"github.com/dinq/menumate/internal/infrastructure/repositories"
	services "github.com/dinq/menumate/internal/infrastructure/service"
	handler "github.com/dinq/menumate/internal/interfaces/http/handlers"
	"github.com/dinq/menumate/internal/interfaces/middleware"
	usecase "github.com/dinq/menumate/internal/usecases"
	"github.com/gin-gonic/gin"
	"github.com/veryfi/veryfi-go/veryfi"
)

func NewOCRJobRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database, notifySvc services.NotificationService) {

	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second
	ctx := context.Background()

	ocrOption := veryfi.Options{
		ClientID:     env.VeryfiClientID,
		ClientSecret: env.VeryfiClientSecret,
		APIKey:       env.VeryfiAPIKey,
		Username:     env.VeryfiUsername,
	}
	ocrService := services.NewOCRService(&ocrOption)

	// storage services
	cloudinaryStorage := services.NewCloudinaryStorage(
		env.CloudinaryName,
		env.CloudinaryAPIKey,
		env.CloudinarySecret,
	)

	// image search services
	imgService, err := services.NewImageSearchService(env.SearchEngineID, env.SearchAPIKey)
	if err != nil {
		logger.Log.Fatal().Err(err).Msg("Failed to initialize Image Search Service")
	}

	// Aiservices
	aiService, err := services.NewAIService(ctx, env.GeminiAPIKey, env.GeminiModelName, imgService)
	if err != nil {
		logger.Log.Fatal().Err(err).Msg("Failed to initialize AI Service")
	}

	// Notifcation
	notifyRepo := repositories.NewNotificationRepository(db, env.NotificationCollection)
	notificationUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	// // Worker
	// pollInterval := 5 * time.Second
	// ocrWorker := services.NewWorker(ctx, ocrJobRepo, ocrService, aiService, imgService, pushService, pollInterval)
	// go ocrWorker.Start()

	// menu repo
	menuRepo := repositories.NewMenuRepository(db, env.MenuCollection)
	menuUsecase := usecase.NewMenuUseCase(menuRepo, ctxTimeout)

	// repositories and usecases
	ocrJobRepo := repositories.NewOCRJobRepository(db, env.OCRJobCollection)
	ocrJobUsecase := usecase.NewOCRJobUseCase(ocrJobRepo, menuRepo, ocrService, aiService, ctxTimeout)

	// ocr Handler
	ocrJobHandler := handler.NewOCRJobHandler(ocrJobUsecase, menuUsecase, cloudinaryStorage, notificationUseCase)

	protected := group.Group("/ocr")
	protected.Use(middleware.AuthMiddleware(*env))
	{
		protected.POST("/upload", ocrJobHandler.UploadMenu)
		protected.GET("/:id", ocrJobHandler.GetOCRJobByID)
		protected.DELETE("/:id", ocrJobHandler.DeleteOCRJob)
		// protected.GET("/:id/result", ocrJobHandler.GetOCRJobResult)
		// protected.PUT("/:id/status", ocrJobHandler.UpdateOCRJobStatus)
	}
}
