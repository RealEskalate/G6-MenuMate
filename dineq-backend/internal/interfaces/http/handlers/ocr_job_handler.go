package handler

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/infrastructure/logger"
	services "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/service"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
)

type OCRJobHandler struct {
	UseCase             domain.IOCRJobUseCase
	MenuUseCase         domain.IMenuUseCase
	StorageService      services.StorageService
	NotificationUseCase domain.INotificationUseCase
	FrontendBaseURL      string

	// Worker         *services.Worker
}

// nutritionalInfoOut mirrors the desired nutritional_info object in frontend contract
type nutritionalInfoOut struct {
	Calories int `json:"calories,omitempty"`
	Protein  int `json:"protein,omitempty"`
	Carbs    int `json:"carbs,omitempty"`
	Fat      int `json:"fat,omitempty"`
}

// menuItemOut matches the requested MenuItem structure for OCR results
type menuItemOut struct {
	Name            string              `json:"name"`
	NameAm          string              `json:"name_am,omitempty"`
	Description     string              `json:"description,omitempty"`
	DescriptionAm   string              `json:"description_am,omitempty"`
	TabTags         []string            `json:"tab_tags,omitempty"`
	TabTagsAm       []string            `json:"tab_tags_am,omitempty"`
	Images          []string            `json:"images,omitempty"`
	ImageThumbnails []string            `json:"image_thumbnails,omitempty"`
	Price           float64             `json:"price,omitempty"`
	Currency        string              `json:"currency,omitempty"`
	Allergies       []string            `json:"allergies,omitempty"`
	AllergiesAm     string              `json:"allergies_am,omitempty"`
	Ingredients     []string            `json:"ingredients,omitempty"`
	IngredientsAm   []string            `json:"ingredients_am,omitempty"`
	NutritionalInfo *nutritionalInfoOut `json:"nutritional_info,omitempty"`
	PreparationTime int                 `json:"preparation_time,omitempty"`
	HowToEat        string              `json:"how_to_eat,omitempty"`
	HowToEatAm      string              `json:"how_to_eat_am,omitempty"`
}

const (
	MaxUploadSizeBytes = 10 * 1024 * 1024 // 10 MB
)

// joinSlice joins a slice of strings with a comma+space; returns empty string if none
func joinSlice(s []string) string {
	if len(s) == 0 {
		return ""
	}
	out := ""
	for i, v := range s {
		if i == 0 {
			out = v
		} else {
			out += ", " + v
		}
	}
	return out
}

// anyToString attempts to convert a loosely typed field to string
func anyToString(v any) string {
	if v == nil {
		return ""
	}
	switch t := v.(type) {
	case string:
		return t
	case fmt.Stringer:
		return t.String()
	default:
		return fmt.Sprintf("%v", t)
	}
}

// fallbackTranslate currently returns the source string if translation missing.
// TODO: integrate real Amharic translation (batch AI call) so blanks are fully localized.
func fallbackTranslate(src string, existing string) string {
	if existing != "" {
		return existing
	}
	return src // placeholder until real translation integrated
}

// enforceAmharicScript replaces common English category/tab words with Amharic script if model missed translation
func enforceAmharicScript(words []string) []string {
	mapper := map[string]string{
		"Breakfast":   "ቁርስ",
		"Lunch":       "ምሳ",
		"Meat":        "ስጋ",
		"Vegetable":   "አትክልት",
		"Vegetarian":  "በተክል",
		"Stew":        "ወጥ",
		"Soup":        "ሾርባ",
		"Egg":         "እንቁላል",
		"Eggs":        "እንቁላል",
		"Combination": "ቅልቅል",
		"Specialty":   "ልዩ",
	}
	out := make([]string, len(words))
	for i, w := range words {
		if v, ok := mapper[w]; ok {
			out[i] = v
		} else {
			out[i] = w
		}
	}
	return out
}

func NewOCRJobHandler(uc domain.IOCRJobUseCase, mc domain.IMenuUseCase, stg services.StorageService, nc domain.INotificationUseCase, frontendBaseURL string) *OCRJobHandler {
	return &OCRJobHandler{
		UseCase:             uc,
		MenuUseCase:         mc,
		StorageService:      stg,
		NotificationUseCase: nc,
		FrontendBaseURL:      frontendBaseURL,
	}
}

// CreateOCRJob handles the creation of a new OCR job
func (h *OCRJobHandler) CreateOCRJob(c *gin.Context) {
	var OCRDto dto.OCRJobDTO
	if err := c.ShouldBindJSON(&OCRDto); err != nil {
		dto.WriteValidationError(c, "payload", "invalid JSON body", "invalid_json", err)
		return
	}
	if err := OCRDto.Validate(); err != nil {
		dto.WriteValidationError(c, "payload", err.Error(), "validation_failed", err)
		return
	}
	job := OCRDto.ToDomain()
	if err := h.UseCase.CreateOCRJob(job); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    OCRDto.FromDomain(job),
	})
}

// GetOCRJobByID retrieves an OCR job by ID
func (h *OCRJobHandler) GetOCRJobByID(c *gin.Context) {
	id := c.Param("id")
	job, err := h.UseCase.GetOCRJobByID(id)
	if err != nil {
		logger.Log.Warn().Str("job_id", id).Err(err).Msg("OCR job lookup failed")
		c.JSON(http.StatusNotFound, gin.H{"success": false, "error": "ocr job not found"})
		return
	}
	response := gin.H{
		"job_id":                    job.ID,
		"status":                    job.Status,
		"created_at":                job.CreatedAt,
		"estimated_completion_time": job.EstimatedCompletion,
		"phase":                     job.Phase,
		"progress":                  job.Progress,
		"phases":                    job.PhaseHistory,
	}
	if job.CompletedAt != nil {
		response["completed_at"] = job.CompletedAt
	}
	if job.Status == domain.OCRFailed && job.Error != "" {
		response["error"] = job.Error
	}
	if job.Status == domain.OCRCompleted && job.Results != nil {
		res := *job.Results
		if res.Menu != nil {
			sanitized := gin.H{}
			if res.ExtractedText != "" {
				sanitized["extracted_text"] = res.ExtractedText
			}
			if len(res.PhotoMatches) > 0 {
				sanitized["photo_matches"] = res.PhotoMatches
			}
			if res.ConfidenceScore != 0 {
				sanitized["confidence_score"] = res.ConfidenceScore
			}
			// Provide structured categories/items if available
			var menuItems []menuItemOut
			for _, tab := range res.Menu.Tabs { // flatten tabs -> categories
				for _, cat := range tab.Categories {
					for _, it := range cat.Items {
						// Use domain 'Allergies' slice directly for the API response.
						var allergiesArr []string
						for _, a := range it.Allergies {
							a = strings.TrimSpace(a)
							if a != "" {
								allergiesArr = append(allergiesArr, a)
							}
						}

						mi := menuItemOut{
							Name:            it.Name,
							NameAm:          fallbackTranslate(it.Name, it.NameAm),
							Description:     it.Description,
							DescriptionAm:   fallbackTranslate(it.Description, it.DescriptionAm),
							TabTags:         []string{tab.Name},
							Price:           it.Price,
							Currency:        it.Currency,
							Allergies:       allergiesArr,
							AllergiesAm:     it.AllergiesAm,
							Ingredients:     it.Ingredients,
							IngredientsAm:   it.IngredientsAm,
							PreparationTime: it.PreparationTime,
							HowToEat:        anyToString(it.HowToEat),
							HowToEatAm:      fallbackTranslate(anyToString(it.HowToEat), anyToString(it.HowToEatAm)),
						}
						if len(mi.Allergies) == 0 && mi.AllergiesAm != "" {
							mi.Allergies = []string{"Contains none commonly recognized. Please inform staff of any allergies."}
						}
						if tab.NameAm != "" {
							mi.TabTagsAm = []string{tab.NameAm}
						} else {
							mi.TabTagsAm = enforceAmharicScript([]string{tab.Name})
						}
						if it.Calories > 0 || it.Protein > 0 || it.Carbs > 0 || it.Fat > 0 {
							mi.NutritionalInfo = &nutritionalInfoOut{Calories: it.Calories, Protein: it.Protein, Carbs: it.Carbs, Fat: it.Fat}
						}
						menuItems = append(menuItems, mi)
					}
				}
			}
			if len(menuItems) > 0 {
				sanitized["menu_items"] = menuItems
			}
			if res.StructuredMenuID != "" {
				sanitized["structured_menu_id"] = res.StructuredMenuID
			}
			response["results"] = sanitized
		} else {
			response["results"] = res
		}
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": response})
}

// ListMyOCRJobs returns OCR jobs for the authenticated user.
func (h *OCRJobHandler) ListMyOCRJobs(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		userID = c.GetString("userId")
	}
	if userID == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	jobs, err := h.UseCase.ListOCRJobsByUserID(userID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	out := make([]gin.H, 0, len(jobs))
	for _, j := range jobs {
		if j == nil {
			continue
		}
		row := gin.H{
			"job_id":                    j.ID,
			"status":                    j.Status,
			"created_at":                j.CreatedAt,
			"updated_at":                j.UpdatedAt,
			"estimated_completion_time": j.EstimatedCompletion,
			"phase":                     j.Phase,
			"progress":                  j.Progress,
		}
		if j.CompletedAt != nil {
			row["completed_at"] = j.CompletedAt
		}
		if j.StructuredMenuID != "" {
			row["structured_menu_id"] = j.StructuredMenuID
		}
		out = append(out, row)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": out})
}

// GetMyPersonalMenus returns OCR-generated structured menus for the authenticated user.
func (h *OCRJobHandler) GetMyPersonalMenus(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		userID = c.GetString("userId")
	}
	if userID == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	jobs, err := h.UseCase.ListOCRJobsByUserID(userID)
	if err != nil {
		dto.WriteError(c, err)
		return
	}

	type menuRow struct {
		menu      *dto.MenuResponse
		createdAt time.Time
	}
	seen := map[string]bool{}
	menus := make([]menuRow, 0)
	for _, j := range jobs {
		if j == nil || j.Results == nil || j.Results.Menu == nil {
			continue
		}
		m := dto.MenuToResponse(j.Results.Menu)
		if m == nil || m.ID == "" {
			continue
		}
		if seen[m.ID] {
			continue
		}
		seen[m.ID] = true
		menus = append(menus, menuRow{menu: m, createdAt: j.CreatedAt})
	}

	sort.Slice(menus, func(i, j int) bool {
		return menus[i].createdAt.After(menus[j].createdAt)
	})

	res := make([]*dto.MenuResponse, 0, len(menus))
	for _, m := range menus {
		res = append(res, m.menu)
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": res})
}

// GetMyPersonalMenuByID returns one OCR-generated structured menu for the authenticated user.
func (h *OCRJobHandler) GetMyPersonalMenuByID(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		userID = c.GetString("userId")
	}
	if userID == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	menuID := c.Param("id")
	menu, err := h.UseCase.GetStructuredMenuByUserAndID(userID, menuID)
	if err != nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": dto.MenuToResponse(menu)})
}

// ShareMyPersonalMenu returns a share URL for a personal OCR-generated menu.
func (h *OCRJobHandler) ShareMyPersonalMenu(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		userID = c.GetString("userId")
	}
	if userID == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	menuID := c.Param("id")
	menu, err := h.UseCase.GetStructuredMenuByUserAndID(userID, menuID)
	if err != nil || menu == nil {
		dto.WriteError(c, domain.ErrNotFound)
		return
	}

	frontendBase := h.FrontendBaseURL
	if frontendBase == "" {
		// Try to get from Origin header (common in CORS requests)
		frontendBase = c.Request.Header.Get("Origin")
	}
	if frontendBase == "" {
		// Fallback to standard local frontend port
		frontendBase = "http://localhost:3000"
	}
	shareURL := fmt.Sprintf("%s/user/menu-display/%s", strings.TrimRight(frontendBase, "/"), menu.ID)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"menu_id":   menu.ID,
			"share_url": shareURL,
		},
		"message": "menu share URL generated",
	})
}

// UpdateMyPersonalMenu updates items in a personal OCR-generated menu
func (h *OCRJobHandler) UpdateMyPersonalMenu(c *gin.Context) {
	userId := c.GetString("user_id")
	if userId == "" {
		userId = c.GetString("userId")
	}
	if userId == "" {
		dto.WriteError(c, domain.ErrUnauthorized)
		return
	}

	menuID := c.Param("id")
	var req dto.MenuRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.WriteValidationError(c, "payload", "invalid JSON body", "invalid_json", err)
		return
	}

	domainMenu := dto.RequestToMenu(&req)
	if domainMenu == nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "invalid menu items"})
		return
	}

	if err := h.UseCase.UpdateStructuredMenu(c.Request.Context(), userId, menuID, domainMenu.Items); err != nil {
		dto.WriteError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "menu updated successfully"})
}

// DeleteOCRJob marks an OCR job as deleted
func (h *OCRJobHandler) DeleteOCRJob(c *gin.Context) {
	id := c.Param("id")
	if err := h.UseCase.DeleteOCRJob(id); err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "OCR job deleted"})
}

// RetryOCRJob retries a failed OCR job without re-uploading image
func (h *OCRJobHandler) RetryOCRJob(c *gin.Context) {
	id := c.Param("id")
	job, err := h.UseCase.RetryJob(id)
	if err != nil {
		dto.WriteError(c, err)
		return
	}
	c.JSON(http.StatusAccepted, gin.H{"success": true, "data": gin.H{"job_id": job.ID, "status": job.Status, "estimated_completion_time": job.EstimatedCompletion}})
}

// UploadMenu handles OCR job creation from an uploaded menu image
func (h *OCRJobHandler) UploadMenu(c *gin.Context) {
	userId := c.GetString("user_id")
	if userId == "" {
		userId = c.GetString("userId")
	}

	// Attempt to derive restaurant ID from context or query; fallback to userId (TODO: fetch from user profile/role association)
	restaurantID := c.GetString("restaurant_id")
	if restaurantID == "" {
		restaurantID = c.Query("restaurant_id")
	}
	if restaurantID == "" {
		restaurantID = userId
	}

	file, err := c.FormFile("menuImage")
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "menuImage file required"})
		return
	}

	// Basic size validation (max 6MB to accommodate high-res, adjustable)
	if file.Size > MaxUploadSizeBytes {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "file too large (max 6MB)"})
		return
	}
	f, err := file.Open()
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
		return
	}
	defer f.Close()

	data, err := io.ReadAll(f)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: err.Error()})
		return
	}

	// MIME sniffing
	if len(data) < 10 {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "empty file"})
		return
	}
	contentType := http.DetectContentType(data[:min(512, len(data))])
	allowed := map[string]bool{"image/jpeg": true, "image/png": true, "image/webp": true}
	if !allowed[contentType] {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Message: domain.ErrInvalidFile.Error(), Error: "unsupported image type"})
		return
	}

	url, _, err := h.StorageService.UploadFile(c.Request.Context(), file.Filename, data, "menus")
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFileToUpload.Error(), Error: err.Error()})
		return
	}

	job := &domain.OCRJob{
		ID:           bson.NewObjectID().Hex(),
		RestaurantID: restaurantID,
		UserID:       userId,
		ImageURL:     url,
		Status:       domain.OCRProcessing,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
	if err := h.UseCase.CreateOCRJob(job); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Message: domain.ErrFailedToCreateOCRJob.Error(), Error: err.Error()})
		return
	}
	logger.Log.Info().Str("job_id", job.ID).Str("user_id", userId).Msg("OCR job created and persisted")

	// Notifications disabled per request (TODO: integrate notification system behind feature flag)

	// Launch async processing with cancellation context (TODO: configurable timeout via env)
	jobCtx, cancel := context.WithCancel(context.Background())
	go func() { defer cancel(); h.processJobAsync(jobCtx, job.ID, userId) }()

	c.JSON(http.StatusAccepted, gin.H{
		"success": true,
		"data": gin.H{
			"job_id":                    job.ID,
			"status":                    job.Status,
			"estimated_completion_time": job.EstimatedCompletion,
		},
	})
}
func (h *OCRJobHandler) processJobAsync(ctx context.Context, jobID, userId string) {
	select {
	case <-ctx.Done():
		logger.Log.Warn().Str("job_id", jobID).Msg("job context canceled before processing started")
		return
	default:
	}
	h.UseCase.ProcessJob(jobID)
	// Notifications disabled per request
}

// helper: min int
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
