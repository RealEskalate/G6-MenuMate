package usecase

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// OrderUsecase implements domain.IOrderUsecase.
type OrderUsecase struct {
	orderRepo   domain.IOrderRepository
	sessionRepo domain.ITableSessionRepository
	timeout     time.Duration
}

// NewOrderUsecase constructs an OrderUsecase wired to the supplied repositories.
func NewOrderUsecase(
	orderRepo domain.IOrderRepository,
	sessionRepo domain.ITableSessionRepository,
	timeout time.Duration,
) domain.IOrderUsecase {
	return &OrderUsecase{
		orderRepo:   orderRepo,
		sessionRepo: sessionRepo,
		timeout:     timeout,
	}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// CreateOrder validates the order, calculates totals, sets initial status/timestamps,
// and persists it. On success the order.ID field is populated with the server-generated ID.
func (uc *OrderUsecase) CreateOrder(ctx context.Context, order *domain.Order) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	// --- Validation ---
	if order.RestaurantID == "" {
		return errors.New("restaurantId is required")
	}
	if order.WaiterID == "" {
		return errors.New("waiterId is required")
	}
	if len(order.Items) == 0 {
		return errors.New("order must contain at least one item")
	}

	// --- Validate & recalculate item totals ---
	for i := range order.Items {
		it := &order.Items[i]
		if it.ItemID == "" {
			return fmt.Errorf("item at index %d has no itemId", i)
		}
		if it.Quantity <= 0 {
			return fmt.Errorf("item %q has invalid quantity %d", it.ItemID, it.Quantity)
		}
		if it.UnitPrice < 0 {
			return fmt.Errorf("item %q has negative unit price", it.ItemID)
		}
		it.TotalPrice = float64(it.Quantity) * it.UnitPrice
		if it.Status == "" {
			it.Status = domain.OrderItemStatusPending
		}
	}

	// --- Calculate order totals ---
	order.SubTotal = calcSubTotal(order.Items)
	if order.TaxAmount < 0 {
		order.TaxAmount = 0
	}
	order.TotalAmount = order.SubTotal + order.TaxAmount

	// --- Default currency ---
	if order.Currency == "" {
		order.Currency = "ETB"
	}

	// --- Set initial state ---
	order.Status = domain.OrderStatusPending
	now := time.Now()
	order.CreatedAt = now
	order.UpdatedAt = now
	order.IsDeleted = false

	return uc.orderRepo.Create(ctx, order)
}

// GetOrderByID fetches a single order by its ID.
func (uc *OrderUsecase) GetOrderByID(ctx context.Context, id string) (*domain.Order, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return nil, errors.New("id is required")
	}
	return uc.orderRepo.GetByID(ctx, id)
}

// UpdateOrder validates and persists changes to a non-deleted order.
// It recalculates totals from the supplied items slice.
func (uc *OrderUsecase) UpdateOrder(ctx context.Context, order *domain.Order) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if order.ID == "" {
		return errors.New("id is required")
	}

	// Ensure the order exists and is not deleted
	existing, err := uc.orderRepo.GetByID(ctx, order.ID)
	if err != nil {
		return err
	}
	if existing.IsDeleted {
		return errors.New("cannot update a deleted order")
	}
	if existing.Status == domain.OrderStatusCompleted || existing.Status == domain.OrderStatusCancelled {
		return fmt.Errorf("cannot update an order with status %q", existing.Status)
	}

	// Recalculate items
	for i := range order.Items {
		it := &order.Items[i]
		it.TotalPrice = float64(it.Quantity) * it.UnitPrice
	}
	order.SubTotal = calcSubTotal(order.Items)
	if order.TaxAmount < 0 {
		order.TaxAmount = 0
	}
	order.TotalAmount = order.SubTotal + order.TaxAmount
	order.UpdatedAt = time.Now()

	return uc.orderRepo.Update(ctx, order)
}

// UpdateOrderStatus validates the requested status transition and applies it.
// waiterID is verified against the order's assigned waiter when transitioning
// to CANCELLED (only the owning waiter may cancel).
func (uc *OrderUsecase) UpdateOrderStatus(ctx context.Context, id string, status domain.OrderStatus, waiterID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return errors.New("id is required")
	}

	existing, err := uc.orderRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	if err := validateStatusTransition(existing.Status, status); err != nil {
		return err
	}

	// Only the assigned waiter (or an admin represented by empty waiterID) may cancel
	if status == domain.OrderStatusCancelled && waiterID != "" && existing.WaiterID != waiterID {
		return errors.New("only the assigned waiter may cancel this order")
	}

	return uc.orderRepo.UpdateStatus(ctx, id, status)
}

// DeleteOrder soft-deletes an order. Only PENDING or CANCELLED orders may be deleted.
func (uc *OrderUsecase) DeleteOrder(ctx context.Context, id string, requesterID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return errors.New("id is required")
	}

	existing, err := uc.orderRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	if existing.Status != domain.OrderStatusPending && existing.Status != domain.OrderStatusCancelled {
		return fmt.Errorf("cannot delete an order with status %q; only PENDING or CANCELLED orders may be deleted", existing.Status)
	}

	// Optional ownership check: if requesterID supplied must match waiter
	if requesterID != "" && existing.WaiterID != requesterID {
		return errors.New("only the assigned waiter or an admin may delete this order")
	}

	return uc.orderRepo.Delete(ctx, id)
}

// ---------------------------------------------------------------------------
// Read operations
// ---------------------------------------------------------------------------

// ListOrders returns a paginated list of orders matching the filter.
func (uc *OrderUsecase) ListOrders(ctx context.Context, filter domain.OrderFilter) ([]*domain.Order, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 20
	}

	return uc.orderRepo.List(ctx, filter)
}

// GetSessionOrders returns all orders belonging to a given table session.
func (uc *OrderUsecase) GetSessionOrders(ctx context.Context, sessionID string) ([]*domain.Order, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if sessionID == "" {
		return nil, errors.New("sessionId is required")
	}
	return uc.orderRepo.GetBySessionID(ctx, sessionID)
}

// ---------------------------------------------------------------------------
// Analytics
// ---------------------------------------------------------------------------

// GetRestaurantRevenue returns total revenue for a restaurant over the named period.
// period accepts: "today", "week", "month", "year".
func (uc *OrderUsecase) GetRestaurantRevenue(ctx context.Context, restaurantID string, period string) (float64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return 0, errors.New("restaurantId is required")
	}

	from, to := periodToRange(period)
	return uc.orderRepo.GetRevenueByRestaurant(ctx, restaurantID, from, to)
}

// GetRestaurantOrderCount returns the number of orders placed for a restaurant
// over the named period. period accepts: "today", "week", "month", "year".
func (uc *OrderUsecase) GetRestaurantOrderCount(ctx context.Context, restaurantID string, period string) (int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return 0, errors.New("restaurantId is required")
	}

	from, to := periodToRange(period)
	return uc.orderRepo.GetOrderCountByRestaurant(ctx, restaurantID, from, to)
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// calcSubTotal sums the TotalPrice of all items in the slice.
func calcSubTotal(items []domain.OrderItem) float64 {
	var total float64
	for _, it := range items {
		total += it.TotalPrice
	}
	return total
}

// validateStatusTransition enforces the allowed state machine transitions:
//
//	PENDING → CONFIRMED | CANCELLED
//	CONFIRMED → PREPARING | CANCELLED
//	PREPARING → READY | CANCELLED
//	READY → SERVED | CANCELLED
//	SERVED → COMPLETED | CANCELLED
//	COMPLETED / CANCELLED → (terminal, no further transitions)
func validateStatusTransition(from, to domain.OrderStatus) error {
	allowed := map[domain.OrderStatus][]domain.OrderStatus{
		domain.OrderStatusPending:   {domain.OrderStatusConfirmed, domain.OrderStatusCancelled},
		domain.OrderStatusConfirmed: {domain.OrderStatusPreparing, domain.OrderStatusCancelled},
		domain.OrderStatusPreparing: {domain.OrderStatusReady, domain.OrderStatusCancelled},
		domain.OrderStatusReady:     {domain.OrderStatusServed, domain.OrderStatusCancelled},
		domain.OrderStatusServed:    {domain.OrderStatusCompleted, domain.OrderStatusCancelled},
	}

	targets, ok := allowed[from]
	if !ok {
		return fmt.Errorf("order is in terminal status %q and cannot be transitioned", from)
	}
	for _, t := range targets {
		if t == to {
			return nil
		}
	}
	return fmt.Errorf("invalid status transition from %q to %q", from, to)
}

// periodToRange converts a named period string into [from, to] time boundaries.
// Unrecognised values default to "today".
func periodToRange(period string) (from, to time.Time) {
	now := time.Now()
	switch period {
	case "week":
		// Start of the current ISO week (Monday)
		weekday := int(now.Weekday())
		if weekday == 0 {
			weekday = 7 // Sunday is 7 in ISO
		}
		from = time.Date(now.Year(), now.Month(), now.Day()-weekday+1, 0, 0, 0, 0, now.Location())
	case "month":
		from = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	case "year":
		from = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
	default: // "today"
		from = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	}
	to = now
	return from, to
}
