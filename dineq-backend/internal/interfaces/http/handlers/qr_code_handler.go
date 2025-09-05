package handler

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type QRCodeHandler struct {
	qrUsecase domain.IQRCodeUseCase
	notifUc   domain.INotificationUseCase
}

func NewQRCodeHandler(qrUsecase domain.IQRCodeUseCase, notifUc domain.INotificationUseCase) *QRCodeHandler {
	return &QRCodeHandler{
		qrUsecase: qrUsecase,
		notifUc:   notifUc,
	}
}

// change status
func (h *QRCodeHandler) UpdateQRCodeStatus(c *gin.Context) {
	restaurantId := c.Param("restaurant_slug")
	statusStr := c.Param("status")

	if restaurantId == "" {
		dto.WriteValidationError(c, "restaurant_slug", domain.ErrInvalidRequest.Error(), "invalid_request", errors.New("restaurant slug is required"))
		return
	}

	if statusStr == "" {
		dto.WriteValidationError(c, "status", domain.ErrInvalidRequest.Error(), "invalid_request", errors.New("status is required"))
		return
	}
	status, err := strconv.ParseBool(statusStr)
	if err != nil {
		dto.WriteValidationError(c, "status", domain.ErrInvalidRequest.Error(), "invalid_request", errors.New("invalid status value"))
		return
	}

	if err := h.qrUsecase.ChangeQRCodeStatus(restaurantId, status); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}

// Get qr code
func (h *QRCodeHandler) GetQRCode(c *gin.Context) {
	restaurantId := c.Param("restaurant_slug")
	if restaurantId == "" {
		dto.WriteValidationError(c, "restaurant_slug", domain.ErrInvalidRequest.Error(), "invalid_request", errors.New("restaurant id is required"))
		return
	}

	qrCode, err := h.qrUsecase.GetQRCodeByRestaurantId(restaurantId)
	if err != nil {
		if errors.Is(err, domain.ErrQRCodeNotFound) {
			dto.WriteError(c, domain.ErrQRCodeNotFound)
		} else {
			dto.WriteError(c, err)
		}
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"qr_code": qrCode}})
}

// Delete qr code
func (h *QRCodeHandler) DeleteQRCode(c *gin.Context) {
	restaurantId := c.Param("restaurant_slug")
	if restaurantId == "" {
		dto.WriteValidationError(c, "restaurant_slug", domain.ErrInvalidRequest.Error(), "invalid_request", errors.New("restaurant id is required"))
		return
	}

	if err := h.qrUsecase.DeleteQRCode(restaurantId); err != nil {
		if errors.Is(err, domain.ErrQRCodeNotFound) {
			dto.WriteError(c, domain.ErrQRCodeNotFound)
		} else {
			dto.WriteError(c, err)
		}
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgDeleted})
}
