package services

import (
	"bytes"
	"context"
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
	baseURL := os.Getenv("FRONTEND_BASE_URL")
	if baseURL == "" {
		baseURL = "http://localhost:3000"
	}
	return &QRService{qrDir: qrDir, baseURL: baseURL}
}

func (qs *QRService) GenerateQRCode(restaurantID string, request *domain.QRCodeRequest) (*dto.QRCodeResponse, error) {
	qrCodeID := uuid.New().String()
	frontendURL := os.Getenv("FRONTEND_URL")
	if frontendURL == "" { frontendURL = qs.baseURL }
	publicMenuURL := fmt.Sprintf("%s/menu/%s", strings.TrimRight(frontendURL, "/"), restaurantID)
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

	// Determine error correction level
	level := qrcode.Medium
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
			if request.Customization.LogoSizePercent > 0 { logoSizePercent = request.Customization.LogoSizePercent }
			// Safety caps by error correction level (approx recommended)
			// H: up to ~30% data restoration => allow <=0.30, M: <=0.20, L: <=0.15
			maxAllowed := 0.25
			switch level {
			case qrcode.High:
				maxAllowed = 0.30
			case qrcode.Medium:
				maxAllowed = 0.20
			case qrcode.Low:
				maxAllowed = 0.15
			default:
				maxAllowed = 0.22
			}
			if logoSizePercent > maxAllowed { logoSizePercent = maxAllowed }
			if logoSizePercent < 0.05 { logoSizePercent = 0.05 }
			// Additionally limit absolute pixel size so modules around finder patterns remain
			maxSide := int(float64(request.Size) * logoSizePercent)
			// Ensure at least 6 modules clearance (rough) from each edge of logo to outer code edge
			modules := qrCode.Bitmap()
			qrModules := len(modules)
			if qrModules > 0 {
				moduleSize := request.Size / qrModules
				minClearance := moduleSize * 6
				maxLogical := request.Size - 2*minClearance
				if maxLogical < maxSide { maxSide = maxLogical }
				if maxSide < moduleSize*8 { maxSide = moduleSize * 8 } // keep logo legible but not tiny
			}

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

			draw.Draw(baseNRGBA, lb.Add(offset), logoImg, image.Point{}, draw.Over)
			img = baseNRGBA
		}
	}

	// Handle include_label / label_text (improved baseline & clipping avoidance)
	labelFontApplied := false
	if request.IncludeLabel || (request.Customization != nil && request.Customization.LabelText != "") {
		label := "Scan Me"
		if request.Customization != nil && request.Customization.LabelText != "" { label = request.Customization.LabelText }
		var labelColor color.Color = color.Black
		if request.Customization != nil && request.Customization.LabelColor != "" {
			if c, err := parseHexColor(request.Customization.LabelColor); err == nil { labelColor = c }
		}
		var fontFace font.Face
		if request.Customization != nil && request.Customization.LabelFontURL != "" {
			log.Printf("Attempting to load custom label font from %s with size %d", request.Customization.LabelFontURL, request.Customization.LabelFontSize)
			if fface, err := loadRemoteFont(request.Customization.LabelFontURL, request.Customization.LabelFontSize); err == nil {
				fontFace = fface
				labelFontApplied = true
			} else {
				log.Printf("Custom font load failed (%v); falling back to basic font", err)
				fontFace = basicfont.Face7x13
			}
		} else if request.Customization != nil && request.Customization.LabelFontSize > 0 {
			log.Printf("No custom font URL provided; basic font does not scale. Using basic font.")
			fontFace = basicfont.Face7x13
		} else {
			fontFace = basicfont.Face7x13
		}
		metrics := fontFace.Metrics()
		ascent := metrics.Ascent.Ceil()
		descent := metrics.Descent.Ceil()
		lineHeight := ascent + descent
		padding := 8 // vertical padding total
		extraHeight := lineHeight + padding
		newImg := image.NewNRGBA(image.Rect(0, 0, img.Bounds().Dx(), img.Bounds().Dy()+extraHeight))
		// Fill background
		draw.Draw(newImg, newImg.Bounds(), &image.Uniform{C: bgCol}, image.Point{}, draw.Src)
		// Draw original QR
		draw.Draw(newImg, img.Bounds(), img, image.Point{}, draw.Src)
		// Compute centered X and baseline Y (baseline = oldHeight + ascent + padding/2 - small tweak)
		d := &font.Drawer{Dst: newImg, Src: &image.Uniform{C: labelColor}, Face: fontFace}
		textWidth := d.MeasureString(label).Ceil()
		log.Printf("[qr-label] text='%s' requested_font_size=%d measured_width=%d lineHeight=%d ascent=%d descent=%d", label, request.Customization.LabelFontSize, textWidth, lineHeight, ascent, descent)
		x := (newImg.Bounds().Dx() - textWidth) / 2
		baseline := img.Bounds().Dy() + ascent + (padding/2)
		// Ensure baseline not exceeding bounds
		if baseline > newImg.Bounds().Dy()-descent { baseline = newImg.Bounds().Dy() - descent }
		d.Dot = fixed.Point26_6{X: fixed.I(x), Y: fixed.I(baseline)}
		d.DrawString(label)
		img = newImg
	}

	var encodedBuf bytes.Buffer
	// Encode QR (with optional label/logo) into memory buffer
	switch request.Format {
	case "jpg", "jpeg":
		if err := jpeg.Encode(&encodedBuf, img, &jpeg.Options{Quality: request.Quality}); err != nil { return nil, fmt.Errorf("jpeg encode: %w", err) }
	case "gif":
		if err := gif.Encode(&encodedBuf, img, nil); err != nil { return nil, fmt.Errorf("gif encode: %w", err) }
	default:
		if err := png.Encode(&encodedBuf, img); err != nil { return nil, fmt.Errorf("png encode: %w", err) }
	}

	cloudName := os.Getenv("CLOUDINARY_CLOUD_NAME")
	apiKey := os.Getenv("CLOUDINARY_API_KEY")
	apiSecret := os.Getenv("CLOUDINARY_API_SECRET")

	if cloudName == "" { cloudName = os.Getenv("CLD_NAME") }
	if apiKey == "" { apiKey = os.Getenv("CLD_API_KEY") }
	if apiSecret == "" { apiSecret = os.Getenv("CLD_SECRET") }
	if cloudName == "" || apiKey == "" || apiSecret == "" {
		if raw := os.Getenv("CLOUDINARY_URL"); raw != "" {
			parts := strings.SplitN(raw, "@", 2)
			if len(parts) == 2 {
				cred := strings.TrimPrefix(parts[0], "cloudinary://")
				cParts := strings.SplitN(cred, ":", 2)
				if len(cParts) == 2 {
					apiKey = cParts[0]
					apiSecret = cParts[1]
					cloudName = parts[1]
					cloudName = strings.TrimSuffix(cloudName, "/")
				}
			}
		}
	}
	if cloudName == "" || apiKey == "" || apiSecret == "" { return nil, fmt.Errorf("cloudinary env vars missing") }
	storage := NewCloudinaryStorage(cloudName, apiKey, apiSecret)
	url, _, err := storage.UploadFile(context.Background(), filename, encodedBuf.Bytes(), "qr_codes")
	if err != nil { return nil, fmt.Errorf("cloudinary upload failed: %w", err) }
	resp := &dto.QRCodeResponse{
		QRCodeID:         qrCodeID,
		ImageURL:         url,
		CloudImageURL:    url,
		PublicMenuURL:    publicMenuURL,
		DownloadURL:      url,
		ExpiresAt:        time.Now().Add(365 * 24 * time.Hour),
		LabelFontApplied: labelFontApplied,
		CreatedAt:        time.Now(),
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

// loadRemoteFont fetches a TTF font and returns a font.Face scaled to desired size (default 16 if size invalid)
func loadRemoteFont(url string, sizePx int) (font.Face, error) {
	if sizePx <= 0 { sizePx = 16 }
	if sizePx > 300 { sizePx = 300 }
	fetch := func(u string) ([]byte, error) {
		// Rewrite common GitHub "github.com/.../raw/..." URLs to raw.githubusercontent.com which actually serves file bytes
		if strings.HasPrefix(u, "https://github.com/") && strings.Contains(u, "/raw/") {
			// Pattern: https://github.com/{owner}/{repo}/raw/{branch}/path/to/file.ttf
			parts := strings.SplitN(strings.TrimPrefix(u, "https://github.com/"), "/", 5)
			if len(parts) >= 5 && parts[2] == "raw" { // {owner},{repo},raw,{branch},rest
				rest := parts[4]
				u = fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/%s/%s", parts[0], parts[1], parts[3], rest)
				log.Printf("[qr-font] rewrote GitHub font URL to raw: %s", u)
			}
		}
		if strings.HasPrefix(strings.ToLower(u), "http://") || strings.HasPrefix(strings.ToLower(u), "https://") {
			client := &http.Client{Timeout: 10 * time.Second}
			req, err := http.NewRequest("GET", u, nil)
			if err != nil { return nil, err }
			req.Header.Set("User-Agent", "MenuMate-QR-FontLoader/1.0")
			req.Header.Set("Accept", "*/*")
			resp, err := client.Do(req)
			if err != nil { return nil, err }
			defer resp.Body.Close()
			if resp.StatusCode != http.StatusOK { return nil, fmt.Errorf("font fetch: %s", resp.Status) }
			return io.ReadAll(resp.Body)
		}
		return os.ReadFile(u)
	}
	data, err := fetch(url)
	if err != nil { return nil, err }
	tt, err := truetype.Parse(data)
	if err != nil { return nil, err }

	mkFace := func(sz float64) font.Face { return truetype.NewFace(tt, &truetype.Options{Size: sz, DPI: 72, Hinting: font.HintingFull}) }
	target := float64(sizePx)
	current := target
	var face font.Face
	var metrics font.Metrics
	for i := 0; i < 5; i++ { // iterative refine up to 5 times
		face = mkFace(current)
		metrics = face.Metrics()
		h := float64(metrics.Height.Ceil())
		if h == 0 { break }
		diff := target - h
		if diff < 0 { diff = -diff }
		if diff <= 1.0 { // acceptable
			break
		}
		scale := target / h
		// dampen scaling to avoid overshoot
		current = current * (0.6 + 0.4*scale)
		if current < 4 { current = 4 }
		if current > 320 { current = 320 }
	}
	log.Printf("[qr-font] loaded font '%s' requested_px=%d final_point_size=%.2f metrics: ascent=%d descent=%d height=%d cap=%d", url, sizePx, current, metrics.Ascent.Ceil(), metrics.Descent.Ceil(), metrics.Height.Ceil(), metrics.CapHeight.Ceil())
	return face, nil
}
