package services

import (
	"context"
	"log"

	"github.com/veryfi/veryfi-go/veryfi"
	"github.com/veryfi/veryfi-go/veryfi/scheme"
)

type IOCRService interface {
	ProcessDocumentURL(ctx context.Context, url string) (*scheme.Document, error)
}

type OcrService struct {
	client *veryfi.Client
}

func NewOCRService(options *veryfi.Options) IOCRService {
	client, err := veryfi.NewClientV8(&veryfi.Options{
		ClientID:     options.ClientID,
		ClientSecret: options.ClientSecret,
		APIKey:       options.APIKey,
		Username:     options.Username,
	})
	if err != nil {
		log.Fatal(err)
	}
	return &OcrService{client: client}
}

func (s *OcrService) ProcessDocumentURL(ctx context.Context, url string) (*scheme.Document, error) {
	resp, err := s.client.ProcessDocumentURL(scheme.DocumentURLOptions{
		FileURL: url,
	})
	if err != nil {
		return nil, err
	}
	return resp, nil
}
