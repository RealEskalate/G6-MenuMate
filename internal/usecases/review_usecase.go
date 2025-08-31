package usecase

import "github.com/dinq/menumate/internal/domain"

type ReviewUsecase struct {
	Repo domain.IReviewUseCase
}

// func NewReviewUsecase(r domain.IReviewRepository) *domain.IReviewUseCase {
// 	return &ReviewUsecase{Repo: r}
// }
