package utils

import (
	"bytes"
	context "context"
	"fmt"
	"mime"
	"os"
	"path/filepath"
	"strings"
	"time"

	cloudinary "github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

// UploadResult encapsulates the essential data returned after upload
type UploadResult struct {
	URL      string
	SecureURL string
	PublicID string
	Format   string
	Bytes    int64
}

// CloudinaryUploader provides a simple wrapper around cloudinary-go for QR image uploads
// It expects the following env vars to be set:
//   CLOUDINARY_CLOUD_NAME
//   CLOUDINARY_API_KEY
//   CLOUDINARY_API_SECRET
// Optionally CLOUDINARY_UPLOAD_FOLDER (defaults to "qr_codes")
func UploadToCloudinary(localPath string) (*UploadResult, error) {
	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	apiKey := os.Getenv("CLOUDINARY_API_KEY")
	apiSecret := os.Getenv("CLOUDINARY_API_SECRET")
	if cloudName == "" || apiKey == "" || apiSecret == "" {
		return nil, fmt.Errorf("cloudinary credentials missing env vars")
	}

	cld, err := cloudinary.NewFromParams(cloudName, apiKey, apiSecret)
	if err != nil {
		return nil, fmt.Errorf("init cloudinary: %w", err)
	}

	folder := os.Getenv("CLOUDINARY_UPLOAD_FOLDER")
	if folder == "" { folder = "qr_codes" }

	fileInfo, err := os.Stat(localPath)
	if err != nil { return nil, fmt.Errorf("stat file: %w", err) }
	if fileInfo.IsDir() { return nil, fmt.Errorf("path is a directory, not a file") }

	ext := strings.TrimPrefix(filepath.Ext(localPath), ".")
	if ext == "" { ext = "png" }
	mimeType := mime.TypeByExtension("." + ext)
	_ = mimeType // currently unused but could be validated

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	overw := true
	uniq := true
	upResp, err := cld.Upload.Upload(ctx, localPath, uploader.UploadParams{
		Folder: folder,
		Overwrite: &overw,
		UniqueFilename: &uniq,
		ResourceType: "image",
	})
	if err != nil { return nil, fmt.Errorf("upload: %w", err) }

	return &UploadResult{
		URL: upResp.URL,
		SecureURL: upResp.SecureURL,
		PublicID: upResp.PublicID,
		Format: upResp.Format,
		Bytes: int64(upResp.Bytes),
	}, nil
}

// UploadBytesToCloudinary uploads raw image bytes (e.g., generated in-memory) to Cloudinary
// filename is used to derive extension & optional public id.
func UploadBytesToCloudinary(data []byte, filename string) (*UploadResult, error) {
	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	apiKey := os.Getenv("CLOUDINARY_API_KEY")
	apiSecret := os.Getenv("CLOUDINARY_API_SECRET")
	if cloudName == "" || apiKey == "" || apiSecret == "" {
		return nil, fmt.Errorf("cloudinary credentials missing env vars")
	}
	cld, err := cloudinary.NewFromParams(cloudName, apiKey, apiSecret)
	if err != nil { return nil, fmt.Errorf("init cloudinary: %w", err) }
	folder := os.Getenv("CLOUDINARY_UPLOAD_FOLDER")
	if folder == "" { folder = "qr_codes" }
	ext := strings.ToLower(filepath.Ext(filename))
	if ext == "" { ext = ".png" }
	publicID := strings.TrimSuffix(filename, ext)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	overw := true
	uniq := false // we control public id
	upResp, err := cld.Upload.Upload(ctx, bytes.NewReader(data), uploader.UploadParams{
		Folder: folder,
		PublicID: publicID,
		Overwrite: &overw,
		UniqueFilename: &uniq,
		ResourceType: "image",
		FilenameOverride: filename,
	})
	if err != nil { return nil, fmt.Errorf("upload bytes: %w", err) }
	return &UploadResult{
		URL: upResp.URL,
		SecureURL: upResp.SecureURL,
		PublicID: upResp.PublicID,
		Format: upResp.Format,
		Bytes: int64(upResp.Bytes),
	}, nil
}
