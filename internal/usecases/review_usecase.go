package usecase

import "github.com/dinq/menumate/internal/domain"

type ReviewUsecase struct {
	Repo domain.ReviewRepository
}

func NewReviewUsecase(r domain.ReviewRepository) *ReviewUsecase {
	return &ReviewUsecase{Repo: r}
}
