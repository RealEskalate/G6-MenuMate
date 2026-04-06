package domain

import (
	"context"
	"time"
)

type ApprovalRequest struct {
	ID          string
	EntityType  string
	EntityID    string
	Status      ApprovalStatus
	RequestedBy string
	ReviewedBy  string
	CreatedAt   time.Time
	ReviewedAt  time.Time
	Comments    string
}

type ApprovalStatus string

const (
	ApprovalStatusPending  ApprovalStatus = "pending"
	ApprovalStatusApproved ApprovalStatus = "approved"
	ApprovalStatusRejected ApprovalStatus = "rejected"
)

type IApprovalRequestUseCase interface {
	CreateApprovalRequest(request *ApprovalRequest) error
	UpdateApprovalRequestStatus(id string, status ApprovalStatus) error
	GetApprovalRequestByID(id string) (*ApprovalRequest, error)
	DeleteApprovalRequest(id string) error
}

// IApprovalRequestRepository defines the persistence contract for approval requests.
// All methods accept a context for timeout/cancellation propagation.
type IApprovalRequestRepository interface {
	Create(ctx context.Context, request *ApprovalRequest) error
	UpdateStatus(ctx context.Context, id, status string) error
	GetByID(ctx context.Context, id string) (*ApprovalRequest, error)
	Delete(ctx context.Context, id string) error
	// List returns a paginated list of approval requests, optionally filtered by status.
	// Pass an empty status string to return all requests regardless of status.
	List(ctx context.Context, page, pageSize int, status string) ([]*ApprovalRequest, int64, error)
	// GetByEntityID returns the most recent approval request for a given entity ID.
	GetByEntityID(ctx context.Context, entityID string) (*ApprovalRequest, error)
}
