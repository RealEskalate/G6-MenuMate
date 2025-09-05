package routers

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	"github.com/gin-gonic/gin"
)

// NewUploadRoutes registers image upload endpoints (Cloudinary-backed)
func NewUploadRoutes(env *bootstrap.Env, group *gin.RouterGroup) {
    _ = time.Second // placeholder if future timeouts needed
    storage := services.NewCloudinaryStorage(env.CloudinaryName, env.CloudinaryAPIKey, env.CloudinarySecret)
    h := handler.NewImageUploadHandler(storage)

    uploads := group.Group("/uploads")
    uploads.Use(middleware.AuthMiddleware(*env))
    {
        uploads.POST("/logo", h.UploadLogo)
        uploads.POST("/image", h.UploadImage)
    }
}