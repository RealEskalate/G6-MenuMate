package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	handler "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/handlers"
	"github.com/gin-gonic/gin"
)

// mockReviewUsecase implements domain.IReviewUsecase for testing CreateReview handler
// Only methods used by CreateReview are implemented; others panic if called unexpectedly.

type mockReviewUsecase struct {
	created   *domain.Review
	fetch     *domain.Review
	createErr error
	fetchErr  error
}

// mockUserUsecase minimal stub for IUserUsecase (only method used)
type mockUserUsecase struct {
	user *domain.User
	err  error
}

func (m *mockUserUsecase) FindUserByID(id string) (*domain.User, error) { return m.user, m.err }
func (m *mockUserUsecase) FindByUsernameOrEmail(ctx context.Context, s string) (*domain.User, error) {
	return m.user, m.err
}
func (m *mockUserUsecase) GetUserByEmail(email string) (*domain.User, error) { return m.user, m.err }
func (m *mockUserUsecase) UpdateUser(id string, user *domain.User) (*domain.User, error) {
	return m.user, m.err
}
func (m *mockUserUsecase) UpdateProfile(userID string, update domain.UserProfileUpdate, fileName string) (*domain.User, error) {
	return m.user, m.err
}
func (m *mockUserUsecase) ChangePassword(userID, oldPassword, newPassword string) error   { return nil }
func (m *mockUserUsecase) Register(request *domain.User) error                            { return nil }
func (m *mockUserUsecase) AssignRole(userID, branchID string, role domain.UserRole) error { return nil }

// Unused interface methods can be added with panic to satisfy compiler if required later.

func (m *mockReviewUsecase) CreateReview(ctx context.Context, review *domain.Review) error {
	m.created = review
	return m.createErr
}
func (m *mockReviewUsecase) GetReviewByID(ctx context.Context, id string) (*domain.Review, error) {
	return m.fetch, m.fetchErr
}
func (m *mockReviewUsecase) ListReviewsByItem(ctx context.Context, itemID string, page, limit int) ([]*domain.Review, int64, error) {
	panic("not used")
}
func (m *mockReviewUsecase) UpdateReview(ctx context.Context, id string, userID string, update *domain.Review) (*domain.Review, error) {
	panic("not used")
}
func (m *mockReviewUsecase) DeleteReview(ctx context.Context, id string, userID string) error {
	panic("not used")
}
func (m *mockReviewUsecase) GetAverageRatingByItem(ctx context.Context, itemID string) (float64, error) {
	panic("not used")
}
func (m *mockReviewUsecase) GetAverageRatingByRestaurant(ctx context.Context, restaurantID string) (float64, error) {
	panic("not used")
}

func TestCreateReviewHandler(t *testing.T) {
	gin.SetMode(gin.TestMode)

	now := time.Now()
	makeRouter := func(withUser bool, uc *mockReviewUsecase) *gin.Engine {
		r := gin.New()
		if withUser {
			r.Use(func(c *gin.Context) { c.Set("user_id", "user1") })
		}
		userUC := &mockUserUsecase{user: &domain.User{ID: "user1", Username: "tester", ProfileImage: "https://img"}}
		h := handler.NewReviewHandler(uc, userUC)
		r.POST("/api/v1/restaurants/id/:restaurant_id/items/:item_id/reviews", h.CreateReview)
		return r
	}

	t.Run("success", func(t *testing.T) {
		mr := &mockReviewUsecase{}
		mr.fetch = &domain.Review{ID: "new-id", ItemID: "itm1", RestaurantID: "rest1", UserID: "user1", Rating: 4.5, Description: "Great", CreatedAt: now, UpdatedAt: now}
		r := makeRouter(true, mr)
		payload := map[string]any{"description": "Great", "rating": 4.5}
		b, _ := json.Marshal(payload)
		req := httptest.NewRequest(http.MethodPost, "/api/v1/restaurants/id/rest1/items/itm1/reviews", bytes.NewReader(b))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusCreated {
			t.Fatalf("expected 201 got %d body=%s", w.Code, w.Body.String())
		}
		if mr.created == nil || mr.created.RestaurantID != "rest1" || mr.created.ItemID != "itm1" || mr.created.UserID != "user1" {
			t.Fatalf("review not populated correctly: %#v", mr.created)
		}
	})

	t.Run("unauthorized", func(t *testing.T) {
		mr := &mockReviewUsecase{}
		r := makeRouter(false, mr)
		b := bytes.NewReader([]byte(`{"description":"Great","rating":4}`))
		req := httptest.NewRequest(http.MethodPost, "/api/v1/restaurants/id/rest1/items/itm1/reviews", b)
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusUnauthorized {
			t.Fatalf("expected 401 got %d body=%s", w.Code, w.Body.String())
		}
	})

	t.Run("rating_out_of_range", func(t *testing.T) {
		mr := &mockReviewUsecase{}
		mr.fetch = &domain.Review{ID: "new-id", ItemID: "itm1", RestaurantID: "rest1", UserID: "user1", Rating: 6, Description: "Bad", CreatedAt: now, UpdatedAt: now}
		r := makeRouter(true, mr)
		b := bytes.NewReader([]byte(`{"description":"Bad","rating":6}`))
		req := httptest.NewRequest(http.MethodPost, "/api/v1/restaurants/id/rest1/items/itm1/reviews", b)
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusBadRequest {
			t.Fatalf("expected 400 got %d body=%s", w.Code, w.Body.String())
		}
	})

	t.Run("invalid_json", func(t *testing.T) {
		mr := &mockReviewUsecase{}
		r := makeRouter(true, mr)
		b := bytes.NewReader([]byte(`{"description":`)) // malformed
		req := httptest.NewRequest(http.MethodPost, "/api/v1/restaurants/id/rest1/items/itm1/reviews", b)
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusBadRequest {
			t.Fatalf("expected 400 got %d body=%s", w.Code, w.Body.String())
		}
	})
}
