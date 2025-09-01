package handler

import (
	"net/http"
	"regexp"
	"strconv"

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
	manager := c.GetString("userid")

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(r))
}

func (h *RestaurantHandler) UpdateRestaurant(c *gin.Context) {
	var input dto.RestaurantResponse
	manager := c.GetString("userid")
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	input.ManagerID = manager

	r := dto.ToDomainRestaurant(&input)
	if err := h.RestaurantUsecase.UpdateRestaurant(c.Request.Context(), r); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ToRestaurantResponse(r))
}

func (h *RestaurantHandler) DeleteRestaurant(c *gin.Context) {
	manager := c.GetString("userid")
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
