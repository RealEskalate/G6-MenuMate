package mapper

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// StaffInvitationModel is the MongoDB persistence model for a staff invitation.
type StaffInvitationModel struct {
	ID           bson.ObjectID `bson:"_id,omitempty"`
	RestaurantID string        `bson:"restaurantId"`
	InvitedBy    string        `bson:"invitedBy"`
	InviteeEmail string        `bson:"inviteeEmail"`
	InviteeName  string        `bson:"inviteeName,omitempty"`
	Role         string        `bson:"role"`
	Token        string        `bson:"token"`
	Status       string        `bson:"status"`
	ExpiresAt    time.Time     `bson:"expiresAt"`
	AcceptedAt   *time.Time    `bson:"acceptedAt,omitempty"`
	CreatedAt    time.Time     `bson:"createdAt"`
	UpdatedAt    time.Time     `bson:"updatedAt"`
}

// StaffInvitationFromDomain converts a domain.StaffInvitation to a StaffInvitationModel
// suitable for insertion or update in MongoDB. The _id field is intentionally omitted
// so that MongoDB auto-generates it on insert; repositories handle ID resolution for updates.
func StaffInvitationFromDomain(inv *domain.StaffInvitation) *StaffInvitationModel {
	if inv == nil {
		return nil
	}
	return &StaffInvitationModel{
		RestaurantID: inv.RestaurantID,
		InvitedBy:    inv.InvitedBy,
		InviteeEmail: inv.InviteeEmail,
		InviteeName:  inv.InviteeName,
		Role:         string(inv.Role),
		Token:        inv.Token,
		Status:       string(inv.Status),
		ExpiresAt:    inv.ExpiresAt,
		AcceptedAt:   inv.AcceptedAt,
		CreatedAt:    inv.CreatedAt,
		UpdatedAt:    inv.UpdatedAt,
	}
}

// StaffInvitationToDomain converts a StaffInvitationModel retrieved from MongoDB back
// into the canonical domain.StaffInvitation representation.
func StaffInvitationToDomain(m *StaffInvitationModel) *domain.StaffInvitation {
	if m == nil {
		return nil
	}
	return &domain.StaffInvitation{
		ID:           m.ID.Hex(),
		RestaurantID: m.RestaurantID,
		InvitedBy:    m.InvitedBy,
		InviteeEmail: m.InviteeEmail,
		InviteeName:  m.InviteeName,
		Role:         domain.UserRole(m.Role),
		Token:        m.Token,
		Status:       domain.InvitationStatus(m.Status),
		ExpiresAt:    m.ExpiresAt,
		AcceptedAt:   m.AcceptedAt,
		CreatedAt:    m.CreatedAt,
		UpdatedAt:    m.UpdatedAt,
	}
}

// StaffInvitationToDomainList converts a slice of StaffInvitationModel into a slice of
// domain.StaffInvitation pointers, filtering out any nil models.
func StaffInvitationToDomainList(models []*StaffInvitationModel) []*domain.StaffInvitation {
	result := make([]*domain.StaffInvitation, 0, len(models))
	for _, m := range models {
		if inv := StaffInvitationToDomain(m); inv != nil {
			result = append(result, inv)
		}
	}
	return result
}
