package usecase

import (
	"context"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type RestaurantUsecase struct {
	Repo       domain.IRestaurantRepo
	ctxtimeout time.Duration
}

func NewRestaurantUsecase(r domain.IRestaurantRepo, timeout time.Duration) domain.IRestaurantUsecase {
	return &RestaurantUsecase{
		Repo:       r,
		ctxtimeout: timeout,
	}
}

func (s *RestaurantUsecase) CreateRestaurant(ctx context.Context, r *domain.Restaurant) error {
	r.Slug = utils.GenerateSlug(r.RestaurantName)
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.Create(c, r)
}

func (s *RestaurantUsecase) UpdateRestaurant(ctx context.Context, r *domain.Restaurant) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
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
