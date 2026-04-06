package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// WaiterLogUsecase implements domain.IWaiterLogUsecase.
// It handles the creation and retrieval of waiter observation logs and exposes
// aggregated food-insight and waiter-performance analytics derived from those logs.
type WaiterLogUsecase struct {
	waiterLogRepo       domain.IWaiterLogRepository
	customerProfileRepo domain.ICustomerProfileRepository
	timeout             time.Duration
}

// NewWaiterLogUsecase constructs a WaiterLogUsecase wired to the supplied
// repositories and returns it typed as the domain interface.
func NewWaiterLogUsecase(
	waiterLogRepo domain.IWaiterLogRepository,
	customerProfileRepo domain.ICustomerProfileRepository,
	timeout time.Duration,
) domain.IWaiterLogUsecase {
	return &WaiterLogUsecase{
		waiterLogRepo:       waiterLogRepo,
		customerProfileRepo: customerProfileRepo,
		timeout:             timeout,
	}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// CreateLog validates the waiter log entry, persists it, and asynchronously
// triggers a customer-profile update so that the observation is reflected in
// CRM analytics without blocking the hot response path.
func (uc *WaiterLogUsecase) CreateLog(ctx context.Context, log *domain.WaiterLog) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	// --- Validation ---
	if log.RestaurantID == "" {
		return fmt.Errorf("restaurantID is required")
	}
	if log.WaiterID == "" {
		return fmt.Errorf("waiterID is required")
	}
	if log.OrderID == "" {
		return fmt.Errorf("orderID is required")
	}

	// Validate observations
	for i, obs := range log.Observations {
		if obs.ItemID == "" {
			return fmt.Errorf("observation at index %d has no itemId", i)
		}
		if obs.LeftoverPercentage < 0 || obs.LeftoverPercentage > 100 {
			return fmt.Errorf("observation at index %d: leftoverPercentage must be 0–100", i)
		}
	}

	// Clamp service rating to 1–5
	if log.ServiceRating < 1 {
		log.ServiceRating = 1
	}
	if log.ServiceRating > 5 {
		log.ServiceRating = 5
	}

	// Default mood to NEUTRAL when not provided
	if log.CustomerMood == "" {
		log.CustomerMood = domain.MoodNeutral
	}

	now := time.Now()
	log.CreatedAt = now
	log.UpdatedAt = now

	if err := uc.waiterLogRepo.Create(ctx, log); err != nil {
		return err
	}

	// --- Async customer-profile update ---
	// Fire and forget: we do not want profile-update latency to affect the
	// waiter's workflow. Errors are logged internally but not propagated.
	if log.CustomerID != "" {
		go uc.asyncUpdateCustomerMood(log.CustomerID, log.RestaurantID, log.CustomerMood)
	}

	return nil
}

// UpdateLog validates and persists changes to an existing waiter log entry.
func (uc *WaiterLogUsecase) UpdateLog(ctx context.Context, log *domain.WaiterLog) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if log.ID == "" {
		return fmt.Errorf("log ID is required")
	}

	// Confirm the log exists before updating
	if _, err := uc.waiterLogRepo.GetByID(ctx, log.ID); err != nil {
		return err
	}

	// Re-validate service rating
	if log.ServiceRating < 1 {
		log.ServiceRating = 1
	}
	if log.ServiceRating > 5 {
		log.ServiceRating = 5
	}

	log.UpdatedAt = time.Now()
	return uc.waiterLogRepo.Update(ctx, log)
}

// ---------------------------------------------------------------------------
// Read operations
// ---------------------------------------------------------------------------

// GetLogByID returns a single waiter log by its ID.
func (uc *WaiterLogUsecase) GetLogByID(ctx context.Context, id string) (*domain.WaiterLog, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return nil, fmt.Errorf("log ID is required")
	}
	return uc.waiterLogRepo.GetByID(ctx, id)
}

// ListLogs returns a paginated list of waiter logs matching the supplied filter.
func (uc *WaiterLogUsecase) ListLogs(ctx context.Context, filter domain.WaiterLogFilter) ([]*domain.WaiterLog, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	if filter.PageSize > 200 {
		filter.PageSize = 200
	}

	return uc.waiterLogRepo.List(ctx, filter)
}

// GetOrderLog returns the waiter log associated with a specific order.
// Returns domain.ErrNotFound when no log has been filed for that order yet.
func (uc *WaiterLogUsecase) GetOrderLog(ctx context.Context, orderID string) (*domain.WaiterLog, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if orderID == "" {
		return nil, fmt.Errorf("orderID is required")
	}
	return uc.waiterLogRepo.GetByOrderID(ctx, orderID)
}

// ---------------------------------------------------------------------------
// Analytics
// ---------------------------------------------------------------------------

// GetFoodInsights returns per-item food-consumption statistics for a restaurant
// over the named period. period accepts: "today", "week", "month", "year".
func (uc *WaiterLogUsecase) GetFoodInsights(
	ctx context.Context,
	restaurantID string,
	period string,
) ([]domain.FoodItemConsumptionStats, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}

	from, to := periodToRange(period)
	return uc.waiterLogRepo.GetFoodConsumptionStats(ctx, restaurantID, from, to)
}

// GetWaiterStats returns aggregated performance statistics for a single waiter
// over the named period. period accepts: "today", "week", "month", "year".
func (uc *WaiterLogUsecase) GetWaiterStats(
	ctx context.Context,
	waiterID string,
	period string,
) (*domain.WaiterPerformanceStats, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if waiterID == "" {
		return nil, fmt.Errorf("waiterID is required")
	}

	from, to := periodToRange(period)
	return uc.waiterLogRepo.GetWaiterPerformance(ctx, waiterID, from, to)
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// asyncUpdateCustomerMood fires a background goroutine that records the mood
// observation on the customer's restaurant profile.  Any error is silently
// discarded because this is a non-critical enrichment path.
func (uc *WaiterLogUsecase) asyncUpdateCustomerMood(customerID, restaurantID string, mood domain.CustomerMood) {
	bgCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	profile, err := uc.customerProfileRepo.GetByUserAndRestaurant(bgCtx, customerID, restaurantID)
	if err != nil {
		// Profile may not exist yet – nothing to update
		return
	}

	// Increment visit-related behavior counters based on observed mood
	now := time.Now()
	profile.Behavior.LastBehaviorUpdatedAt = now
	profile.UpdatedAt = now

	_ = uc.customerProfileRepo.Update(bgCtx, profile)
}
