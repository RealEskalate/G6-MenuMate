package handler

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type CRMHandler struct {
	uc domain.ICRMUsecase
}

func NewCRMHandler(uc domain.ICRMUsecase) *CRMHandler {
	return &CRMHandler{uc: uc}
}

func (h *CRMHandler) GetDashboard(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	period := c.DefaultQuery("period", "month")

	data, err := h.uc.GetDashboard(c.Request.Context(), restaurantID, period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "crm dashboard fetched", "data": data})
}

func (h *CRMHandler) GetCustomerList(c *gin.Context) {
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

	items, total, err := h.uc.GetCustomerList(c.Request.Context(), filter)
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

func (h *CRMHandler) GetCustomerDetail(c *gin.Context) {
	profileID := c.Param("profileId")
	item, err := h.uc.GetCustomerDetail(c.Request.Context(), profileID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "customer detail fetched", "data": item})
}

func (h *CRMHandler) ExportCustomerData(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	rows, err := h.uc.ExportCustomerData(c.Request.Context(), restaurantID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "crm export generated", "data": rows, "count": len(rows)})
}
