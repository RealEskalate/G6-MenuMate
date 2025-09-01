package domain

import (
	"context"
	"time"
)

type OCRJob struct {
	ID               string
	RestaurantID     string
	UserID           string
	ImageURL         string
	Status           OCRJobStatus
	ResultText       string
	StructuredMenuID string
	Error            string
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

type OCRJobStatus string

const (
	OCRPending    OCRJobStatus = "pending"
	OCRProcessing OCRJobStatus = "processing"
	OCRCompleted  OCRJobStatus = "completed"
	OCRFailed     OCRJobStatus = "failed"
)

type IOCRJobUseCase interface {
	CreateOCRJob(job *OCRJob) error
	UpdateOCRJobStatus(id string, status OCRJobStatus) error
	GetOCRJobByID(id string) (*OCRJob, error)
	// ProcessOCRJob(id string) (*AIParseResult, error)
	DeleteOCRJob(id string) error
}

type IOCRJobRepository interface {
	Create(ctx context.Context, job *OCRJob) error
	Update(ctx context.Context, id string, job *OCRJob) error
	UpdateStatus(ctx context.Context, id, status string) error
	GetByID(ctx context.Context, id string) (*OCRJob, error)
	Delete(ctx context.Context, id string) error
	GetPendingJobs(ctx context.Context) ([]*OCRJob, error)
	GetUserFCMToken(userID string) string
}
