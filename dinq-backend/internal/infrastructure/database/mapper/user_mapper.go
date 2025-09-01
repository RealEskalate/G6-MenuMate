package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserModel struct {
	ID           bson.ObjectID      `bson:"_id,omitempty"`
	Email        string             `bson:"email,omitempty"`
	PhoneNumber  string             `bson:"phone_number,omitempty"`
	Username     string             `bson:"username,omitempty"`
	Password string             `bson:"password_hash,omitempty"`
	AuthProvider string             `bson:"auth_provider,omitempty"`
	IsVerified   bool               `bson:"is_verified"`
	FullName     string             `bson:"full_name,omitempty"`
	FirstName    string             `bson:"first_name,omitempty"`
	LastName     string             `bson:"last_name,omitempty"`
	ProfileImage string             `bson:"profile_image,omitempty"`
	Role         string             `bson:"role"`
	Status       string             `bson:"status"`
	Preferences  *domain.Preference `bson:"preferences,omitempty"`
	LastLoginAt  *time.Time         `bson:"last_login_at,omitempty"`
	CreatedAt    time.Time          `bson:"created_at"`
	UpdatedAt    time.Time          `bson:"updated_at"`
	IsDeleted    bool               `bson:"is_deleted"`
}

func UserToDomain(user *UserModel) *domain.User {
	if user == nil { return nil }
	return &domain.User{
		ID:           user.ID.Hex(),
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Username:     user.Username,
		Password: user.Password,
		AuthProvider: domain.AuthProvider(user.AuthProvider),
		IsVerified:   user.IsVerified,
		FullName:     user.FullName,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		ProfileImage: user.ProfileImage,
		Role:         domain.UserRole(user.Role),
		Status:       domain.UserStatus(user.Status),
		Preferences:  user.Preferences,
		LastLoginAt:  user.LastLoginAt,
		CreatedAt:    user.CreatedAt,
		UpdatedAt:    user.UpdatedAt,
		IsDeleted:    user.IsDeleted,
	}
}

func UserFromDomain(user *domain.User) *UserModel {
	if user == nil { return nil }
	return &UserModel{
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Username:     user.Username,
		Password: user.Password,
		AuthProvider: string(user.AuthProvider),
		IsVerified:   user.IsVerified,
		FullName:     user.FullName,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		ProfileImage: user.ProfileImage,
		Role:         string(user.Role),
		Status:       string(user.Status),
		Preferences:  user.Preferences,
		LastLoginAt:  user.LastLoginAt,
		CreatedAt:    user.CreatedAt,
		UpdatedAt:    user.UpdatedAt,
		IsDeleted:    user.IsDeleted,
	}
}

func UserToDomainList(userModels []*UserModel) []*domain.User {
	var users []*domain.User
	for _, userModel := range userModels {
		users = append(users, UserToDomain(userModel))
	}
	return users
}
