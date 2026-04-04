package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type AnalyticsUsecase struct {
	restaurantRepo domain.IRestaurantRepo
	itemRepo       domain.IItemRepository
	reviewRepo     domain.IReviewRepository
	viewEventRepo  domain.IViewEventRepository
	qrRepo         domain.IQRCodeRepository
	timeout        time.Duration
}

func NewAnalyticsUsecase(
	rr domain.IRestaurantRepo,
	ir domain.IItemRepository,
	revR domain.IReviewRepository,
	vr domain.IViewEventRepository,
	qr domain.IQRCodeRepository,
	timeout time.Duration,
) domain.IAnalyticsUsecase {
	return &AnalyticsUsecase{
		restaurantRepo: rr,
		itemRepo:       ir,
		reviewRepo:     revR,
		viewEventRepo:  vr,
		qrRepo:         qr,
		timeout:        timeout,
	}
}

func (uc *AnalyticsUsecase) GetRestaurantAnalytics(restaurantID string, period string) (*domain.RestaurantAnalytics, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.timeout)
	defer cancel()

	// 1. Get Restaurant Basic Stats
	restaurant, err := uc.restaurantRepo.GetByID(ctx, restaurantID)
	if err != nil {
		return nil, err
	}

	// 2. Get Total Reviews Count and Star Distribution
	distribution, err := uc.reviewRepo.GetStarDistribution(ctx, restaurantID)
	if err != nil {
		distribution = []domain.StarDistribution{}
	}

	var totalReviews int64
	for _, d := range distribution {
		totalReviews += int64(d.Count)
	}

	// 3. Get Visitors Data (Views per hour for last 24h)
	visitors, err := uc.viewEventRepo.GetAnalyticsByEntity(ctx, restaurantID, "restaurant")
	if err != nil {
		visitors = []domain.VisitorPoint{}
	}

	// 4. Get Popular Items (Top 5 by views)
	// We might need a SearchItems call with sort by popularity
	items, _, err := uc.itemRepo.SearchItems(ctx, domain.ItemFilter{
		SortBy:   "popularity",
		Order:    -1,
		Page:     1,
		PageSize: 5,
	})
	if err != nil {
		items = []domain.Item{}
	}

	popularItems := make([]domain.PopularItem, 0, len(items))
	for _, it := range items {
		popularItems = append(popularItems, domain.PopularItem{
			Name:  it.Name,
			Views: it.ViewCount,
		})
	}

	// 5. Total QR Scans (Simulated for now if no specific logging exists, or use view events with type 'qr')
	// For now, let's just return a placeholder or check if qrRepo has something.
	// In some systems, QR scans are just restaurant views with a 'src=qr' param.

	return &domain.RestaurantAnalytics{
		TotalViews:       restaurant.ViewCount,
		AverageRating:    restaurant.AverageRating,
		TotalReviews:     totalReviews,
		VisitorsData:     visitors,
		PopularItems:     popularItems,
		StarDistribution: distribution,
		TotalQRScans:     0, // TODO: Implement QR scan tracking if needed
	}, nil
}
