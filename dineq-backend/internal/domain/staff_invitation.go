package domain

import (
	"context"
	"time"
)

type InvitationStatus string

const (
	InvitationPending  InvitationStatus = "PENDING"
	InvitationAccepted InvitationStatus = "ACCEPTED"
	InvitationExpired  InvitationStatus = "EXPIRED"
	InvitationRevoked  InvitationStatus = "REVOKED"
)

type StaffInvitation struct {
	ID           string
	RestaurantID string
	InvitedBy    string // userID of owner/manager
	InviteeEmail string
	InviteeName  string
	Role         UserRole // MANAGER, STAFF, WAITER
	Token        string
	Status       InvitationStatus
	ExpiresAt    time.Time
	AcceptedAt   *time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type IStaffInvitationRepository interface {
	Create(ctx context.Context, inv *StaffInvitation) error
	GetByID(ctx context.Context, id string) (*StaffInvitation, error)
	GetByToken(ctx context.Context, token string) (*StaffInvitation, error)
	GetByRestaurant(ctx context.Context, restaurantID string) ([]*StaffInvitation, error)
	UpdateStatus(ctx context.Context, id string, status InvitationStatus) error
	Delete(ctx context.Context, id string) error
	GetStaffByRestaurant(ctx context.Context, restaurantID string, role string) ([]*User, error)
}

type IStaffManagementUsecase interface {
	InviteStaff(ctx context.Context, restaurantID, invitedBy, email, name string, role UserRole) (*StaffInvitation, error)
	AcceptInvitation(ctx context.Context, token, userID string) error
	RevokeInvitation(ctx context.Context, invitationID, requesterID string) error
	ListInvitations(ctx context.Context, restaurantID string) ([]*StaffInvitation, error)
	RemoveStaff(ctx context.Context, restaurantID, staffID, requesterID string) error
	GetRestaurantStaff(ctx context.Context, restaurantID string, role string) ([]*User, error)
	GetMyRestaurantAssignments(ctx context.Context, userID string) ([]*Restaurant, error)
}
