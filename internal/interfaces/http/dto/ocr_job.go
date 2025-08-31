package dto

import (
	"fmt"
	"time"

	"github.com/dinq/menumate/internal/domain"
)

// OCRJobDTO represents the data transfer object for an OCRJob
type OCRJobDTO struct {
	ID               string    `json:"id"`
	RestaurantID     string    `json:"restaurantId"`
	ImageURL         string    `json:"imageUrl"`
	Status           string    `json:"status"`
	ResultText       string    `json:"resultText,omitempty"`
	StructuredMenuID string    `json:"structuredMenuId,omitempty"`
	Error            string    `json:"error,omitempty"`
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`
}

// Validate checks the OCRJobDTO for required fields
func (oj *OCRJobDTO) Validate() error {
	if oj.RestaurantID == "" || oj.ImageURL == "" || oj.Status == "" {
		return fmt.Errorf("ocrJob ID, restaurantID, imageURL, and status are required")
	}
	return nil
}

// ToDomain converts the OCRJobDTO to a domain.OCRJob entity
func (oj *OCRJobDTO) ToDomain() *domain.OCRJob {
	return &domain.OCRJob{
		ID:               oj.ID,
		RestaurantID:     oj.RestaurantID,
		ImageURL:         oj.ImageURL,
		Status:           domain.OCRJobStatus(oj.Status),
		ResultText:       oj.ResultText,
		StructuredMenuID: oj.StructuredMenuID,
		Error:            oj.Error,
		CreatedAt:        oj.CreatedAt,
		UpdatedAt:        oj.UpdatedAt,
	}
}

// FromDomain converts a domain.OCRJob entity to an OCRJobDTO
func (oj *OCRJobDTO) FromDomain(job *domain.OCRJob) *OCRJobDTO {
	return &OCRJobDTO{
		ID:               job.ID,
		RestaurantID:     job.RestaurantID,
		ImageURL:         job.ImageURL,
		Status:           string(job.Status),
		ResultText:       job.ResultText,
		StructuredMenuID: job.StructuredMenuID,
		Error:            job.Error,
		CreatedAt:        job.CreatedAt,
		UpdatedAt:        job.UpdatedAt,
	}
}
