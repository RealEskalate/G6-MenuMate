package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// AuditLogModel is the MongoDB representation of an audit log entry.
type AuditLogModel struct {
	ID          bson.ObjectID `bson:"_id,omitempty"`
	ActorID     string        `bson:"actorId"`
	ActorRole   string        `bson:"actorRole"`
	ActorName   string        `bson:"actorName,omitempty"`
	Action      string        `bson:"action"`
	EntityType  string        `bson:"entityType"`
	EntityID    string        `bson:"entityId"`
	EntityName  string        `bson:"entityName,omitempty"`
	OldValue    string        `bson:"oldValue,omitempty"`
	NewValue    string        `bson:"newValue,omitempty"`
	IPAddress   string        `bson:"ipAddress,omitempty"`
	UserAgent   string        `bson:"userAgent,omitempty"`
	Description string        `bson:"description,omitempty"`
	CreatedAt   time.Time     `bson:"createdAt"`
}

// AuditLogFromDomain converts a domain.AuditLog to an AuditLogModel ready for persistence.
// The ID field is intentionally omitted so MongoDB auto-generates it on insert.
func AuditLogFromDomain(l *domain.AuditLog) *AuditLogModel {
	if l == nil {
		return nil
	}
	return &AuditLogModel{
		ActorID:     l.ActorID,
		ActorRole:   l.ActorRole,
		ActorName:   l.ActorName,
		Action:      string(l.Action),
		EntityType:  l.EntityType,
		EntityID:    l.EntityID,
		EntityName:  l.EntityName,
		OldValue:    l.OldValue,
		NewValue:    l.NewValue,
		IPAddress:   l.IPAddress,
		UserAgent:   l.UserAgent,
		Description: l.Description,
		CreatedAt:   l.CreatedAt,
	}
}

// AuditLogToDomain converts an AuditLogModel retrieved from MongoDB to a domain.AuditLog.
func AuditLogToDomain(m *AuditLogModel) *domain.AuditLog {
	if m == nil {
		return nil
	}
	return &domain.AuditLog{
		ID:          m.ID.Hex(),
		ActorID:     m.ActorID,
		ActorRole:   m.ActorRole,
		ActorName:   m.ActorName,
		Action:      domain.AuditAction(m.Action),
		EntityType:  m.EntityType,
		EntityID:    m.EntityID,
		EntityName:  m.EntityName,
		OldValue:    m.OldValue,
		NewValue:    m.NewValue,
		IPAddress:   m.IPAddress,
		UserAgent:   m.UserAgent,
		Description: m.Description,
		CreatedAt:   m.CreatedAt,
	}
}

// AuditLogToDomainList converts a slice of AuditLogModel to a slice of domain.AuditLog pointers.
func AuditLogToDomainList(models []*AuditLogModel) []*domain.AuditLog {
	logs := make([]*domain.AuditLog, 0, len(models))
	for _, m := range models {
		logs = append(logs, AuditLogToDomain(m))
	}
	return logs
}
