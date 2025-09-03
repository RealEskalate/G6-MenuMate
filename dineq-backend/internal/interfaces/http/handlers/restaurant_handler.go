package handler

import (
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strconv"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

// RestaurantHandler handles HTTP requests related to restaurants.
type RestaurantHandler struct {
	RestaurantUsecase domain.IRestaurantUsecase
}

// NewRestaurantHandler creates a new RestaurantHandler instance.
func NewRestaurantHandler(u domain.IRestaurantUsecase) *RestaurantHandler {
	return &RestaurantHandler{RestaurantUsecase: u}
}

// IsValidObjectID checks if a string is a valid 24-character MongoDB ObjectID.
func IsValidObjectID(id string) bool {
	if len(id) != 24 {
		return false
	}
	match, _ := regexp.MatchString("^[0-9a-fA-F]{24}$", id)
	return match
}

// CreateRestaurant handles the creation of a new restaurant, supporting both JSON and multipart form data.
func (h *RestaurantHandler) CreateRestaurant(c *gin.Context) {
	manager := c.GetString("user_id")

	// Validate manager_id from context
	if manager == "" || !IsValidObjectID(manager) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or missing manager_id (must be a valid ObjectID)"})
		return
	}

	// Use a single domain.Restaurant object to consolidate data
	r := &domain.Restaurant{
		ManagerID: manager,
	}

	files := make(map[string][]byte)

	contentType := c.ContentType()
	if contentType == "application/json" {
		// Handle JSON request
		var input dto.RestaurantResponse
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		r.RestaurantName = input.Name
		r.RestaurantPhone = input.Phone
		r.About = input.About

	} else if c.Request.MultipartForm != nil || contentType == "multipart/form-data" {
		// Handle multipart/form-data request
		restaurantName := c.PostForm("restaurant_name")
		if restaurantName == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "restaurant_name is required"})
			return
		}
		r.RestaurantName = restaurantName
		r.RestaurantPhone = c.PostForm("restaurant_phone")
		r.Tags = c.PostFormArray("tags")
		about := c.PostForm("about")
		if about != "" {
			r.About = about
		}

		// Read files into []byte
		for _, field := range []string{"logo_image", "verification_docs", "cover_image"} {
			fileHeader, err := c.FormFile(field)
			if err != nil {
				if err != http.ErrMissingFile {
					c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to read %s: %v", field, err)})
					return
				}
				continue
			}

			file, err := fileHeader.Open()
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to open %s", field)})
				return
			}
			defer file.Close()

			data, err := io.ReadAll(file)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to read %s", field)})
				return
			}
			files[field] = data
		}

	} else {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported content type"})
		return
	}

	if err := h.RestaurantUsecase.CreateRestaurant(c.Request.Context(), r, files); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, dto.ToRestaurantResponse(r))
}

// GetRestaurant retrieves a restaurant by its slug.
func (h *RestaurantHandler) GetRestaurant(c *gin.Context) {
	slug := c.Param("slug")
	r, err := h.RestaurantUsecase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil {
		if err == domain.ErrRestaurantDeleted {
			c.JSON(http.StatusGone, gin.H{"error": "restaurant deleted"})
			return
		}
		// Try old slug fallback
		old, oldErr := h.RestaurantUsecase.GetRestaurantByOldSlug(c.Request.Context(), slug)
		if oldErr != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		// Redirect permanently to new slug
		c.Header("Location", "/api/v1/restaurants/"+old.Slug)
		c.JSON(http.StatusPermanentRedirect, gin.H{"redirect_to": old.Slug})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(r))
}

// UpdateRestaurant updates an existing restaurant, supporting both JSON and multipart form data.
func (h *RestaurantHandler) UpdateRestaurant(c *gin.Context) {
	slug := c.Param("slug")
	manager := c.GetString("user_id")

	if manager == "" || !IsValidObjectID(manager) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or missing manager_id (must be a valid ObjectID)"})
		return
	}

	existing, err := h.RestaurantUsecase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	if existing.ManagerID != manager {
		c.JSON(http.StatusForbidden, gin.H{"error": "not authorized to update this restaurant"})
		return
	}

	files := make(map[string][]byte)

	// Determine request type
	contentType := c.ContentType()

	if contentType == "application/json" {
		var input dto.RestaurantResponse
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		// Merge mutable fields from JSON
		if input.Name != "" && input.Name != existing.RestaurantName {
			updateSlug(existing, input.Name)
		}
		if input.Phone != "" {
			existing.RestaurantPhone = input.Phone
		}
		if input.About != "" {
			existing.About = input.About
		}

		if input.VerificationStatus != "" {
			existing.VerificationStatus = domain.VerificationStatus(input.VerificationStatus)
		}
	} else if c.Request.MultipartForm != nil || contentType == "multipart/form-data" {
		if err := c.Request.ParseMultipartForm(10 << 20); err != nil { // 10MB max
			c.JSON(http.StatusBadRequest, gin.H{"error": "failed to parse form: " + err.Error()})
			return
		}
		// Merge mutable fields from multipart form
		if name := c.PostForm("name"); name != "" && name != existing.RestaurantName {
			updateSlug(existing, name)
		}
		if phone := c.PostForm("phone"); phone != "" {
			existing.RestaurantPhone = phone
		}
		if about := c.PostForm("about"); about != "" {
			existing.About = about
		}
		if status := c.PostForm("verification_status"); status != "" {
			existing.VerificationStatus = domain.VerificationStatus(status)
		}
		// Read files from multipart form
		for _, field := range []string{"logo_image", "verification_docs", "cover_image"} {
			fileHeader, err := c.FormFile(field)
			if err != nil {
				if err != http.ErrMissingFile {
					c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to read %s: %v", field, err)})
					return
				}
				continue
			}

			file, err := fileHeader.Open()
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to open %s", field)})
				return
			}
			defer file.Close()

			data, err := io.ReadAll(file)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("failed to read %s", field)})
				return
			}
			files[field] = data
		}

	} else {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported content type"})
		return
	}

	existing.ManagerID = manager

	if err := h.RestaurantUsecase.UpdateRestaurant(c.Request.Context(), existing, files); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(existing))
}

// updateSlug is a helper function to manage slug updates and history.
func updateSlug(r *domain.Restaurant, newName string) {
	seen := make(map[string]struct{})
	var cleaned []string

	// include existing previous slugs
	for _, s := range r.PreviousSlugs {
		if s == r.Slug {
			continue
		}
		if _, ok := seen[s]; ok {
			continue
		}
		seen[s] = struct{}{}
		cleaned = append(cleaned, s)
	}

	// append current slug
	if _, ok := seen[r.Slug]; !ok {
		cleaned = append(cleaned, r.Slug)
	}

	// cap length at 10
	if len(cleaned) > 10 {
		cleaned = cleaned[len(cleaned)-10:]
	}

	r.PreviousSlugs = cleaned
	r.RestaurantName = newName
	r.Slug = utils.GenerateSlug(newName)
}

// DeleteRestaurant handles the deletion of a restaurant.
func (h *RestaurantHandler) DeleteRestaurant(c *gin.Context) {
	manager := c.GetString("user_id")
	id := c.Param("id")
	if err := h.RestaurantUsecase.DeleteRestaurant(c.Request.Context(), id, manager); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusNoContent)
}

// GetBranches retrieves the branches of a restaurant, with pagination.
func (h *RestaurantHandler) GetBranches(c *gin.Context) {
	slug := c.Param("slug")
	page, pageSize := 1, 10
	if p := c.Query("page"); p != "" {
		if val, _ := strconv.Atoi(p); val > 0 {
			page = val
		}
	}
	if ps := c.Query("pageSize"); ps != "" {
		if val, _ := strconv.Atoi(ps); val > 0 {
			pageSize = val
		}
	}
	branches, total, err := h.RestaurantUsecase.ListBranchesBySlug(c.Request.Context(), slug, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	totalPages := (total + int64(pageSize) - 1) / int64(pageSize)
	c.JSON(http.StatusOK, gin.H{
		"slug":       slug,
		"page":       page,
		"pageSize":   pageSize,
		"total":      total,
		"totalPages": totalPages,
		"branches":   dto.ToRestaurantResponseList(branches),
	})
}

// GetUniqueRestaurants retrieves a list of unique restaurants, with pagination.
func (h *RestaurantHandler) GetUniqueRestaurants(c *gin.Context) {
	page, pageSize := 1, 10
	if p := c.Query("page"); p != "" {
		if val, _ := strconv.Atoi(p); val > 0 {
			page = val
		}
	}
	if ps := c.Query("pageSize"); ps != "" {
		if val, _ := strconv.Atoi(ps); val > 0 {
			pageSize = val
		}
	}

	restaurants, total, err := h.RestaurantUsecase.ListUniqueRestaurants(c.Request.Context(), page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	totalPages := (total + int64(pageSize) - 1) / int64(pageSize)

	c.JSON(http.StatusOK, gin.H{
		"page":        page,
		"pageSize":    pageSize,
		"total":       total,
		"totalPages":  totalPages,
		"restaurants": dto.ToRestaurantResponseList(restaurants),
	})
}
