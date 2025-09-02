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
	restaurantId := c.Param("restaurant_id")
	statusStr := c.Query("status")

	if restaurantId == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Restaurant ID is required"})
		return
	}

	if statusStr == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Status is required"})
		return
	}
	status, err := strconv.ParseBool(statusStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Invalid status value"})
		return
	}

	if err := h.qrUsecase.ChangeQRCodeStatus(restaurantId, status); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToUpdateQRStatus.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgUpdated})
}

// Get qr code
func (h *QRCodeHandler) GetQRCode(c *gin.Context) {
	restaurantId := c.Param("restaurant_id")
	if restaurantId == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Restaurant ID is required"})
		return
	}

	qrCode, err := h.qrUsecase.GetQRCodeByRestaurantId(restaurantId)
	if err != nil {
		if errors.Is(err, domain.ErrQRCodeNotFound) {
			c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrQRCodeNotFound.Error(), Error: err.Error()})
		} else {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToGetQRCode.Error(), Error: err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: gin.H{"qr_code": qrCode}})
}

// Delete qr code
func (h *QRCodeHandler) DeleteQRCode(c *gin.Context) {
	restaurantId := c.Param("restaurant_id")
	if restaurantId == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidRequest.Error(), Error: "Restaurant ID is required"})
		return
	}

	if err := h.qrUsecase.DeleteQRCode(restaurantId); err != nil {
		if errors.Is(err, domain.ErrQRCodeNotFound) {
			c.JSON(http.StatusNotFound, dto.ErrorResponse{Message: domain.ErrQRCodeNotFound.Error(), Error: err.Error()})
		} else {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToDeleteQRCode.Error(), Error: err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgDeleted})
}
