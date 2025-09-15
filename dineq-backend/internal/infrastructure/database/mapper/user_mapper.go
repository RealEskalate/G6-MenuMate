package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserModel struct {
	ID           bson.ObjectID       `bson:"_id,omitempty"`
	Email        string              `bson:"email,omitempty"`
	PhoneNumber  string              `bson:"phoneNumber,omitempty"`
	Username     string              `bson:"username,omitempty"`
	Password     string              `bson:"passwordHash,omitempty"`
	AuthProvider string              `bson:"authProvider,omitempty"`
	IsVerified   bool                `bson:"isVerified"`
	FullName     string              `bson:"fullName,omitempty"`
	FirstName    string              `bson:"firstName,omitempty"`
	LastName     string              `bson:"lastName,omitempty"`
	ProfileImage string              `bson:"profileImage,omitempty"`
	Role         string              `bson:"role"`
	Status       string              `bson:"status"`
	Preferences  *domain.Preferences `bson:"preferences,omitempty"`
	LastLoginAt  *time.Time          `bson:"lastLoginAt,omitempty"`
	CreatedAt    time.Time           `bson:"createdAt"`
	UpdatedAt    time.Time           `bson:"updatedAt"`
	IsDeleted    bool                `bson:"isDeleted"`
}

func UserToDomain(user *UserModel) *domain.User {
	return &domain.User{
		ID:           user.ID.Hex(),
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Username:     user.Username,
		Password:     user.Password,
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
	if user == nil {
		return nil
	}
	return &UserModel{
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Username:     user.Username,
		Password:     user.Password,
		AuthProvider: string(user.AuthProvider),
		IsVerified:   user.IsVerified,
		FullName:     user.FullName,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		ProfileImage: user.ProfileImage,
		Role:         string(user.Role),
		Status:       string(user.Status),
		Preferences:  user.Preferences,
		CreatedAt:    user.CreatedAt,
		UpdatedAt:    user.UpdatedAt,
	}
}

func UserToDomainList(userModels []*UserModel) []*domain.User {
	var users []*domain.User
	for _, userModel := range userModels {
		users = append(users, UserToDomain(userModel))
	}
	return users
}
