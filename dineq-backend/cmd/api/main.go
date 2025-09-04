package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/routers"
	"github.com/gin-gonic/gin"
)

func main() {

	// Initialize logger
	logger.InitLogger()
	logger.Log.Info().Msg("-------------Starting DineQ Menu Mate API---------------")

	// Load environment & bootstrap app
	app, err := bootstrap.InitApp()
	if err != nil {
		logger.Log.Fatal().Err(err).Msg("failed to initialize app")
	}
	env := app.Env
	db := app.Mongo.Database(env.DB_Name)
	defer app.CloseDBConnection()

	logger.Log.Info().Str("db", env.DB_Name).Msg("Database acquired")

	timeout := time.Duration(env.CtxTSeconds) * time.Second

	// Gin router
	router := gin.Default()
	// router.Use(middleware.RequestLogger())
	// router.Use(middleware.Recovery())

	router.Use(func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		allowAll := false
		for _, o := range env.CORSAllowedOrigins { if o == "*" { allowAll = true; break } }
		if origin != "" { c.Writer.Header().Add("Vary", "Origin") }
		if allowAll {
			if origin != "" {
				c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
			} else {
				c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
			}
		} else if origin != "" {
			for _, allowed := range env.CORSAllowedOrigins {
				if allowed == origin {
					c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
					break
				}
			}
		}
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, Accept")
		c.Writer.Header().Set("Access-Control-Expose-Headers", "Content-Length, Content-Type")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	routers.Setup(env, timeout, db, router)

	srv := &http.Server{
		Addr:         env.Port,
		Handler:      router,
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	// Start HTTP server in goroutine
	go func() {
		logger.Log.Info().Str("port", env.Port).Msg("🚀 Server running")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Log.Fatal().Err(err).Msg("listen")
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Log.Info().Msg("Shutdown Server...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Log.Error().Err(err).Msg("Server Shutdown Error")
	}
	logger.Log.Info().Msg("--------------------Server exiting----------------")
}
