package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type WaiterLogHandler struct {
	uc domain.IWaiterLogUsecase
}

func NewWaiterLogHandler(uc domain.IWaiterLogUsecase) *WaiterLogHandler {
	return &WaiterLogHandler{uc: uc}
}

func (h *WaiterLogHandler) CreateLog(c *gin.Context) {
	var req domain.WaiterLog
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid waiter log payload", "invalid_payload", err)
		return
	}

	if req.WaiterID == "" {
		req.WaiterID = c.GetString("user_id")
	}

	if err := h.uc.CreateLog(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "waiter log created", "data": req})
}

func (h *WaiterLogHandler) UpdateLog(c *gin.Context) {
	logID := c.Param("logId")
	var req domain.WaiterLog
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid waiter log payload", "invalid_payload", err)
		return
	}
	req.ID = logID

	if err := h.uc.UpdateLog(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "waiter log updated"})
}

func (h *WaiterLogHandler) GetByID(c *gin.Context) {
	item, err := h.uc.GetLogByID(c.Request.Context(), c.Param("logId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "waiter log fetched", "data": item})
}

func (h *WaiterLogHandler) GetByOrderID(c *gin.Context) {
	item, err := h.uc.GetOrderLog(c.Request.Context(), c.Param("orderId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order waiter log fetched", "data": item})
}

func (h *WaiterLogHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := domain.WaiterLogFilter{
		RestaurantID: c.Query("restaurantId"),
		WaiterID:     c.Query("waiterId"),
		OrderID:      c.Query("orderId"),
		CustomerMood: c.Query("customerMood"),
		Page:         page,
		PageSize:     pageSize,
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

	items, total, err := h.uc.ListLogs(c.Request.Context(), filter)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "waiter logs fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *WaiterLogHandler) GetFoodInsights(c *gin.Context) {
	restaurantID := c.Param("restaurantId")
	period := c.DefaultQuery("period", "month")

	items, err := h.uc.GetFoodInsights(c.Request.Context(), restaurantID, period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "food insights fetched", "data": items})
}

func (h *WaiterLogHandler) GetWaiterStats(c *gin.Context) {
	waiterID := c.Param("waiterId")
	period := c.DefaultQuery("period", "month")

	item, err := h.uc.GetWaiterStats(c.Request.Context(), waiterID, period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "waiter stats fetched", "data": item})
}
