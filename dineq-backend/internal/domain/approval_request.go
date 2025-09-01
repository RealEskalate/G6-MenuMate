package domain

import "time"

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

// repository
type IApprovalRequestRepository interface {
	Create(request *ApprovalRequest) error
	UpdateStatus(id, status string) error
	GetByID(id string) (*ApprovalRequest, error)
	Delete(id string) error
}
