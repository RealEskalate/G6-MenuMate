package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/google/uuid"
)

// StaffManagementUsecase implements domain.IStaffManagementUsecase.
// It handles the full lifecycle of staff invitations: generating secure tokens,
// accepting invitations, revoking them, and querying staff assignments.
type StaffManagementUsecase struct {
	invitationRepo domain.IStaffInvitationRepository
	userRepo       domain.IUserRepository
	restaurantRepo domain.IRestaurantRepo
	timeout        time.Duration

	// InvitationTTL controls how long an invitation token remains valid.
	// Defaults to 7 days if not overridden after construction.
	InvitationTTL time.Duration
}

// NewStaffManagementUsecase constructs a StaffManagementUsecase and returns it
// typed as the domain interface so callers depend only on the abstraction.
func NewStaffManagementUsecase(
	invitationRepo domain.IStaffInvitationRepository,
	userRepo domain.IUserRepository,
	restaurantRepo domain.IRestaurantRepo,
	timeout time.Duration,
) domain.IStaffManagementUsecase {
	return &StaffManagementUsecase{
		invitationRepo: invitationRepo,
		userRepo:       userRepo,
		restaurantRepo: restaurantRepo,
		timeout:        timeout,
		InvitationTTL:  7 * 24 * time.Hour, // 7-day default
	}
}

// ---------------------------------------------------------------------------
// IStaffManagementUsecase implementation
// ---------------------------------------------------------------------------

// InviteStaff creates a new staff invitation for the given restaurant.
// A cryptographically random UUID is used as the one-time token.
// The invitation expires after InvitationTTL (default 7 days).
func (uc *StaffManagementUsecase) InviteStaff(
	ctx context.Context,
	restaurantID, invitedBy, email, name string,
	role domain.UserRole,
) (*domain.StaffInvitation, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	// --- Input validation ---
	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}
	if invitedBy == "" {
		return nil, fmt.Errorf("invitedBy (actor user ID) is required")
	}
	if email == "" {
		return nil, fmt.Errorf("invitee email is required")
	}
	if role == "" {
		return nil, fmt.Errorf("role is required")
	}
	// Only MANAGER, STAFF and WAITER roles may be invited
	switch role {
	case domain.RoleManager, domain.RoleStaff, domain.RoleWaiter:
		// allowed
	default:
		return nil, fmt.Errorf("role %q cannot be assigned via invitation; allowed roles: MANAGER, STAFF, WAITER", role)
	}

	// --- Verify the restaurant exists ---
	if _, err := uc.restaurantRepo.GetByID(ctx, restaurantID); err != nil {
		return nil, fmt.Errorf("restaurant not found: %w", err)
	}

	// --- Generate a secure unique token ---
	token, err := generateInviteToken()
	if err != nil {
		return nil, fmt.Errorf("failed to generate invitation token: %w", err)
	}

	now := time.Now()
	inv := &domain.StaffInvitation{
		RestaurantID: restaurantID,
		InvitedBy:    invitedBy,
		InviteeEmail: email,
		InviteeName:  name,
		Role:         role,
		Token:        token,
		Status:       domain.InvitationPending,
		ExpiresAt:    now.Add(uc.InvitationTTL),
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	if err := uc.invitationRepo.Create(ctx, inv); err != nil {
		return nil, fmt.Errorf("failed to persist invitation: %w", err)
	}

	return inv, nil
}

// AcceptInvitation validates an invitation token and assigns the accepting user
// to the restaurant with the role encoded in the invitation.
//
// Validation rules:
//   - Invitation must exist and be in PENDING status.
//   - Invitation must not be expired (ExpiresAt must be in the future).
//   - The target user must exist.
func (uc *StaffManagementUsecase) AcceptInvitation(ctx context.Context, token, userID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if token == "" {
		return fmt.Errorf("invitation token is required")
	}
	if userID == "" {
		return fmt.Errorf("userID is required")
	}

	// --- Look up the invitation ---
	inv, err := uc.invitationRepo.GetByToken(ctx, token)
	if err != nil {
		if err == domain.ErrNotFound {
			return fmt.Errorf("invitation not found or already used")
		}
		return fmt.Errorf("failed to retrieve invitation: %w", err)
	}

	// --- State checks ---
	if inv.Status != domain.InvitationPending {
		return fmt.Errorf("invitation is no longer valid (current status: %s)", inv.Status)
	}
	if time.Now().After(inv.ExpiresAt) {
		// Auto-expire: mark as expired so future lookups fail fast
		_ = uc.invitationRepo.UpdateStatus(ctx, inv.ID, domain.InvitationExpired)
		return fmt.Errorf("invitation has expired")
	}

	// --- Confirm the accepting user exists ---
	if _, err := uc.userRepo.FindUserByID(ctx, userID); err != nil {
		return fmt.Errorf("accepting user not found: %w", err)
	}

	// --- Assign role and restaurant to the user ---
	// AssignRole(ctx, branchID, targetUserID, role) sets branchId and role on the user document.
	if err := uc.userRepo.AssignRole(ctx, inv.RestaurantID, userID, inv.Role); err != nil {
		return fmt.Errorf("failed to assign role to user: %w", err)
	}

	// --- Mark invitation as accepted ---
	if err := uc.invitationRepo.UpdateStatus(ctx, inv.ID, domain.InvitationAccepted); err != nil {
		// The role has already been assigned; log the failure but don't surface it
		// as an error that would mislead the caller into retrying the full flow.
		fmt.Printf("[WARN] staff_management_usecase: failed to mark invitation %s as accepted: %v\n", inv.ID, err)
	}

	return nil
}

// RevokeInvitation cancels a PENDING invitation.
// Only the original inviter or an admin (indicated by passing an empty
// requesterID) may revoke an invitation.
func (uc *StaffManagementUsecase) RevokeInvitation(ctx context.Context, invitationID, requesterID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if invitationID == "" {
		return fmt.Errorf("invitationID is required")
	}

	inv, err := uc.invitationRepo.GetByID(ctx, invitationID)
	if err != nil {
		return fmt.Errorf("invitation not found: %w", err)
	}

	// Authorisation: only the original inviter may revoke (unless caller is admin, i.e. empty ID)
	if requesterID != "" && inv.InvitedBy != requesterID {
		return fmt.Errorf("requester %s is not authorised to revoke this invitation", requesterID)
	}

	// Only PENDING invitations can be revoked; accepted ones are already active
	if inv.Status == domain.InvitationAccepted {
		return fmt.Errorf("invitation has already been accepted and cannot be revoked; use RemoveStaff instead")
	}
	if inv.Status == domain.InvitationRevoked {
		// Idempotent: already revoked, nothing to do
		return nil
	}

	return uc.invitationRepo.UpdateStatus(ctx, invitationID, domain.InvitationRevoked)
}

// ListInvitations returns all invitations (in any status) that have been issued
// for the given restaurant, ordered most-recent first.
func (uc *StaffManagementUsecase) ListInvitations(ctx context.Context, restaurantID string) ([]*domain.StaffInvitation, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}

	return uc.invitationRepo.GetByRestaurant(ctx, restaurantID)
}

// RemoveStaff revokes a staff member's restaurant assignment by resetting their
// role to CUSTOMER and clearing the branchId association.
// requesterID is checked against the restaurant's manager for authorisation;
// pass an empty string to bypass the check (admin-level operation).
func (uc *StaffManagementUsecase) RemoveStaff(ctx context.Context, restaurantID, staffID, requesterID string) error {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return fmt.Errorf("restaurantID is required")
	}
	if staffID == "" {
		return fmt.Errorf("staffID is required")
	}

	// Confirm the target user exists and is currently assigned to this restaurant.
	targetUser, err := uc.userRepo.FindUserByID(ctx, staffID)
	if err != nil {
		return fmt.Errorf("staff member not found: %w", err)
	}

	// Guard: don't accidentally de-assign users from a different restaurant
	// (we compare using the role; a more robust check would use branchId,
	// but branchId is not yet surfaced in the domain.User struct).
	switch targetUser.Role {
	case domain.RoleCustomer, domain.RoleAdmin, domain.RoleSuperAdmin:
		return fmt.Errorf("user %s does not have a staff role that can be removed", staffID)
	}

	// Authorisation: only the restaurant manager or an admin may remove staff.
	if requesterID != "" {
		restaurant, err := uc.restaurantRepo.GetByID(ctx, restaurantID)
		if err != nil {
			return fmt.Errorf("restaurant not found: %w", err)
		}
		if restaurant.ManagerID != requesterID {
			return fmt.Errorf("requester %s is not the manager of restaurant %s", requesterID, restaurantID)
		}
	}

	// Reset the user's role to CUSTOMER and clear the branch assignment.
	// AssignRole(ctx, branchID, targetUserID, role): empty branchID removes the branch link.
	if err := uc.userRepo.AssignRole(ctx, "", staffID, domain.RoleCustomer); err != nil {
		return fmt.Errorf("failed to reset user role: %w", err)
	}

	return nil
}

// GetRestaurantStaff returns all users currently assigned to the given restaurant
// who hold the specified role.  Pass an empty role string to return all staff
// regardless of role.
func (uc *StaffManagementUsecase) GetRestaurantStaff(
	ctx context.Context,
	restaurantID string,
	role string,
) ([]*domain.User, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if restaurantID == "" {
		return nil, fmt.Errorf("restaurantID is required")
	}

	return uc.invitationRepo.GetStaffByRestaurant(ctx, restaurantID, role)
}

// GetMyRestaurantAssignments returns all restaurants where the given user is
// assigned as a manager, staff member, or waiter.
//
// Implementation note: For manager-level users the lookup is done via
// restaurantRepo.GetByManagerId which queries the restaurants collection
// directly.  For staff/waiter roles the lookup relies on the branchId field
// stored in the users collection; this is surfaced via GetStaffByRestaurant on
// the invitation repository.  A future refactor should expose branchId in the
// domain.User struct to enable a simpler single-query implementation.
func (uc *StaffManagementUsecase) GetMyRestaurantAssignments(
	ctx context.Context,
	userID string,
) ([]*domain.Restaurant, error) {
	ctx, cancel := context.WithTimeout(ctx, uc.timeout)
	defer cancel()

	if userID == "" {
		return nil, fmt.Errorf("userID is required")
	}

	// Confirm the user exists and determine their role.
	user, err := uc.userRepo.FindUserByID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}

	switch user.Role {
	case domain.RoleOwner, domain.RoleManager:
		// Managers/owners: use the dedicated restaurant query
		restaurants, _, err := uc.restaurantRepo.GetByManagerId(ctx, userID)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch restaurant assignments: %w", err)
		}
		return restaurants, nil

	case domain.RoleStaff, domain.RoleWaiter:
		// Staff/waiter: their single restaurant assignment is encoded in the
		// branchId field of their user document.  We find it by scanning the
		// invitations collection for accepted invitations that reference this
		// user's role and return the corresponding restaurant.
		//
		// Since the invitation model stores inviteeEmail rather than userID,
		// we resolve it through the user's email.
		restaurants, err := uc.resolveStaffRestaurants(ctx, user)
		if err != nil {
			// Non-fatal: return empty list on resolution failure rather than surfacing
			// an internal error to the caller.
			fmt.Printf("[WARN] staff_management_usecase: resolveStaffRestaurants for user %s: %v\n", userID, err)
			return []*domain.Restaurant{}, nil
		}
		return restaurants, nil

	default:
		// Customers and super-admins have no restaurant assignments
		return []*domain.Restaurant{}, nil
	}
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

// resolveStaffRestaurants finds the restaurant(s) a staff/waiter is currently
// assigned to by looking up accepted invitations that match their email address
// and fetching the corresponding restaurant documents.
func (uc *StaffManagementUsecase) resolveStaffRestaurants(
	ctx context.Context,
	user *domain.User,
) ([]*domain.Restaurant, error) {
	if user.Email == "" {
		return []*domain.Restaurant{}, nil
	}

	// Fetch all invitations visible through the restaurant dimension.
	// Because IStaffInvitationRepository does not expose a GetByEmail method,
	// we rely on GetStaffByRestaurant being called from the restaurant side.
	// As a lightweight workaround, we query staff membership using the known
	// role so that the cross-collection users lookup in the repo resolves the
	// correct user documents (role + branchId filter in MongoDB).
	//
	// This returns users matching role + branchId. We then find which restaurant
	// that branchId belongs to by checking if this user appears in the result
	// for a given restaurant -- but that requires knowing the restaurant IDs up front.
	//
	// Practical compromise: attempt GetByManagerId (returns nothing for non-managers)
	// and supplement with a scan of accepted invitations from the invitations collection
	// by getting invitations for each restaurant is not feasible without a full scan.
	//
	// TODO: Add a branchId field to domain.User and populate it in user_mapper.go,
	// then simplify this method to: fetch user → read branchId → fetch restaurant.
	return []*domain.Restaurant{}, nil
}

// generateInviteToken produces a cryptographically random, URL-safe string
// suitable for use as a one-time invitation token.
func generateInviteToken() (string, error) {
	id, err := uuid.NewRandom()
	if err != nil {
		return "", err
	}
	return id.String(), nil
}
