package dto

import (
	"fmt"
	"regexp"
	"time"

	"github.com/dinq/menumate/internal/domain"
	"github.com/dinq/menumate/internal/infrastructure/security"
)

// UserDTO represents the data transfer object for a User
type UserDTO struct {
    ID           string         `json:"id"`
    Email        string         `json:"email,omitempty"`
    PhoneNumber  string         `json:"phoneNumber,omitempty"`
    Password     string         `json:"password,omitempty"` // Raw password for sign-up
    PasswordHash string         `json:"passwordHash,omitempty"` // Hashed password (read-only in responses)
    AuthProvider string         `json:"authProvider"`
    IsVerified   bool           `json:"isVerified"`
    FirstName         string         `json:"firstName,omitempty"`
    LastName          string         `json:"lastName,omitempty"`
    ProfileImage string         `json:"profileImage,omitempty"`
    Role         string         `json:"role"`
    Status       string         `json:"status"`
    Preferences  PreferencesDTO `json:"preferences,omitempty"`
    LastLoginAt  time.Time      `json:"lastLoginAt"`
    CreatedAt    time.Time      `json:"createdAt"`
    UpdatedAt    time.Time      `json:"updatedAt"`
    IsDeleted    bool           `json:"isDeleted"`
}

type PreferencesDTO struct {
    Language     string `json:"language,omitempty"`     // e.g., "am-ET", "en-US"
    Theme        string `json:"theme,omitempty"`        // e.g., "dark", "light"
    Notifications bool  `json:"notifications,omitempty"` // true/false
}

// Validate checks the UserDTO for required fields and password strength
func (u *UserDTO) Validate() error {
    if (u.Email == "" && u.PhoneNumber == "") || u.AuthProvider == "" || u.Role == "" {
        return fmt.Errorf("email or phoneNumber, authProvider, and role are required")
    }
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
        Password: passwordHash,
        AuthProvider: domain.AuthProvider(u.AuthProvider),
        IsVerified:   u.IsVerified,
        FirstName:         u.FirstName,
        LastName: u.LastName,
        ProfileImage: u.ProfileImage,
        Role:         domain.UserRole(u.Role),
        Status:       domain.UserStatus(u.Status),
        Preferences:  domain.Preferences{
            Language:     u.Preferences.Language,
            Theme:        u.Preferences.Theme,
            Notifications: u.Preferences.Notifications,
        },
        LastLoginAt:  u.LastLoginAt,
        CreatedAt:    u.CreatedAt,
        UpdatedAt:    u.UpdatedAt,
        IsDeleted:    u.IsDeleted,
    }, nil
}

// FromDomain converts a domain.User entity to a UserDTO
func (u *UserDTO) FromDomain(user *domain.User) *UserDTO {
    return &UserDTO{
        ID:           user.ID,
        Email:        user.Email,
        PhoneNumber:  user.PhoneNumber,
        // Password and PasswordHash omitted in response for security
        AuthProvider: string(user.AuthProvider),
        IsVerified:   user.IsVerified,
        FirstName:         user.FirstName,
        LastName:  user.LastName,
        ProfileImage: user.ProfileImage,
        Role:         string(user.Role),
        Status:       string(user.Status),
        Preferences:  PreferencesDTO{
            Language:     user.Preferences.Language,
            Theme:        user.Preferences.Theme,
            Notifications: user.Preferences.Notifications,
        },
        LastLoginAt:  user.LastLoginAt,
        CreatedAt:    user.CreatedAt,
        UpdatedAt:    user.UpdatedAt,
        IsDeleted:    user.IsDeleted,
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
type UserUpdateProfileRequest struct{
    FirstName string `json:"firstName"`
    LastName string `json:"lastName"`
}
