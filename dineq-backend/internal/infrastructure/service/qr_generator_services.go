package services

import (
	"bytes"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/gif"
	"image/jpeg"
	"image/png"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/disintegration/imaging"
	"github.com/skip2/go-qrcode"
)

type QRGeneratorService struct {
	Content string
}

func NewQRGenerator(content string) *QRGeneratorService {
	return &QRGeneratorService{Content: content}
}

// SaveImageAsUserFormat saves the image to the specified path in the given format (e.g., "png", "jpeg", "gif")
func (g *QRGeneratorService) SaveImageAsUserFormat(img image.Image, format string) (bytes.Buffer, error) {
	var buf bytes.Buffer

	switch strings.ToLower(format) {
	case "png":
		if err := png.Encode(&buf, img); err != nil {
			return buf, fmt.Errorf("failed to encode image: %w", err)
		}
	case "jpeg", "jpg":
		if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: 90}); err != nil {
			return buf, fmt.Errorf("failed to encode image: %w", err)
		}
		return buf, nil
	case "gif":
		if err := gif.Encode(&buf, img, nil); err != nil {
			return buf, fmt.Errorf("failed to encode image: %w", err)
		}
	default:
		return buf, fmt.Errorf("unsupported image format: %s", format)
	}
	return buf, nil
}

// GenerateGradientQRWithLogo draws a gradient QR and overlays a logo at center.
func (g *QRGeneratorService) GenerateGradientQRWithLogo(cfg *domain.QRConfig) (image.Image, error) {
	handleEmptyFields(cfg)
	start, err := hexToRGBA(cfg.Start)
	if err != nil {
		return nil, err
	}
	end, err := hexToRGBA(cfg.End)
	if err != nil {
		return nil, err
	}
	if cfg.LogoScale <= 0 || cfg.LogoScale >= 0.4 {
		cfg.LogoScale = 0.20
	}

	qr, err := qrcode.New(g.Content, qrcode.Highest)
	if err != nil {
		return nil, err
	}

	matrix := qr.Bitmap()
	n := len(matrix)
	if n == 0 {
		return nil, err
	}

	size := cfg.Size
	moduleSizeF := float64(size) / float64(n)

	canvas := image.NewRGBA(image.Rect(0, 0, size, size))

	// fill background white
	draw.Draw(canvas, canvas.Bounds(), &image.Uniform{color.White}, image.Point{}, draw.Src)

	// draw modules with vertical gradient
	for y := 0; y < n; y++ {
		t := float64(y) / float64(n-1)
		r := uint8(float64(start.R)*(1-t) + float64(end.R)*t)
		g := uint8(float64(start.G)*(1-t) + float64(end.G)*t)
		b := uint8(float64(start.B)*(1-t) + float64(end.B)*t)
		col := color.RGBA{r, g, b, 255}

		for x := 0; x < n; x++ {
			if !matrix[y][x] {
				continue
			}
			x0 := int(float64(x) * moduleSizeF)
			y0 := int(float64(y) * moduleSizeF)
			x1 := int(float64(x+1) * moduleSizeF)
			y1 := int(float64(y+1) * moduleSizeF)
			rect := image.Rect(x0, y0, x1, y1)
			draw.Draw(canvas, rect, &image.Uniform{col}, image.Point{}, draw.Src)
		}
	}

	// load logo image from URL or path
	var logo image.Image
	if cfg.LogoURL != "" {
		client := &http.Client{Timeout: 15 * time.Second}
		resp, err := client.Get(cfg.LogoURL)
		if err != nil {
			return canvas, err
		}
		defer resp.Body.Close()

		img, err := imaging.Decode(resp.Body)
		if err != nil {
			return canvas, err
		}
		logo = img
	} else {
		return canvas, nil
	}
	// add this elif block to handle missing logo
	// else if cfg.LogoPath != "" {
	// 	img, err := imaging.Open(cfg.LogoPath)
	// 	if err != nil {
	// 		return canvas, err
	// 	}
	// 	logo = img
	// }

	// resize logo
	logoTarget := int(cfg.LogoScale * float64(size))
	if logoTarget < 32 {
		logoTarget = 32
	}
	logo = imaging.Fit(logo, logoTarget, logoTarget, imaging.Lanczos)

	// draw optional white rectangle behind logo
	cx := size / 2
	cy := size / 2

	if cfg.WhiteBg {
		padding := int(0.06 * float64(logoTarget))
		bgW := logo.Bounds().Dx() + 2*padding
		bgH := logo.Bounds().Dy() + 2*padding
		bgMinX := cx - bgW/2
		bgMinY := cy - bgH/2
		bgRect := image.Rect(bgMinX, bgMinY, bgMinX+bgW, bgMinY+bgH)
		draw.Draw(canvas, bgRect, &image.Uniform{color.White}, image.Point{}, draw.Over)
	}

	// overlay logo at center
	logoMinX := cx - logo.Bounds().Dx()/2
	logoMinY := cy - logo.Bounds().Dy()/2
	targetRect := image.Rect(logoMinX, logoMinY, logoMinX+logo.Bounds().Dx(), logoMinY+logo.Bounds().Dy())
	draw.Draw(canvas, targetRect, logo, image.Point{0, 0}, draw.Over)

	return canvas, nil
}

func hexToRGBA(hex string) (color.RGBA, error) {
	hex = strings.TrimPrefix(hex, "#")
	if len(hex) != 6 && len(hex) != 8 {
		return color.RGBA{}, fmt.Errorf("invalid hex color: %s", hex)
	}

	r, err := strconv.ParseUint(hex[0:2], 16, 8)
	if err != nil {
		return color.RGBA{}, err
	}
	g, err := strconv.ParseUint(hex[2:4], 16, 8)
	if err != nil {
		return color.RGBA{}, err
	}
	b, err := strconv.ParseUint(hex[4:6], 16, 8)
	if err != nil {
		return color.RGBA{}, err
	}
	if len(hex) == 8 {
		// RGBA
		a, err := strconv.ParseUint(hex[6:8], 16, 8)
		if err != nil {
			return color.RGBA{}, err
		}
		return color.RGBA{uint8(r), uint8(g), uint8(b), uint8(a)}, nil
	} else if len(hex) == 6 {
		// RGB
		return color.RGBA{uint8(r), uint8(g), uint8(b), 255}, nil
	}
	return color.RGBA{}, fmt.Errorf("invalid hex color: %s", hex)
}
func handleEmptyFields(cfg *domain.QRConfig) {

	// handle empty fields
	if cfg.Size == 0 {
		cfg.Size = 1024
	}
	if cfg.LogoScale == 0.0 {
		cfg.LogoScale = 0.20
	}
	if cfg.Format == "" {
		cfg.Format = "png"
	}
	if cfg.Start == "" {
		cfg.Start = "#000000"
	}
	if cfg.End == "" {
		cfg.End = "#000000"
	}
	if cfg.WhiteBg {
		cfg.WhiteBg = true
	}
}
