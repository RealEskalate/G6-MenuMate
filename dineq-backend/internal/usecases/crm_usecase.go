package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// CRMUsecase implements domain.ICRMUsecase.
// It aggregates data from multiple repositories to build the CRM dashboard and
// provides customer-list, customer-detail, and data-export capabilities.
type CRMUsecase struct {
	customerProfileRepo domain.ICustomerProfileRepository
	orderRepo           domain.IOrderRepository
	waiterLogRepo       domain.IWaiterLogRepository
	sessionRepo         domain.ITableSessionRepository
	timeout             time.Duration
}

// NewCRMUsecase constructs a CRMUsecase wired to the supplied repositories and
// returns it typed as the domain interface so callers depend only on the abstraction.
func NewCRMUsecase(
	customerProfileRepo domain.ICustomerProfileRepository,
	orderRepo domain.IOrderRepository,
	waiterLogRepo domain.IWaiterLogRepository,
	sessionRepo domain.ITableSessionRepository,
	timeout time.Duration,
) domain.ICRMUsecase {
	return &CRMUsecase{
		customerProfileRepo: customerProfileRepo,
		orderRepo:           orderRepo,
		waiterLogRepo:       waiterLogRepo,
		sessionRepo:         sessionRepo,
		timeout:             timeout,
	}
}

// ---------------------------------------------------------------------------
// ICRMUsecase implementation
// ---------------------------------------------------------------------------

// GetDashboard assembles the full CRM dashboard for a restaurant over the
// named period ("today", "week", "month", "year").
// Each data source is fetched independently; failures in non-critical sections
// are logged but do not abort the whole response.
func (uc *CRMUsecase) GetDashboard(ctx context.Context, restaurantID, period string) (*domain.CRMDashboard, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout*3) // dashboard needs more time
	defer cancel()

	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}

	from, to := periodToRange(period)

	dashboard := &domain.CRMDashboard{
		RestaurantID: restaurantID,
		Period:       period,
	}

	// -----------------------------------------------------------------------
	// 1. Customer segment counts
	// -----------------------------------------------------------------------
	segmentCounts, err := uc.customerProfileRepo.CountBySegment(ctx, restaurantID)
	if err == nil {
		dashboard.CustomersBySegment = buildSegmentCounts(segmentCounts)

		var total int64
		for _, sc := range dashboard.CustomersBySegment {
			total += sc.Count
		}
		dashboard.TotalCustomers = total

		// Derive individual segment counters for the overview header
		dashboard.NewCustomers = segmentCounts[string(domain.SegmentNew)]
		dashboard.ReturningCustomers = segmentCounts[string(domain.SegmentRegular)] +
			segmentCounts[string(domain.SegmentLoyal)] +
			segmentCounts[string(domain.SegmentVIP)]
		dashboard.AtRiskCustomers = segmentCounts[string(domain.SegmentAtRisk)]
		dashboard.LostCustomers = segmentCounts[string(domain.SegmentLost)]

		// Retention rate: (returning + loyal + vip) / total
		if total > 0 {
			retained := dashboard.ReturningCustomers
			dashboard.RetentionRate = float64(retained) / float64(total) * 100
		}

		// Loyalty tier distribution (reuse segment aggregation if available)
		dashboard.CustomersByLoyalty = buildLoyaltyCountsFromSegment(segmentCounts)
	}

	// -----------------------------------------------------------------------
	// 2. Top spenders
	// -----------------------------------------------------------------------
	topProfiles, err := uc.customerProfileRepo.GetTopCustomers(ctx, restaurantID, 10)
	if err == nil {
		dashboard.TopSpenders = profilesToSummaries(topProfiles)
	}

	// -----------------------------------------------------------------------
	// 3. Recent visitors (last 10 completed sessions)
	// -----------------------------------------------------------------------
	sessions, _, err := uc.sessionRepo.List(ctx, restaurantID, 1, 10)
	if err == nil {
		dashboard.RecentVisitors = sessionsToSummaries(sessions)
	}

	// -----------------------------------------------------------------------
	// 4. Customer growth
	// -----------------------------------------------------------------------
	growth, err := uc.customerProfileRepo.GetCustomerGrowth(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.CustomerGrowth = growth
	}

	// -----------------------------------------------------------------------
	// 5. Revenue & order metrics from the order repository
	// -----------------------------------------------------------------------
	revenue, err := uc.orderRepo.GetRevenueByRestaurant(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.TotalRevenue = revenue
	}

	orderCount, err := uc.orderRepo.GetOrderCountByRestaurant(ctx, restaurantID, from, to)
	if err == nil {
		if orderCount > 0 && dashboard.TotalRevenue > 0 {
			dashboard.AvgOrderValue = dashboard.TotalRevenue / float64(orderCount)
		}
	}

	// -----------------------------------------------------------------------
	// 6. Top items by order frequency
	// -----------------------------------------------------------------------
	topItems, err := uc.orderRepo.GetTopItemsByRestaurant(ctx, restaurantID, 10)
	if err == nil {
		dashboard.TopItems = topItems
	}

	// -----------------------------------------------------------------------
	// 7. Peak hours and daily revenue breakdown
	// -----------------------------------------------------------------------
	peakHours, err := uc.orderRepo.GetOrdersByHour(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.PeakHours = peakHours
	}

	revenueByDay, err := uc.orderRepo.GetOrdersByDay(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.RevenueByDay = revenueByDay
	}

	// -----------------------------------------------------------------------
	// 8. Average visits per customer
	// -----------------------------------------------------------------------
	if dashboard.TotalCustomers > 0 {
		totalVisits := countTotalVisitsFromSessions(sessions)
		dashboard.AvgVisitsPerCustomer = float64(totalVisits) / float64(dashboard.TotalCustomers)
	}

	// -----------------------------------------------------------------------
	// 9. Food insights from waiter logs
	// -----------------------------------------------------------------------
	foodInsights, err := uc.waiterLogRepo.GetFoodConsumptionStats(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.FoodInsights = foodInsights
	}

	// -----------------------------------------------------------------------
	// 10. Waiter performance (fetch stats for each waiter who filed logs in period)
	// -----------------------------------------------------------------------
	waiterPerf := uc.buildWaiterPerformance(ctx, restaurantID, from, to)
	dashboard.WaiterPerformance = waiterPerf

	// -----------------------------------------------------------------------
	// 11. Customer satisfaction overview from mood statistics
	// -----------------------------------------------------------------------
	moodStats, err := uc.waiterLogRepo.GetCustomerMoodStats(ctx, restaurantID, from, to)
	if err == nil {
		dashboard.SatisfactionOverview = buildSatisfactionOverview(moodStats)
	}

	return dashboard, nil
}

// GetCustomerList delegates to the customer profile repository with the
// supplied filter and returns the paginated result.
func (uc *CRMUsecase) GetCustomerList(
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

	return uc.customerProfileRepo.List(ctx, filter)
}

// GetCustomerDetail returns the full profile for a customer.
func (uc *CRMUsecase) GetCustomerDetail(ctx context.Context, profileID string) (*domain.CustomerRestaurantProfile, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if profileID == "" {
		return nil, fmt.Errorf("profileID is required")
	}

	return uc.customerProfileRepo.GetByID(ctx, profileID)
}

// ExportCustomerData returns a lightweight CustomerSummary slice for all
// customers of a restaurant, suitable for CSV / spreadsheet export.
func (uc *CRMUsecase) ExportCustomerData(ctx context.Context, restaurantID string) ([]*domain.CustomerSummary, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout*2)
	defer cancel()

	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}

	// Fetch all profiles in pages of 200 to avoid a single huge allocation
	var summaries []*domain.CustomerSummary
	page := 1
	pageSize := 200

	for {
		filter := domain.CustomerProfileFilter{
			RestaurantID: restaurantID,
			Page:         page,
			PageSize:     pageSize,
			SortBy:       "total_spent",
			Order:        -1,
		}

		profiles, total, err := uc.customerProfileRepo.List(ctx, filter)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch customer profiles for export: %w", err)
		}

		for _, p := range profiles {
			summaries = append(summaries, profileToSummary(p))
		}

		fetched := int64(page * pageSize)
		if fetched >= total {
			break
		}
		page++
	}

	return summaries, nil
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

// buildSegmentCounts converts a map[string]int64 to a slice of domain.SegmentCount
// with percentage calculations.
func buildSegmentCounts(counts map[string]int64) []domain.SegmentCount {
	var total int64
	for _, c := range counts {
		total += c
	}

	result := make([]domain.SegmentCount, 0, len(counts))
	for seg, count := range counts {
		pct := 0.0
		if total > 0 {
			pct = float64(count) / float64(total) * 100
		}
		result = append(result, domain.SegmentCount{
			Segment: seg,
			Count:   count,
			Pct:     pct,
		})
	}
	return result
}

// buildLoyaltyCountsFromSegment builds a stub loyalty-count slice from segment
// data as a lightweight proxy when a dedicated loyalty-tier aggregation is not
// available.
func buildLoyaltyCountsFromSegment(segmentCounts map[string]int64) []domain.LoyaltyCount {
	// Map VIP → GOLD/PLATINUM proxy, LOYAL → SILVER, rest → BRONZE
	loyaltyMap := map[string]int64{
		string(domain.LoyaltyBronze):   segmentCounts[string(domain.SegmentNew)] + segmentCounts[string(domain.SegmentRegular)],
		string(domain.LoyaltySilver):   segmentCounts[string(domain.SegmentLoyal)],
		string(domain.LoyaltyGold):     segmentCounts[string(domain.SegmentVIP)] / 2,
		string(domain.LoyaltyPlatinum): segmentCounts[string(domain.SegmentVIP)] - segmentCounts[string(domain.SegmentVIP)]/2,
	}

	result := make([]domain.LoyaltyCount, 0, 4)
	for tier, count := range loyaltyMap {
		result = append(result, domain.LoyaltyCount{Tier: tier, Count: count})
	}
	return result
}

// profilesToSummaries converts a slice of CustomerRestaurantProfile to lightweight summaries.
func profilesToSummaries(profiles []*domain.CustomerRestaurantProfile) []domain.CustomerSummary {
	summaries := make([]domain.CustomerSummary, 0, len(profiles))
	for _, p := range profiles {
		summaries = append(summaries, *profileToSummary(p))
	}
	return summaries
}

// profileToSummary converts a single profile to a CustomerSummary.
// Fields that require cross-collection user data (Name, Email, Phone, AvatarURL)
// are left empty here; they should be enriched at the handler layer when needed.
func profileToSummary(p *domain.CustomerRestaurantProfile) *domain.CustomerSummary {
	return &domain.CustomerSummary{
		UserID:      p.UserID,
		ProfileID:   p.ID,
		TotalSpent:  p.TotalSpent,
		TotalVisits: p.TotalVisits,
		LastVisitAt: p.LastVisitAt,
		Segment:     string(p.Segment),
		LoyaltyTier: string(p.LoyaltyTier),
	}
}

// sessionsToSummaries converts recent TableSession records to lightweight summaries.
func sessionsToSummaries(sessions []*domain.TableSession) []domain.CustomerSummary {
	summaries := make([]domain.CustomerSummary, 0, len(sessions))
	for _, s := range sessions {
		summaries = append(summaries, domain.CustomerSummary{
			UserID: s.CustomerID,
			Name:   s.CustomerName,
			Phone:  s.CustomerPhone,
		})
	}
	return summaries
}

// countTotalVisitsFromSessions returns a rough visit count derived from the
// fetched sessions slice (used for AvgVisitsPerCustomer approximation).
func countTotalVisitsFromSessions(sessions []*domain.TableSession) int {
	return len(sessions)
}

// buildWaiterPerformance fetches waiter-log based performance stats for all
// waiters who appear in logs for the restaurant within the date range.
// Errors per-waiter are silently discarded.
func (uc *CRMUsecase) buildWaiterPerformance(
	ctx context.Context,
	restaurantID string,
	from, to time.Time,
) []domain.WaiterPerformanceStats {

	// Retrieve distinct waiter IDs from recent logs
	filter := domain.WaiterLogFilter{
		RestaurantID: restaurantID,
		DateFrom:     &from,
		DateTo:       &to,
		Page:         1,
		PageSize:     500, // large page to capture all relevant waiter IDs
	}
	logs, _, err := uc.waiterLogRepo.List(ctx, filter)
	if err != nil {
		return nil
	}

	// Deduplicate waiter IDs
	seen := make(map[string]bool)
	for _, l := range logs {
		if l.WaiterID != "" {
			seen[l.WaiterID] = true
		}
	}

	stats := make([]domain.WaiterPerformanceStats, 0, len(seen))
	for waiterID := range seen {
		perf, err := uc.waiterLogRepo.GetWaiterPerformance(ctx, waiterID, from, to)
		if err != nil || perf == nil {
			continue
		}
		stats = append(stats, *perf)
	}
	return stats
}

// buildSatisfactionOverview converts the raw mood-count map into a
// SatisfactionOverview with percentage breakdowns.
func buildSatisfactionOverview(moodStats map[string]int) domain.SatisfactionOverview {
	happy := moodStats[string(domain.MoodHappy)]
	neutral := moodStats[string(domain.MoodNeutral)]
	dissatisfied := moodStats[string(domain.MoodDissatisfied)] + moodStats[string(domain.MoodAngry)]
	total := happy + neutral + dissatisfied

	if total == 0 {
		return domain.SatisfactionOverview{}
	}

	happyPct := float64(happy) / float64(total) * 100
	neutralPct := float64(neutral) / float64(total) * 100
	dissatisfiedPct := float64(dissatisfied) / float64(total) * 100

	// Weighted mood score: happy=5, neutral=3, dissatisfied=1
	avgMoodScore := (float64(happy)*5 + float64(neutral)*3 + float64(dissatisfied)*1) / float64(total)

	// Net Promoter Score estimate: promoters (happy) – detractors (dissatisfied)
	nps := (float64(happy) - float64(dissatisfied)) / float64(total) * 100

	return domain.SatisfactionOverview{
		HappyPct:         happyPct,
		NeutralPct:       neutralPct,
		DissatisfiedPct:  dissatisfiedPct,
		AvgMoodScore:     avgMoodScore,
		NetPromoterScore: nps,
	}
}
