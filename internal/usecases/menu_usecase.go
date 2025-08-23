package usecase

import "github.com/dinq/menumate/internal/domain"

type MenuUsecase struct {
	Repo domain.MenuRepository
}

func NewMenuUsecase(r domain.MenuRepository) *MenuUsecase {
	return &MenuUsecase{Repo: r}
}
