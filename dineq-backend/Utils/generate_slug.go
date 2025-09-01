package utils

import (
	"regexp"
	"strings"

	"github.com/google/uuid"
)

func GenerateSlug(name string) string {
	slug := strings.ToLower(name)

	// Remove non-alphanumeric characters
	re := regexp.MustCompile(`[^a-z0-9]+`)
	slug = re.ReplaceAllString(slug, "")

	// Append short UUID to guarantee uniqueness
	uid := uuid.New().String()[:8]

	return slug + "-" + uid

}
