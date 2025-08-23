package usecase

import "github.com/dinq/menumate/internal/domain"

type RestaurantUsecase struct {
	Repo domain.RestaurantRepository
}

func NewRestaurantUsecase(r domain.RestaurantRepository) *RestaurantUsecase {
	return &RestaurantUsecase{Repo: r}
}
