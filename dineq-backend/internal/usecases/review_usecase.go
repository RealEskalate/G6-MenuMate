package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ReviewUsecase struct {
	repo       domain.IReviewRepository
	ctxtimeout time.Duration
}

func NewReviewUsecase(repo domain.IReviewRepository, timeout time.Duration) *ReviewUsecase {
	return &ReviewUsecase{
		repo:       repo,
		ctxtimeout: timeout,
	}
}

// Create a new review for an item
func (uc *ReviewUsecase) CreateReview(ctx context.Context, review *domain.Review) error {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()

	if err := uc.repo.Create(ctx, review); err != nil {
		return err
	}

	// Synchronously update item average (client often expects fresh item rating)
	if review.ItemID != "" {
		if _, err := uc.repo.AverageRatingByItem(ctx, review.ItemID); err != nil {
			return err
		}
	}

	// Further cascading handled asynchronously inside repository simpleAsyncCascade
	return nil
}

// Get a review by its ID
func (uc *ReviewUsecase) GetReviewByID(ctx context.Context, id string) (*domain.Review, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()
	// fmt.Errorf("passed review")
	review, err := uc.repo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	fmt.Printf("[DEBUG] Retrieved review: %+v\n", review)
	return review, nil
}

// List reviews for a specific item (with pagination)
func (uc *ReviewUsecase) ListReviewsByItem(ctx context.Context, itemID string, page, limit int) ([]*domain.Review, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()
	return uc.repo.ListByItem(ctx, itemID, page, limit)
}

func (uc *ReviewUsecase) UpdateReview(ctx context.Context, id string, userID string, update *domain.Review) (*domain.Review, error) {

	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()

	// 1. Update the review in the repository
	if err := uc.repo.Update(ctx, id, userID, update); err != nil {
		return nil, err
	}

	// 2. Fetch the updated review to return it
	updatedReview, err := uc.repo.FindByID(ctx, id)
	if err != nil {
		// This would be unusual if the update succeeded, but handle it just in case
		return nil, err
	}

	// Async cascade handled by repository Update via simpleAsyncCascade

	return updatedReview, nil
}

// Delete a review (by ID and user)
func (uc *ReviewUsecase) DeleteReview(ctx context.Context, id string, userID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()

	// 1. Ensure review exists (minimal check)
	if _, err := uc.repo.FindByID(ctx, id); err != nil {
		return err
	}

	// 2. Delete the review (soft delete)
	if err := uc.repo.Delete(ctx, id, userID); err != nil {
		return err
	}

	// Async cascade handled in repository Delete via simpleAsyncCascade

	return nil
}

// Get average rating for an item
func (uc *ReviewUsecase) GetAverageRatingByItem(ctx context.Context, itemID string) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()
	return uc.repo.AverageRatingByItem(ctx, itemID)
}

// Get average rating for a restaurant (from its items' averages)
func (uc *ReviewUsecase) GetAverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
	defer cancel()
	return uc.repo.AverageRatingByRestaurant(ctx, restaurantID)
}

// TriggerCascade removed: repository now owns async updates
