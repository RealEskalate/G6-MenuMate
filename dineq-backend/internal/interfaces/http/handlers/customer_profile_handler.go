package handler

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type CustomerProfileHandler struct {
	uc domain.ICustomerProfileUsecase
}

func NewCustomerProfileHandler(uc domain.ICustomerProfileUsecase) *CustomerProfileHandler {
	return &CustomerProfileHandler{uc: uc}
}

type recordVisitRequest struct {
	OrderAmount float64 `json:"orderAmount"`
}

type customerNoteRequest struct {
	Note string `json:"note" binding:"required"`
}

func (h *CustomerProfileHandler) GetOrCreate(c *gin.Context) {
	userID := c.Param("userId")
	restaurantID := c.Param("restaurantId")

	item, err := h.uc.GetOrCreateProfile(c.Request.Context(), userID, restaurantID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "customer profile fetched", "data": item})
}

func (h *CustomerProfileHandler) UpdateProfile(c *gin.Context) {
	profileID := c.Param("profileId")
	var req domain.CustomerRestaurantProfile
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid customer profile payload", "invalid_payload", err)
		return
	}
	req.ID = profileID

	if err := h.uc.UpdateProfile(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "customer profile updated"})
}

func (h *CustomerProfileHandler) GetByID(c *gin.Context) {
	item, err := h.uc.GetProfileByID(c.Request.Context(), c.Param("profileId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "customer profile fetched", "data": item})
}

func (h *CustomerProfileHandler) ListCustomers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	order, _ := strconv.Atoi(c.DefaultQuery("order", "-1"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := domain.CustomerProfileFilter{
		RestaurantID: c.Param("restaurantId"),
		Segment:      c.Query("segment"),
		LoyaltyTier:  c.Query("loyaltyTier"),
		Search:       c.Query("search"),
		Tag:          c.Query("tag"),
		Page:         page,
		PageSize:     pageSize,
		SortBy:       c.DefaultQuery("sortBy", "total_spent"),
		Order:        order,
	}

	items, total, err := h.uc.ListCustomers(c.Request.Context(), filter)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "customers fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *CustomerProfileHandler) RecordVisit(c *gin.Context) {
	var req recordVisitRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid visit payload", "invalid_payload", err)
		return
	}

	userID := c.Param("userId")
	restaurantID := c.Param("restaurantId")

	if err := h.uc.RecordVisit(c.Request.Context(), userID, restaurantID, req.OrderAmount); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "visit recorded"})
}

func (h *CustomerProfileHandler) AddNote(c *gin.Context) {
	profileID := c.Param("profileId")
	staffID := c.GetString("user_id")

	var req customerNoteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid note payload", "invalid_payload", err)
		return
	}

	if err := h.uc.AddCustomerNote(c.Request.Context(), profileID, req.Note, staffID); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "customer note added"})
}

func (h *CustomerProfileHandler) UpdateDietaryPreferences(c *gin.Context) {
	userID := c.GetString("user_id")
	var prefs domain.DietaryPreferences
	if err := c.ShouldBindJSON(&prefs); err != nil {
		dto.WriteValidationError(c, "payload", "invalid dietary preferences payload", "invalid_payload", err)
		return
	}

	if err := h.uc.UpdateDietaryPreferences(c.Request.Context(), userID, prefs); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "dietary preferences updated"})
}

func (h *CustomerProfileHandler) GetTopCustomers(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	items, err := h.uc.GetTopCustomers(c.Request.Context(), restaurantID, limit)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "top customers fetched", "data": items})
}

func (h *CustomerProfileHandler) GetAtRiskCustomers(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	items, err := h.uc.GetAtRiskCustomers(c.Request.Context(), restaurantID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "at risk customers fetched", "data": items})
}

func (h *CustomerProfileHandler) GetMyHistory(c *gin.Context) {
	userID := c.GetString("user_id")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	items, total, err := h.uc.GetCustomerHistory(c.Request.Context(), userID, page, pageSize)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "customer history fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}
