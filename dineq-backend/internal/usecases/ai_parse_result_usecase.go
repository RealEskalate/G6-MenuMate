package usecase

// import (
// 	"context"
// 	"time"

// 	"github.com/RealEskalate/G6-MenuMate/internal/domain"
// 	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
// 	"github.com/veryfi/veryfi-go/veryfi/scheme"
// )

// type AIParseResultUseCase struct {
// 	repo      domain.IAIParseResultRepository
// 	aiService services.IAIService
// }

// func NewAIParseResultUseCase(repo domain.IAIParseResultRepository, aiService services.IAIService) *AIParseResultUseCase {
// 	return &AIParseResultUseCase{repo: repo, aiService: aiService}
// }

// func (uc *AIParseResultUseCase) CreateAIParseResult(ctx context.Context, result *domain.AIParseResult) error {
// 	result.CreatedAt = time.Now()
// 	result.UpdatedAt = time.Now()
// 	return uc.repo.Create(ctx, result)
// }

// func (uc *AIParseResultUseCase) GetAIParseResultByID(ctx context.Context, id string) (*domain.AIParseResult, error) {
// 	return uc.repo.GetByID(ctx, id)
// }

// func (uc *AIParseResultUseCase) ApproveParseResult(ctx context.Context, id string) error {
// 	result, err := uc.repo.GetByID(ctx, id)
// 	if err != nil {
// 		return err
// 	}
// 	// Add approval logic here
// 	result.UpdatedAt = time.Now()
// 	return uc.repo.Create(ctx, result)
// }

// func (uc *AIParseResultUseCase) DeleteAIParseResult(ctx context.Context, id string) error {
// 	result, err := uc.repo.GetByID(ctx, id)
// 	if err != nil {
// 		return err
// 	}
// 	result.UpdatedAt = time.Now()
// 	return uc.repo.Create(ctx, result)
// }

// func (uc *AIParseResultUseCase) StructureMenuItems(ctx context.Context, result *domain.AIParseResult) (*domain.Menu, error) {
// 	// Convert line items to MenuItem format using aiService
// 	lineItems := uc.parseLineItems(result.RawText) // Placeholder parsing
// 	menuItem, err := uc.aiService.StructureWithGemini(ctx, lineItems)
// 	if err != nil {
// 		return nil, err
// 	}
// 	return menuItem, nil
// }

// func (uc *AIParseResultUseCase) parseLineItems(rawText string) []scheme.LineItem {
// 	// Placeholder: Parse rawText into line items
// 	// This should be implemented based on Veryfi response structure
// 	return []scheme.LineItem{} // Replace with actual parsing logic
// }
