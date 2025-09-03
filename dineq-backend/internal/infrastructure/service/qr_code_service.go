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
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/disintegration/imaging"
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
		} else {
			log.Printf("Invalid foreground color '%s': %v", request.Customization.ForegroundColor, err)
			fgCol = color.Black // Default to black
		}
		if c, err := parseHexColor(request.Customization.BackgroundColor); err == nil {
			bgCol = c
			haveColors = true
		} else {
			log.Printf("Invalid background color '%s': %v", request.Customization.BackgroundColor, err)
			bgCol = color.White // Default to white
		}
	} else {
		fgCol = color.Black
		bgCol = color.White
	}

	img := qrCode.Image(request.Size)
	if haveColors {
		img = recolorQRImage(img, fgCol, bgCol)
	}

	if request.Customization != nil && request.Customization.Logo != "" {
		logoImg, err := fetchLogoImage(request.Customization.Logo)
		if err != nil {
			log.Printf("Failed to fetch logo '%s': %v", request.Customization.Logo, err)
			// Optionally return error: return nil, fmt.Errorf("fetch logo: %w", err)
		} else {
			log.Printf("Logo loaded: %dx%d", logoImg.Bounds().Dx(), logoImg.Bounds().Dy())
			// Configurable logo size (default: 25% of QR code size)
			logoSizePercent := 0.25
			if request.Customization.LogoSizePercent > 0 && request.Customization.LogoSizePercent <= 0.5 {
				logoSizePercent = request.Customization.LogoSizePercent
			}
			maxSide := int(float64(request.Size) * logoSizePercent)

			// Resize logo with high-quality scaling
			lb := logoImg.Bounds()
			if lb.Dx() > maxSide || lb.Dy() > maxSide {
				logoImg = imaging.Resize(logoImg, maxSide, 0, imaging.Lanczos)
				lb = logoImg.Bounds()
				log.Printf("Logo resized to: %dx%d", lb.Dx(), lb.Dy())
			}

			// Convert QR code to NRGBA
			baseNRGBA, ok := img.(*image.NRGBA)
			if !ok {
				converted := image.NewNRGBA(img.Bounds())
				draw.Draw(converted, converted.Bounds(), img, image.Point{}, draw.Src)
				baseNRGBA = converted
			}

			// Calculate logo position (centered)
			offset := image.Pt((baseNRGBA.Bounds().Dx()-lb.Dx())/2, (baseNRGBA.Bounds().Dy()-lb.Dy())/2)

			// Draw background square using QR background color
			pad := 4
			bgRect := image.Rect(offset.X-pad, offset.Y-pad, offset.X+lb.Dx()+pad, offset.Y+lb.Dy()+pad)
			draw.Draw(baseNRGBA, bgRect, &image.Uniform{C: bgCol}, image.Point{}, draw.Src)

			// Overlay logo
			draw.Draw(baseNRGBA, lb.Add(offset), logoImg, image.Point{}, draw.Over)
			img = baseNRGBA
		}
	}

	// Handle include_label (if needed, add label rendering logic here)
	if request.IncludeLabel {
		log.Printf("IncludeLabel is true, but label rendering is not implemented")
		// Add label rendering logic here (e.g., restaurant name or URL)
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

	resp := &dto.QRCodeResponse{
		QRCodeID:      qrCodeID,
		ImageURL:      fmt.Sprintf("%s/qr/%s", qs.baseURL, filename),
		PublicMenuURL: publicMenuURL,
		DownloadURL:   fmt.Sprintf("%s/qr/download/%s", qs.baseURL, qrCodeID),
		ExpiresAt:     time.Now().Add(365 * 24 * time.Hour),
	}
	return resp, nil
}

func (qs *QRService) GetQRCodePath(filename string) string {
	return filepath.Join(qs.qrDir, filename)
}

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
		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Get(path)
		if err != nil {
			return nil, fmt.Errorf("fetch logo from URL: %w", err)
		}
		if resp.StatusCode != http.StatusOK {
			resp.Body.Close()
			return nil, fmt.Errorf("logo fetch: %s", resp.Status)
		}
		rc = resp.Body
	} else {
		rc, err = os.Open(path)
		if err != nil {
			return nil, fmt.Errorf("open local logo file: %w", err)
		}
	}
	defer rc.Close()

	buf, err := io.ReadAll(rc)
	if err != nil {
		return nil, fmt.Errorf("read logo image: %w", err)
	}

	// Try decoding as PNG
	if img, err := png.Decode(bytes.NewReader(buf)); err == nil {
		return img, nil
	}
	// Try decoding as JPEG
	if img, err := jpeg.Decode(bytes.NewReader(buf)); err == nil {
		return img, nil
	}

	return nil, errors.New("unsupported logo image format (png/jpeg only)")
}

func recolorQRImage(src image.Image, fg, bg color.Color) image.Image {
	b := src.Bounds()
	dst := image.NewNRGBA(b)
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			r, g, bl, a := src.At(x, y).RGBA()
			if a > 0 && r < 0x4000 && g < 0x4000 && bl < 0x4000 { // dark
				dst.Set(x, y, fg)
			} else { // light
				dst.Set(x, y, bg)
			}
		}
	}
	return dst
}
