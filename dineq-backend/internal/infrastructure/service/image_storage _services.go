package services

import (
	"bytes"
	"context"
	"fmt"
	"image"
	_ "image/gif"  // Register GIF decoder (optional, for future)
	_ "image/jpeg" // Register JPEG decoder (optional, for future)
	_ "image/png"  // Register PNG decoder

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

type StorageService interface {
	UploadFile(ctx context.Context, fileName string, fileData []byte, folder string) (string, string, error)
	DeleteFile(ctx context.Context, publicID string) error
}
type CloudinaryStorage struct {
	client *cloudinary.Cloudinary
}

func NewCloudinaryStorage(cldName, apiKey, apiSecret string) StorageService {
	cld, err := cloudinary.NewFromParams(
		cldName,
		apiKey,
		apiSecret,
	)

	if err != nil {
		logger.Log.Fatal().Err(err).Msg("Failed to initialize Cloudinary")
		return nil
	}
	return &CloudinaryStorage{client: cld}
}

// UploadFile implements StorageService.
func (c *CloudinaryStorage) UploadFile(ctx context.Context, fileName string, fileData []byte, folder string) (string, string, error) {
	_, format, err := image.DecodeConfig(bytes.NewReader(fileData))
	if err != nil {
		return "", "", domain.ErrInvalidFile
	}
	if format != "jpeg" && format != "png" && format != "gif" {
		return "", "", fmt.Errorf("unsupported image format: %s", format)
	}

	folderDir := fmt.Sprintf("dineQ/%s", folder)

	isUnique := true
	uploadResult, err := c.client.Upload.Upload(ctx, bytes.NewReader(fileData), uploader.UploadParams{
		Folder:         folderDir,
		UniqueFilename: &isUnique,
	})
	if err != nil {
		return "", "", fmt.Errorf("failed to upload file: %w", err)
	}

	return uploadResult.SecureURL, uploadResult.PublicID, nil
}

// DeleteFile deletes a file from Cloudinary using its public ID.
func (c *CloudinaryStorage) DeleteFile(ctx context.Context, publicID string) error {
	destroyResult, err := c.client.Upload.Destroy(ctx, uploader.DestroyParams{
		PublicID: publicID,
	})
	if err != nil {
		return fmt.Errorf("failed to delete file: %w", err)
	}
	if destroyResult.Result != "ok" {
		return fmt.Errorf("failed to delete file: %v", destroyResult.Result)
	}
	return nil
}
