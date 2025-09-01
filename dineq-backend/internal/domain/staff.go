package domain

import (
	"time"
)

// Role defines staff role
type Role string

const (
	Manager Role = "MANAGER"
	Staff   Role = "STAFF"
)

// StaffAssignment represents a user's assignment to a branch
type StaffAssignment struct {
	ID        string
	BranchID  string
	UserID    string
	Role      Role
	CreatedAt time.Time
	IsDeleted bool
}

func NewStaffAssignment(branchID, userID string, role Role) *StaffAssignment {
	return &StaffAssignment{
		BranchID:  branchID,
		UserID:    userID,
		Role:      role,
		CreatedAt: time.Now(),
		IsDeleted: false,
	}
}
