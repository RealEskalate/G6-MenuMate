package domain

import "errors"

type DomainError struct {
	Err  error
	Code int
}

var (
	ErrNotFound                       = errors.New("not found")
	ErrUserNotFound                   = errors.New("user not found")
	ErrTokenExpired                   = errors.New("token expired")
	ErrInvalidInput                   = errors.New("invalid input")
	ErrUnauthorized                   = errors.New("User not authenticated or authorized")
	ErrInvalidFile                    = errors.New("invalid file format")
	ErrOTPNotFound                    = errors.New("OTP not found")
	ErrOTPExpired                     = errors.New("OTP expired")
	ErrOTPMaxAttempts                 = errors.New("maximum OTP attempts exceeded")
	ErrOTPStillValid                  = errors.New("OTP is still valid")
	ErrOTPInvalidCode                 = errors.New("invalid OTP code")
	ErrOTPInvalid                     = errors.New("invalid OTP")
	ErrOTPFailedToDelete              = errors.New("failed to delete OTP")
	ErrRestaurantNotFound             = errors.New("restaurant not found")
	ErrInvalidRequest                 = errors.New("invalid request")
	ErrServerIssue                    = errors.New("internal server error")
	ErrPasswordAndEmailRequired       = errors.New("email and password are required")
	ErrFailedToRegisterUser           = errors.New("failed to register user")
	ErrTokenInvalidOrExpired          = errors.New("token invalid or expired")
	ErrFileToUpload                   = errors.New("failed to upload file")
	ErrFailedToCreateOCRJob           = errors.New("failed to create OCR job")
	ErrUserAlreadyLoggedOut           = errors.New("User already logged out")
	ErrUserNotLoggedIn                = errors.New("User not logged in")
	ErrFailedToGetMenu                = errors.New("failed to get menu")
	ErrFailedToUpdateMenu             = errors.New("failed to update menu")
	ErrFailedToDeleteMenu             = errors.New("failed to delete menu")
	ErrFailedToCreateMenu             = errors.New("failed to create menu")
	ErrFailedToDeleteFile             = errors.New("failed to delete file")
	ErrPasswordResetTokenExists       = errors.New("password reset token already exists")
	ErrPasswordResetRateLimitExceeded = errors.New("password reset rate limit exceeded")
	ErrFailedToVerifyUser             = errors.New("failed to verify user")
	ErrFailedToResendOTP              = errors.New("failed to resend OTP")
	ErrCodeNotFound                   = errors.New("code not found")
	ErrFailedToCreateOAuthService     = errors.New("failed to create oauth service")
	ErrFailedToGetUserInfo            = errors.New("failed to get user info")
	ErrFailedToDeleteToken            = errors.New("failed to delete token")
	ErrFailedToProcessRequest         = errors.New("failed to process request")
	ErrFailedToResetPassword          = errors.New("failed to reset password")
	ErrInvalidCredentials             = errors.New("invalid email or password")
	ErrEmailAlreadyInUse              = errors.New("email already in use")
	ErrTokenGenerationIssue           = errors.New("failed to generate token")
	ErrRefreshTokenNotFound           = errors.New("refresh token not found")
	ErrFailedToRevokeToken            = errors.New("failed to revoke token")
	ErrFailedToUpdateToken            = errors.New("failed to update token")
	ErrFailedToSaveToken              = errors.New("failed to save token")
	ErrPasswordShortLen               = errors.New("password must be at least 8 characters long")
	ErrPasswordMustContainUpperLetter = errors.New("password must contain at least one uppercase letter")
	ErrPasswordMustContainLowerLetter = errors.New("password must contain at least one lowercase letter")
	ErrPasswordMustContainNumber      = errors.New("password must contain at least one number")
	ErrPasswordMustContainSpecialChar = errors.New("password must contain at least one special character")
)

var (
	MsgSuccess          = "Operation completed successfully"
	MsgCreated          = "Resource created successfully"
	MsgUpdated          = "Resource updated successfully"
	MsgDeleted          = "Resource deleted successfully"
	MsgValidationFailed = "Validation failed, please check your input"
	MsgProcessing       = "Processing your request"
)
