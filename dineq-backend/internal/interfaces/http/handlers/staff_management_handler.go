package handler

import (
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type StaffManagementHandler struct {
	uc domain.IStaffManagementUsecase
}

func NewStaffManagementHandler(uc domain.IStaffManagementUsecase) *StaffManagementHandler {
	return &StaffManagementHandler{uc: uc}
}

type inviteStaffRequest struct {
	RestaurantID string `json:"restaurantId" binding:"required"`
	Email        string `json:"email" binding:"required,email"`
	Name         string `json:"name"`
	Role         string `json:"role" binding:"required"`
}

type acceptInviteRequest struct {
	Token string `json:"token" binding:"required"`
}

func (h *StaffManagementHandler) InviteStaff(c *gin.Context) {
	invitedBy := c.GetString("user_id")
	var req inviteStaffRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid invitation payload", "invalid_payload", err)
		return
	}

	inv, err := h.uc.InviteStaff(
		c.Request.Context(),
		req.RestaurantID,
		invitedBy,
		req.Email,
		req.Name,
		domain.UserRole(req.Role),
	)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "staff invitation sent", "data": inv})
}

func (h *StaffManagementHandler) AcceptInvitation(c *gin.Context) {
	userID := c.GetString("user_id")
	var req acceptInviteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid accept invitation payload", "invalid_payload", err)
		return
	}

	if err := h.uc.AcceptInvitation(c.Request.Context(), req.Token, userID); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "invitation accepted"})
}

func (h *StaffManagementHandler) RevokeInvitation(c *gin.Context) {
	requesterID := c.GetString("user_id")
	invitationID := c.Param("invitationId")

	if err := h.uc.RevokeInvitation(c.Request.Context(), invitationID, requesterID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "invitation revoked"})
}

func (h *StaffManagementHandler) ListInvitations(c *gin.Context) {
	restaurantID := c.Query("restaurantId")
	items, err := h.uc.ListInvitations(c.Request.Context(), restaurantID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "invitations fetched", "data": items})
}

func (h *StaffManagementHandler) RemoveStaff(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	staffID := c.Param("staffId")
	requesterID := c.GetString("user_id")

	if err := h.uc.RemoveStaff(c.Request.Context(), restaurantID, staffID, requesterID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "staff removed"})
}

func (h *StaffManagementHandler) GetRestaurantStaff(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	role := c.Query("role")
	users, err := h.uc.GetRestaurantStaff(c.Request.Context(), restaurantID, role)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "restaurant staff fetched", "data": dto.ToUserResponseList(users)})
}

func (h *StaffManagementHandler) GetMyAssignments(c *gin.Context) {
	userID := c.GetString("user_id")
	items, err := h.uc.GetMyRestaurantAssignments(c.Request.Context(), userID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "restaurant assignments fetched", "data": items})
}
