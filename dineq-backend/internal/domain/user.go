package domain

import (
	"context"
	"time"
)

// User represents an application user.
type User struct {
	ID           string
	Email        string
	PhoneNumber  string
	Username     string
	Password     string
	AuthProvider AuthProvider
	IsVerified   bool
	FullName     string
	FirstName    string
	LastName     string
	ProfileImage string
	Role         UserRole
	Status       UserStatus
	Preferences  *Preferences
	LastLoginAt  *time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
	DeletedAt    *time.Time
	IsDeleted    bool
}

type Preferences struct {
	Language      string // e.g., "am-ET", "en-US"
	Theme         string // e.g., "dark", "light"
	Notifications bool   // true/false
	Favorites     []string
}
type UserRole string

const (
	RoleAdmin      UserRole = "ADMIN"
	RoleOwner      UserRole = "OWNER"
	RoleManager    UserRole = "MANAGER"
	RoleStaff      UserRole = "STAFF"
	RoleCustomer   UserRole = "CUSTOMER"
	RoleWaiter     UserRole = "WAITER"
	RoleSuperAdmin UserRole = "SUPER_ADMIN"
)

const (
	Active    UserStatus = "ACTIVE"
	Inactive  UserStatus = "INACTIVE"
	Suspended UserStatus = "SUSPENDED"
)

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
	AvatarURL  string
}

type UserFilter struct {
	Role     string
	Status   string
	Search   string // search by name/email/username
	Page     int
	PageSize int
}

type IUserUsecase interface {
	FindByUsernameOrEmail(context.Context, string) (*User, error)
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
	GetUserByUsername(context.Context, string) (*User, error)
	GetUserByPhone(context.Context, string) (*User, error)
	UpdateUser(context.Context, string, *User) error
	GetAllUsers(ctx context.Context, filter UserFilter) ([]*User, int64, error)
	CountUsers(ctx context.Context, filter UserFilter) (int64, error)
	PermanentDeleteUser(ctx context.Context, userID string) error
	FindByUsernameOrEmail(context.Context, string) (User, error)
	ChangeRole(context.Context, string, string, string) error
	GetUserByEmail(context.Context, string) (*User, error)
	AssignRole(context.Context, string, string, UserRole) error
}
