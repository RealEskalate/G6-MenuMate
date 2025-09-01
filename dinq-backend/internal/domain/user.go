package domain

import (
	"context"
	"time"
)

// Preference captures per-user UI / notification settings.
type Preference struct {
	Language      string
	Theme         string
	Notifications bool
}

// User represents an application user.
type User struct {
	ID            string
	Email         string
	PhoneNumber   string
	Username      string
	Password  string
	AuthProvider  AuthProvider
	IsVerified    bool
	FullName      string
	FirstName     string
	LastName      string
	ProfileImage  string
	Role          UserRole
	Status        UserStatus
	Preferences   *Preference
	LastLoginAt   *time.Time
	CreatedAt     time.Time
	UpdatedAt     time.Time
	IsDeleted     bool
}

type UserRole string

const (
	RoleAdmin   UserRole = "ADMIN"
	RoleOwner   UserRole = "OWNER"
	RoleManager UserRole = "MANAGER"
	RoleStaff   UserRole = "STAFF"
	RoleCustomer UserRole = "CUSTOMER"
)

// AuthProvider enumerates authentication sources.
type AuthProvider string
const (
	AuthEmail  AuthProvider = "EMAIL"
	AuthGoogle AuthProvider = "GOOGLE"
	AuthPhone  AuthProvider = "PHONE"
)

// UserStatus captures account lifecycle state.
type UserStatus string
const (
	StatusActive    UserStatus = "ACTIVE"
	StatusInactive  UserStatus = "INACTIVE"
	StatusSuspended UserStatus = "SUSPENDED"
)

type UserProfileUpdate struct {
	FirstName  string
	LastName   string
	AvatarData []byte
}

type IUserUsecase interface {
	FindByUsernameOrEmail(context.Context, string) (*User, error)
	FindUserByID(string) (*User, error)
	GetUserByEmail(email string) (*User, error)
	UpdateUser(id string, user *User) (*User, error)
	UpdateProfile(userID string, update UserProfileUpdate, fileName string) (*User, error)
	ChangePassword(userID, oldPassword, newPassword string) error

	Register(request *User) error
}

type IUserRepository interface {
	CreateUser(context.Context, *User) error
	FindUserByID(context.Context, string) (*User, error)
	GetUserByUsername(context.Context, string) (*User, error)
	GetUserByEmail(context.Context, string) (*User, error)
	GetUserByPhone(context.Context, string) (*User, error)
	UpdateUser(context.Context, string, *User) error
	GetAllUsers(context.Context) ([]*User, error)
	FindByUsernameOrEmail(context.Context, string) (User, error)
	ChangeRole(context.Context, string, string, string) error
}
