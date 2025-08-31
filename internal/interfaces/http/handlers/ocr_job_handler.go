package handler

import (
	"io"
	"net/http"
	"time"

	utils "github.com/dinq/menumate/Utils"
	"github.com/dinq/menumate/internal/domain"
	services "github.com/dinq/menumate/internal/infrastructure/service"
	"github.com/dinq/menumate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type OCRJobHandler struct {
	UseCase             domain.IOCRJobUseCase
	MenuUseCase         domain.IMenuUseCase
	StorageService      services.StorageService
	NotificationUseCase domain.INotificationUseCase

	// Worker         *services.Worker
}

func NewOCRJobHandler(uc domain.IOCRJobUseCase, mc domain.IMenuUseCase, stg services.StorageService, nc domain.INotificationUseCase) *OCRJobHandler {
	return &OCRJobHandler{UseCase: uc, MenuUseCase: mc, StorageService: stg, NotificationUseCase: nc}
}

// CreateOCRJob handles the creation of a new OCR job
func (h *OCRJobHandler) CreateOCRJob(c *gin.Context) {
	var OCRDto dto.OCRJobDTO
	if err := c.ShouldBindJSON(&OCRDto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := OCRDto.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	job := OCRDto.ToDomain()
	if err := h.UseCase.CreateOCRJob(job); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, OCRDto.FromDomain(job))
}

// GetOCRJobByID retrieves an OCR job by ID
func (h *OCRJobHandler) GetOCRJobByID(c *gin.Context) {
	id := c.Param("id")
	job, err := h.UseCase.GetOCRJobByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "OCR job not found"})
		return
	}
	jobDto := dto.OCRJobDTO{}
	c.JSON(http.StatusOK, jobDto.FromDomain(job))
}

// DeleteOCRJob marks an OCR job as deleted
func (h *OCRJobHandler) DeleteOCRJob(c *gin.Context) {
	id := c.Param("id")
	if err := h.UseCase.DeleteOCRJob(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "OCR job deleted"})
}

func (h *OCRJobHandler) UploadMenu(c *gin.Context) {
	userId := c.GetString("userId")

	if err := h.NotificationUseCase.SendNotificationFromRoute(c.Request.Context(), userId, "We're processing your menu. we'll let you know when it's done", domain.MenuUpload); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	var data []byte
	var fileName string

	file, err := c.FormFile("menuImage")
	if err == nil {
		f, err := file.Open()
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		defer f.Close()

		data, err = io.ReadAll(f)
		if err != nil {
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
			return
		}
		fileName = file.Filename
	} else if err != http.ErrMissingFile {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
		return
	} else {
		// No file uploaded, use default avatar or leave it empty
		data = nil
		fileName = ""
	}

	url, publicId, err := h.StorageService.UploadFile(c.Request.Context(), fileName, data, "menus")
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFileToUpload.Error(), Error: err.Error()})
		return
	}
	job := &domain.OCRJob{
		RestaurantID: utils.GenerateUUID(),
		ImageURL:     url,
		Status:       domain.OCRPending,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
	if err := h.UseCase.CreateOCRJob(job); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToCreateOCRJob.Error(), Error: err.Error()})
		return
	}
	// if the Ocr is successfull we should remove the menu photo on the storage
	if job.Status == domain.OCRCompleted {
		if err := h.StorageService.DeleteFile(c.Request.Context(), publicId); err != nil {
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToDeleteFile.Error(), Error: err.Error()})
			return
		}
	}

	// if menu creation successful let give it back the menu
	menu, err := h.MenuUseCase.GetMenuByID(job.StructuredMenuID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToGetMenu.Error(), Error: err.Error()})
		return
	}

	// send notification
	if err := h.NotificationUseCase.SendNotificationFromRoute(c.Request.Context(), userId, "Texts are extracted from the menu successfully", domain.MenuUpload); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrServerIssue.Error(), Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SuccessResponse{Message: domain.MsgSuccess, Data: dto.MenuToDTO(menu)})
}
