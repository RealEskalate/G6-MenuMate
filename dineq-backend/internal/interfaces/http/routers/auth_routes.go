package routers

import (
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/email"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/repositories"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/middleware"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
	"github.com/gin-gonic/gin"
)

func NewAuthRoutes(env *bootstrap.Env, api *gin.RouterGroup, db mongo.Database) {
	// context time out
	ctxTimeout := time.Duration(env.CtxTSeconds) * time.Second

	// jwt services
	authService := security.NewJWTService(
		env.ATS,
		env.RTS,
		env.AccTEMinutes,
		env.RefTEHours,
	)

	// user repository
	userRepo := repositories.NewUserRepository(db, env.UserCollection)

	// email service
	emailService := email.NewGomailEmailService(
		env.SMTPHost,
		env.SMTPPort,
		env.SMTPFrom,
		env.SMTPUsername,
		env.SMTPPassword,
	)

	// reset password repository
	resetPasswordRepo := repositories.NewPasswordResetRepository(db, env.PasswordResetCollection, env.PasswordResetSessionCollection)

	// password reset usecase
	passwordResetUsecase := usecase.NewPasswordResetUsecase(
		resetPasswordRepo,
		userRepo,
		emailService,
		time.Duration(env.PasswordResetExpiry)*time.Minute,
		env.ResetURL,
	)

	// otp usecase and otp repository
	otpRepo := repositories.NewOTPRepository(db, env.OtpCollection)
	otpUsecase := usecase.NewOTPUsecase(otpRepo, emailService, ctxTimeout, time.Duration(env.OtpExpireMinutes)*time.Minute, env.OtpMaximumAttempts, env.SecretSalt)

	// storage services
	cloudinaryStorage := services.NewCloudinaryStorage(
		env.CloudinaryName,
		env.CloudinaryAPIKey,
		env.CloudinarySecret,
	)

	// Notifcation
	notifyRepo := repositories.NewNotificationRepository(db, env.NotificationCollection)
	notifySvc := services.NewNotificationService()
	notificationUseCase := usecase.NewNotificationUseCase(notifyRepo, notifySvc)

	authController := handler.AuthController{
		UserUsecase:          usecase.NewUserUsecase(userRepo, cloudinaryStorage, ctxTimeout),
		OTP:                  otpUsecase,
		AuthService:          authService,
		RefreshTokenUsecase:  usecase.NewRefreshTokenUsecase(repositories.NewRefreshTokenRepository(db, env.RefreshTokenCollection)),
		NotificationUseCase:  notificationUseCase,
		PasswordResetUsecase: passwordResetUsecase,
		GoogleClientID:       env.GoogleClientID,
		GoogleClientSecret:   env.GoogleClientSecret,
		GoogleRedirectURL:    env.GoogleRedirectURL,
		CookieSecure:         env.CookieSecure,
		CookieDomain:         env.CookieDomain,
		FrontendBaseURL:      env.FrontendBaseURL,
	CookieHTTPOnly:       strings.ToLower(env.AppEnv) != "development",
	}

	auth := api.Group("/auth/")
	{
		auth.POST("/register", authController.RegisterRequest)
		auth.POST("/login", authController.LoginRequest)
		auth.POST("/logout", authController.LogoutRequest)
		auth.POST("/forgot-password", authController.ForgotPasswordRequest)
		auth.POST("/verify-reset-token", authController.VerifyResetToken)
		auth.POST("/reset-password", authController.ResetPassword)
		auth.POST("/refresh", authController.RefreshToken)

		auth.GET("/google/login", authController.GoogleLogin)
		auth.GET("/google/callback", authController.GoogleCallback)

	}
	authHead := auth
	authHead.Use(middleware.AuthMiddleware(*env))
	{
		authHead.POST("/verify-email", authController.VerifyEmailRequest)
		authHead.POST("/resend-otp", authController.ResendOTPRequest)
		authHead.PATCH("/verify-otp", authController.VerifyOTPRequest)
	}
}
