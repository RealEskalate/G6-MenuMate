package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type UserModel struct {
	ID         bson.ObjectID `bson:"_id,omitempty"`
	Username   string        `bson:"username"`
	Email      string        `bson:"email"`
	Password   string        `bson:"password"`
	FirstName  string        `bson:"first_name"`
	LastName   string        `bson:"last_name"`
	Role       string        `bson:"role"`
	Bio        string        `bson:"bio"`
	IsVerified bool          `bson:"is_verified"`
	AvatarURL  string        `bson:"avatar_url"`
	CreatedAt  time.Time     `bson:"created_at"`
	UpdatedAt  time.Time     `bson:"updated_at"`
}

func UserToDomain(user *UserModel) *domain.User {
	return &domain.User{
		ID:         user.ID.Hex(),
		Username:   user.Username,
		Email:      user.Email,
		FirstName:  user.FirstName,
		LastName:   user.LastName,
		Password:   user.Password,
		Role:       domain.UserRole(user.Role),
		Bio:        user.Bio,
		IsVerified: user.IsVerified,
		AvatarURL:  user.AvatarURL,
		CreatedAt:  user.CreatedAt,
		UpdatedAt:  user.UpdatedAt,
	}
}

func UserFromDomain(user *domain.User) *UserModel {

	return &UserModel{
		Username:   user.Username,
		Email:      user.Email,
		FirstName:  user.FirstName,
		LastName:   user.LastName,
		Password:   user.Password,
		Role:       string(user.Role),
		Bio:        user.Bio,
		IsVerified: user.IsVerified,
		AvatarURL:  user.AvatarURL,
		CreatedAt:  user.CreatedAt,
		UpdatedAt:  user.UpdatedAt,
	}
}

func UserToDomainList(userModels []*UserModel) []*domain.User {
	var users []*domain.User
	for _, userModel := range userModels {
		users = append(users, UserToDomain(userModel))
	}
	return users
}
