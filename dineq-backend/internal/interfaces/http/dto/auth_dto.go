package dto

import "time"

type LoginRequest struct {
	Identifier string `json:"identifier" validate:"required"`
	Password   string `json:"password" validate:"required,min=6,max=100"`
}

type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}
type RefreshTokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

type ForgotPasswordRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Platform string `json:"platform" validate:"required,oneof=web mobile"`
}

type PasswordResetSession struct {
	UserID    string
	Token     string // random session token
	ExpiresAt time.Time
}

// VerifyResetTokenRequest
type VerifyResetTokenRequest struct {
	Email string `json:"email" validate:"required,email"`
	Token string `json:"token" validate:"required"`
}

// verify reset token and allow password reset
type SetNewPasswordRequest struct {
	SessionToken string `json:"session_token" validate:"required"`
	NewPassword  string `json:"new_password" validate:"required,min=8"`
}

type ChangeRoleRequest struct {
	UserID string `json:"user_id" validate:"required"`
	Role   string `json:"role" validate:"required,oneof=admin user superadmin"`
}

type VerifyEmailRequest struct {
	Email string `json:"email" validate:"required,email"`
}

// type ChangePasswordRequest struct {
// 	OldPassword string `json:"oldPassword" validate:"required,min=8"`
// 	NewPassword string `json:"newPassword" validate:"required,min=8"`
// }
