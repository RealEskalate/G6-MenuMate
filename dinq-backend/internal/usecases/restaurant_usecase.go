package usecase

import (
	// "context"
	"context"
	"errors"
	// "fmt"
	"regexp"
	"strings"
	"time"

	"github.com/dinq/menumate/internal/domain"
	"github.com/dinq/menumate/internal/infrastructure/logger"
)

type RestaurantUsecase struct {
	restaurantRepo domain.IRestaurantRepository
	storageService domain.StorageService
	ctxtimeout     time.Duration
}

func NewRestaurantUsecase(
	restaurantRepo domain.IRestaurantRepository,storageService domain.StorageService ,  timeout time.Duration) *RestaurantUsecase {
    return &RestaurantUsecase{
        restaurantRepo: restaurantRepo,
		storageService: storageService,
        ctxtimeout:     timeout,
    }
}

func (uc *RestaurantUsecase) RegisterRestaurant(ctx context.Context, request *domain.Restaurant) error {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()
    request.Name = sanitizeString(request.Name)
    request.Contact.Email = sanitizeString(request.Contact.Email)
    request.Contact.Phone = sanitizeString(request.Contact.Phone)
    request.About = sanitizeString(request.About)

	if request.Name == "" {
        return domain.ErrRestaurantNotFound
    }
    if !isValidEmail(request.Contact.Email) {
        return domain.ErrInvalidEmailFormat
    }
    if !isValidPhone(request.Contact.Phone) {
        return domain.ErrInvalidPhoneFormat
    }
	restaurant, err := uc.restaurantRepo.GetByEmail(ctx,request.Contact.Email)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		logger.Log.Error().Err(err).Str("email", request.Contact.Email).Msg("Failed to get restaurant by email")
		return domain.ErrInternalServerError 
	}
	if restaurant != nil {
		return domain.ErrUserAlreadyExist
	}
	restaurant, err = uc.restaurantRepo.GetByPhone(ctx, request.Contact.Phone)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		logger.Log.Error().Err(err).Str("phone", request.Contact.Phone).Msg("Failed to get restaurant by phone")
        return domain.ErrInternalServerError 
    }
	if restaurant != nil {
		return domain.ErrUserAlreadyExist
	}
	request.CreatedAt = time.Now().Unix()
	request.UpdatedAt = time.Now().Unix()

	return uc.restaurantRepo.Create(ctx,request)
}
func sanitizeString(input string) string {
    // Remove leading/trailing spaces and control characters
    return strings.TrimSpace(input)
}
func isValidEmail(email string) bool {
    re := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
    return re.MatchString(email)
}

func isValidPhone(phone string) bool {
    re := regexp.MustCompile(`^[0-9+\-() ]{7,20}$`)
    return re.MatchString(phone)
}