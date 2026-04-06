package handler

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type TableSessionHandler struct {
	uc domain.ITableSessionUsecase
}

func NewTableSessionHandler(uc domain.ITableSessionUsecase) *TableSessionHandler {
	return &TableSessionHandler{uc: uc}
}

func (h *TableSessionHandler) Create(c *gin.Context) {
	var req domain.TableSession
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid table session payload", "invalid_payload", err)
		return
	}
	if req.WaiterID == "" {
		req.WaiterID = c.GetString("user_id")
	}

	if err := h.uc.CreateSession(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "table session created", "data": req})
}

func (h *TableSessionHandler) GetByID(c *gin.Context) {
	item, err := h.uc.GetSessionByID(c.Request.Context(), c.Param("sessionId"))
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "table session fetched", "data": item})
}

func (h *TableSessionHandler) Update(c *gin.Context) {
	var req domain.TableSession
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid table session payload", "invalid_payload", err)
		return
	}
	req.ID = c.Param("sessionId")

	if err := h.uc.UpdateSession(c.Request.Context(), &req); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "table session updated"})
}

func (h *TableSessionHandler) Close(c *gin.Context) {
	waiterID := c.GetString("user_id")
	if err := h.uc.CloseSession(c.Request.Context(), c.Param("sessionId"), waiterID); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "table session closed"})
}

func (h *TableSessionHandler) List(c *gin.Context) {
	restaurantID := c.Query("restaurantId")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}

	items, total, err := h.uc.ListSessions(c.Request.Context(), restaurantID, page, pageSize)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "table sessions fetched",
		"data":       items,
		"total":      total,
		"page":       page,
		"pageSize":   pageSize,
		"totalPages": (total + int64(pageSize) - 1) / int64(pageSize),
	})
}

func (h *TableSessionHandler) GetActiveByTable(c *gin.Context) {
	restaurantID := c.Query("restaurantId")
	tableNumber := c.Query("tableNumber")

	item, err := h.uc.GetActiveSessionByTable(c.Request.Context(), restaurantID, tableNumber)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "active table session fetched", "data": item})
}

func (h *TableSessionHandler) GetWaiterActive(c *gin.Context) {
	waiterID := c.Param("waiterId")
	if waiterID == "" || waiterID == "me" {
		waiterID = c.GetString("user_id")
	}
	items, err := h.uc.GetWaiterActiveSessions(c.Request.Context(), waiterID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "waiter active sessions fetched", "data": items})
}
