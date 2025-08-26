package usecase

import "github.com/RealEskalate/G6-MenuMate/internal/domain"

type ReviewUsecase struct {
	Repo domain.ReviewRepository
}

func NewReviewUsecase(r domain.ReviewRepository) *ReviewUsecase {
	return &ReviewUsecase{Repo: r}
}
