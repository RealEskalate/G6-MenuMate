package usecase

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
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
	ctx, cancel := context.WithTimeout(context.Background(), uc.ctxTimeout*5)
	defer cancel()

	job.CreatedAt = time.Now()
	job.UpdatedAt = time.Now()

	// Step 1: OCR
	text, err := uc.ocrService.ProcessDocumentURL(ctx, job.ImageURL)
	if err != nil {
		job.Status = "failed"
		job.Error = err.Error()
		return err
	}

	fmt.Println("OCR Text:", text.OCRText)
	// fmt.Println("OCR OK:", job.ID)
	// sampleLineItem := scheme.LineItems{
	// 	[]scheme.LineItem{
	// 		{
	// 			ID:          1,
	// 			Type:        "cat-1",
	// 			Section:     "kitfo",
	// 			Description: "Delicious kitfo",
	// 			Price:       100,
	// 		},
	// 		{
	// 			ID:          2,
	// 			Type:        "cat-1",
	// 			Section:     "Burger",
	// 			Description: "Juicy beef burger",
	// 			Price:       150,
	// 		},
	// 		{
	// 			ID:          3,
	// 			Type:        "cat-3",
	// 			Section:     "Soda",
	// 			Description: "Refreshing soda",
	// 			Price:       15,
	// 		},
	// 	},
	// }

	// Step 2: AI Structuring
	menu, err := uc.aiService.StructureWithGemini(ctx, text.OCRText)

	if err != nil {
		job.Status = domain.OCRFailed
		job.Error = err.Error()
		return err
	}

	// Step 3: Save structured menu
	err = uc.menuRepo.Create(ctx, menu)
	if err != nil {
		job.Status = domain.OCRFailed
		job.Error = err.Error()
		return err
	}
	job.StructuredMenuID = menu.ID
	job.Status = domain.OCRCompleted

	if err := uc.repo.Create(ctx, job); err != nil {
		// delete structured menu if job creation fails
		uc.menuRepo.Delete(ctx, menu.ID)
		return err
	}

	return nil
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
