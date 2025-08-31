package domain

import (
	"context"
	"time"
)

type User struct {
    ID           string
    Email        string
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
    Language     string // e.g., "am-ET", "en-US"
    Theme        string // e.g., "dark", "light"
    Notifications bool  // true/false
}
type UserRole string

const (
	RoleAdmin           UserRole = "ADMIN"
	RoleStaff           UserRole = "STAFF"
	RoleManager         UserRole = "MANAGER"
	RoleUser            UserRole = "CUSTOMER"
)

type UserStatus string

const (
	Active   UserStatus = "ACTIVE"
	Inactive UserStatus = "INACTIVE"
	Suspended UserStatus = "SUSPENDED"
)

type AuthProvider string
const(
	EmailProvider AuthProvider = "EMAIL"
	GoogleProvider AuthProvider = "GOOGLE"
	PhoneProvider AuthProvider = "PHONE"
)

type UserProfileUpdate struct {
	FirstName  string
	LastName   string
	AvatarData []byte
}

type IUserUsecase interface {
	FindUserByID(string) (*User, error)
	GetUserByEmail(email string) (*User, error)
	UpdateUser(id string, user *User) (*User, error)
	UpdateProfile(userID string, update UserProfileUpdate, fileName string) (*User, error)
	ChangePassword(userID, oldPassword, newPassword string) error

	Register(request *User) error
	AssignRole(userID, branchID string, role UserRole) error
}

type IUserRepository interface {
	CreateUser(context.Context, *User) error
	FindUserByID(context.Context, string) (*User, error)
	GetUserByEmail(context.Context, string) (*User, error)
	UpdateUser(context.Context, string, *User) error
	GetAllUsers(context.Context) ([]*User, error)
    AssignRole(context.Context, string, string, UserRole) error

	SaveFCMToken(userID string, token string) error
	GetFCMToken(userID string) (string, error)
}
