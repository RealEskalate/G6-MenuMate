package handler

import (
	"io"
	"net/http"
	"strings"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

// ImageUploadHandler handles generic image uploads (e.g., QR logos)
type ImageUploadHandler struct { Storage services.StorageService }

func NewImageUploadHandler(storage services.StorageService) *ImageUploadHandler { return &ImageUploadHandler{Storage: storage} }

func (h *ImageUploadHandler) UploadImage(c *gin.Context) {
    // Accept either 'image' or 'file'
    file, err := c.FormFile("image")
    if err != nil { file, err = c.FormFile("file") }
    if err != nil {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "image or file field required"})
        return
    }
    if file.Size == 0 || file.Size > 8*1024*1024 { // 8MB cap
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "file size invalid (max 8MB)"})
        return
    }
    fh, err := file.Open()
    if err != nil {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
        return
    }
    defer fh.Close()
    data, err := io.ReadAll(fh)
    if err != nil || len(data) == 0 {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "unable to read file"})
        return
    }
    ct := http.DetectContentType(data[:minIntLocal(512, len(data))])
    if !(strings.HasPrefix(ct, "image/")) {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "unsupported content type"})
        return
    }
    folder := c.PostForm("folder")
    if folder == "" { folder = c.Query("folder") }
    if folder == "" { folder = "general" }
    // sanitize folder (allow a-z0-9-_ only)
    cleaned := make([]rune, 0, len(folder))
    for _, r := range folder { if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') || r=='-' || r=='_' { cleaned = append(cleaned, r) } }
    if len(cleaned) == 0 { cleaned = []rune("general") }
    folder = string(cleaned)

    url, publicID, err := h.Storage.UploadFile(c.Request.Context(), file.Filename, data, folder)
    if err != nil {
        c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFileToUpload.Error(), Error: err.Error()})
        return
    }
    c.JSON(http.StatusCreated, gin.H{"success": true, "data": gin.H{"url": url, "public_id": publicID, "folder": folder, "content_type": ct, "bytes": file.Size}})
}

// Backwards compatibility alias (legacy /uploads/logo)
func (h *ImageUploadHandler) UploadLogo(c *gin.Context) { c.Request.Form.Add("folder", "qr-assets"); h.UploadImage(c) }

func minIntLocal(a,b int) int { if a < b { return a }; return b }