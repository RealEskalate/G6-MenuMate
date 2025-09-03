package usecase

import (
	"context"
	"fmt"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
)

type RestaurantUsecase struct {
	Repo           domain.IRestaurantRepo
	StorageService services.StorageService
	ctxtimeout     time.Duration
}

func NewRestaurantUsecase(r domain.IRestaurantRepo, timeout time.Duration, storage services.StorageService) domain.IRestaurantUsecase {
	return &RestaurantUsecase{
		Repo:           r,
		StorageService: storage,
		ctxtimeout:     timeout,
	}
}

func (s *RestaurantUsecase) CreateRestaurant(ctx context.Context, r *domain.Restaurant, files map[string][]byte) error {
	r.Slug = utils.GenerateSlug(r.RestaurantName)
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout*5)
	defer cancel()

	for fieldName, fileData := range files {
		if len(fileData) == 0 {
			continue // skip empty files
		}

		url, _, err := s.StorageService.UploadFile(context.Background(), fmt.Sprintf("%s_%d", fieldName, time.Now().UnixNano()), fileData, "restaurant_images")
		if err != nil {
			return fmt.Errorf("failed to upload %s: %w", fieldName, err)
		}
		fmt.Print("field:" + fieldName)
		switch fieldName {
		case "logo_image":
			r.LogoImage = &url
		case "verification_docs":
			r.VerificationDocs = &url
		case "cover_image":
			r.CoverImage = &url
		}
	}

	return s.Repo.Create(c, r)
}

func (s *RestaurantUsecase) UpdateRestaurant(ctx context.Context, r *domain.Restaurant, files map[string][]byte) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()

	for field, data := range files {
		url, _, err := s.StorageService.UploadFile(c, fmt.Sprintf("%s_%d", field, time.Now().UnixNano()), data, "restaurant_images")
		if err != nil {
			return fmt.Errorf("failed to upload %s: %w", field, err)
		}

		switch field {
		case "logo_image":
			r.LogoImage = &url
		case "verification_docs":
			r.VerificationDocs = &url
		case "cover_image":
			r.CoverImage = &url
		}
	}
	return s.Repo.Update(c, r)
}

func (s *RestaurantUsecase) DeleteRestaurant(ctx context.Context, id string, manager string) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.Delete(c, id, manager)
}

func (s *RestaurantUsecase) GetRestaurantBySlug(ctx context.Context, slug string) (*domain.Restaurant, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.GetBySlug(c, slug)
}

func (s *RestaurantUsecase) GetRestaurantByOldSlug(ctx context.Context, slug string) (*domain.Restaurant, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.GetByOldSlug(c, slug)
}

func (s *RestaurantUsecase) ListBranchesBySlug(ctx context.Context, slug string, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	if pageSize > 50 {
		pageSize = 50
	}
	return s.Repo.ListAllBranches(c, slug, page, pageSize)
}

func (s *RestaurantUsecase) ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	if pageSize > 50 {
		pageSize = 50
	}
	return s.Repo.ListUniqueRestaurants(c, page, pageSize)
}
