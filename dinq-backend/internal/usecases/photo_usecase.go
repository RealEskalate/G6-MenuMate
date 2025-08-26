package usecase

import "github.com/dinq/menumate/internal/domain"

type PhotoUsecase struct {
	Repo domain.PhotoRepository
}

func NewPhotoUsecase(r domain.PhotoRepository) *PhotoUsecase {
	return &PhotoUsecase{Repo: r}
}
