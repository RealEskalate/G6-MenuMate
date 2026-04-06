package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// ApprovalRequestModel is the MongoDB persistence model for an approval request.
type ApprovalRequestModel struct {
	ID          bson.ObjectID `bson:"_id,omitempty"`
	EntityType  string        `bson:"entityType"`
	EntityID    string        `bson:"entityId"`
	Status      string        `bson:"status"`
	RequestedBy string        `bson:"requestedBy"`
	ReviewedBy  string        `bson:"reviewedBy,omitempty"`
	CreatedAt   time.Time     `bson:"createdAt"`
	ReviewedAt  *time.Time    `bson:"reviewedAt,omitempty"`
	Comments    string        `bson:"comments,omitempty"`
}

// ApprovalRequestFromDomain converts a domain.ApprovalRequest to an ApprovalRequestModel
// ready for persistence. The _id field is intentionally omitted so MongoDB auto-generates
// it on insert; repositories that perform updates must resolve the ObjectID from the
// domain ID string themselves.
func ApprovalRequestFromDomain(r *domain.ApprovalRequest) *ApprovalRequestModel {
	if r == nil {
		return nil
	}

	var reviewedAt *time.Time
	if !r.ReviewedAt.IsZero() {
		t := r.ReviewedAt
		reviewedAt = &t
	}

	return &ApprovalRequestModel{
		EntityType:  r.EntityType,
		EntityID:    r.EntityID,
		Status:      string(r.Status),
		RequestedBy: r.RequestedBy,
		ReviewedBy:  r.ReviewedBy,
		CreatedAt:   r.CreatedAt,
		ReviewedAt:  reviewedAt,
		Comments:    r.Comments,
	}
}

// ApprovalRequestToDomain converts an ApprovalRequestModel retrieved from MongoDB back
// into the canonical domain.ApprovalRequest representation.
func ApprovalRequestToDomain(m *ApprovalRequestModel) *domain.ApprovalRequest {
	if m == nil {
		return nil
	}

	var reviewedAt time.Time
	if m.ReviewedAt != nil {
		reviewedAt = *m.ReviewedAt
	}

	return &domain.ApprovalRequest{
		ID:          m.ID.Hex(),
		EntityType:  m.EntityType,
		EntityID:    m.EntityID,
		Status:      domain.ApprovalStatus(m.Status),
		RequestedBy: m.RequestedBy,
		ReviewedBy:  m.ReviewedBy,
		CreatedAt:   m.CreatedAt,
		ReviewedAt:  reviewedAt,
		Comments:    m.Comments,
	}
}

// ApprovalRequestToDomainList converts a slice of ApprovalRequestModel into a slice of
// domain.ApprovalRequest pointers, filtering out any nil models.
func ApprovalRequestToDomainList(models []*ApprovalRequestModel) []*domain.ApprovalRequest {
	result := make([]*domain.ApprovalRequest, 0, len(models))
	for _, m := range models {
		if req := ApprovalRequestToDomain(m); req != nil {
			result = append(result, req)
		}
	}
	return result
}
