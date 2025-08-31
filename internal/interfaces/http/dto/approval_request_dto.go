package dto

import (
	"fmt"
	"time"

	"github.com/dinq/menumate/internal/domain"
)

// ApprovalRequestDTO represents the data transfer object for an ApprovalRequest
type ApprovalRequestDTO struct {
	ID          string    `json:"id"`
	EntityType  string    `json:"entityType"`
	EntityID    string    `json:"entityId"`
	Status      string    `json:"status"`
	RequestedBy string    `json:"requestedBy"`
	ReviewedBy  string    `json:"reviewedBy,omitempty"`
	CreatedAt   time.Time `json:"createdAt"`
	ReviewedAt  time.Time `json:"reviewedAt,omitempty"`
	Comments    string    `json:"comments,omitempty"`
}

// Validate checks the ApprovalRequestDTO for required fields
func (ar *ApprovalRequestDTO) Validate() error {
	if ar.ID == "" || ar.EntityType == "" || ar.EntityID == "" || ar.Status == "" || ar.RequestedBy == "" {
		return fmt.Errorf("approvalRequest ID, entityType, entityID, status, and requestedBy are required")
	}
	return nil
}

// ToDomain converts the ApprovalRequestDTO to a domain.ApprovalRequest entity
func (ar *ApprovalRequestDTO) ToDomain() *domain.ApprovalRequest {
	return &domain.ApprovalRequest{
		ID:          ar.ID,
		EntityType:  ar.EntityType,
		EntityID:    ar.EntityID,
		Status:      domain.ApprovalStatus(ar.Status),
		RequestedBy: ar.RequestedBy,
		ReviewedBy:  ar.ReviewedBy,
		CreatedAt:   ar.CreatedAt,
		ReviewedAt:  ar.ReviewedAt,
		Comments:    ar.Comments,
	}
}

// FromDomain converts a domain.ApprovalRequest entity to an ApprovalRequestDTO
func (ar *ApprovalRequestDTO) FromDomain(request *domain.ApprovalRequest) *ApprovalRequestDTO {
	return &ApprovalRequestDTO{
		ID:          request.ID,
		EntityType:  request.EntityType,
		EntityID:    request.EntityID,
		Status:      string(request.Status),
		RequestedBy: request.RequestedBy,
		ReviewedBy:  request.ReviewedBy,
		CreatedAt:   request.CreatedAt,
		ReviewedAt:  request.ReviewedAt,
		Comments:    request.Comments,
	}
}
