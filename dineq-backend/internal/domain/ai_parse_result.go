package domain

import (
	"context"
	"time"
)

type ItemData struct {
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

type CategoryData struct {
	Name  string     `json:"name"`
	Items []ItemData `json:"items"`
}

type TabData struct {
	Name       string         `json:"name"`
	Categories []CategoryData `json:"categories"`
}

type StructuredData struct {
	Tabs []TabData `json:"tabs"`
}

type AIParseResult struct {
	ID              string         `json:"id"`
	OCRJobID        string         `json:"ocr_job_id"`
	RawText         string         `json:"raw_text"`
	StructuredData  StructuredData `json:"structured_data"`
	ConfidenceScore float64        `json:"confidence_score"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
}

type IAIParseResultUseCase interface {
	CreateAIParseResult(result *AIParseResult) error
	GetAIParseResultByID(id string) (*AIParseResult, error)
	ApproveParseResult(id string) error
	DeleteAIParseResult(id string) error
	StructureMenu(result *AIParseResult) (Menu, error)
}

type IAIParseResultRepository interface {
	Create(ctx context.Context, result *AIParseResult) error
	GetByID(ctx context.Context, id string) (*AIParseResult, error)
	Delete(ctx context.Context, id string) error
}
