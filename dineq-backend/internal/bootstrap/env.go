package bootstrap

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type Env struct {
	Port         string `mapstructure:"PORT"`
	AppEnv       string `mapstructure:"APP_ENV"`
	DB_Uri       string `mapstructure:"DB_URI"`
	DB_Name      string `mapstructure:"DB_NAME"`
	RTS          string `mapstructure:"REFRESH_TOKEN_SECRET"`
	ATS          string `mapstructure:"ACCESS_TOKEN_SECRET"`
	RefTEHours   int    `mapstructure:"REFRESH_TOKEN_EXPIRE_HOURS"`
	AccTEMinutes int    `mapstructure:"ACCESS_TOKEN_EXPIRE_MINUTES"`
	CtxTSeconds  int    `mapstructure:"CONTEXT_TIMEOUT_SECONDS"`

	// blog post defaults
	Page               int    `mapstructure:"PAGE"`
	PageSize           int    `mapstructure:"PAGE_SIZE"`
	Recency            string `mapstructure:"RECENCY"`
	BlogPostCollection string `mapstructure:"BLOG_POST_COLLECTION"`

	// blog comment defaults
	BlogCommentCollection string `mapstructure:"BLOG_COMMENT_COLLECTION"`
	// blog user reaction defaults
	BlogUserReactionCollection string `mapstructure:"BLOG_USER_REACTION_COLLECTION"`

	// user collection
	UserCollection string `mapstructure:"USER_COLLECTION"`

	// review collection
	ReviewCollection string 	`mapstructure:"REVIEW_COLLECTION"`

	// Cookie / Security settings
	CookieSecure bool   `mapstructure:"COOKIE_SECURE"`
	CookieDomain string `mapstructure:"COOKIE_DOMAIN"`

	// user refresh token collection
	RefreshTokenCollection string `mapstructure:"REFRESH_TOKEN_COLLECTION"`

	// restaurant collection
	RestaurantCollection string `mapstructure:"RESTAURANT_COLLECTION"`

	// password reset token collection
	PasswordResetCollection string `mapstructure:"PASSWORD_RESET_TOKEN_COLLECTION"`
	// password reset token expiry
	PasswordResetExpiry int `mapstructure:"PASSWORD_RESET_TOKEN_EXPIRE_MINUTES"` // in minutes

	// email configuration
	SMTPHost     string `mapstructure:"SMTP_HOST"`
	SMTPPort     int    `mapstructure:"SMTP_PORT"`
	SMTPFrom     string `mapstructure:"SMTP_FROM"`
	SMTPUsername string `mapstructure:"SMTP_USERNAME"`
	SMTPPassword string `mapstructure:"SMTP_PASSWORD"` // App Password for Gmail
	ResetURL     string `mapstructure:"RESET_URL"`

	// Gemini AI configuration
	GeminiAPIKey    string `mapstructure:"GEMINI_API_KEY"`
	GeminiModelName string `mapstructure:"GEMINI_MODEL_NAME"`

	// OTP secret salt
	SecretSalt         string `mapstructure:"MY_SUPER_SECRET_SALT"`
	OtpCollection      string `mapstructure:"OTP_COLLECTION"`
	OtpExpireMinutes   int    `mapstructure:"OTP_EXPIRE_MINUTES"`
	OtpMaximumAttempts int    `mapstructure:"OTP_MAXIMUM_ATTEMPTS"`
	// Redis configuration
	RedisHost     string `mapstructure:"REDIS_HOST"`
	RedisPort     int    `mapstructure:"REDIS_PORT"`
	RedisPassword string `mapstructure:"REDIS_PASSWORD"`
	RedisDB       int    `mapstructure:"REDIS_DB"`

	// Redis cache configuration
	CacheExpirationSeconds int `mapstructure:"CACHE_EXPIRATION_SECONDS"` // in seconds

	// Google OAuth2 Configuration
	GoogleClientID     string `mapstructure:"GOOGLE_CLIENT_ID"`
	GoogleClientSecret string `mapstructure:"GOOGLE_CLIENT_SECRET"`
	GoogleRedirectURL  string `mapstructure:"GOOGLE_REDIRECT_URL"`

	// Translation API configuration
	RapidAPIKey         string `mapstructure:"RAPIDAPI_KEY"`
	RapidAPIHost        string `mapstructure:"RAPIDAPI_HOST"`
	RapidAPIContentType string `mapstructure:"RAPIDAPI_CONTENT_TYPE"`

	// Programmable search engine config
	SearchEngineID string `mapstructure:"SEARCH_ENGINE_ID"`
	SearchAPIKey   string `mapstructure:"SEARCH_ENGINE_API_KEY"`

	// Cloudinary Config
	CloudinaryAPIKey string `mapstructure:"CLD_API_KEY"`
	CloudinarySecret string `mapstructure:"CLD_SECRET"`
	CloudinaryName   string `mapstructure:"CLD_NAME"`

	OCRJobCollection string `mapstructure:"OCR_JOB_COLLECTION"`

	VeryfiClientID     string `mapstructure:"VERIFY_CLIENT_ID"`
	VeryfiClientSecret string `mapstructure:"VERIFY_CLIENT_SECRET"`
	VeryfiAPIKey       string `mapstructure:"VERIFY_API_KEY"`
	VeryfiUsername     string `mapstructure:"VERIFY_USERNAME"`

	// notification collection
	NotificationCollection string `mapstructure:"NOTIFICATION_COLLECTION"`

	// menu collection
	MenuCollection string `mapstructure:"MENU_COLLECTION"`
	// qr code collection
	QRCodeCollection string `mapstructure:"QR_CODE_COLLECTION"`
	ItemCollection    string `mapstructure:"ITEM_COLLECTION"`
}

// Viper can be made injectable
func NewEnv() (*Env, error) {
	// Load .env file if present
	if err := godotenv.Load(); err != nil {
		log.Println("Error loading .env file:", err)
	}
	fmt.Println("DB_URI:", os.Getenv("DB_URI"))
	env := &Env{}
	env.Port = os.Getenv("PORT")
	env.AppEnv = os.Getenv("APP_ENV")
	env.DB_Uri = os.Getenv("DB_URI")
	env.DB_Name = os.Getenv("DB_NAME")
	env.RTS = os.Getenv("REFRESH_TOKEN_SECRET")
	env.ATS = os.Getenv("ACCESS_TOKEN_SECRET")
	env.UserCollection = os.Getenv("USER_COLLECTION")
	env.RefreshTokenCollection = os.Getenv("REFRESH_TOKEN_COLLECTION")
	env.RestaurantCollection = os.Getenv("RESTAURANT_COLLECTION")
	env.ReviewCollection = os.Getenv("REVIEW_COLLECTION")
	env.PasswordResetCollection = os.Getenv("PASSWORD_RESET_TOKEN_COLLECTION")
	env.PasswordResetExpiry, _ = strconv.Atoi(os.Getenv("PASSWORD_RESET_TOKEN_EXPIRE_MINUTES"))
	env.RefTEHours, _ = strconv.Atoi(os.Getenv("REFRESH_TOKEN_EXPIRE_HOURS"))
	env.AccTEMinutes, _ = strconv.Atoi(os.Getenv("ACCESS_TOKEN_EXPIRE_MINUTES"))
	env.CtxTSeconds, _ = strconv.Atoi(os.Getenv("CONTEXT_TIMEOUT_SECONDS"))
	env.Page, _ = strconv.Atoi(os.Getenv("PAGE"))
	env.PageSize, _ = strconv.Atoi(os.Getenv("PAGE_SIZE"))
	env.Recency = os.Getenv("RECENCY")
	env.BlogPostCollection = os.Getenv("BLOG_POST_COLLECTION")
	env.BlogCommentCollection = os.Getenv("BLOG_COMMENT_COLLECTION")
	env.BlogUserReactionCollection = os.Getenv("BLOG_USER_REACTION_COLLECTION")
	env.SMTPHost = os.Getenv("SMTP_HOST")
	env.SMTPPort, _ = strconv.Atoi(os.Getenv("SMTP_PORT"))
	env.SMTPFrom = os.Getenv("SMTP_FROM")
	env.SMTPUsername = os.Getenv("SMTP_USERNAME")
	env.SMTPPassword = os.Getenv("SMTP_PASSWORD")
	env.ResetURL = os.Getenv("RESET_URL")
	env.GeminiAPIKey = os.Getenv("GEMINI_API_KEY")
	env.GeminiModelName = os.Getenv("GEMINI_MODEL_NAME")
	env.SecretSalt = os.Getenv("MY_SUPER_SECRET_SALT")
	env.OtpCollection = os.Getenv("OTP_COLLECTION")
	env.OtpExpireMinutes, _ = strconv.Atoi(os.Getenv("OTP_EXPIRE_MINUTES"))
	env.OtpMaximumAttempts, _ = strconv.Atoi(os.Getenv("OTP_MAXIMUM_ATTEMPTS"))
	env.RedisHost = os.Getenv("REDIS_HOST")
	env.RedisPort, _ = strconv.Atoi(os.Getenv("REDIS_PORT"))
	env.RedisPassword = os.Getenv("REDIS_PASSWORD")
	env.RedisDB, _ = strconv.Atoi(os.Getenv("REDIS_DB"))
	env.CacheExpirationSeconds, _ = strconv.Atoi(os.Getenv("CACHE_EXPIRATION_SECONDS"))
	env.GoogleClientID = os.Getenv("GOOGLE_CLIENT_ID")
	env.GoogleClientSecret = os.Getenv("GOOGLE_CLIENT_SECRET")
	env.GoogleRedirectURL = os.Getenv("GOOGLE_REDIRECT_URL")
	env.RapidAPIKey = os.Getenv("RAPIDAPI_KEY")
	env.RapidAPIHost = os.Getenv("RAPIDAPI_HOST")
	env.RapidAPIContentType = os.Getenv("RAPIDAPI_CONTENT_TYPE")
	env.SearchEngineID = os.Getenv("SEARCH_ENGINE_ID")
	env.SearchAPIKey = os.Getenv("SEARCH_ENGINE_API_KEY")
	env.CloudinaryAPIKey = os.Getenv("CLD_API_KEY")
	env.CloudinarySecret = os.Getenv("CLD_SECRET")
	env.CloudinaryName = os.Getenv("CLD_NAME")
	env.OCRJobCollection = os.Getenv("OCR_JOB_COLLECTION")
	env.VeryfiClientID = os.Getenv("VERIFY_CLIENT_ID")
	env.VeryfiClientSecret = os.Getenv("VERIFY_CLIENT_SECRET")
	env.VeryfiAPIKey = os.Getenv("VERIFY_API_KEY")
	env.VeryfiUsername = os.Getenv("VERIFY_USERNAME")
	env.NotificationCollection = os.Getenv("NOTIFICATION_COLLECTION")
	env.MenuCollection = os.Getenv("MENU_COLLECTION")
	env.CookieSecure = strings.ToLower(os.Getenv("COOKIE_SECURE")) == "true"
	env.CookieDomain = os.Getenv("COOKIE_DOMAIN")
	env.MenuCollection = os.Getenv("MENU_COLLECTION")
	env.QRCodeCollection = os.Getenv("QR_CODE_COLLECTION")
	env.ItemCollection = os.Getenv("ITEM_COLLECTION")

	if env.AppEnv == "development" {
		log.Println("The App is running in development env")
	}

	return env, nil
}
