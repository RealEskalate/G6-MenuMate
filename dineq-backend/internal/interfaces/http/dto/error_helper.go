package dto

import (
	"errors"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/gin-gonic/gin"
)

// mongo duplicate key pattern example: E11000 duplicate key error collection: db.users index: email_1 dup key: { email: "test@example.com" }
var mongoDupKeyRegex = regexp.MustCompile(`(?i)duplicate key.*?index: (\w+).*?\{ :? ?"?([\w@.+-]+)"? ?}`)

// map index names to field identifiers if they differ
var indexToField = map[string]string{
    "email_1":    "email",
    "username_1": "username",
    "phone_1":    "phone",
}

// domain error -> code mapping (snake_case)
var domainErrorCode = map[error]string{
    domain.ErrEmailAlreadyInUse:        "email_already_in_use",
    domain.ErrUsernameAlreadyInUse:     "username_already_in_use",
    domain.ErrPhoneAlreadyInUse:        "phone_already_in_use",
    domain.ErrInvalidCredentials:       "invalid_credentials",
    domain.ErrInvalidInput:             "invalid_input",
    domain.ErrUnauthorized:             "unauthorized",
    domain.ErrNotFound:                 "not_found",
    domain.ErrUserNotFound:             "user_not_found",
    domain.ErrRestaurantNotFound:       "restaurant_not_found",
    domain.ErrRestaurantDeleted:        "restaurant_deleted",
    domain.ErrFailedToRegisterUser:     "failed_to_register_user",
    domain.ErrTokenGenerationIssue:     "token_generation_failed",
    domain.ErrTokenExpired:             "token_expired",
    domain.ErrTokenInvalidOrExpired:    "token_invalid_or_expired",
    domain.ErrRefreshTokenNotFound:     "refresh_token_not_found",
    domain.ErrFailedToCreateOCRJob:     "failed_to_create_ocr_job",
    domain.ErrFileToUpload:             "failed_to_upload_file",
    domain.ErrInvalidFile:              "invalid_file",
    domain.ErrFailedToProcessRequest:   "failed_to_process_request",
    domain.ErrFailedToResetPassword:    "failed_to_reset_password",
    domain.ErrPasswordShortLen:         "password_too_short",
    domain.ErrPasswordMustContainUpperLetter: "password_missing_uppercase",
    domain.ErrPasswordMustContainLowerLetter: "password_missing_lowercase",
    domain.ErrPasswordMustContainNumber:      "password_missing_number",
    domain.ErrPasswordMustContainSpecialChar: "password_missing_special_char",
}

// NormalizeError converts an arbitrary error into our unified ErrorResponse metadata.
// httpStatus is determined heuristically if not explicitly provided.
func NormalizeError(err error) (status int, resp ErrorResponse) {
    if err == nil {
        return http.StatusInternalServerError, ErrorResponse{Message: "unknown error", Code: "unknown_error"}
    }

    // Direct domain error mapping (avoid hashing arbitrary error in map lookup which caused panic for mongo.WriteException)
    for derr, code := range domainErrorCode {
        if errors.Is(err, derr) {
            status = statusFromDomainError(derr)
            return status, ErrorResponse{Message: derr.Error(), Code: code}
        }
    }

    raw := err.Error()

    // Duplicate key detection (Mongo)
    if strings.Contains(strings.ToLower(raw), "duplicate key") {
        field, value := parseDuplicateKey(raw)
        msg := field + " already in use"
        code := field + "_already_in_use"
        resp = ErrorResponse{Message: msg, Code: code, Field: field, Error: value}
        // 409 Conflict for duplicates
        return http.StatusConflict, resp
    }

    // Fallback classification
    status = http.StatusBadRequest
    if strings.Contains(strings.ToLower(raw), "not found") {
        status = http.StatusNotFound
    } else if strings.Contains(strings.ToLower(raw), "unauthorized") || strings.Contains(strings.ToLower(raw), "forbidden") {
        status = http.StatusUnauthorized
    } else if strings.Contains(strings.ToLower(raw), "internal") || strings.Contains(strings.ToLower(raw), "timeout") {
        status = http.StatusInternalServerError
    }

    resp = ErrorResponse{Message: userFacingMessage(raw), Code: canonicalizeCode(raw), Error: raw}
    return status, resp
}

func statusFromDomainError(err error) int {
    switch err {
    case domain.ErrNotFound, domain.ErrUserNotFound, domain.ErrRestaurantNotFound:
        return http.StatusNotFound
    case domain.ErrRestaurantDeleted:
        return http.StatusGone
    case domain.ErrUnauthorized:
        return http.StatusUnauthorized
    case domain.ErrInvalidCredentials, domain.ErrInvalidInput:
        return http.StatusBadRequest
    case domain.ErrEmailAlreadyInUse, domain.ErrUsernameAlreadyInUse, domain.ErrPhoneAlreadyInUse:
        return http.StatusConflict
    default:
        return http.StatusInternalServerError
    }
}

// parseDuplicateKey extracts field and value from a Mongo duplicate key error string.
func parseDuplicateKey(msg string) (field, value string) {
    lower := strings.ToLower(msg)
    // attempt simple pattern first
    if strings.Contains(lower, "email") {
        field = "email"
    } else if strings.Contains(lower, "username") {
        field = "username"
    } else if strings.Contains(lower, "phone") {
        field = "phone"
    }

    matches := mongoDupKeyRegex.FindStringSubmatch(msg)
    if len(matches) >= 3 {
        idx := matches[1]
        val := matches[2]
        if f, ok := indexToField[idx]; ok {
            field = f
        } else if field == "" { // fallback to index name prefix
            field = strings.TrimSuffix(idx, "_1")
        }
        value = val
    }
    if field == "" {
        field = "resource"
    }
    return
}

// userFacingMessage trims overly verbose messages.
func userFacingMessage(raw string) string {
    // For now just strip common mongo prefix
    if i := strings.Index(raw, "duplicate key error"); i >= 0 {
        return "duplicate value"
    }
    return raw
}

// canonicalizeCode converts arbitrary raw error text to snake_case token.
func canonicalizeCode(raw string) string {
    raw = strings.ToLower(raw)
    repl := strings.NewReplacer(" ", "_", "-", "_", ":", "", ",", "", ".", "", "=", "", "'", "", "\"", "")
    raw = repl.Replace(raw)
    raw = regexp.MustCompile(`[^a-z0-9_]+`).ReplaceAllString(raw, "")
    raw = strings.Trim(raw, "_")
    if raw == "" {
        return "error"
    }
    if len(raw) > 60 {
        raw = raw[:60]
    }
    return raw
}

// WriteError normalizes and writes the error to the gin context.
func WriteError(c *gin.Context, err error) {
    status, e := NormalizeError(err)
    if isProduction() {
        e.Error = "" // strip internal detail
    }
    c.JSON(status, e)
}

// WriteValidationError writes a structured validation error for a specific field.
func WriteValidationError(c *gin.Context, field, message, code string, internal error) {
    if code == "" { code = canonicalizeCode(message) }
    e := ErrorResponse{Message: message, Code: code, Field: field}
    if internal != nil && !isProduction() { e.Error = internal.Error() }
    c.JSON(http.StatusBadRequest, e)
}

// NewError creates a new generic API error.
func NewError(message, code string) ErrorResponse {
    if code == "" {
        code = canonicalizeCode(message)
    }
    return ErrorResponse{Message: message, Code: code}
}

// JoinErrors join multiple errors into one (for potential batch validation scenarios)
func JoinErrors(errs ...error) error {
    var parts []string
    for _, e := range errs {
        if e == nil { continue }
        parts = append(parts, e.Error())
    }
    if len(parts) == 0 { return nil }
    return errors.New(strings.Join(parts, "; "))
}

// isProduction checks APP_ENV for production masking.
func isProduction() bool {
    env := strings.ToLower(os.Getenv("APP_ENV"))
    return env == "prod" || env == "production"
}
