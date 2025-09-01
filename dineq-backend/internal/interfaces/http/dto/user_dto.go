package dto

import (
	"regexp"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
)

// UserDTO represents the data transfer object for a User
type UserDTO struct {
	ID           string         `json:"id"`
	Email        string         `json:"email" validate:"required_without=PhoneNumber,omitempty,email"`
	PhoneNumber  string         `json:"phone_number,omitempty" validate:"required_without=Email,omitempty,e164"`
	Password     string         `json:"password,omitempty"` // Raw password for sign-up
	AuthProvider string         `json:"auth_provider"`
	IsVerified   bool           `json:"is_verified"`
	FirstName    string         `json:"first_name,omitempty"`
	LastName     string         `json:"last_name,omitempty"`
	Username     string         `json:"username,omitempty"`
	ProfileImage string         `json:"profile_image,omitempty"`
	Role         string         `json:"role" validate:"required,oneof=ADMIN STAFF MANAGER USER OWNER"`
	Status       string         `json:"status" validate:"required,oneof=ACTIVE INACTIVE SUSPENDED"`
	Preferences  PreferencesDTO `json:"preferences,omitempty"`
	LastLoginAt  time.Time      `json:"last_login_at"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	IsDeleted    bool           `json:"is_deleted"`
}

type PreferencesDTO struct {
	Language      string `json:"language,omitempty"`      // e.g., "am-ET", "en-US"
	Theme         string `json:"theme,omitempty"`         // e.g., "dark", "light"
	Notifications bool   `json:"notifications,omitempty"` // true/false
}

// Validate checks the UserDTO for required fields and password strength
func (u *UserDTO) Validate() error {
	// Validate password only if provided (e.g., during sign-up)
	if u.Password != "" {
		if err := ValidatePasswordStrength(u.Password); err != nil {
			return err
		}
	}
	return nil
}

// ToDomain converts the UserDTO to a domain.User entity, hashing the password
func (u *UserDTO) ToDomain() (*domain.User, error) {
	passwordHash, err := security.HashPassword(u.Password)
	if err != nil {
		return nil, err
	}
	return &domain.User{
		ID:           u.ID,
		Email:        u.Email,
		PhoneNumber:  u.PhoneNumber,
		Password:     passwordHash,
		AuthProvider: domain.AuthProvider(u.AuthProvider),
		IsVerified:   u.IsVerified,
		FirstName:    u.FirstName,
		LastName:     u.LastName,
		Username:     u.Username,
		ProfileImage: u.ProfileImage,
		Role:         domain.UserRole(u.Role),
		Status:       domain.UserStatus(u.Status),
		Preferences: domain.Preferences{
			Language:      u.Preferences.Language,
			Theme:         u.Preferences.Theme,
			Notifications: u.Preferences.Notifications,
		},
		LastLoginAt: u.LastLoginAt,
		CreatedAt:   u.CreatedAt,
		UpdatedAt:   u.UpdatedAt,
		IsDeleted:   u.IsDeleted,
	}, nil
}

// FromDomain converts a domain.User entity to a UserDTO
func (u *UserDTO) FromDomain(user *domain.User) *UserDTO {
	return &UserDTO{
		ID:          user.ID,
		Email:       user.Email,
		PhoneNumber: user.PhoneNumber,
		// Password and PasswordHash omitted in response for security
		AuthProvider: string(user.AuthProvider),
		IsVerified:   user.IsVerified,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		Username:     user.Username,
		ProfileImage: user.ProfileImage,
		Role:         string(user.Role),
		Status:       string(user.Status),
		Preferences: PreferencesDTO{
			Language:      user.Preferences.Language,
			Theme:         user.Preferences.Theme,
			Notifications: user.Preferences.Notifications,
		},
		LastLoginAt: user.LastLoginAt,
		CreatedAt:   user.CreatedAt,
		UpdatedAt:   user.UpdatedAt,
		IsDeleted:   user.IsDeleted,
	}
}

// validatePasswordStrength checks if the password meets strength requirements
func ValidatePasswordStrength(password string) error {
	if len(password) < 8 {
		return domain.ErrPasswordShortLen
	}
	if !regexp.MustCompile(`[A-Z]`).MatchString(password) {
		return domain.ErrPasswordMustContainUpperLetter
	}
	if !regexp.MustCompile(`[a-z]`).MatchString(password) {
		return domain.ErrPasswordMustContainLowerLetter
	}
	if !regexp.MustCompile(`[0-9]`).MatchString(password) {
		return domain.ErrPasswordMustContainNumber
	}
	if !regexp.MustCompile(`[!@#\$%^&*]`).MatchString(password) {
		return domain.ErrPasswordMustContainSpecialChar
	}
	return nil
}

// userprofile update req
type UserUpdateProfileRequest struct {
	FirstName string `json:"first_name,omitempty"`
	LastName  string `json:"last_name,omitempty"`
}
