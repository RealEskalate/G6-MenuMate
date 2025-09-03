package routers

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
	"github.com/veryfi/veryfi-go/veryfi"
)

func NewOCRJobRoutes(env *bootstrap.Env, group *gin.RouterGroup, db mongo.Database, notifUc domain.INotificationUseCase) {

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

	// // Worker
	// pollInterval := 5 * time.Second
	// ocrWorker := services.NewWorker(ctx, ocrJobRepo, ocrService, aiService, imgService, pushService, pollInterval)
	// go ocrWorker.Start()

	// qr services
	qrService := services.NewQRService()

	// menu repo
	menuRepo := repositories.NewMenuRepository(db, env.MenuCollection)
	menuUsecase := usecase.NewMenuUseCase(menuRepo, *qrService, ctxTimeout)

	// repositories and usecases
	ocrJobRepo := repositories.NewOCRJobRepository(db, env.OCRJobCollection)
	ocrJobUsecase := usecase.NewOCRJobUseCase(ocrJobRepo, menuRepo, ocrService, aiService, ctxTimeout)

	// ocr Handler
	ocrJobHandler := handler.NewOCRJobHandler(ocrJobUsecase, menuUsecase, cloudinaryStorage, notifUc)

	// Backward compatibility / transition routes for previously documented /ocr-jobs paths
	legacy := group.Group("/ocr-jobs")
	legacy.Use(middleware.AuthMiddleware(*env))
	{
		// Allow POST to either base or /upload for flexibility
		legacy.POST("", ocrJobHandler.UploadMenu)
		legacy.POST("/upload", ocrJobHandler.UploadMenu)
		legacy.GET("/:id", ocrJobHandler.GetOCRJobByID)
		legacy.DELETE("/:id", ocrJobHandler.DeleteOCRJob)
	}
}
