package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type RestaurantUsecase struct {
	Repo       domain.IRestaurantRepo
	ctxtimeout time.Duration
}

func NewRestaurantUsecase(r domain.IRestaurantRepo, timeout time.Duration) domain.IRestaurantUsecase {
	return &RestaurantUsecase{
		Repo:       r,
		ctxtimeout: timeout,
	}
}

func (s *RestaurantUsecase) CreateRestaurant(ctx context.Context, r *domain.Restaurant) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.Create(c, r)
}

func (s *RestaurantUsecase) UpdateRestaurant(ctx context.Context, r *domain.Restaurant) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.Update(c, r)
}

func (s *RestaurantUsecase) DeleteRestaurant(ctx context.Context, id string, manager string) error {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.Delete(c, id, manager)
}

func (s *RestaurantUsecase) GetRestaurantBySlug(ctx context.Context, slug string) (*domain.Restaurant, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	return s.Repo.GetBySlug(c, slug)
}

func (s *RestaurantUsecase) ListBranchesBySlug(ctx context.Context, slug string, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	if pageSize > 50 {
		pageSize = 50
	}
	return s.Repo.ListAllBranches(c, slug, page, pageSize)
}

func (s *RestaurantUsecase) ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*domain.Restaurant, int64, error) {
	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
	defer cancel()
	if pageSize > 50 {
		pageSize = 50
	}
	return s.Repo.ListUniqueRestaurants(c, page, pageSize)
}

// package usecase

// import (
// 	"context"
// 	"time"

// 	"github.com/RealEskalate/G6-MenuMate/internal/domain"
// )

// type RestaurantUsecase struct {
// 	Repo       domain.IRestaurantRepo
// 	URepo      domain.IUserRepository
// 	ctxtimeout time.Duration
// }

// func NewRestaurantUsecase(r domain.IRestaurantRepo, timeout time.Duration) domain.IRestaurantUsecase {
// 	return &RestaurantUsecase{
// 		Repo:       r,
// 		ctxtimeout: timeout,
// 	}
// }

// func (s *RestaurantUsecase) ListBranchesBySlug(ctx context.Context, slug string, page, pageSize int) ([]*domain.Restaurant, int64, error) {

// 	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
// 	defer cancel()
// 	branches, total, err := s.Repo.ListAllBranches(c, slug, page, pageSize)
// 	if err != nil {
// 		return nil, 0, err
// 	}

// 	// enforce a max page size for safety
// 	if pageSize > 50 {
// 		pageSize = 50
// 	}

// 	return branches, total, nil
// }

// func (s *RestaurantUsecase) ListUniqueRestaurants(ctx context.Context, page, pageSize int) ([]*domain.Restaurant, int64, error) {
// 	c, cancel := context.WithTimeout(ctx, s.ctxtimeout)
// 	defer cancel()

// 	if pageSize > 50 {
// 		pageSize = 50
// 	}

// 	branches, total, err := s.Repo.ListUniqueRestaurants(c, page, pageSize)
// 	if err != nil {
// 		return nil, 0, err
// 	}
// 	return branches, total, nil
// }

// // func (r *RestaurantUsecase) CreateBranch(ctx context.Context, branch domain.RestaurantBranch, ownerId string, managerEmail string) domain.DomainError {
// // 	branch.CreatedAt = time.Now()
// // 	branch.UpdatedAt = time.Now()

// // 	manager, err := r.PromoteToManger(ctx, managerEmail)

// // 	if err != nil {
// // 		return domain.DomainError{
// // 			Err:  err,
// // 			Code: http.StatusBadRequest,
// // 		}
// // 	}
// // 	branch.Manager = manager.ID
// // 	c, cancel := context.WithTimeout(ctx, r.ctxtimeout)
// // 	defer cancel()

// // 	err2 := r.BRepo.AddBranch(c, ownerId, branch)
// // 	if err2.Err != nil {
// // 		return domain.DomainError{
// // 			Err:  err2.Err,
// // 			Code: http.StatusBadRequest,
// // 		}
// // 	}
// // 	return domain.DomainError{}
// // }

// // func (r *RestaurantUsecase) PromoteToManger(ctx context.Context, managerEmail string) (*domain.User, error) {
// // 	manager, err := r.URepo.GetUserByEmail(ctx, managerEmail)
// // 	if err != nil {
// // 		return &domain.User{}, err
// // 	}
// // 	err = r.URepo.ChangeRole(ctx, manager.ID, string(domain.RoleManager), manager.Username)
// // 	if err != nil {
// // 		return &domain.User{}, err
// // 	}
// // 	return manager, nil
// // }

// // func (r *RestaurantUsecase) GetBranches(ctx context.Context, restaurantId string) ([]*domain.RestaurantBranch, domain.DomainError) {

// // }
