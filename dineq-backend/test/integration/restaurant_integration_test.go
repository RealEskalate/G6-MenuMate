package integration

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/routers"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// helper to generate a valid 24-char hex ObjectID string (not calling Mongo) using bson.NewObjectID
func newHexObjectID() string { return bson.NewObjectID().Hex() }

func makeJWT(t *testing.T, env *bootstrap.Env, sub string) string {
	t.Helper()
	claims := jwt.MapClaims{
		"sub":         sub,
		"username":    "integration_user",
		"is_verified": true,
		"role":        "manager",
		"exp":         time.Now().Add(30 * time.Minute).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	s, err := token.SignedString([]byte(env.ATS))
	if err != nil {
		t.Fatalf("failed to sign token: %v", err)
	}
	return s
}

// RestaurantCreatePayload mirrors fields accepted by handler (dto.RestaurantResponse subset)
type RestaurantCreatePayload struct {
	Name  string `json:"name"`
	Phone string `json:"phone"`
}

type RestaurantResponse struct {
	ID   string `json:"id"`
	Slug string `json:"slug"`
	Name string `json:"name"`
}

func TestRestaurantLifecycle_RedirectAndDeletion(t *testing.T) {
	// Ensure we have DB env; skip if missing to allow unit test runs without integration setup
	if os.Getenv("DB_URI") == "" { // fallback if not loaded yet
		// try loading .env (bootstrap does this internally) but quick skip check first
	}

	app, err := bootstrap.InitApp()
	if err != nil {
		t.Skipf("skipping integration test, failed to init app: %v", err)
	}
	defer app.CloseDBConnection()

	env := app.Env
	if env.DB_Uri == "" || env.DB_Name == "" || env.RestaurantCollection == "" || env.ATS == "" {
		t.Skip("missing required env vars for integration test")
	}

	managerID := newHexObjectID()
	jwtToken := makeJWT(t, env, managerID)

	// Build router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	routers.Setup(env, time.Duration(env.CtxTSeconds)*time.Second, app.Mongo.Database(env.DB_Name), router)

	// ---- 1. Create Restaurant ----
	createPayload := RestaurantCreatePayload{Name: "Original Integration Resto", Phone: "+10000000000"}
	body, _ := json.Marshal(createPayload)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/restaurants", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+jwtToken)
	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)
	if rr.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d: %s", rr.Code, rr.Body.String())
	}
	var created RestaurantResponse
	if err := json.Unmarshal(rr.Body.Bytes(), &created); err != nil {
		t.Fatalf("failed to parse create response: %v", err)
	}
	if created.Slug == "" || created.ID == "" {
		t.Fatalf("expected slug & id in create response: %+v", created)
	}
	originalSlug := created.Slug
	createdID := created.ID

	// ---- 2. Update Name (trigger slug change) ----
	updatePayload := map[string]any{"name": "Renamed Integration Resto"}
	uBody, _ := json.Marshal(updatePayload)
	uReq := httptest.NewRequest(http.MethodPut, "/api/v1/restaurants/"+originalSlug, bytes.NewReader(uBody))
	uReq.Header.Set("Content-Type", "application/json")
	uReq.Header.Set("Authorization", "Bearer "+jwtToken)
	uRec := httptest.NewRecorder()
	router.ServeHTTP(uRec, uReq)
	if uRec.Code != http.StatusOK {
		t.Fatalf("expected 200 on update, got %d: %s", uRec.Code, uRec.Body.String())
	}
	var updated RestaurantResponse
	if err := json.Unmarshal(uRec.Body.Bytes(), &updated); err != nil {
		t.Fatalf("failed to parse update response: %v", err)
	}
	if updated.Slug == originalSlug {
		t.Fatalf("slug did not change on update; old=%s new=%s", originalSlug, updated.Slug)
	}
	newSlug := updated.Slug

	// ---- 3. GET old slug -> expect 308 redirect ----
	gReq := httptest.NewRequest(http.MethodGet, "/api/v1/restaurants/"+originalSlug, nil)
	gReq.Header.Set("Authorization", "Bearer "+jwtToken)
	gRec := httptest.NewRecorder()
	router.ServeHTTP(gRec, gReq)
	if gRec.Code != http.StatusPermanentRedirect {
		t.Fatalf("expected 308 for old slug, got %d: %s", gRec.Code, gRec.Body.String())
	}
	loc := gRec.Header().Get("Location")
	expectedLoc := "/api/v1/restaurants/" + newSlug
	if loc != expectedLoc {
		t.Fatalf("expected Location %s, got %s", expectedLoc, loc)
	}

	// ---- 4. GET new slug -> 200 ----
	g2Req := httptest.NewRequest(http.MethodGet, "/api/v1/restaurants/"+newSlug, nil)
	g2Req.Header.Set("Authorization", "Bearer "+jwtToken)
	g2Rec := httptest.NewRecorder()
	router.ServeHTTP(g2Rec, g2Req)
	if g2Rec.Code != http.StatusOK {
		t.Fatalf("expected 200 for new slug get, got %d: %s", g2Rec.Code, g2Rec.Body.String())
	}

	// ---- 5. DELETE restaurant -> 204 ----
	dReq := httptest.NewRequest(http.MethodDelete, "/api/v1/restaurants/"+createdID, nil)
	dReq.Header.Set("Authorization", "Bearer "+jwtToken)
	dRec := httptest.NewRecorder()
	router.ServeHTTP(dRec, dReq)
	if dRec.Code != http.StatusNoContent {
		t.Fatalf("expected 204 on delete, got %d: %s", dRec.Code, dRec.Body.String())
	}

	// ---- 6. GET new slug after deletion -> 410 ----
	g3Req := httptest.NewRequest(http.MethodGet, "/api/v1/restaurants/"+newSlug, nil)
	g3Req.Header.Set("Authorization", "Bearer "+jwtToken)
	g3Rec := httptest.NewRecorder()
	router.ServeHTTP(g3Rec, g3Req)
	if g3Rec.Code != http.StatusGone {
		t.Fatalf("expected 410 after deletion, got %d: %s", g3Rec.Code, g3Rec.Body.String())
	}

	// ---- 7. Cleanup (hard delete the soft-deleted doc) ----
	coll := app.Mongo.Database(env.DB_Name).Collection(env.RestaurantCollection)
	oid, err := bson.ObjectIDFromHex(createdID)
	if err == nil {
		// ignore errors (best-effort cleanup)
		_, _ = coll.DeleteOne(context.Background(), bson.M{"_id": oid})
	}

	// lightweight assertion on slug format (UUID suffix) using util used in unit tests
	if !utilsSlugHasSuffixFormat(updated.Slug) {
		t.Errorf("updated slug does not appear to have expected suffix format: %s", updated.Slug)
	}
}

// utilsSlugHasSuffixFormat performs a light heuristic check that slug ends with 8 hex chars (uuid fragment)
func utilsSlugHasSuffixFormat(slug string) bool {
	if len(slug) < 9 {
		return false
	}
	// last 9 chars should be '-' + 8 hex
	suffix := slug[len(slug)-9:]
	if suffix[0] != '-' {
		return false
	}
	for _, r := range suffix[1:] {
		if !((r >= '0' && r <= '9') || (r >= 'a' && r <= 'f')) {
			return false
		}
	}
	return true
}
