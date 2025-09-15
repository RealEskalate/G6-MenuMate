package usecase

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"strings"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
	"github.com/google/uuid"

	"golang.org/x/crypto/bcrypt"
)

type PasswordResetUsecase struct {
	UserRepo          domain.IUserRepository
	EmailService      domain.IEmailService
	PasswordResetRepo domain.IPasswordResetRepository
	PasswordExpiry    time.Duration
	ResetURL          string
}

func NewPasswordResetUsecase(repo domain.IPasswordResetRepository, userRepo domain.IUserRepository, emailService domain.IEmailService, expiry time.Duration, ResetURL string) domain.IPasswordResetUsecase {
	return &PasswordResetUsecase{
		PasswordResetRepo: repo,
		UserRepo:          userRepo,
		EmailService:      emailService,
		PasswordExpiry:    expiry,
		ResetURL:          ResetURL,
	}
}

func (u *PasswordResetUsecase) FindByEmail(email string) (*domain.PasswordResetToken, error) {
	return u.PasswordResetRepo.FindByEmail(context.Background(), email)
}

func (u *PasswordResetUsecase) MarkAsUsed(token *domain.PasswordResetToken) error {
	return u.PasswordResetRepo.MarkAsUsed(context.Background(), token)
}

func (u *PasswordResetUsecase) RequestReset(email, platform string) error {
	user, err := u.UserRepo.GetUserByEmail(context.Background(), email)
	if err != nil {
		return err
	}

	// Enforce valid platform
	if platform != string(domain.PlatformWeb) && platform != string(domain.PlatformMobile) {
		return errors.New("invalid reset platform")
	}

	var method string
	if platform == string(domain.PlatformMobile) {
		method = "otp" // mobile users get OTP
	} else {
		method = "link" // web users get reset link
	}

	var plainToken string
	var expiry time.Duration

	if method == "otp" {
		plainToken = fmt.Sprintf("%06d", rand.Intn(1000000)) // 6-digit OTP
		expiry = 5 * time.Minute
	} else {
		plainToken = uuid.NewString() // reset link token
		expiry = u.PasswordExpiry
	}

	hashedToken, _ := security.HashToken(plainToken)
	// Create new reset token (skip update logic here for simplicity)
	resetToken := &domain.PasswordResetToken{
		Email:     user.Email,
		TokenHash: hashedToken,
		Method:    method,
		ExpiresAt: time.Now().Add(expiry),
		Used:      false,
		RateLimit: 1,
		CreatedAt: time.Now(),
	}

	// Check if user already has a reset token
	existingToken, err := u.PasswordResetRepo.FindByEmail(context.Background(), email)
	if err == nil && existingToken != nil {

		if time.Now().Before(existingToken.ExpiresAt) {
			return domain.ErrOTPStillValid
		}

		// Check if the user has reached the maximum attempts
		if existingToken.RateLimit >= 5 {
			if time.Since(existingToken.CreatedAt) < 24*time.Hour {
				return domain.ErrOTPMaxAttempts
			}
			// Reset attempts after 24 hours
			existingToken.RateLimit = 0
		}
		// Update existing token
		existingToken.TokenHash = hashedToken
		existingToken.Method = method
		existingToken.ExpiresAt = time.Now().Add(expiry)
		existingToken.Used = false
		existingToken.RateLimit += 1
		existingToken.CreatedAt = time.Now()
		if err := u.PasswordResetRepo.UpdateResetToken(context.Background(), existingToken); err != nil {
			return err
		}
	} else {
		// Save new token
		if err := u.PasswordResetRepo.SaveResetToken(context.Background(), resetToken); err != nil {
			return err
		}
	}

	// Build email body
	var body string
	var name string
	if user.FirstName != "" && user.LastName != "" {
		name = user.FirstName + " " + user.LastName
	} else if user.FirstName != "" {
		name = user.FirstName
	} else if user.Username != "" {
		name = user.Username
	} else {
		name = strings.Split(user.Email, "@")[0]
	}

	if method == "otp" {
		var data = struct {
			Title   string
			Name    string
			Message string
			OTP     string
			Expiry  string
		}{Title: "Password Reset", Name: name, Message: "You requested to reset your password. Use the OTP below to proceed.", OTP: plainToken, Expiry: u.PasswordExpiry.String()}
		body, err = utils.RenderTemplate("otp.html", data)
	} else {
		resetURL := fmt.Sprintf("%s?email=%s&token=%s", u.ResetURL, user.Email, plainToken)
		var data = struct {
			Name     string
			ResetURL string
			Expiry   string
		}{Name: name, ResetURL: resetURL, Expiry: u.PasswordExpiry.String()}
		fmt.Println("Reset URL:", resetURL) // For debugging; remove in production
		body, err = utils.RenderTemplate("reset_link.html", data)
	}
	if err != nil {
		return err
	}

	return u.EmailService.SendEmail(context.Background(), user.Email, "Password Reset", body)
}

func (u *PasswordResetUsecase) VerifyResetToken(email, token string) (string, error) {
	ctx := context.Background()

	// Get token record
	resetToken, err := u.PasswordResetRepo.FindByEmail(ctx, email)
	if err != nil {
		return "", err
	}

	// Check if expired or used
	if resetToken.Used || resetToken.ExpiresAt.Before(time.Now()) {
		return "", domain.ErrTokenInvalidOrExpired
	}

	// Compare submitted token with hashed token
	if match, err := security.ValidateTokenHash(resetToken.TokenHash, token); err != nil || !match {
		return "", domain.ErrTokenInvalidOrExpired
	}

	// Generate temporary session token for password reset
	sessionToken := uuid.NewString()
	session := &domain.PasswordResetSession{
		UserID:    resetToken.Email,
		Token:     sessionToken,
		ExpiresAt: time.Now().Add(15 * time.Minute), // short-lived
	}

	// Save session to DB
	if err := u.PasswordResetRepo.SaveResetSession(ctx, session); err != nil {
		return "", err
	}

	return sessionToken, nil
}

func (u *PasswordResetUsecase) ResetPasswordWithSession(sessionToken, newPassword string) error {
	ctx := context.Background()

	// Get session
	session, err := u.PasswordResetRepo.GetResetSession(ctx, sessionToken)
	if err != nil || session.ExpiresAt.Before(time.Now()) {
		return domain.ErrTokenInvalidOrExpired
	}

	// Get user
	user, err := u.UserRepo.GetUserByEmail(ctx, session.UserID)
	if err != nil {
		return err
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user.Password = string(hashedPassword)

	// Update user
	if err := u.UserRepo.UpdateUser(ctx, user.ID, user); err != nil {
		return err
	}

	// Mark original reset token as used
	resetToken, _ := u.PasswordResetRepo.FindByEmail(ctx, user.Email)
	if resetToken != nil {
		resetToken.Used = true
		u.PasswordResetRepo.MarkAsUsed(ctx, resetToken)
	}

	// delete password reset
	if resetToken != nil {
		u.PasswordResetRepo.DeleteResetToken(ctx, resetToken.Email)
	}

	// Delete session
	return u.PasswordResetRepo.DeleteResetSession(ctx, sessionToken)
}
