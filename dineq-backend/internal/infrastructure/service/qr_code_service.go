package services

import (
	"bytes"
	"errors"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/gif"
	"image/jpeg"
	"image/png"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/golang/freetype/truetype"
	"golang.org/x/image/font"
	"golang.org/x/image/font/basicfont"
	"golang.org/x/image/math/fixed"

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
	if request.Format != "png" && request.Format != "jpg" && request.Format != "jpeg" && request.Format != "gif" {
		request.Format = "png"
	}
	if request.Quality <= 0 || request.Quality > 100 { request.Quality = 90 }

	filename := fmt.Sprintf("%s.%s", qrCodeID, request.Format)
	filePath := filepath.Join(qs.qrDir, filename)

	// Determine error correction level
	level := qrcode.Medium
	if request.Customization != nil && request.Customization.ErrorCorrection != "" {
		switch strings.ToUpper(request.Customization.ErrorCorrection) {
		case "L": level = qrcode.Low
		case "M": level = qrcode.Medium
		case "Q": level = qrcode.Medium // fallback (library lacks Quartile)
		case "H": level = qrcode.High
		}
	}
	qrCode, err := qrcode.New(publicMenuURL, level)
	if err != nil {
		return nil, fmt.Errorf("init qr: %w", err)
	}

	var fgCol, bgCol color.Color
	var haveColors bool
	var gradientFrom, gradientTo color.Color
	var haveGradient bool
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
		// Gradient (optional)
		if request.Customization.GradientFrom != "" && request.Customization.GradientTo != "" {
			gf, errF := parseHexColor(request.Customization.GradientFrom)
			gt, errT := parseHexColor(request.Customization.GradientTo)
			if errF == nil && errT == nil {
				gradientFrom = gf
				gradientTo = gt
				haveGradient = true
			}
		}
	} else {
		fgCol = color.Black
		bgCol = color.White
	}

	img := qrCode.Image(request.Size)
	// Optional margin padding
	if request.Customization != nil && request.Customization.Margin > 0 {
		m := request.Customization.Margin
		bg := image.NewNRGBA(image.Rect(0, 0, img.Bounds().Dx()+2*m, img.Bounds().Dy()+2*m))
		var fillCol color.Color = color.White
		if c, err := parseHexColor(request.Customization.BackgroundColor); err == nil { fillCol = c }
		draw.Draw(bg, bg.Bounds(), &image.Uniform{C: fillCol}, image.Point{}, draw.Src)
		draw.Draw(bg, img.Bounds().Add(image.Pt(m, m)), img, image.Point{}, draw.Src)
		img = bg
	}
	if haveColors {
		if haveGradient {
			img = applyGradientColoring(img, bgCol, gradientFrom, gradientTo, strings.ToLower(request.Customization.GradientDirection) == "vertical")
		} else {
			img = recolorQRImage(img, fgCol, bgCol)
		}
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
			if request.Customization.LogoSizePercent > 0 && request.Customization.LogoSizePercent <= 0.6 {
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
			if request.Customization.LogoBackgroundPadding > 0 { pad = request.Customization.LogoBackgroundPadding }
			bgColor := bgCol
			if request.Customization.LogoBackgroundColor != "" { if c, err := parseHexColor(request.Customization.LogoBackgroundColor); err == nil { bgColor = c } }
			if request.Customization.LogoBackground { // draw background box only when enabled
				bgRect := image.Rect(offset.X-pad, offset.Y-pad, offset.X+lb.Dx()+pad, offset.Y+lb.Dy()+pad)
				draw.Draw(baseNRGBA, bgRect, &image.Uniform{C: bgColor}, image.Point{}, draw.Src)
			}

			// Optional tint/opacity & advanced blending for PNG logos
			logoNRGBA := image.NewNRGBA(logoImg.Bounds())
			draw.Draw(logoNRGBA, logoNRGBA.Bounds(), logoImg, image.Point{}, draw.Src)
			// Apply global opacity if set (0-100)
			opacity := 100
			if request.Customization.LogoOpacity > 0 && request.Customization.LogoOpacity <= 100 { opacity = request.Customization.LogoOpacity }
			blendMode := strings.ToLower(request.Customization.LogoBlendMode)
			if blendMode == "" { blendMode = "replace" }
			tintStrength := 100
			if request.Customization.LogoTintStrength > 0 && request.Customization.LogoTintStrength <= 100 { tintStrength = request.Customization.LogoTintStrength }
			removeWhite := request.Customization.LogoAutoRemoveWhite
			whiteThreshold := request.Customization.LogoWhiteThreshold
			if whiteThreshold <= 0 || whiteThreshold > 255 { whiteThreshold = 245 }
			// Precompute gradient colors for tint if enabled
			var tintFrom, tintTo color.Color
			if request.Customization.LogoTintGradient && haveGradient {
				tintFrom = gradientFrom; tintTo = gradientTo
			}
			for y2 := 0; y2 < logoNRGBA.Bounds().Dy(); y2++ {
				for x2 := 0; x2 < logoNRGBA.Bounds().Dx(); x2++ {
					idx := logoNRGBA.PixOffset(x2, y2)
					a := logoNRGBA.Pix[idx+3]
					if a == 0 { continue }
					// Auto-remove near-white backgrounds
					if removeWhite {
						rp, gp, bp := logoNRGBA.Pix[idx+0], logoNRGBA.Pix[idx+1], logoNRGBA.Pix[idx+2]
						if rp >= uint8(whiteThreshold) && gp >= uint8(whiteThreshold) && bp >= uint8(whiteThreshold) {
							logoNRGBA.Pix[idx+3] = 0
							continue
						}
					}
					if tintFrom != nil && tintTo != nil {
						// compute t based on QR gradient direction
						var t float64
						if strings.ToLower(request.Customization.GradientDirection) == "vertical" {
							// map absolute Y position in QR space
							absY := offset.Y + y2
							t = float64(absY-img.Bounds().Min.Y)/float64(img.Bounds().Dy()-1)
						} else {
							absX := offset.X + x2
							t = float64(absX-img.Bounds().Min.X)/float64(img.Bounds().Dx()-1)
						}
						fr, fg, fb, fa := rgba8(tintFrom)
						tr, tg, tb, ta := rgba8(tintTo)
						cr := lerp(fr, tr, t)
						cg := lerp(fg, tg, t)
						cb := lerp(fb, tb, t)
						ca := lerp(fa, ta, t)
						// blend modes
						origR, origG, origB := logoNRGBA.Pix[idx+0], logoNRGBA.Pix[idx+1], logoNRGBA.Pix[idx+2]
						s := float64(tintStrength)/100.0
						switch blendMode {
						case "multiply":
							logoNRGBA.Pix[idx+0] = uint8(float64(origR) * float64(cr) / 255.0)
							logoNRGBA.Pix[idx+1] = uint8(float64(origG) * float64(cg) / 255.0)
							logoNRGBA.Pix[idx+2] = uint8(float64(origB) * float64(cb) / 255.0)
						case "overlay":
							// simple overlay approximation
							logoNRGBA.Pix[idx+0] = overlayChannel(origR, cr)
							logoNRGBA.Pix[idx+1] = overlayChannel(origG, cg)
							logoNRGBA.Pix[idx+2] = overlayChannel(origB, cb)
						default: // replace (with strength)
							logoNRGBA.Pix[idx+0] = uint8(float64(origR)*(1-s) + float64(cr)*s)
							logoNRGBA.Pix[idx+1] = uint8(float64(origG)*(1-s) + float64(cg)*s)
							logoNRGBA.Pix[idx+2] = uint8(float64(origB)*(1-s) + float64(cb)*s)
						}
						logoNRGBA.Pix[idx+3] = uint8(int(ca) * opacity / 100)
					} else if opacity < 100 {
						logoNRGBA.Pix[idx+3] = uint8(int(a) * opacity / 100)
					}
				}
			}
			// Overlay processed logo
			draw.Draw(baseNRGBA, lb.Add(offset), logoNRGBA, image.Point{}, draw.Over)
			img = baseNRGBA
		}
	}

	// Handle include_label (if needed, add label rendering logic here)
	labelFontApplied := false
	if request.IncludeLabel || (request.Customization != nil && request.Customization.LabelText != "") {
		label := "Scan Me"
		if request.Customization != nil && request.Customization.LabelText != "" { label = request.Customization.LabelText }
		var labelColor color.Color = color.Black
		if request.Customization != nil && request.Customization.LabelColor != "" {
			if c, err := parseHexColor(request.Customization.LabelColor); err == nil { labelColor = c }
		}
		var fontFace font.Face = basicfont.Face7x13
		if request.Customization != nil && request.Customization.LabelFontURL != "" {
			log.Printf("Attempting to load label font from %s", request.Customization.LabelFontURL)
			if fface, err := loadRemoteFont(request.Customization.LabelFontURL, request.Customization.LabelFontSize); err == nil { fontFace = fface; labelFontApplied = true } else { log.Printf("font load failed, using basic: %v", err) }
		}
		labelHeight := fontFace.Metrics().Height.Ceil() + 8
		// Extend canvas downward
		newImg := image.NewNRGBA(image.Rect(0,0,img.Bounds().Dx(), img.Bounds().Dy()+labelHeight))
		// Fill new background with bgCol
		draw.Draw(newImg, newImg.Bounds(), &image.Uniform{C: bgCol}, image.Point{}, draw.Src)
		draw.Draw(newImg, img.Bounds(), img, image.Point{}, draw.Src)
		// Draw label centered
		d := &font.Drawer{Dst: newImg, Src: &image.Uniform{C: labelColor}, Face: fontFace}
		textWidth := d.MeasureString(label).Ceil()
		x := (newImg.Bounds().Dx() - textWidth)/2
		y := img.Bounds().Dy() + (labelHeight+fontFace.Metrics().Ascent.Ceil())/2 - 4
		d.Dot = fixed.Point26_6{X: fixed.I(x), Y: fixed.I(y)}
		d.DrawString(label)
		img = newImg
	}

	f, err := os.Create(filePath)
	if err != nil {
		return nil, fmt.Errorf("create file: %w", err)
	}
	defer f.Close()

	switch request.Format {
	case "jpg", "jpeg":
		if err := jpeg.Encode(f, img, &jpeg.Options{Quality: request.Quality}); err != nil { return nil, fmt.Errorf("jpeg encode: %w", err) }
	case "gif":
		if err := gif.Encode(f, img, nil); err != nil { return nil, fmt.Errorf("gif encode: %w", err) }
	default:
		if err := png.Encode(f, img); err != nil { return nil, fmt.Errorf("png encode: %w", err) }
	}

	resp := &dto.QRCodeResponse{
		QRCodeID:      qrCodeID,
		ImageURL:      fmt.Sprintf("%s/qr/%s", qs.baseURL, filename),
		PublicMenuURL: publicMenuURL,
		DownloadURL:   fmt.Sprintf("%s/qr/download/%s", qs.baseURL, qrCodeID),
		ExpiresAt:     time.Now().Add(365 * 24 * time.Hour),
		LabelFontApplied: labelFontApplied,
	}
	return resp, nil
}

func (qs *QRService) GetQRCodePath(filename string) string {
	return filepath.Join(qs.qrDir, filename)
}

func parseHexColor(s string) (color.Color, error) {
	s = strings.TrimSpace(s)
	if s == "" { return nil, errors.New("empty color") }
	s = strings.TrimPrefix(s, "#")
	if len(s) != 6 && len(s) != 8 { return nil, errors.New("invalid length") }
	var r, g, b, a uint8 = 0,0,0,255
	if len(s) == 6 {
		if _, err := fmt.Sscanf(s, "%02x%02x%02x", &r,&g,&b); err != nil { return nil, err }
	} else {
		if _, err := fmt.Sscanf(s, "%02x%02x%02x%02x", &r,&g,&b,&a); err != nil { return nil, err }
	}
	return color.NRGBA{R:r,G:g,B:b,A:a}, nil
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

// applyGradientColoring replaces dark modules with gradient colors interpolated between from->to across axis.
func applyGradientColoring(src image.Image, bg, from, to color.Color, vertical bool) image.Image {
	b := src.Bounds()
	dst := image.NewNRGBA(b)
	fr, fg, fb, fa := rgba8(from)
	tr, tg, tb, ta := rgba8(to)
	for y := b.Min.Y; y < b.Max.Y; y++ {
		for x := b.Min.X; x < b.Max.X; x++ {
			r, g, bl, a := src.At(x, y).RGBA()
			isDark := a > 0 && r < 0x4000 && g < 0x4000 && bl < 0x4000
			if isDark {
				var t float64
				if vertical {
					t = float64(y-b.Min.Y)/float64(b.Dy()-1)
				} else {
					t = float64(x-b.Min.X)/float64(b.Dx()-1)
				}
				cr := lerp(fr, tr, t)
				cg := lerp(fg, tg, t)
				cb := lerp(fb, tb, t)
				ca := lerp(fa, ta, t)
				dst.Set(x, y, color.NRGBA{R: cr, G: cg, B: cb, A: ca})
			} else {
				dst.Set(x, y, bg)
			}
		}
	}
	return dst
}

func rgba8(c color.Color) (r, g, b, a uint8) {
	r16, g16, b16, a16 := c.RGBA()
	return uint8(r16 >> 8), uint8(g16 >> 8), uint8(b16 >> 8), uint8(a16 >> 8)
}

func lerp(a, b uint8, t float64) uint8 { return uint8(float64(a) + (float64(b)-float64(a))*t) }

// overlayChannel applies an approximate overlay blend on two channels (base=orig, blend=gradient)
func overlayChannel(base, blend uint8) uint8 {
	b := float64(blend) / 255.0
	ba := float64(base) / 255.0
	var out float64
	if ba < 0.5 {
		out = 2 * ba * b
	} else {
		out = 1 - 2*(1-ba)*(1-b)
	}
	if out < 0 { out = 0 } else if out > 1 { out = 1 }
	return uint8(out * 255.0)
}

// loadRemoteFont fetches a TTF font and returns a font.Face scaled to desired size (default 16 if size invalid)
func loadRemoteFont(url string, size int) (font.Face, error) {
	if size <= 0 { size = 16 }
	var data []byte
	if strings.HasPrefix(strings.ToLower(url), "http://") || strings.HasPrefix(strings.ToLower(url), "https://") {
		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Get(url)
		if err != nil { return nil, err }
		defer resp.Body.Close()
		if resp.StatusCode != http.StatusOK { return nil, fmt.Errorf("font fetch: %s", resp.Status) }
		b, err := io.ReadAll(resp.Body)
		if err != nil { return nil, err }
		data = b
	} else {
		b, err := os.ReadFile(url)
		if err != nil { return nil, err }
		data = b
	}
	f, err := truetype.Parse(data)
	if err != nil { return nil, err }
	face := truetype.NewFace(f, &truetype.Options{Size: float64(size), DPI: 72})
	return face, nil
}
