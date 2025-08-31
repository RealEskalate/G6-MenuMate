package usecase

import "github.com/dinq/menumate/internal/domain"

type RestaurantUsecase struct {
	Repo domain.IRestaurantRepository
}

// func NewRestaurantUsecase(r domain.IRestaurantRepository) *domain.IRestaurantUseCase {
// 	return &RestaurantUsecase{Repo: r}
// }
