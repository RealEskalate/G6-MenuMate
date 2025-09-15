package handlers_test

// import (
// 	"context"
// 	"net/http"
// 	"net/http/httptest"
// 	"testing"

// 	"github.com/RealEskalate/G6-MenuMate/internal/domain"
// 	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
// 	"github.com/gin-gonic/gin"
// )

// type mockRestaurantUsecase struct {
// 	bySlug       map[string]*domain.Restaurant
// 	byOldSlug    map[string]*domain.Restaurant
// 	deletedSlugs map[string]bool
// }

// func (m *mockRestaurantUsecase) CreateRestaurant(context.Context, *domain.Restaurant) error {
// 	return nil
// }
// func (m *mockRestaurantUsecase) UpdateRestaurant(context.Context, *domain.Restaurant) error {
// 	return nil
// }
// func (m *mockRestaurantUsecase) DeleteRestaurant(context.Context, string, string) error { return nil }
// func (m *mockRestaurantUsecase) GetRestaurantBySlug(_ context.Context, slug string) (*domain.Restaurant, error) {
// 	if m.deletedSlugs == nil {
// 		m.deletedSlugs = map[string]bool{}
// 	}
// 	if m.deletedSlugs[slug] {
// 		return nil, domain.ErrRestaurantDeleted
// 	}
// 	r := m.bySlug[slug]
// 	if r == nil {
// 		return nil, domain.ErrRestaurantNotFound
// 	}
// 	return r, nil
// }
// func (m *mockRestaurantUsecase) GetRestaurantByOldSlug(_ context.Context, slug string) (*domain.Restaurant, error) {
// 	r := m.byOldSlug[slug]
// 	if r == nil {
// 		return nil, domain.ErrRestaurantNotFound
// 	}
// 	return r, nil
// }
// func (m *mockRestaurantUsecase) ListBranchesBySlug(context.Context, string, int, int) ([]*domain.Restaurant, int64, error) {
// 	return nil, 0, nil
// }
// func (m *mockRestaurantUsecase) ListUniqueRestaurants(context.Context, int, int) ([]*domain.Restaurant, int64, error) {
// 	return nil, 0, nil
// }

// func TestGetRestaurantRedirectOldSlug(t *testing.T) {
// 	gin.SetMode(gin.TestMode)
// 	uc := &mockRestaurantUsecase{
// 		bySlug: map[string]*domain.Restaurant{
// 			"new-cool-restaurant": {ID: "123", Slug: "new-cool-restaurant", RestaurantName: "Cool"},
// 		},
// 		byOldSlug: map[string]*domain.Restaurant{
// 			"old-cool-restaurant": {ID: "123", Slug: "new-cool-restaurant", RestaurantName: "Cool"},
// 		},
// 		deletedSlugs: map[string]bool{},
// 	}
// 	h := handler.NewRestaurantHandler(uc)
// 	r := gin.Default()
// 	r.GET("/api/v1/restaurants/:slug", h.GetRestaurant)

// 	req := httptest.NewRequest(http.MethodGet, "/api/v1/restaurants/old-cool-restaurant", nil)
// 	w := httptest.NewRecorder()
// 	r.ServeHTTP(w, req)

// 	if w.Code != http.StatusPermanentRedirect {
// 		t.Fatalf("expected 308, got %d", w.Code)
// 	}
// 	if loc := w.Header().Get("Location"); loc != "/api/v1/restaurants/new-cool-restaurant" {
// 		t.Fatalf("expected Location header to new slug, got %s", loc)
// 	}
// }

// func TestGetRestaurantDeletedReturns410(t *testing.T) {
// 	gin.SetMode(gin.TestMode)
// 	uc := &mockRestaurantUsecase{
// 		bySlug:       map[string]*domain.Restaurant{},
// 		byOldSlug:    map[string]*domain.Restaurant{},
// 		deletedSlugs: map[string]bool{"gone-rest": true},
// 	}
// 	h := handler.NewRestaurantHandler(uc)
// 	r := gin.Default()
// 	r.GET("/api/v1/restaurants/:slug", h.GetRestaurant)

// 	req := httptest.NewRequest(http.MethodGet, "/api/v1/restaurants/gone-rest", nil)
// 	w := httptest.NewRecorder()
// 	r.ServeHTTP(w, req)

// 	if w.Code != http.StatusGone {
// 		t.Fatalf("expected 410, got %d", w.Code)
// 	}
// }
