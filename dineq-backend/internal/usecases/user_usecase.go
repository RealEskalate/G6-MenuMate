package usecase

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

type UserUsecase struct {
	userRepo            domain.IUserRepository
	storageService      services.StorageService
	ctxtimeout          time.Duration
	NotificationUseCase domain.INotificationUseCase
}

func NewUserUsecase(userRepo domain.IUserRepository, storageService services.StorageService, timeout time.Duration) domain.IUserUsecase {
	return &UserUsecase{
		userRepo:       userRepo,
		storageService: storageService,
		ctxtimeout:     timeout,
	}
}

func (uc *UserUsecase) Register(request *domain.User) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()

	// Default role if not supplied
	if request.Role == "" {
		request.Role = domain.RoleCustomer
	}
	// Default status if not supplied
	if request.Status == "" {
		request.Status = domain.StatusActive
	}
	// Default auth provider if empty
	if request.AuthProvider == "" {
		request.AuthProvider = domain.AuthEmail
	}

	// Normalize inputs (lowercase email & username, trim spaces)
	request.Email = strings.TrimSpace(strings.ToLower(request.Email))
	request.Username = strings.TrimSpace(strings.ToLower(request.Username))
	request.PhoneNumber = strings.TrimSpace(request.PhoneNumber)

	if request.Password != "" { // hash raw password provided (DTO mapped plaintext into Password)
		h, _ := security.HashPassword(request.Password)
		request.Password = h
	}
	request.IsVerified = false
	now := time.Now()
	request.CreatedAt = now
	request.UpdatedAt = now
	// Generate default avatar if none provided
	if strings.TrimSpace(request.ProfileImage) == "" {
		avatarURL, err := uc.generateAndUploadAvatar(ctx, request)
		if err == nil {
			request.ProfileImage = avatarURL
		}
	}

	err := uc.userRepo.CreateUser(ctx, request)
	if err != nil {
		// Handle duplicate key errors from Mongo instead of racing with manual existence queries
		var writeExc *mongo.WriteException
		if errors.As(err, &writeExc) {
			for _, we := range writeExc.WriteErrors {
				// Inspect message for index names we set: ux_email, ux_username, ux_phone_number
				if strings.Contains(we.Message, "ux_email") {
					return domain.ErrEmailAlreadyInUse
				}
				if strings.Contains(we.Message, "ux_username") {
					return domain.ErrUsernameAlreadyInUse
				}
				if strings.Contains(we.Message, "ux_phone_number") {
					return domain.ErrPhoneAlreadyInUse
				}
			}
			return domain.ErrDuplicateUser
		}
		return err
	}
	return nil
}

// generateAndUploadAvatar fetches a UI-Avatar image
func (uc *UserUsecase) generateAndUploadAvatar(ctx context.Context, u *domain.User) (string, error) {
	name := strings.TrimSpace(u.Username)
	if name == "" {
		parts := []string{}
		if u.FirstName != "" {
			parts = append(parts, u.FirstName)
		}
		if u.LastName != "" {
			parts = append(parts, u.LastName)
		}
		if len(parts) > 0 {
			name = strings.Join(parts, "+")
		}
	}
	if name == "" && u.Email != "" {
		name = strings.Split(u.Email, "@")[0]
	}
	if name == "" {
		name = "User"
	}
	return fmt.Sprintf("https://ui-avatars.com/api/?name=%s&background=random&color=fff&format=png", name), nil
}

// find user by username or id
func (uc *UserUsecase) FindByUsernameOrEmail(ctx context.Context, identifier string) (*domain.User, error) {
	// Delegate to repository which already supports username, email, or phone via $or filter.
	u, err := uc.userRepo.FindByUsernameOrEmail(ctx, identifier)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

func (uc *UserUsecase) FindUserByID(uid string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()
	return uc.userRepo.FindUserByID(ctx, uid)
}

func (uc *UserUsecase) GetUserByEmail(email string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()
	return uc.userRepo.GetUserByEmail(ctx, email)
}

func (uc *UserUsecase) UpdateUser(id string, user *domain.User) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()

	user.UpdatedAt = time.Now()
	if err := uc.userRepo.UpdateUser(ctx, id, user); err != nil {
		return nil, err
	}
	return user, nil
}

func (uc *UserUsecase) UpdateProfile(userID string, update domain.UserProfileUpdate, fileName string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get user
	user, err := uc.userRepo.FindUserByID(ctx, userID)
	if err == domain.ErrNotFound {
		return nil, domain.ErrUserNotFound
	}
	if err != nil {
		return nil, err
	}
	fmt.Println(update.FirstName, update.LastName)
	var publicId string
	// Handle avatar upload
	if len(update.AvatarData) > 0 {
		avatarURL, pubId, err := uc.storageService.UploadFile(ctx, fileName, update.AvatarData, "profile")
		publicId = pubId
		if err != nil {
			return nil, fmt.Errorf("failed to upload avatar: %w", err)
		}

		// Wait for the upload to complete
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		default:
			// Continue if no timeout or cancellation
		}

		user.ProfileImage = avatarURL
	}

	// Apply updates
	if update.FirstName != "" {
		user.FirstName = update.FirstName
	}
	if update.LastName != "" {
		user.LastName = update.LastName
	}

	// Update in repository
	if err := uc.userRepo.UpdateUser(ctx, user.ID, user); err != nil {
		uc.storageService.DeleteFile(ctx, publicId)
		return nil, err
	}

	return user, nil
}

func (uc *UserUsecase) ChangePassword(userID, oldPassword, newPassword string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()

	// Find user
	user, err := uc.userRepo.FindUserByID(ctx, userID)
	if err != nil {
		return err
	}

	// Check old password
	storedHash := user.Password
	if err := security.ValidatePassword(storedHash, oldPassword); err != nil {
		return errors.New("invalid old password")
	}

	// Hash new password
	hashedPassword, err := security.HashPassword(newPassword)
	if err != nil {
		return err
	}

	// Update password
	user.Password = hashedPassword
	return uc.userRepo.UpdateUser(ctx, user.ID, user)
}

// assign Role
func (uc *UserUsecase) AssignRole(userID string, branchID string, role domain.UserRole) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()

	// Find user
	user, err := uc.userRepo.FindUserByID(ctx, userID)
	if err != nil {
		return err
	}

	// Assign role
	user.Role = role
	return uc.userRepo.UpdateUser(ctx, user.ID, user)
}
