package usecase

import "github.com/RealEskalate/G6-MenuMate/internal/domain"

type ItemUsecase struct {
	Repo domain.ItemRepository
}

func NewItemUsecase(r domain.ItemRepository) *ItemUsecase {
	return &ItemUsecase{Repo: r}
}
