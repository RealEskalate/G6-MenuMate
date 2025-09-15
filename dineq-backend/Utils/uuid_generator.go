package utils

import (
	"github.com/google/uuid"
)

// GenerateUUID generates a new UUID (version 4) and returns it as a string.
func GenerateUUID() string {
	return uuid.New().String()
}
