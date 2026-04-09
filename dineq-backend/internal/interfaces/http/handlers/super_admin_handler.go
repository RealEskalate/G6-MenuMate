package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type SuperAdminHandler struct {
	uc domain.ISuperAdminUsecase
}

func NewSuperAdminHandler(uc domain.ISuperAdminUsecase) *SuperAdminHandler {
	return &SuperAdminHandler{uc: uc}
}

type updateUserStatusRequest struct {
	Status string `json:"status" binding:"required"`
	Reason string `json:"reason"`
}

type updateUserRoleRequest struct {
	Role string `json:"role" binding:"required"`
}

type rejectRestaurantRequest struct {
	Reason string `json:"reason" binding:"required"`
}

type approveRestaurantRequest struct {
	Comment string `json:"comment"`
}

type deleteUserRequest struct {
	Reason string `json:"reason"`
}

type createUserRequest struct {
	Email     string `json:"email" binding:"required,email"`
	Username  string `json:"username" binding:"required"`
	Password  string `json:"password" binding:"required"`
	FullName  string `json:"fullName" binding:"required"`
	Role      string `json:"role" binding:"required"`
}

type updateRestaurantRequest struct {
	RestaurantName  string   `json:"restaurantName"`
	RestaurantPhone string   `json:"restaurantPhone"`
	Tags            []string `json:"tags"`
	PrimaryColor    string   `json:"primaryColor"`
	AccentColor     string   `json:"accentColor"`
}

func (h *SuperAdminHandler) CreateUser(c *gin.Context) {
	var req createUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid request payload", "invalid_payload", err)
		return
	}

	user := &domain.User{
		Email:    req.Email,
		Username: req.Username,
		Password: req.Password,
		FullName: req.FullName,
		Role:     domain.UserRole(req.Role),
	}

	adminID := c.GetString("user_id")
	err := h.uc.CreateUser(c.Request.Context(), adminID, user)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "user created", "data": dto.ToUserResponse(*user)})
}

func (h *SuperAdminHandler) GetPlatformAnalytics(c *gin.Context) {
	period := c.DefaultQuery("period", "month")
	data, err := h.uc.GetPlatformAnalytics(c.Request.Context(), period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "platform analytics fetched", "data": data})
}

func (h *SuperAdminHandler) ListUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	sortBy := c.DefaultQuery("sortBy", "createdAt")
	sortOrderStr := c.DefaultQuery("sortOrder", "-1")
	sortOrder, _ := strconv.Atoi(sortOrderStr)

	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	users, total, err := h.uc.GetAllUsers(c.Request.Context(), domain.UserFilter{
		Role:      c.Query("role"),
		Status:    c.Query("status"),
		Search:    c.Query("search"),
		Page:      page,
		PageSize:  pageSize,
		SortBy:    sortBy,
		SortOrder: sortOrder,
	})
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "users fetched",
		"data":      dto.ToUserResponseList(users),
		"total":     total,
		"page":      page,
		"pageSize":  pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *SuperAdminHandler) UpdateUserStatus(c *gin.Context) {
	userID := c.Param("userId")
	var req updateUserStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid request payload", "invalid_payload", err)
		return
	}

	adminID := c.GetString("user_id")
	err := h.uc.UpdateUserStatus(c.Request.Context(), adminID, userID, domain.UserStatus(req.Status), req.Reason)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user status updated"})
}

func (h *SuperAdminHandler) UpdateUserRole(c *gin.Context) {
	userID := c.Param("userId")
	var req updateUserRoleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid request payload", "invalid_payload", err)
		return
	}

	adminID := c.GetString("user_id")
	err := h.uc.UpdateUserRole(c.Request.Context(), adminID, userID, domain.UserRole(req.Role))
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user role updated"})
}

func (h *SuperAdminHandler) DeleteUser(c *gin.Context) {
	userID := c.Param("userId")
	adminID := c.GetString("user_id")

	var req deleteUserRequest
	_ = c.ShouldBindJSON(&req)

	err := h.uc.DeleteUser(c.Request.Context(), adminID, userID, req.Reason)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user deleted"})
}

func (h *SuperAdminHandler) PermanentDeleteUser(c *gin.Context) {
	userID := c.Param("userId")
	adminID := c.GetString("user_id")

	err := h.uc.PermanentDeleteUser(c.Request.Context(), adminID, userID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "user permanently deleted"})
}

func (h *SuperAdminHandler) ListRestaurants(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	sortBy := c.DefaultQuery("sortBy", "created")
	sortOrderStr := c.DefaultQuery("sortOrder", "-1")
	sortOrder, _ := strconv.Atoi(sortOrderStr)

	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	restaurants, total, err := h.uc.GetAllRestaurants(
		c.Request.Context(),
		page,
		pageSize,
		c.Query("status"),
		c.Query("search"),
		sortBy,
		sortOrder,
	)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "restaurants fetched",
		"data":       dto.ToRestaurantResponseList(restaurants),
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *SuperAdminHandler) ApproveRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	adminID := c.GetString("user_id")

	var req approveRestaurantRequest
	_ = c.ShouldBindJSON(&req)

	err := h.uc.ApproveRestaurant(c.Request.Context(), restaurantID, adminID, req.Comment)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "restaurant approved"})
}

func (h *SuperAdminHandler) RejectRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	adminID := c.GetString("user_id")

	var req rejectRestaurantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid request payload", "invalid_payload", err)
		return
	}

	err := h.uc.RejectRestaurant(c.Request.Context(), restaurantID, adminID, req.Reason)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "restaurant rejected"})
}

func (h *SuperAdminHandler) UpdateRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	var req updateRestaurantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid request payload", "invalid_payload", err)
		return
	}

	// Fetch existing first to avoid overwriting fields not in the request
	// But for simplicity in this console, we'll assume the request has what we want to update
	// or we just map what's provided.
	r := &domain.Restaurant{
		ID:              restaurantID,
		RestaurantName:  req.RestaurantName,
		RestaurantPhone: req.RestaurantPhone,
		Tags:            req.Tags,
		PrimaryColor:    req.PrimaryColor,
		AccentColor:     req.AccentColor,
	}

	adminID := c.GetString("user_id")
	err := h.uc.UpdateRestaurant(c.Request.Context(), adminID, r)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "restaurant updated"})
}

func (h *SuperAdminHandler) DeleteRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	adminID := c.GetString("user_id")

	err := h.uc.DeleteRestaurant(c.Request.Context(), restaurantID, adminID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "restaurant soft-deleted"})
}

func (h *SuperAdminHandler) PermanentDeleteRestaurant(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	adminID := c.GetString("user_id")

	err := h.uc.PermanentDeleteRestaurant(c.Request.Context(), restaurantID, adminID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "restaurant permanently deleted"})
}

func (h *SuperAdminHandler) GetPendingApprovals(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	items, total, err := h.uc.GetPendingApprovals(c.Request.Context(), page, pageSize)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "pending approvals fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *SuperAdminHandler) GetAuditLogs(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "50"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 50
	}

	filter := domain.AuditLogFilter{
		ActorID:    c.Query("actorId"),
		EntityType: c.Query("entityType"),
		EntityID:   c.Query("entityId"),
		Action:     c.Query("action"),
		Search:     c.Query("search"),
		Page:       page,
		PageSize:   pageSize,
	}

	if v := c.Query("dateFrom"); v != "" {
		if t, err := time.Parse(time.RFC3339, v); err == nil {
			filter.DateFrom = &t
		}
	}
	if v := c.Query("dateTo"); v != "" {
		if t, err := time.Parse(time.RFC3339, v); err == nil {
			filter.DateTo = &t
		}
	}

	items, total, err := h.uc.GetAuditLogs(c.Request.Context(), filter)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "audit logs fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}
