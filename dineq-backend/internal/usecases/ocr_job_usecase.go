package usecase

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
)

type OCRJobUseCase struct {
	repo       domain.IOCRJobRepository
	menuRepo   domain.IMenuRepository
	ocrService services.IOCRService
	aiService  services.IAIService
	ctxTimeout time.Duration
}

func NewOCRJobUseCase(repo domain.IOCRJobRepository, menuRepo domain.IMenuRepository, ocrService services.IOCRService, aiService services.IAIService, ctxTimeout time.Duration) domain.IOCRJobUseCase {
	return &OCRJobUseCase{repo: repo, menuRepo: menuRepo, ocrService: ocrService, aiService: aiService, ctxTimeout: ctxTimeout}
}

func (uc *OCRJobUseCase) CreateOCRJob(job *domain.OCRJob) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	job.CreatedAt = time.Now()
	job.UpdatedAt = time.Now()
	// naive estimate: 2 minutes from now (could refine using historical averages)
	job.EstimatedCompletion = job.CreatedAt.Add(2 * time.Minute)
	if job.Status == "" { job.Status = domain.OCRProcessing }
	return uc.repo.Create(ctx, job)
}

// ProcessJob performs the heavy OCR + AI work and updates the job record.
func (uc *OCRJobUseCase) ProcessJob(jobID string) {
	logger.Log.Info().Str("job_id", jobID).Msg("Starting OCR job processing")

	// Fetch job with a short context
	fetchCtx, cancelFetch := context.WithTimeout(context.Background(), uc.ctxTimeout)
	job, err := uc.repo.GetByID(fetchCtx, jobID)
	cancelFetch()
	if err != nil {
		logger.Log.Error().Str("job_id", jobID).Err(err).Msg("Failed to fetch job for processing")
		return
	}
	if job.Status == domain.OCRCompleted {
		logger.Log.Warn().Str("job_id", jobID).Msg("Job already completed; skipping")
		return
	}

	job.Status = domain.OCRProcessing
	job.Phase = domain.PhaseReceived
	job.Progress = 5
	appendPhase(job, domain.PhaseReceived, "done")
	job.UpdatedAt = time.Now()
	persistWithFallback(uc, job, "set processing")

	// OCR Stage
	ocrCtx, cancelOCR := context.WithTimeout(context.Background(), uc.ctxTimeout*4)
	text, err := uc.ocrService.ProcessDocumentURL(ocrCtx, job.ImageURL)
	cancelOCR()
	if err != nil {
		logger.Log.Error().Str("job_id", jobID).Err(err).Msg("OCR extraction failed")
		job.Status = domain.OCRFailed
		job.Error = err.Error()
		job.Phase = domain.PhaseOCRExtraction
		appendPhase(job, domain.PhaseOCRExtraction, "failed")
		job.UpdatedAt = time.Now()
		persistWithFallback(uc, job, "failed status (OCR stage)")
		return
	}
	logger.Log.Info().Str("job_id", jobID).Int("text_length", len(text.OCRText)).Msg("OCR extraction succeeded")
	job.Phase = domain.PhaseOCRExtraction
	appendPhase(job, domain.PhaseOCRExtraction, "done")
	job.Progress = 40
	persistWithFallback(uc, job, "phase ocr done")

	// AI Stage with small retry on timeout
	var menu *domain.Menu
	var aiErr error
	job.Phase = domain.PhaseAIStructuring
	appendPhase(job, domain.PhaseAIStructuring, "running")
	job.Progress = 50
	persistWithFallback(uc, job, "phase ai start")
	trimmed := slimOCRText(text.OCRText, 8000)
	for attempt := 1; attempt <= 2; attempt++ {
		base := 180 * time.Second
		if len(trimmed) > 6000 { base = 240 * time.Second }
		if len(trimmed) > 12000 { base = 300 * time.Second }
		if len(trimmed) > 18000 { base = 360 * time.Second }
		if len(trimmed) > 24000 { base = 390 * time.Second }
		aiCtx, cancelAI := context.WithTimeout(context.Background(), base)
		menu, aiErr = uc.aiService.StructureWithGemini(aiCtx, trimmed)
		cancelAI()
		if aiErr == nil { break }
		if errors.Is(aiErr, context.DeadlineExceeded) || strings.Contains(aiErr.Error(), "context deadline exceeded") {
			logger.Log.Warn().Str("job_id", jobID).Int("attempt", attempt).Err(aiErr).Msg("AI structuring timeout; retrying")
			continue
		}
		break
	}
	if aiErr != nil {
		logger.Log.Error().Str("job_id", jobID).Err(aiErr).Msg("AI structuring failed")
		job.Status = domain.OCRFailed
		job.Error = aiErr.Error()
		appendPhase(job, domain.PhaseAIStructuring, "failed")
		job.UpdatedAt = time.Now()
		persistWithFallback(uc, job, "failed status (AI stage)")
		return
	}
	logger.Log.Info().Str("job_id", jobID).Str("menu_id", menu.ID).Msg("AI structuring produced menu")
	appendPhase(job, domain.PhaseAIStructuring, "done")
	job.Progress = 75
	persistWithFallback(uc, job, "phase ai done")

	// Persist menu
	menuCtx, cancelMenu := context.WithTimeout(context.Background(), uc.ctxTimeout*2)
	if err := uc.menuRepo.Create(menuCtx, menu); err != nil {
		cancelMenu()
		logger.Log.Error().Str("job_id", jobID).Err(err).Msg("Failed to persist structured menu")
		job.Status = domain.OCRFailed
		job.Error = err.Error()
		job.Phase = domain.PhaseMenuPersist
		appendPhase(job, domain.PhaseMenuPersist, "failed")
		job.UpdatedAt = time.Now()
		persistWithFallback(uc, job, "failed status (menu persist stage)")
		return
	}
	cancelMenu()
	job.Phase = domain.PhaseMenuPersist
	appendPhase(job, domain.PhaseMenuPersist, "done")
	job.Progress = 90
	persistWithFallback(uc, job, "phase menu persisted")

	job.StructuredMenuID = menu.ID
	// capture raw AI JSON if available
	if gs, ok := uc.aiService.(*services.GeminiService); ok {
		job.RawAIJSON = gs.RawLastAIJSON()
	}
	job.Status = domain.OCRCompleted
	job.Phase = domain.PhaseCompleted
	appendPhase(job, domain.PhaseCompleted, "done")
	completed := time.Now()
	job.CompletedAt = &completed
	job.Results = &domain.OCRJobResult{ExtractedText: text.OCRText, StructuredMenuID: menu.ID, Menu: menu, RawAIJSON: job.RawAIJSON}
	job.UpdatedAt = time.Now()
	job.Progress = 100
	persistWithFallback(uc, job, "completed status")
	logger.Log.Info().Str("job_id", jobID).Str("menu_id", menu.ID).Msg("OCR job completed successfully")
}

// persistWithFallback tries to persist with a short context; on failure due to context or timeout it retries with a fresh background context.
func persistWithFallback(uc *OCRJobUseCase, job *domain.OCRJob, stage string) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	err := uc.repo.Update(ctx, job.ID, job)
	cancel()
	if err == nil { return }
	logger.Log.Error().Str("job_id", job.ID).Str("stage", stage).Err(err).Msg("Primary job update failed; attempting fallback")
	fbCtx, fbCancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	if err2 := uc.repo.Update(fbCtx, job.ID, job); err2 != nil {
		logger.Log.Error().Str("job_id", job.ID).Str("stage", stage).Err(err2).Msg("Fallback job update failed")
	} else {
		logger.Log.Info().Str("job_id", job.ID).Str("stage", stage).Msg("Fallback job update succeeded")
	}
	fbCancel()
}

// appendPhase updates or appends a phase record with status transitions and timestamps
func appendPhase(job *domain.OCRJob, phaseName, status string) {
	now := time.Now()
	for i := range job.PhaseHistory {
		if job.PhaseHistory[i].Name == phaseName {
			// update existing
			if job.PhaseHistory[i].StartedAt == nil { job.PhaseHistory[i].StartedAt = &now }
			if status == "done" || status == "failed" { job.PhaseHistory[i].EndedAt = &now }
			job.PhaseHistory[i].Status = status
			return
		}
	}
	ph := domain.OCRPhase{Name: phaseName, Status: status, StartedAt: &now}
	if status == "done" || status == "failed" { ph.EndedAt = &now }
	job.PhaseHistory = append(job.PhaseHistory, ph)
}

func (uc *OCRJobUseCase) UpdateOCRJobStatus(id string, status domain.OCRJobStatus) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	job, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	job.Status = status
	job.UpdatedAt = time.Now()
	return uc.repo.Update(ctx, id, job)
}

func (uc *OCRJobUseCase) GetOCRJobByID(id string) (*domain.OCRJob, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	return uc.repo.GetByID(ctx, id)
}

func (uc *OCRJobUseCase) DeleteOCRJob(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	return uc.repo.Delete(ctx, id)
}

// RetryJob resets a failed OCR job to processing and launches processing again.
func (uc *OCRJobUseCase) RetryJob(id string) (*domain.OCRJob, error) {
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout)
	defer cancel()
	job, err := uc.repo.GetByID(ctx, id)
	if err != nil { return nil, err }
	if job.Status != domain.OCRFailed {
		return nil, errors.New("only failed jobs can be retried")
	}
	// reset relevant fields but keep original image URL and user context
	job.Status = domain.OCRProcessing
	job.Error = ""
	job.Phase = domain.PhaseReceived
	job.Progress = 5
	job.PhaseHistory = nil
	job.CompletedAt = nil
	job.StructuredMenuID = ""
	job.Results = nil
	job.UpdatedAt = time.Now()
	job.EstimatedCompletion = time.Now().Add(2 * time.Minute)
	if err := uc.repo.Update(ctx, job.ID, job); err != nil { return nil, err }
	// async reprocess
	go uc.ProcessJob(job.ID)
	return job, nil
}

// slimOCRText truncates very large OCR text to maxChars, preserving start and end segments.
func slimOCRText(s string, maxChars int) string {
	if maxChars <= 0 || len(s) <= maxChars { return s }
	// keep 60% head, 40% tail
	head := int(float64(maxChars) * 0.6)
	tail := maxChars - head - 20 // allocate ellipsis marker length
	if tail < 0 { tail = 0 }
	if head > len(s) { head = len(s) }
	if tail > len(s)-head { tail = len(s) - head }
	return s[:head] + "\n...[TRUNCATED]...\n" + s[len(s)-tail:]
}
