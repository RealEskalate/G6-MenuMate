package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type OrderHandler struct {
	uc domain.IOrderUsecase
}

func NewOrderHandler(uc domain.IOrderUsecase) *OrderHandler {
	return &OrderHandler{uc: uc}
}

type updateOrderStatusRequest struct {
	Status string `json:"status" binding:"required"`
}

func (h *OrderHandler) Create(c *gin.Context) {
	var req domain.Order
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid order payload", "invalid_payload", err)
		return
	}
	if req.WaiterID == "" {
		req.WaiterID = c.GetString("user_id")
	}
	if err := h.uc.CreateOrder(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "order created", "data": req})
}

func (h *OrderHandler) GetByID(c *gin.Context) {
	item, err := h.uc.GetOrderByID(c.Request.Context(), c.Param("orderId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order fetched", "data": item})
}

func (h *OrderHandler) Update(c *gin.Context) {
	var req domain.Order
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid order payload", "invalid_payload", err)
		return
	}
	req.ID = c.Param("orderId")
	if err := h.uc.UpdateOrder(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order updated"})
}

func (h *OrderHandler) UpdateStatus(c *gin.Context) {
	var req updateOrderStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid order status payload", "invalid_payload", err)
		return
	}
	waiterID := c.GetString("user_id")
	if err := h.uc.UpdateOrderStatus(c.Request.Context(), c.Param("orderId"), domain.OrderStatus(req.Status), waiterID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order status updated"})
}

func (h *OrderHandler) Delete(c *gin.Context) {
	requesterID := c.GetString("user_id")
	if err := h.uc.DeleteOrder(c.Request.Context(), c.Param("orderId"), requesterID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order deleted"})
}

func (h *OrderHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	filter := domain.OrderFilter{
		RestaurantID: c.Query("restaurantId"),
		WaiterID:     c.Query("waiterId"),
		CustomerID:   c.Query("customerId"),
		Status:       c.Query("status"),
		TableNumber:  c.Query("tableNumber"),
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

	items, total, err := h.uc.ListOrders(c.Request.Context(), filter)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "orders fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *OrderHandler) GetBySession(c *gin.Context) {
	items, err := h.uc.GetSessionOrders(c.Request.Context(), c.Param("sessionId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "session orders fetched", "data": items})
}

func (h *OrderHandler) GetRevenue(c *gin.Context) {
	restaurantID := c.Query("restaurantId")
	period := c.DefaultQuery("period", "month")
	value, err := h.uc.GetRestaurantRevenue(c.Request.Context(), restaurantID, period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "revenue fetched", "data": gin.H{"restaurantId": restaurantID, "period": period, "revenue": value}})
}

func (h *OrderHandler) GetOrderCount(c *gin.Context) {
	restaurantID := c.Query("restaurantId")
	period := c.DefaultQuery("period", "month")
	value, err := h.uc.GetRestaurantOrderCount(c.Request.Context(), restaurantID, period)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "order count fetched", "data": gin.H{"restaurantId": restaurantID, "period": period, "count": value}})
}
