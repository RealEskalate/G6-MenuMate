package utils

import (
	"regexp"
	"strings"
	"unicode"
	"unicode/utf8"

	"github.com/google/uuid"
	"golang.org/x/text/unicode/norm"
)

// GenerateSlug converts an arbitrary title/sentence into a URL friendly slug and
// appends an 8 char unique suffix derived from a UUID (hex only) to minimize collision risk.
// Examples:
//   "Hello World!" => "hello-world-1a2b3c4d"
//   "Äëî Ünicôde"  => "aeio-unicode-9f8e7d6c"
// Rules:
//   * Lower-case
//   * Non alphanumeric (after accent stripping) become single hyphens
//   * Trim leading / trailing hyphens
//   * Collapse consecutive hyphens
//   * Ensure base portion is not empty (fallback: "item")
func GenerateSlug(text string) string {
	base := sanitizeToSlugCore(text)
	if base == "" {
		base = "item"
	}
	// create short uuid (first 8 hex chars, remove hyphens first)
	raw := uuid.New().String()
	raw = strings.ReplaceAll(raw, "-", "")
	suffix := raw[:8]
	return base + "-" + suffix
}

// sanitizeToSlugCore performs normalization & transliteration then builds the core slug (without unique suffix)
func sanitizeToSlugCore(s string) string {
	s = strings.TrimSpace(s)
	if s == "" {
		return ""
	}
	// Unicode normalize and remove diacritics
	s = norm.NFD.String(s)
	// Strip combining marks
	var b strings.Builder
	b.Grow(len(s))
	for _, r := range s {
		if unicode.Is(unicode.Mn, r) { // skip diacritical marks
			continue
		}
		b.WriteRune(r)
	}
	s = b.String()
	s = strings.ToLower(s)

	// Replace any run of non a-z0-9 with hyphen
	reNon := regexp.MustCompile(`[^a-z0-9]+`)
	s = reNon.ReplaceAllString(s, "-")
	// Trim leading/trailing hyphens
	s = strings.Trim(s, "-")
	// Guard against empty after trimming
	if s == "" {
		return ""
	}
	// Ensure valid UTF-8 (defensive)
	if !utf8.ValidString(s) {
		// fallback: remove invalid runes
		var clean strings.Builder
		for _, r := range s {
			if r == unicode.ReplacementChar {
				continue
			}
			clean.WriteRune(r)
		}
		s = clean.String()
	}
	return s
}

