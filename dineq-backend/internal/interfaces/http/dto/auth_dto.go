package dto

type LoginRequest struct {
<<<<<<< HEAD
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
=======
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6,max=100"`
}

type LoginResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" validate:"required"`
}
type RefreshTokenResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
>>>>>>> Backend_develop
}

type ForgotPasswordRequest struct {
	Email string `json:"email" validate:"required,email"`
}

type ResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Token       string `json:"token" binding:"required"`
<<<<<<< HEAD
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type ChangeRoleRequest struct {
	UserID string `json:"user_id" validate:"required"`
=======
	NewPassword string `json:"newPassword" binding:"required,min=8"`
}

type ChangeRoleRequest struct {
	UserID string `json:"userId" validate:"required"`
>>>>>>> Backend_develop
	Role   string `json:"role" validate:"required,oneof=admin user superadmin"`
}

type VerifyEmailRequest struct {
	Email string `json:"email" validate:"required,email"`
}
<<<<<<< HEAD
=======

type ChangePasswordRequest struct {
	OldPassword string `json:"oldPassword" validate:"required,min=8"`
	NewPassword string `json:"newPassword" validate:"required,min=8"`
}
>>>>>>> Backend_develop
