package dto

import (
	"errors"
	"net/http"
	"testing"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

func TestNormalizeError_Domain(t *testing.T) {
    status, resp := NormalizeError(domain.ErrEmailAlreadyInUse)
    if status != http.StatusConflict { t.Fatalf("expected 409 got %d", status) }
    if resp.Code != "email_already_in_use" { t.Fatalf("unexpected code %s", resp.Code) }
    if resp.Message != domain.ErrEmailAlreadyInUse.Error() { t.Fatalf("unexpected message %s", resp.Message) }
}

func TestNormalizeError_DuplicateKey(t *testing.T) {
    mongoErr := errors.New(`E11000 duplicate key error collection: g6.users index: email_1 dup key: { : "test@example.com" }`)
    status, resp := NormalizeError(mongoErr)
    if status != http.StatusConflict { t.Fatalf("expected conflict got %d", status) }
    if resp.Field != "email" { t.Fatalf("expected field email got %s", resp.Field) }
    if resp.Code != "email_already_in_use" { t.Fatalf("expected code email_already_in_use got %s", resp.Code) }
}

func TestNormalizeError_Fallback(t *testing.T) {
    genericErr := errors.New("some random failure happened")
    status, resp := NormalizeError(genericErr)
    if status != http.StatusBadRequest { t.Fatalf("expected 400 got %d", status) }
    if resp.Code == "" { t.Fatalf("expected non-empty code") }
    if resp.Message == "" { t.Fatalf("expected non-empty message") }
}
