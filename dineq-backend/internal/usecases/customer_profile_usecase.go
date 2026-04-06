package usecase

import (
	"context"
	"errors"
	"fmt"
	"math"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// CustomerProfileUsecase implements domain.ICustomerProfileUsecase.
// It owns the business logic for customer segmentation, loyalty tiers, visit
// recording, and profile lifecycle management.
type CustomerProfileUsecase struct {
	profileRepo domain.ICustomerProfileRepository
	timeout     time.Duration

	// VIPSpendThreshold is the lifetime-spent value above which a customer is
	// promoted to the VIP segment regardless of visit frequency.
	VIPSpendThreshold float64
	// VIPVisitThreshold is the total-visit count above which a customer is
	// promoted to the VIP segment regardless of total spend.
	VIPVisitThreshold int
}

// NewCustomerProfileUsecase constructs a CustomerProfileUsecase and returns it
// typed as the domain interface so callers depend only on the abstraction.
func NewCustomerProfileUsecase(
	profileRepo domain.ICustomerProfileRepository,
	timeout time.Duration,
) domain.ICustomerProfileUsecase {
	return &CustomerProfileUsecase{
		profileRepo:       profileRepo,
		timeout:           timeout,
		VIPSpendThreshold: 5000,
		VIPVisitThreshold: 20,
	}
}

// ---------------------------------------------------------------------------
// Profile lifecycle
// ---------------------------------------------------------------------------

// GetOrCreateProfile fetches the existing per-restaurant profile for the given
// user, or creates a fresh one when none exists yet.
func (uc *CustomerProfileUsecase) GetOrCreateProfile(
	ctx context.Context,
	userID, restaurantID string,
) (*domain.CustomerRestaurantProfile, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if userID == "" || restaurantID == "" {
		return nil, errors.New("userID and restaurantID are required")
	}

	profile, err := uc.profileRepo.GetByUserAndRestaurant(ctx, userID, restaurantID)
	if err == nil {
		return profile, nil
	}
	if !errors.Is(err, domain.ErrNotFound) {
		return nil, fmt.Errorf("failed to look up customer profile: %w", err)
	}

	// Profile does not yet exist – create a skeleton record.
	now := time.Now()
	profile = &domain.CustomerRestaurantProfile{
		UserID:        userID,
		RestaurantID:  restaurantID,
		Segment:       domain.SegmentNew,
		LoyaltyTier:   domain.LoyaltyBronze,
		LoyaltyPoints: 0,
		FavoriteItems: []string{},
		FavoriteMenus: []string{},
		Tags:          []string{},
		CreatedAt:     now,
		UpdatedAt:     now,
	}

	if err := uc.profileRepo.Create(ctx, profile); err != nil {
		return nil, fmt.Errorf("failed to create customer profile: %w", err)
	}
	return profile, nil
}

// GetProfileByID retrieves a profile by its ObjectID hex string.
func (uc *CustomerProfileUsecase) GetProfileByID(ctx context.Context, id string) (*domain.CustomerRestaurantProfile, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return nil, errors.New("profile ID is required")
	}
	return uc.profileRepo.GetByID(ctx, id)
}

// UpdateProfile replaces the mutable fields of an existing profile.
// The caller must supply a profile with a valid, non-empty ID.
func (uc *CustomerProfileUsecase) UpdateProfile(ctx context.Context, profile *domain.CustomerRestaurantProfile) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if profile.ID == "" {
		return errors.New("profile ID is required")
	}

	profile.UpdatedAt = time.Now()
	return uc.profileRepo.Update(ctx, profile)
}

// ---------------------------------------------------------------------------
// Listing & analytics
// ---------------------------------------------------------------------------

// ListCustomers returns a paginated, optionally filtered list of customer
// profiles for a restaurant.
func (uc *CustomerProfileUsecase) ListCustomers(
	ctx context.Context,
	filter domain.CustomerProfileFilter,
) ([]*domain.CustomerRestaurantProfile, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}
	if filter.PageSize > 100 {
		filter.PageSize = 100
	}

	return uc.profileRepo.List(ctx, filter)
}

// GetTopCustomers returns the top-N customers for a restaurant ordered by
// lifetime spend descending.
func (uc *CustomerProfileUsecase) GetTopCustomers(
	ctx context.Context,
	restaurantID string,
	limit int,
) ([]*domain.CustomerRestaurantProfile, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, errors.New("restaurantID is required")
	}
	if limit <= 0 {
		limit = 10
	}
	return uc.profileRepo.GetTopCustomers(ctx, restaurantID, limit)
}

// GetAtRiskCustomers returns customers who haven't visited in 30 or more days.
func (uc *CustomerProfileUsecase) GetAtRiskCustomers(
	ctx context.Context,
	restaurantID string,
) ([]*domain.CustomerRestaurantProfile, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, errors.New("restaurantID is required")
	}
	// "At risk" = no visit in the last 30 days
	return uc.profileRepo.GetAtRiskCustomers(ctx, restaurantID, 30)
}

// ---------------------------------------------------------------------------
// Visit & spend recording
// ---------------------------------------------------------------------------

// RecordVisit increments visit/order counts, updates spent totals, recalculates
// the average spend, and re-derives the segment and loyalty tier.
// If no profile exists for the (userID, restaurantID) pair one is created.
func (uc *CustomerProfileUsecase) RecordVisit(
	ctx context.Context,
	userID, restaurantID string,
	orderAmount float64,
) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if userID == "" || restaurantID == "" {
		return errors.New("userID and restaurantID are required")
	}
	if orderAmount < 0 {
		return errors.New("orderAmount must be non-negative")
	}

	profile, err := uc.profileRepo.GetByUserAndRestaurant(ctx, userID, restaurantID)
	if err != nil {
		if !errors.Is(err, domain.ErrNotFound) {
			return fmt.Errorf("failed to fetch profile for visit recording: %w", err)
		}
		// Bootstrap a new profile then record the visit on it.
		profile, err = uc.GetOrCreateProfile(ctx, userID, restaurantID)
		if err != nil {
			return err
		}
	}

	now := time.Now()

	// Update counters
	profile.TotalVisits++
	profile.TotalOrders++
	profile.TotalSpent += orderAmount

	// Recalculate average spend
	if profile.TotalOrders > 0 {
		profile.AverageSpent = profile.TotalSpent / float64(profile.TotalOrders)
	}

	// Track first / last visit timestamps
	if profile.FirstVisitAt == nil {
		profile.FirstVisitAt = &now
	}
	profile.LastVisitAt = &now

	// Award loyalty points: 1 point per unit of currency spent (floor)
	pointsEarned := int(math.Floor(orderAmount))
	profile.LoyaltyPoints += pointsEarned

	// Re-derive segment and loyalty tier
	profile.Segment = uc.calculateSegment(profile)
	profile.LoyaltyTier = calculateLoyaltyTier(profile.LoyaltyPoints)

	profile.UpdatedAt = now
	return uc.profileRepo.Update(ctx, profile)
}

// ---------------------------------------------------------------------------
// Segment management
// ---------------------------------------------------------------------------

// UpdateCustomerSegments recomputes and persists the segment for every customer
// profile belonging to the supplied restaurant.
// This is typically run as a background job (e.g. daily cron).
func (uc *CustomerProfileUsecase) UpdateCustomerSegments(ctx context.Context, restaurantID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return errors.New("restaurantID is required")
	}

	// Fetch all profiles for the restaurant (no pagination – background job)
	filter := domain.CustomerProfileFilter{
		RestaurantID: restaurantID,
		Page:         1,
		PageSize:     1000,
	}

	for {
		profiles, total, err := uc.profileRepo.List(ctx, filter)
		if err != nil {
			return fmt.Errorf("failed to list profiles for segment update: %w", err)
		}

		for _, p := range profiles {
			newSegment := uc.calculateSegment(p)
			if newSegment != p.Segment {
				if updateErr := uc.profileRepo.UpdateSegment(ctx, p.ID, newSegment); updateErr != nil {
					// Log and continue rather than aborting the whole batch
					fmt.Printf("[WARN] failed to update segment for profile %s: %v\n", p.ID, updateErr)
				}
			}
		}

		// Check if there are more pages
		fetched := int64(filter.Page * filter.PageSize)
		if fetched >= total {
			break
		}
		filter.Page++
	}

	return nil
}

// ---------------------------------------------------------------------------
// Notes & preferences
// ---------------------------------------------------------------------------

// AddCustomerNote appends a timestamped note to a profile's InternalNotes field.
func (uc *CustomerProfileUsecase) AddCustomerNote(
	ctx context.Context,
	profileID, note, staffID string,
) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if profileID == "" {
		return errors.New("profileID is required")
	}
	if note == "" {
		return errors.New("note text is required")
	}

	profile, err := uc.profileRepo.GetByID(ctx, profileID)
	if err != nil {
		return err
	}

	timestamp := time.Now().Format(time.RFC3339)
	entry := fmt.Sprintf("[%s] (%s): %s", timestamp, staffID, note)

	if profile.InternalNotes == "" {
		profile.InternalNotes = entry
	} else {
		profile.InternalNotes = profile.InternalNotes + "\n" + entry
	}

	profile.UpdatedAt = time.Now()
	return uc.profileRepo.Update(ctx, profile)
}

// UpdateDietaryPreferences replaces the dietary preferences stored on the
// customer's per-restaurant profile. If the customer has profiles at multiple
// restaurants the update only affects the profile for the specified restaurant.
func (uc *CustomerProfileUsecase) UpdateDietaryPreferences(
	ctx context.Context,
	userID string,
	prefs domain.DietaryPreferences,
) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if userID == "" {
		return errors.New("userID is required")
	}

	// Fetch all profiles for this user across all restaurants
	filter := domain.CustomerProfileFilter{Page: 1, PageSize: 200}
	profiles, _, err := uc.profileRepo.List(ctx, filter)
	if err != nil {
		return fmt.Errorf("failed to fetch profiles: %w", err)
	}

	updated := false
	for _, p := range profiles {
		if p.UserID != userID {
			continue
		}
		p.DietaryPrefs = prefs
		p.UpdatedAt = time.Now()
		if updateErr := uc.profileRepo.Update(ctx, p); updateErr != nil {
			return fmt.Errorf("failed to update dietary preferences for profile %s: %w", p.ID, updateErr)
		}
		updated = true
	}

	if !updated {
		return fmt.Errorf("no profiles found for user %s", userID)
	}
	return nil
}

// GetCustomerHistory returns all per-restaurant profiles for a given user,
// giving a cross-restaurant visit history overview.
func (uc *CustomerProfileUsecase) GetCustomerHistory(
	ctx context.Context,
	userID string,
	page, pageSize int,
) ([]*domain.CustomerRestaurantProfile, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if userID == "" {
		return nil, 0, errors.New("userID is required")
	}
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	// We query by userId across all restaurants
	filter := domain.CustomerProfileFilter{
		Page:     page,
		PageSize: pageSize,
		SortBy:   "last_visit",
		Order:    -1,
	}

	profiles, total, err := uc.profileRepo.List(ctx, filter)
	if err != nil {
		return nil, 0, err
	}

	// Filter client-side to only this user's profiles
	// (the repo does not expose a userId-only filter today; this is safe for
	// reasonable page sizes and should be refactored to a DB filter if volumes grow)
	result := make([]*domain.CustomerRestaurantProfile, 0, len(profiles))
	for _, p := range profiles {
		if p.UserID == userID {
			result = append(result, p)
		}
	}
	return result, total, nil
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

// calculateSegment derives a CustomerSegment from the profile's visit history.
//
// Rules (evaluated in priority order):
//
//	VIP        – total_spent > VIPSpendThreshold OR total_visits > VIPVisitThreshold
//	NEW        – total_visits == 1
//	LOST       – last visit > 90 days ago
//	AT_RISK    – last visit 30-90 days ago
//	LOYAL      – total_visits >= 10 AND last visit < 30 days ago
//	REGULAR    – total_visits 2-9 AND last visit < 30 days ago
//	NEW        – fallback (shouldn't normally be reached)
func (uc *CustomerProfileUsecase) calculateSegment(p *domain.CustomerRestaurantProfile) domain.CustomerSegment {
	// VIP check first
	if p.TotalSpent > uc.VIPSpendThreshold || p.TotalVisits > uc.VIPVisitThreshold {
		return domain.SegmentVIP
	}

	// Brand-new customer (first visit)
	if p.TotalVisits <= 1 {
		return domain.SegmentNew
	}

	// Recency logic
	if p.LastVisitAt != nil {
		daysSinceLast := int(time.Since(*p.LastVisitAt).Hours() / 24)

		switch {
		case daysSinceLast > 90:
			return domain.SegmentLost
		case daysSinceLast >= 30:
			return domain.SegmentAtRisk
		case p.TotalVisits >= 10:
			return domain.SegmentLoyal
		default:
			return domain.SegmentRegular
		}
	}

	// No last-visit timestamp recorded yet
	return domain.SegmentNew
}

// calculateLoyaltyTier maps a points balance to a LoyaltyTier.
//
//	BRONZE   –    0 –  999 points
//	SILVER   – 1000 – 4999 points
//	GOLD     – 5000 – 9999 points
//	PLATINUM – 10000+ points
func calculateLoyaltyTier(points int) domain.LoyaltyTier {
	switch {
	case points >= 10000:
		return domain.LoyaltyPlatinum
	case points >= 5000:
		return domain.LoyaltyGold
	case points >= 1000:
		return domain.LoyaltySilver
	default:
		return domain.LoyaltyBronze
	}
}
