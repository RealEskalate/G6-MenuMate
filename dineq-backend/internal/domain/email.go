package domain

import (
	"context"
	"time"
)

type IEmailService interface {
	SendEmail(ctx context.Context, to, subject, body string) error
}

type IPasswordResetUsecase interface {
	RequestReset(email string, platform string) error
	VerifyResetToken(email, token string) (string, error)
	ResetPasswordWithSession(sessionToken, newPassword string) error
}

type IPasswordResetRepository interface {
	SaveResetToken(ctx context.Context, token *PasswordResetToken) error
	FindByEmail(ctx context.Context, email string) (*PasswordResetToken, error)
	MarkAsUsed(ctx context.Context, token *PasswordResetToken) error
	DeleteResetToken(ctx context.Context, email string) error
	UpdateResetToken(ctx context.Context, token *PasswordResetToken) error

	SaveResetSession(ctx context.Context, session *PasswordResetSession) error
	GetResetSession(ctx context.Context, sessionToken string) (*PasswordResetSession, error)
	DeleteResetSession(ctx context.Context, sessionToken string) error
}

type PasswordResetSession struct {
	UserID    string
	Token     string // random session token
	ExpiresAt time.Time
}
