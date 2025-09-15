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

	// Support light-weight mode for CORS testing without DB (set SKIP_DB=true)
	var env *bootstrap.Env
	var dbName string
	skipDB := os.Getenv("SKIP_DB") == "true"
	var app *bootstrap.Application
	var err error
	if skipDB {
		env, err = bootstrap.NewEnv()
		if err != nil {
			logger.Log.Fatal().Err(err).Msg("failed to load env in SKIP_DB mode")
		}
		if env.Port == "" {
			env.Port = ":8080"
		}
		logger.Log.Warn().Msg("Running in SKIP_DB mode (no database connection) – for CORS / middleware testing only")
	} else {
		app, err = bootstrap.InitApp()
		if err != nil {
			logger.Log.Fatal().Err(err).Msg("failed to initialize app")
		}
		env = app.Env
		dbName = env.DB_Name
		logger.Log.Info().Str("db", env.DB_Name).Msg("Database acquired")
		defer app.CloseDBConnection()
	}

	timeout := time.Duration(env.CtxTSeconds) * time.Second

	// Gin router
	router := gin.Default()
	// router.Use(middleware.RequestLogger())
	// router.Use(middleware.Recovery())

	router.Use(func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		allowAll := false
		for _, o := range env.CORSAllowedOrigins {
			if o == "*" {
				allowAll = true
				break
			}
		}
		if origin != "" {
			c.Writer.Header().Add("Vary", "Origin")
		}
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

		// Dynamically reflect requested headers to avoid blocking custom headers (e.g. 'skip-auth')
		requestedHeaders := c.GetHeader("Access-Control-Request-Headers")
		if requestedHeaders == "" {
			// Fallback baseline list – include common & custom application headers
			requestedHeaders = "Origin, Content-Type, Authorization, Accept, Skip-Auth, X-Requested-With"
		}
		c.Writer.Header().Set("Access-Control-Allow-Headers", requestedHeaders)
		// Expose additional headers if needed by frontend (add Set-Cookie for clarity)
		c.Writer.Header().Set("Access-Control-Expose-Headers", "Content-Length, Content-Type, Set-Cookie")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	if skipDB {
		// Minimal health endpoint when DB is skipped
		router.GET("/api/v1/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok", "db": "skipped"})
		})
	} else {
		routers.Setup(env, timeout, app.Mongo.Database(dbName), router)
	}

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
