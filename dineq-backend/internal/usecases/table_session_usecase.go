package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// TableSessionUsecase implements domain.ITableSessionUsecase.
// It enforces business rules around table-session lifecycle such as preventing
// duplicate active sessions for the same table and validating that only the
// assigned waiter can close a session.
type TableSessionUsecase struct {
	sessionRepo domain.ITableSessionRepository
	orderRepo   domain.IOrderRepository
	timeout     time.Duration
}

// NewTableSessionUsecase constructs a TableSessionUsecase and returns it typed as the
// domain interface so callers are decoupled from the concrete struct.
func NewTableSessionUsecase(
	sessionRepo domain.ITableSessionRepository,
	orderRepo domain.IOrderRepository,
	timeout time.Duration,
) domain.ITableSessionUsecase {
	return &TableSessionUsecase{
		sessionRepo: sessionRepo,
		orderRepo:   orderRepo,
		timeout:     timeout,
	}
}

// ---------------------------------------------------------------------------
// Write operations
// ---------------------------------------------------------------------------

// CreateSession opens a new table session.
// It rejects the request when an ACTIVE session already exists for the same
// table in the same restaurant to prevent double-opening a table.
func (uc *TableSessionUsecase) CreateSession(ctx context.Context, session *domain.TableSession) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	// Validate required fields
	if session.RestaurantID == "" {
		return fmt.Errorf("restaurantID is required")
	}
	if session.TableNumber == "" {
		return fmt.Errorf("tableNumber is required")
	}
	if session.WaiterID == "" {
		return fmt.Errorf("waiterID is required")
	}

	// Prevent duplicate active sessions for the same table
	existing, err := uc.sessionRepo.GetActiveByTable(ctx, session.RestaurantID, session.TableNumber)
	if err != nil && err != domain.ErrNotFound {
		return fmt.Errorf("failed to check for existing session: %w", err)
	}
	if existing != nil {
		return fmt.Errorf("table %s already has an active session (id: %s)", session.TableNumber, existing.ID)
	}

	// Initialise timestamps and defaults
	now := time.Now()
	session.Status = domain.TableSessionActive
	session.StartedAt = now
	session.CreatedAt = now
	session.UpdatedAt = now
	if session.OrderIDs == nil {
		session.OrderIDs = []string{}
	}
	if session.GuestCount <= 0 {
		session.GuestCount = 1
	}

	return uc.sessionRepo.Create(ctx, session)
}

// UpdateSession persists changes to an existing session's mutable fields.
// The caller is responsible for supplying the full updated session object.
func (uc *TableSessionUsecase) UpdateSession(ctx context.Context, session *domain.TableSession) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if session.ID == "" {
		return fmt.Errorf("session ID is required")
	}

	// Confirm the session exists before attempting an update
	if _, err := uc.sessionRepo.GetByID(ctx, session.ID); err != nil {
		return err
	}

	session.UpdatedAt = time.Now()
	return uc.sessionRepo.Update(ctx, session)
}

// CloseSession marks a session as COMPLETED and calculates TotalSpent from all
// non-cancelled orders associated with the session.
// Only the waiter who owns the session may close it.
func (uc *TableSessionUsecase) CloseSession(ctx context.Context, id string, waiterID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	session, err := uc.sessionRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Authorisation: only the assigned waiter (or a manager, handled at handler level)
	if session.WaiterID != waiterID {
		return fmt.Errorf("waiter %s is not authorised to close session %s", waiterID, id)
	}

	if session.Status != domain.TableSessionActive {
		return fmt.Errorf("session %s is already %s and cannot be closed again", id, session.Status)
	}

	// Aggregate total spent from orders in this session
	orders, err := uc.orderRepo.GetBySessionID(ctx, id)
	if err != nil && err != domain.ErrNotFound {
		return fmt.Errorf("failed to fetch session orders: %w", err)
	}

	var totalSpent float64
	for _, o := range orders {
		if o.Status != domain.OrderStatusCancelled {
			totalSpent += o.TotalAmount
		}
	}

	// Persist updated totals directly before flipping status
	now := time.Now()
	session.Status = domain.TableSessionCompleted
	session.EndedAt = &now
	session.TotalSpent = totalSpent
	session.TotalOrders = len(orders)
	session.UpdatedAt = now

	return uc.sessionRepo.Update(ctx, session)
}

// ---------------------------------------------------------------------------
// Read operations
// ---------------------------------------------------------------------------

// GetSessionByID retrieves a single session by its ID.
func (uc *TableSessionUsecase) GetSessionByID(ctx context.Context, id string) (*domain.TableSession, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if id == "" {
		return nil, fmt.Errorf("session ID is required")
	}
	return uc.sessionRepo.GetByID(ctx, id)
}

// ListSessions returns a reverse-chronological, paginated list of sessions for
// a restaurant.
func (uc *TableSessionUsecase) ListSessions(
	ctx context.Context,
	restaurantID string,
	page, pageSize int,
) ([]*domain.TableSession, int64, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, 0, fmt.Errorf("restaurantID is required")
	}
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	return uc.sessionRepo.List(ctx, restaurantID, page, pageSize)
}

// GetActiveSessionByTable retrieves the currently active session for a table.
// Returns domain.ErrNotFound when no active session exists.
func (uc *TableSessionUsecase) GetActiveSessionByTable(
	ctx context.Context,
	restaurantID, tableNumber string,
) (*domain.TableSession, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" || tableNumber == "" {
		return nil, fmt.Errorf("restaurantID and tableNumber are required")
	}
	return uc.sessionRepo.GetActiveByTable(ctx, restaurantID, tableNumber)
}

// GetWaiterActiveSessions returns all sessions currently in ACTIVE status
// that are assigned to the specified waiter.
func (uc *TableSessionUsecase) GetWaiterActiveSessions(
	ctx context.Context,
	waiterID string,
) ([]*domain.TableSession, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if waiterID == "" {
		return nil, fmt.Errorf("waiterID is required")
	}
	return uc.sessionRepo.GetActiveByWaiter(ctx, waiterID)
}
