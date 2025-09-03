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
	EstimatedCompletion time.Time
	CompletedAt         *time.Time
	Results             *OCRJobResult // structured response for polling
	RawAIJSON           string // raw Gemini JSON for audit
	Phase              string
	Progress           int
	PhaseHistory       []OCRPhase
}

// OCRJobResult holds structured result fields returned to clients
type OCRJobResult struct {
	ExtractedText    string          `json:"extracted_text,omitempty"`
	PhotoMatches     []string        `json:"photo_matches,omitempty"`
	ConfidenceScore  float64         `json:"confidence_score,omitempty"`
	StructuredMenuID string          `json:"structured_menu_id,omitempty"`
	Menu             *Menu           `json:"menu,omitempty"`
	RawAIJSON        string          `json:"raw_ai_json,omitempty"`
}

// OCRPhase represents a pipeline phase status
type OCRPhase struct {
	Name      string     `bson:"name" json:"name"`
	Status    string     `bson:"status" json:"status"` // pending|running|done|failed
	StartedAt *time.Time `bson:"startedAt,omitempty" json:"started_at,omitempty"`
	EndedAt   *time.Time `bson:"endedAt,omitempty" json:"ended_at,omitempty"`
}

// Phase names constants
const (
	PhaseReceived      = "received"
	PhaseOCRExtraction = "ocr_extraction"
	PhaseAIStructuring = "ai_structuring"
	PhaseMenuPersist   = "menu_persist"
	PhaseCompleted     = "completed"
)

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
	ProcessJob(id string)
	DeleteOCRJob(id string) error
	RetryJob(id string) (*OCRJob, error)
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
