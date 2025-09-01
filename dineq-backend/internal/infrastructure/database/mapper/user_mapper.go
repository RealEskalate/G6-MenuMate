package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// Add any additional types if needed, for example:
// type Preferences struct {
//	   // define preference fields
// }

type UserModel struct {
	ID           bson.ObjectID `bson:"_id,omitempty"`
	Email        string        `bson:"email"`
	PhoneNumber  string        `bson:"phoneNumber"`
	Password     string        `bson:"password"`
	AuthProvider string        `bson:"authProvider"`
	FirstName    string        `bson:"firstName"`
	LastName     string        `bson:"lastName"`
	AvatarURL    string        `bson:"avatarUrl"`
	Role         string        `bson:"role"`
	Status       string        `bson:"status"`
	Preferences  any           `bson:"preferences"` // adjust type if needed
	IsVerified   bool          `bson:"isVerified"`
	LastLoginAt  time.Time     `bson:"lastLoginAt"`
	CreatedAt    time.Time     `bson:"createdAt"`
	UpdatedAt    time.Time     `bson:"updatedAt"`
	IsDeleted    bool          `bson:"isDeleted"`
}

func UserToDomain(user *UserModel) *domain.User {
	var pref domain.Preferences
	if user.Preferences != nil {
		prefMap, ok := user.Preferences.(map[string]any)
		if ok {
			if lang, found := prefMap["language"].(string); found {
				pref.Language = lang
			}
			if theme, found := prefMap["theme"].(string); found {
				pref.Theme = theme
			}
			if notifications, found := prefMap["notifications"].(bool); found {
				pref.Notifications = notifications
			}
		}
	}
	return &domain.User{
		ID:           user.ID.Hex(),
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Password:     user.Password,
		AuthProvider: domain.AuthProvider(user.AuthProvider),
		IsVerified:   user.IsVerified,
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		ProfileImage: user.AvatarURL,
		Role:         domain.UserRole(user.Role),
		Status:       domain.UserStatus(user.Status),
		Preferences:  pref, // convert to domain.Preferences
		LastLoginAt:  user.LastLoginAt,
		CreatedAt:    user.CreatedAt,
		UpdatedAt:    user.UpdatedAt,
		IsDeleted:    user.IsDeleted,
	}
}

func UserFromDomain(user *domain.User) *UserModel {
	id := bson.NewObjectID()
	if user.ID != "" {
		var err error
		id, err = bson.ObjectIDFromHex(user.ID)
		if err != nil {
			// Handle error - for now, create new ID
			id = bson.NewObjectID()
		}
	}
	return &UserModel{
		ID:           id,
		Email:        user.Email,
		PhoneNumber:  user.PhoneNumber,
		Password:     user.Password,
		AuthProvider: string(user.AuthProvider),
		FirstName:    user.FirstName,
		LastName:     user.LastName,
		AvatarURL:    user.ProfileImage,
		Role:         string(user.Role),
		Status:       string(user.Status),
		Preferences:  user.Preferences, // adjust conversion if necessary
		IsVerified:   user.IsVerified,
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
