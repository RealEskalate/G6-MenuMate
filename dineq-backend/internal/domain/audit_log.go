package domain

import (
	"context"
	"time"
)

type AuditAction string

const (
	AuditActionCreate   AuditAction = "CREATE"
	AuditActionUpdate   AuditAction = "UPDATE"
	AuditActionDelete   AuditAction = "DELETE"
	AuditActionApprove  AuditAction = "APPROVE"
	AuditActionReject   AuditAction = "REJECT"
	AuditActionSuspend  AuditAction = "SUSPEND"
	AuditActionActivate AuditAction = "ACTIVATE"
	AuditActionLogin    AuditAction = "LOGIN"
	AuditActionLogout   AuditAction = "LOGOUT"
)

type AuditLog struct {
	ID          string
	ActorID     string
	ActorRole   string
	ActorName   string
	Action      AuditAction
	EntityType  string // "user", "restaurant", "order", "menu", "item"
	EntityID    string
	EntityName  string
	OldValue    string // JSON snapshot before
	NewValue    string // JSON snapshot after
	IPAddress   string
	UserAgent   string
	Description string
	CreatedAt   time.Time
}

type AuditLogFilter struct {
	ActorID    string
	EntityType string
	EntityID   string
	Action     string
	Search     string // partial match on name/description/actor
	DateFrom   *time.Time
	DateTo     *time.Time
	Page       int
	PageSize   int
}

type IAuditLogRepository interface {
	Create(ctx context.Context, log *AuditLog) error
	List(ctx context.Context, filter AuditLogFilter) ([]*AuditLog, int64, error)
	GetByEntityID(ctx context.Context, entityID string) ([]*AuditLog, error)
}

type IAuditLogUsecase interface {
	Log(ctx context.Context, log *AuditLog) error
	GetLogs(ctx context.Context, filter AuditLogFilter) ([]*AuditLog, int64, error)
}
