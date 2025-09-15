package dto

import (
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type ItemDataDTO struct {
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

type CategoryDataDTO struct {
	Name  string        `json:"name"`
	Items []ItemDataDTO `json:"items"`
}

type TabDataDTO struct {
	Name       string            `json:"name"`
	Categories []CategoryDataDTO `json:"categories"`
}

type StructuredDataDTO struct {
	Tabs []TabDataDTO `json:"tabs"`
}

type AIParseResultDTO struct {
	ID              string            `json:"id"`
	OCRJobID        string            `json:"ocr_job_id"`
	RawText         string            `json:"raw_text"`
	StructuredData  StructuredDataDTO `json:"structured_data"`
	ConfidenceScore float64           `json:"confidence_score"`
	CreatedAt       time.Time         `json:"created_at"`
	UpdatedAt       time.Time         `json:"updated_at"`
}

type MenuItemDTO struct {
	Category               string            `json:"category"`
	DescriptionEnglish     string            `json:"description_english"`
	MoreDescriptionEnglish string            `json:"more_description_english"`
	DescriptionAmharic     string            `json:"description_amharic"`
	MoreDescriptionAmharic string            `json:"more_description_amharic"`
	Price                  map[string]string `json:"price"`
	ImageURL               string            `json:"image_url"`
}

func (apr *AIParseResultDTO) Validate() error {
	if apr.OCRJobID == "" || apr.RawText == "" {
		return fmt.Errorf("aiParseResult ID, ocrJobID, and rawText are required")
	}
	// Optional: Validate structured data if present
	if len(apr.StructuredData.Tabs) > 0 {
		for _, tab := range apr.StructuredData.Tabs {
			if tab.Name == "" {
				return fmt.Errorf("tab name is required if structured data is provided")
			}
		}
	}
	return nil
}

// ToDomain converts the AIParseResultDTO to a domain.AIParseResult entity
func (apr *AIParseResultDTO) ToDomain() *domain.AIParseResult {
	tabs := make([]domain.TabData, len(apr.StructuredData.Tabs))
	for i, tabDTO := range apr.StructuredData.Tabs {
		categories := make([]domain.CategoryData, len(tabDTO.Categories))
		for j, catDTO := range tabDTO.Categories {
			items := make([]domain.ItemData, len(catDTO.Items))
			for k, itemDTO := range catDTO.Items {
				items[k] = domain.ItemData{
					Name:  itemDTO.Name,
					Price: itemDTO.Price,
				}
			}
			categories[j] = domain.CategoryData{
				Name:  catDTO.Name,
				Items: items,
			}
		}
		tabs[i] = domain.TabData{
			Name:       tabDTO.Name,
			Categories: categories,
		}
	}
	return &domain.AIParseResult{
		ID:       apr.ID,
		OCRJobID: apr.OCRJobID,
		RawText:  apr.RawText,
		StructuredData: domain.StructuredData{
			Tabs: tabs,
		},
		ConfidenceScore: apr.ConfidenceScore,
		CreatedAt:       apr.CreatedAt,
		UpdatedAt:       apr.UpdatedAt,
	}
}

// FromDomain converts a domain.AIParseResult entity to an AIParseResultDTO
func (apr *AIParseResultDTO) FromDomain(result *domain.AIParseResult) *AIParseResultDTO {
	tabs := make([]TabDataDTO, len(result.StructuredData.Tabs))
	for i, tab := range result.StructuredData.Tabs {
		categories := make([]CategoryDataDTO, len(tab.Categories))
		for j, cat := range tab.Categories {
			items := make([]ItemDataDTO, len(cat.Items))
			for k, item := range cat.Items {
				items[k] = ItemDataDTO{
					Name:  item.Name,
					Price: item.Price,
				}
			}
			categories[j] = CategoryDataDTO{
				Name:  cat.Name,
				Items: items,
			}
		}
		tabs[i] = TabDataDTO{
			Name:       tab.Name,
			Categories: categories,
		}
	}
	return &AIParseResultDTO{
		ID:       result.ID,
		OCRJobID: result.OCRJobID,
		RawText:  result.RawText,
		StructuredData: StructuredDataDTO{
			Tabs: tabs,
		},
		ConfidenceScore: result.ConfidenceScore,
		CreatedAt:       result.CreatedAt,
		UpdatedAt:       result.UpdatedAt,
	}
}
