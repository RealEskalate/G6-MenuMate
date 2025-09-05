package dto

// ErrorResponse represents the unified error payload returned by the API.
// Fields:
//  message: short, user-friendly description (ALWAYS present)
//  code: machine-readable snake_case token (ALWAYS present)
//  field: (optional) field name related to the error (e.g., "email")
//  error: (optional) internal/debug detail (only in non-production or when safe)
type ErrorResponse struct {
	Message string `json:"message"`
	Code    string `json:"code"`
	Field   string `json:"field,omitempty"`
	Error   string `json:"error,omitempty"`
}

type SuccessResponse struct {
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}
