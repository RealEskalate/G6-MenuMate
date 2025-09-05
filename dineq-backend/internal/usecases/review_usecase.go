package usecase

import (
	"context"
	"time"
    "fmt"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ReviewUsecase struct {
    repo      domain.IReviewRepository
    ctxtimeout time.Duration
}

func NewReviewUsecase(repo domain.IReviewRepository, timeout time.Duration) *ReviewUsecase {
    return &ReviewUsecase{
        repo:      repo,
        ctxtimeout: timeout,
    }
}

// Create a new review for an item
func (uc *ReviewUsecase) CreateReview(ctx context.Context, review *domain.Review) error {
    ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
    defer cancel()

    // 1. Create the review
    if err := uc.repo.Create(ctx, review); err != nil {
        return err
    }

    // 2. Update the item's average rating
    if _, err := uc.repo.AverageRatingByItem(ctx, review.ItemID); err != nil {
        // Optionally: log this error, but still return nil if review creation succeeded
        return err
    }

    // 3. Optionally: Update the restaurant's average rating if you have restaurantID in review
    // if review.RestaurantID != "" {
    //     _, _ = uc.repo.AverageRatingByRestaurant(ctx, review.RestaurantID)
    // }

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

    // 3. Asynchronously update the item's average rating
    if updatedReview.ItemID != "" {
        go func() {
            // Create a new context for the background task
            bgCtx, bgCancel := context.WithTimeout(context.Background(), uc.ctxtimeout)
            defer bgCancel()
            _, _ = uc.repo.AverageRatingByItem(bgCtx, updatedReview.ItemID)
        }()
    }

    return updatedReview, nil
}

// Delete a review (by ID and user)
func (uc *ReviewUsecase) DeleteReview(ctx context.Context, id string, userID string) error {
    ctx, cancel := context.WithTimeout(ctx, uc.ctxtimeout)
    defer cancel()

    // 1. Find the review to get the itemID
    review, err := uc.repo.FindByID(ctx, id)
    if err != nil {
        return err
    }

    // 2. Delete the review (soft delete)
    if err := uc.repo.Delete(ctx, id, userID); err != nil {
        return err
    }

    // 3. Update the item's average rating
    if review != nil && review.ItemID != "" {
        if _, err := uc.repo.AverageRatingByItem(ctx, review.ItemID); err != nil {
            return err
        }
    }

    // 4. Optionally: Update the restaurant's average rating if you have restaurantID in review
    // if review != nil && review.RestaurantID != "" {
    //     _, _ = uc.repo.AverageRatingByRestaurant(ctx, review.RestaurantID)
    // }

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