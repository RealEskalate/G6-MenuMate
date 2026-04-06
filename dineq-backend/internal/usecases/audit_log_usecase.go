package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// AuditLogUsecase implements domain.IAuditLogUsecase.
// Logging is intentionally non-blocking: the Log method fires a goroutine so
// that audit trail creation never slows down the hot path.
type AuditLogUsecase struct {
	auditLogRepo domain.IAuditLogRepository
	timeout      time.Duration
}

// NewAuditLogUsecase constructs an AuditLogUsecase and returns it typed as the
// domain interface so callers depend only on the abstraction.
func NewAuditLogUsecase(
	auditLogRepo domain.IAuditLogRepository,
	timeout time.Duration,
) domain.IAuditLogUsecase {
	return &AuditLogUsecase{
		auditLogRepo: auditLogRepo,
		timeout:      timeout,
	}
}

// ---------------------------------------------------------------------------
// IAuditLogUsecase implementation
// ---------------------------------------------------------------------------

// Log persists an audit-log entry.  The call is synchronous and returns any
// persistence error to the caller so that critical audit paths (e.g. security
// events) can react to failures.  For fire-and-forget usage wrap the call in a
// goroutine at the call site.
func (uc *AuditLogUsecase) Log(ctx context.Context, log *domain.AuditLog) error {
	if log == nil {
		return domain.ErrInvalidInput
	}

	// Stamp the creation time if the caller hasn't set it.
	if log.CreatedAt.IsZero() {
		log.CreatedAt = time.Now()
	}

	// Validate the minimum required fields.
	if log.ActorID == "" {
		return domain.ErrInvalidInput
	}
	if log.Action == "" {
		return domain.ErrInvalidInput
	}
	if log.EntityType == "" {
		return domain.ErrInvalidInput
	}

	persistCtx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	return uc.auditLogRepo.Create(persistCtx, log)
}

// GetLogs returns a paginated slice of audit-log entries matching the supplied
// filter together with the total count of matching documents.
func (uc *AuditLogUsecase) GetLogs(ctx context.Context, filter domain.AuditLogFilter) ([]*domain.AuditLog, int64, error) {
	// Apply safe defaults for pagination.
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 50
	}
	if filter.PageSize > 200 {
		filter.PageSize = 200
	}

	queryCtx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	return uc.auditLogRepo.List(queryCtx, filter)
}
