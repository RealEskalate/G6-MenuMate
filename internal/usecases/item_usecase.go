package usecase

import "github.com/dinq/menumate/internal/domain"

type ItemUsecase struct {
	Repo domain.ItemRepository
}

func NewItemUsecase(r domain.ItemRepository) *ItemUsecase {
	return &ItemUsecase{Repo: r}
}
