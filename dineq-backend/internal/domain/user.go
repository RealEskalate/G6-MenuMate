package domain

import (
	"context"
	"time"
)

<<<<<<< HEAD
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

=======
type User struct {
	ID           string
	Email        string
	Username     string
	PhoneNumber  string
	Password     string
	AuthProvider AuthProvider
	IsVerified   bool
	FirstName    string
	LastName     string
	ProfileImage string
	Role         UserRole
	Status       UserStatus
	Preferences  Preferences
	LastLoginAt  time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
	IsDeleted    bool
}

type Preferences struct {
	Language      string // e.g., "am-ET", "en-US"
	Theme         string // e.g., "dark", "light"
	Notifications bool   // true/false
}
>>>>>>> Backend_develop
type UserRole string

const (
	RoleAdmin   UserRole = "ADMIN"
<<<<<<< HEAD
	RoleOwner   UserRole = "OWNER"
	RoleManager UserRole = "MANAGER"
	RoleStaff   UserRole = "STAFF"
	RoleCustomer UserRole = "CUSTOMER"
)

// AuthProvider enumerates authentication sources.
type AuthProvider string
=======
	RoleStaff   UserRole = "STAFF"
	RoleManager UserRole = "MANAGER"
	RoleUser    UserRole = "USER"
)

type UserStatus string

const (
	Active    UserStatus = "ACTIVE"
	Inactive  UserStatus = "INACTIVE"
	Suspended UserStatus = "SUSPENDED"
)

type AuthProvider string

>>>>>>> Backend_develop
const (
	AuthEmail  AuthProvider = "EMAIL"
	AuthGoogle AuthProvider = "GOOGLE"
	AuthPhone  AuthProvider = "PHONE"
)

<<<<<<< HEAD
// UserStatus captures account lifecycle state.
type UserStatus string
const (
	StatusActive    UserStatus = "ACTIVE"
	StatusInactive  UserStatus = "INACTIVE"
	StatusSuspended UserStatus = "SUSPENDED"
)

=======
>>>>>>> Backend_develop
type UserProfileUpdate struct {
	FirstName  string
	LastName   string
	AvatarData []byte
}

type IUserUsecase interface {
<<<<<<< HEAD
	FindByUsernameOrEmail(context.Context, string) (*User, error)
=======
>>>>>>> Backend_develop
	FindUserByID(string) (*User, error)
	GetUserByEmail(email string) (*User, error)
	UpdateUser(id string, user *User) (*User, error)
	UpdateProfile(userID string, update UserProfileUpdate, fileName string) (*User, error)
	ChangePassword(userID, oldPassword, newPassword string) error

	Register(request *User) error
<<<<<<< HEAD
=======
	AssignRole(userID, branchID string, role UserRole) error
>>>>>>> Backend_develop
}

type IUserRepository interface {
	CreateUser(context.Context, *User) error
	FindUserByID(context.Context, string) (*User, error)
<<<<<<< HEAD
	GetUserByUsername(context.Context, string) (*User, error)
	GetUserByEmail(context.Context, string) (*User, error)
	GetUserByPhone(context.Context, string) (*User, error)
	UpdateUser(context.Context, string, *User) error
	GetAllUsers(context.Context) ([]*User, error)
	FindByUsernameOrEmail(context.Context, string) (User, error)
	ChangeRole(context.Context, string, string, string) error
=======
	GetUserByEmail(context.Context, string) (*User, error)
	UpdateUser(context.Context, string, *User) error
	GetAllUsers(context.Context) ([]*User, error)
	AssignRole(context.Context, string, string, UserRole) error
>>>>>>> Backend_develop
}
