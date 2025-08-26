package routers

import (
	"net/http"
	"time"

	"github.com/dinq/menumate/internal/bootstrap"
	mongo "github.com/dinq/menumate/internal/infrastructure/database"
	"github.com/gin-gonic/gin"
)

func Setup(env *bootstrap.Env, timeout time.Duration, db mongo.Database, router *gin.Engine) {
	router.GET("/", func(ctx *gin.Context) { ctx.Redirect(http.StatusPermanentRedirect, "/api") })
	api := router.Group("/api/v1")
	{
		NewAuthRoutes(env, api, db)
		NewUserRoutes(env, api, db)
	}
}
