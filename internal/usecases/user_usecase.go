package usecase

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/dinq/menumate/internal/domain"
	"github.com/dinq/menumate/internal/infrastructure/security"
	services "github.com/dinq/menumate/internal/infrastructure/service"
)

type UserUsecase struct {
	userRepo       domain.IUserRepository
	storageService services.StorageService
	ctxtimeout     time.Duration
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
    if request.Role == "" {
	request.Role = domain.RoleUser // Default role is User
	}
	user, err := uc.userRepo.GetUserByEmail(ctx, request.Email)
	if err == nil && user != nil {
		return domain.ErrEmailAlreadyInUse
	}
	request.IsVerified = false
	request.CreatedAt = time.Now()
	request.UpdatedAt = time.Now()
	return uc.userRepo.CreateUser(ctx, request)
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
	if err := security.ValidatePassword(user.Password, oldPassword); err != nil {
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
