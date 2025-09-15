package usecase

import "github.com/RealEskalate/G6-MenuMate/internal/domain"

type PhotoUsecase struct {
	Repo domain.PhotoRepository
}

func NewPhotoUsecase(r domain.PhotoRepository) *PhotoUsecase {
	return &PhotoUsecase{Repo: r}
}
