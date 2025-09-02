package handler

import (
	"net/http"
	"regexp"
	"strconv"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

type RestaurantHandler struct {
	RestaurantUsecase domain.IRestaurantUsecase
}

func NewRestaurantHandler(u domain.IRestaurantUsecase) *RestaurantHandler {
	return &RestaurantHandler{RestaurantUsecase: u}
}

func IsValidObjectID(id string) bool {
	if len(id) != 24 {
		return false
	}
	match, _ := regexp.MatchString("^[0-9a-fA-F]{24}$", id)
	return match
}

func (h *RestaurantHandler) CreateRestaurant(c *gin.Context) {
	var input dto.RestaurantResponse
	manager := c.GetString("user_id")

       if err := c.ShouldBindJSON(&input); err != nil {
	       c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	       return
       }

       // Validate manager_id
       if manager == "" || !IsValidObjectID(manager) {
	       c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or missing manager_id (must be a valid ObjectID)"})
	       return
       }
       input.ManagerID = manager

       r := dto.ToDomainRestaurant(&input)

       if err := h.RestaurantUsecase.CreateRestaurant(c.Request.Context(), r); err != nil {
	       c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	       return
       }
       c.JSON(http.StatusCreated, dto.ToRestaurantResponse(r))
}

func (h *RestaurantHandler) GetRestaurant(c *gin.Context) {
	slug := c.Param("slug")
	r, err := h.RestaurantUsecase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil {
		if err == domain.ErrRestaurantDeleted {
			c.JSON(http.StatusGone, gin.H{"error": "restaurant deleted"})
			return
		}
		// try old slug fallback
		old, oldErr := h.RestaurantUsecase.GetRestaurantByOldSlug(c.Request.Context(), slug)
		if oldErr != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		// Redirect (permanent, preserve method) to new slug
		c.Header("Location", "/api/v1/restaurants/"+old.Slug)
		c.JSON(http.StatusPermanentRedirect, gin.H{"redirect_to": old.Slug})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(r))
}

func (h *RestaurantHandler) UpdateRestaurant(c *gin.Context) {
	slug := c.Param("slug")
	manager := c.GetString("user_id")

	// Validate manager id
	if manager == "" || !IsValidObjectID(manager) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or missing manager_id (must be a valid ObjectID)"})
		return
	}

	// Fetch existing restaurant by slug so we obtain its persistent ID
	existing, err := h.RestaurantUsecase.GetRestaurantBySlug(c.Request.Context(), slug)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	// ownership check (only manager can update)
	if existing.ManagerID != manager {
		c.JSON(http.StatusForbidden, gin.H{"error": "not authorized to update this restaurant"})
		return
	}

	var input dto.RestaurantResponse
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Merge allowed mutable fields; if name changes, regenerate slug & store previous
	if input.Name != "" {
		if input.Name != existing.RestaurantName {
			// append current slug to previous list if changed
			// dedupe and cap at 10
			seen := make(map[string]struct{})
			var cleaned []string
			// include existing previous first
			for _, s := range existing.PreviousSlugs {
				if s == existing.Slug { // skip if same as current slug
					continue
				}
				if _, ok := seen[s]; ok { continue }
				seen[s] = struct{}{}
				cleaned = append(cleaned, s)
			}
			// append current slug
			if _, ok := seen[existing.Slug]; !ok {
				cleaned = append(cleaned, existing.Slug)
			}
			// cap length
			if len(cleaned) > 10 {
				cleaned = cleaned[len(cleaned)-10:]
			}
			existing.PreviousSlugs = cleaned
			existing.RestaurantName = input.Name
			existing.Slug = utils.GenerateSlug(existing.RestaurantName)
		}
	}
	if input.Phone != "" {
		existing.RestaurantPhone = input.Phone
	}
	if input.About != nil {
		existing.About = input.About
	}
	if input.LogoImage != nil {
		existing.LogoImage = input.LogoImage
	}
	if len(input.Tags) > 0 { // replace tags if provided
		existing.Tags = input.Tags
	}
	// MenuID optional replacement
	if input.MenuID != "" {
		existing.MenuID = input.MenuID
	}
	// VerificationStatus update only if provided and non-empty
	if input.VerificationStatus != "" {
		existing.VerificationStatus = domain.VerificationStatus(input.VerificationStatus)
	}

	// Set manager explicitly (should already match)
	existing.ManagerID = manager

	if err := h.RestaurantUsecase.UpdateRestaurant(c.Request.Context(), existing); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(existing))
}

func (h *RestaurantHandler) DeleteRestaurant(c *gin.Context) {
	manager := c.GetString("user_id")
	id := c.Param("id")
	if err := h.RestaurantUsecase.DeleteRestaurant(c.Request.Context(), id, manager); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusNoContent)
}

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
