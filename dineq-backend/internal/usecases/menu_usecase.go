package usecase

import "github.com/RealEskalate/G6-MenuMate/internal/domain"

type MenuUsecase struct {
	Repo domain.MenuRepository
}

func NewMenuUsecase(r domain.MenuRepository) *MenuUsecase {
	return &MenuUsecase{Repo: r}
}
