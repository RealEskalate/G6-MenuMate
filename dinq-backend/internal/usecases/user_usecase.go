package usecase

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/security"
)

type UserUsecase struct {
	userRepo       domain.IUserRepository
	storageService domain.StorageService
	ctxtimeout     time.Duration
}

func NewUserUsecase(userRepo domain.IUserRepository, storageService domain.StorageService, timeout time.Duration) domain.IUserUsecase {
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
	// Default auth provider if empty
	if request.AuthProvider == "" {
		request.AuthProvider = domain.AuthEmail
	}

	// Basic uniqueness check on email (legacy username flow retained only if provided)
	if request.Username != "" {
		if existing, err := uc.userRepo.FindByUsernameOrEmail(ctx, request.Username); err == nil && (existing != domain.User{}) {
			return errors.New("username already exists")
		}
	}
	if request.Email != "" {
		if existing, err := uc.userRepo.FindByUsernameOrEmail(ctx, request.Email); err == nil && (existing != domain.User{}) {
			return errors.New("email already exists")
		}
	}

	if request.PasswordHash != "" { // hash raw password provided in PasswordHash field
		h, _ := security.HashPassword(request.PasswordHash)
		request.PasswordHash = h
	}
	// migrate legacy Password field if provided instead
	if request.Password != "" && request.PasswordHash == "" {
		h, _ := security.HashPassword(request.Password)
		request.PasswordHash = h
		request.Password = "" // clear legacy
	}
	request.IsVerified = false
	now := time.Now()
	request.CreatedAt = now
	request.UpdatedAt = now
	err := uc.userRepo.CreateUser(ctx, request)
	if err != nil {
		return err
	}
	return nil
}

// Logout
func (uc *UserUsecase) Logout(userID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
	defer cancel()

	return uc.userRepo.InvalidateTokens(ctx, userID)
}

// find user by username or id
func (uc *UserUsecase) FindByUsernameOrEmail(ctx context.Context, identifier string) (*domain.User, error) {
	emailRegex := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	isEmail, _ := regexp.MatchString(emailRegex, identifier)
	var user *domain.User
	var err error
	if isEmail {
		user, err = uc.userRepo.GetUserByEmail(ctx, identifier)
	} else {
		user, err = uc.userRepo.GetUserByUsername(ctx, identifier)
	}
	return user, err
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
	// Handle avatar upload
	if len(update.AvatarData) > 0 {
		avatarURL, err := uc.storageService.UploadFile(ctx, fileName, update.AvatarData)
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

		user.AvatarURL = avatarURL
	}
	fmt.Println(user)

	// Apply updates
	if update.Bio != "" {
		user.Bio = update.Bio
	}
	if update.FirstName != "" {
		user.FirstName = update.FirstName
	}
	if update.LastName != "" {
		user.LastName = update.LastName
	}

	// Update in repository
	if err := uc.userRepo.UpdateUser(ctx, user.ID, user); err != nil {
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

	// Check old password (prefer PasswordHash)
	storedHash := user.Password
	if user.PasswordHash != "" { storedHash = user.PasswordHash }
	if err := security.ValidatePassword(storedHash, oldPassword); err != nil {
		return errors.New("invalid old password")
	}

	// Hash new password
	hashedPassword, err := security.HashPassword(newPassword)
	if err != nil {
		return err
	}

	// Update password
	user.PasswordHash = hashedPassword
	user.Password = "" // clear legacy
	return uc.userRepo.UpdateUser(ctx, user.ID, user)
}
