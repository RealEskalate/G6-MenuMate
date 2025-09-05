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
	// base context & timeout for service initialization (long-running OCR/AI may exceed; see TODO below)
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second
	ctx, cancel := context.WithTimeout(context.Background(), ctxTimeout)
	defer cancel()
	// TODO: Consider a separate, larger timeout specifically for long OCR+AI pipeline stages if env.CtxTSeconds is small.

	// Basic credential presence checks (log warnings, continue in degraded mode)
	if env.VeryfiClientID == "" || env.VeryfiClientSecret == "" || env.VeryfiAPIKey == "" || env.VeryfiUsername == "" {
		logger.Log.Warn().Msg("veryfi credentials incomplete; OCR extraction may fail")
	}
	if env.CloudinaryName == "" || env.CloudinaryAPIKey == "" || env.CloudinarySecret == "" {
		logger.Log.Warn().Msg("cloudinary credentials incomplete; uploads may fail")
	}
	if env.GeminiAPIKey == "" {
		logger.Log.Warn().Msg("gemini api key missing; AI enhancements disabled")
	}
	if env.SearchAPIKey == "" || env.SearchEngineID == "" {
		logger.Log.Warn().Msg("image search credentials missing; photo enrichment disabled")
	}

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
		logger.Log.Error().Err(err).Msg("failed to initialize image search service; OCR upload will proceed without image enrichment")
		imgService = nil // graceful degrade
	}

	// Aiservices
	aiService, err := services.NewAIService(ctx, env.GeminiAPIKey, env.GeminiModelName, imgService)
	if err != nil {
		logger.Log.Error().Err(err).Msg("failed to initialize AI service; OCR results will lack AI enhancements")
		aiService = nil // graceful degrade
	}

	// qr services
	qrServices := services.NewQRGenerator(env.QRCodeContent)

	// repositories
	menuRepo := repositories.NewMenuRepository(db, env.MenuCollection)
	ocrJobRepo := repositories.NewOCRJobRepository(db, env.OCRJobCollection)

	// use cases
	menuUsecase := usecase.NewMenuUseCase(menuRepo, *qrServices, cloudinaryStorage, ctxTimeout)
	ocrJobUsecase := usecase.NewOCRJobUseCase(ocrJobRepo, menuRepo, ocrService, aiService, ctxTimeout)

	// Worker (disabled)
	// TODO: Re-enable background worker for OCR job polling & retries.
	// TODO: Add notification dispatch integration guarded by feature flag.

	// OCR Handler
	ocrJobHandler := handler.NewOCRJobHandler(ocrJobUsecase, menuUsecase, cloudinaryStorage, notifUc)

	// Single canonical OCR route group (legacy /ocr-jobs removed)
	protected := group.Group("/ocr")
	protected.Use(middleware.AuthMiddleware(*env))
	{
		protected.POST("/upload", ocrJobHandler.UploadMenu)
		protected.GET("/:id", ocrJobHandler.GetOCRJobByID) // endpoint returns JSON for job
		protected.DELETE("/:id", ocrJobHandler.DeleteOCRJob)
		protected.POST("/:id/retry", ocrJobHandler.RetryOCRJob)
	}
}
