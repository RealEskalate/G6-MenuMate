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
	OCRJobID        string         `json:"ocrJobId"`
	RawText         string         `json:"rawText"`
	StructuredData  StructuredData `json:"structuredData"`
	ConfidenceScore float64        `json:"confidenceScore"`
	CreatedAt       time.Time      `json:"createdAt"`
	UpdatedAt       time.Time      `json:"updatedAt"`
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
