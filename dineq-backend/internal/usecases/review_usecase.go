package usecase

import "github.com/RealEskalate/G6-MenuMate/internal/domain"

type ReviewUsecase struct {
<<<<<<< HEAD
	Repo domain.ReviewRepository
}

func NewReviewUsecase(r domain.ReviewRepository) *ReviewUsecase {
	return &ReviewUsecase{Repo: r}
}
=======
	Repo domain.IReviewUseCase
}

// func NewReviewUsecase(r domain.IReviewRepository) *domain.IReviewUseCase {
// 	return &ReviewUsecase{Repo: r}
// }
>>>>>>> Backend_develop
