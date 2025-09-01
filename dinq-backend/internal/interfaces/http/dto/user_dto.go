package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type Preference struct {
	Language      string `json:"language" validate:"omitempty,min=2,max=8"`
	Theme         string `json:"theme" validate:"omitempty,oneof=light dark system"`
	Notifications *bool  `json:"notifications" validate:"omitempty"`
}

type UserRequest struct {
	ID           string             `json:"id" validate:"omitempty"`
	Username     string             `json:"username" validate:"required,alphanum,min=3,max=50"`
	Email        string             `json:"email" validate:"required_without=PhoneNumber,omitempty,email"`
	PhoneNumber  string             `json:"phone_number" validate:"required_without=Email,omitempty,e164"`
	Password     string             `json:"password" validate:"required_without=AuthProvider,min=6,max=100"`
	FirstName    string             `json:"first_name" validate:"required_without=FullName,omitempty,alpha,min=2,max=50"`
	LastName     string             `json:"last_name" validate:"required_without=FullName,omitempty,alpha,min=2,max=50"`
	FullName     string             `json:"full_name" validate:"omitempty,min=2,max=100"`
	Role         string             `json:"role" validate:"omitempty,oneof=OWNER MANAGER STAFF CUSTOMER ADMIN"`
	AuthProvider string             `json:"auth_provider" validate:"required,oneof=EMAIL GOOGLE PHONE"`
	Status       string             `json:"status" validate:"omitempty,oneof=ACTIVE INACTIVE SUSPENDED"`
	ProfileImage string             `json:"profile_image" validate:"omitempty,url"`
	IsVerified   bool               `json:"is_verified" validate:"omitempty"`
	Preferences  *Preference `json:"preferences" validate:"omitempty,dive"`
}

type UserResponse struct {
	ID           string            `json:"id"`
	Username     string            `json:"username,omitempty"`
	Email        string            `json:"email,omitempty"`
	PhoneNumber  string            `json:"phone_number,omitempty"`
	FullName     string            `json:"full_name,omitempty"`
	FirstName    string            `json:"first_name,omitempty"`
	LastName     string            `json:"last_name,omitempty"`
	Role         string            `json:"role"`
	Status       string            `json:"status"`
	AuthProvider string            `json:"auth_provider"`
	ProfileImage string            `json:"profile_image,omitempty"`
	IsVerified   bool              `json:"is_verified"`
	Preferences  *Preference `json:"preferences,omitempty"`
	CreatedAt    time.Time         `json:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at"`
}

// user registration request mapper
func ToDomainUser(req UserRequest) domain.User {
	var pref *domain.Preference
	if req.Preferences != nil {
		p := &domain.Preference{Language: req.Preferences.Language, Theme: req.Preferences.Theme}
		if req.Preferences.Notifications != nil { p.Notifications = *req.Preferences.Notifications }
		pref = p
	}
	return domain.User{
		Email:        req.Email,
		Username:     req.Username,
		PhoneNumber:  req.PhoneNumber,
		Password: req.Password, // caller should hash before persistence
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		FullName:     req.FullName,
		Role:         domain.UserRole(req.Role),
		AuthProvider: domain.AuthProvider(req.AuthProvider),
		Status:       domain.UserStatus(req.Status),
		ProfileImage: req.ProfileImage,
		IsVerified:   req.IsVerified,
		Preferences:  pref,
	}
}

func ToUserResponse(user domain.User) UserResponse {
	var pref *Preference
	if user.Preferences != nil {
		pref = &Preference{Language: user.Preferences.Language, Theme: user.Preferences.Theme, Notifications: &user.Preferences.Notifications}
	}
	return UserResponse{
		ID:           user.ID,
		Username:     user.Username,
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		FullName:     user.FullName,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		Role:         string(user.Role),
		Status:       string(user.Status),
		AuthProvider: string(user.AuthProvider),
		ProfileImage: user.ProfileImage,
		IsVerified:   user.IsVerified,
		Preferences:  pref,
		CreatedAt:    user.CreatedAt,
		UpdatedAt:    user.UpdatedAt,
	}
}

// to response list
func ToUserResponseList(users []*domain.User) []UserResponse {
	var responses []UserResponse
	for _, user := range users {
		responses = append(responses, ToUserResponse(*user))
	}
	return responses
}

// / 	USER UPDATE REQUEST
// user update profile request
type UserUpdateProfileRequest struct {
	Bio       string `form:"bio" validate:"omitempty,max=500"`
	FirstName string `form:"first_name" validate:"omitempty,alpha,min=2,max=50"`
	LastName  string `form:"last_name" validate:"omitempty,alpha,min=2,max=50"`
}

// change password request
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" validate:"required,min=6,max=100"`
	NewPassword string `json:"new_password" validate:"required,min=6,max=100"`
}
