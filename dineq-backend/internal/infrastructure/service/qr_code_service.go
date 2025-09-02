package services

import (
	"bytes"
	"errors"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/jpeg"
	"image/png"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/google/uuid"
	"github.com/skip2/go-qrcode"
)

type QRService struct {
	qrDir   string
	baseURL string
}

func NewQRService() *QRService {
	qrDir := "./qr-codes"
	os.MkdirAll(qrDir, 0755)
	baseURL := os.Getenv("BASE_URL")
	if baseURL == "" {
		baseURL = "http://localhost:8080"
	}
	return &QRService{qrDir: qrDir, baseURL: baseURL}
}

// GenerateQRCode generates a QR code for a restaurant menu with optional customization
func (qs *QRService) GenerateQRCode(restaurantID string, request *domain.QRCodeRequest) (*dto.QRCodeResponse, error) {
	qrCodeID := uuid.New().String()
	publicMenuURL := fmt.Sprintf("%s/menu/%s", qs.baseURL, restaurantID)
	if request.Size <= 0 {
		request.Size = 256
	}
	if request.Format == "" {
		request.Format = "png"
	}
	if request.Format != "png" && request.Format != "jpg" && request.Format != "jpeg" {
		request.Format = "png"
	}

	filename := fmt.Sprintf("%s.%s", qrCodeID, request.Format)
	filePath := filepath.Join(qs.qrDir, filename)

	qrCode, err := qrcode.New(publicMenuURL, qrcode.Medium)
	if err != nil {
		return nil, fmt.Errorf("init qr: %w", err)
	}
	var fgCol, bgCol color.Color
	var haveColors bool
	if request.Customization != nil {
		if c, err := parseHexColor(request.Customization.ForegroundColor); err == nil {
			fgCol = c
			haveColors = true
		}
		if c, err := parseHexColor(request.Customization.BackgroundColor); err == nil {
			bgCol = c
			haveColors = true
		} else if haveColors {
			// default background if only fg provided
			bgCol = color.White
		}
	}
	img := qrCode.Image(request.Size)
	if haveColors {
		img = recolorQRImage(img, fgCol, bgCol)
	}
	if request.Customization != nil && request.Customization.Logo != "" {
		if logoImg, err := fetchLogoImage(request.Customization.Logo); err == nil {
			maxSide := request.Size / 4
			lb := logoImg.Bounds()
			lw, lh := lb.Dx(), lb.Dy()
			scale := 1.0
			if lw > maxSide || lh > maxSide {
				sx := float64(maxSide) / float64(lw)
				sy := float64(maxSide) / float64(lh)
				if sx < sy {
					scale = sx
				} else {
					scale = sy
				}
			}
			if scale < 1.0 {
				newW := int(float64(lw) * scale)
				newH := int(float64(lh) * scale)
				scaled := image.NewRGBA(image.Rect(0, 0, newW, newH))
				for y := 0; y < newH; y++ {
					for x := 0; x < newW; x++ {
						sx := int(float64(x) / scale)
						sy := int(float64(y) / scale)
						scaled.Set(x, y, logoImg.At(sx, sy))
					}
				}
				logoImg = scaled
				lb = logoImg.Bounds()
			}
			baseNRGBA, ok := img.(*image.NRGBA)
			if !ok {
				converted := image.NewNRGBA(img.Bounds())
				draw.Draw(converted, converted.Bounds(), img, image.Point{}, draw.Src)
				baseNRGBA = converted
			}
			offset := image.Pt((baseNRGBA.Bounds().Dx()-lb.Dx())/2, (baseNRGBA.Bounds().Dy()-lb.Dy())/2)
			// Draw white (or bg) square under logo for readability
			pad := 4
			bgRect := image.Rect(offset.X-pad, offset.Y-pad, offset.X+lb.Dx()+pad, offset.Y+lb.Dy()+pad)
			draw.Draw(baseNRGBA, bgRect, &image.Uniform{C: color.White}, image.Point{}, draw.Src)
			draw.Draw(baseNRGBA, lb.Add(offset), logoImg, image.Point{}, draw.Over)
			img = baseNRGBA
		}
	}
	f, err := os.Create(filePath)
	if err != nil {
		return nil, fmt.Errorf("create file: %w", err)
	}
	defer f.Close()
	switch request.Format {
	case "jpg", "jpeg":
		if err := jpeg.Encode(f, img, &jpeg.Options{Quality: 90}); err != nil {
			return nil, fmt.Errorf("jpeg encode: %w", err)
		}
	default:
		if err := png.Encode(f, img); err != nil {
			return nil, fmt.Errorf("png encode: %w", err)
		}
	}
	resp := &dto.QRCodeResponse{QRCodeID: qrCodeID, ImageURL: fmt.Sprintf("%s/qr/%s", qs.baseURL, filename), PublicMenuURL: publicMenuURL, DownloadURL: fmt.Sprintf("%s/qr/download/%s", qs.baseURL, qrCodeID), ExpiresAt: time.Now().Add(365 * 24 * time.Hour)}
	return resp, nil
}

func (qs *QRService) GetQRCodePath(filename string) string { return filepath.Join(qs.qrDir, filename) }

func parseHexColor(s string) (color.Color, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil, errors.New("empty color")
	}
	s = strings.TrimPrefix(s, "#")
	if len(s) != 6 {
		return nil, errors.New("invalid length")
	}
	var r, g, b uint8
	if _, err := fmt.Sscanf(s, "%02x%02x%02x", &r, &g, &b); err != nil {
		return nil, err
	}
	return color.NRGBA{R: r, G: g, B: b, A: 255}, nil
}

func fetchLogoImage(path string) (image.Image, error) {
	var rc io.ReadCloser
	var err error
	if strings.HasPrefix(strings.ToLower(path), "http://") || strings.HasPrefix(strings.ToLower(path), "https://") {
		resp, err := http.Get(path)
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusOK {
			resp.Body.Close()
			return nil, fmt.Errorf("logo fetch: %s", resp.Status)
		}
		rc = resp.Body
	} else {
		rc, err = os.Open(path)
		if err != nil {
			return nil, err
		}
	}
	defer rc.Close()
	buf, err := io.ReadAll(rc)
	if err != nil {
		return nil, err
	}
	if img, err := png.Decode(bytes.NewReader(buf)); err == nil {
		return img, nil
	}
	if img, err := jpeg.Decode(bytes.NewReader(buf)); err == nil {
		return img, nil
	}
	return nil, errors.New("unsupported logo image (png/jpg only)")
}

// recolorQRImage replaces black/white pixels with provided foreground/background colors.
// Assumes original QR image uses solid black modules on white background.
func recolorQRImage(src image.Image, fg, bg color.Color) image.Image {
	if fg == nil && bg == nil {
		return src
	}
	b := src.Bounds()
	dst := image.NewNRGBA(b)
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			r, g, bl, a := src.At(x, y).RGBA()
			// treat dark pixels as modules
			if a > 0 && r < 0x4000 && g < 0x4000 && bl < 0x4000 { // dark
				if fg != nil {
					dst.Set(x, y, fg)
				} else {
					dst.Set(x, y, src.At(x, y))
				}
			} else { // light
				if bg != nil {
					dst.Set(x, y, bg)
				} else {
					dst.Set(x, y, src.At(x, y))
				}
			}
		}
	}
	return dst
}
