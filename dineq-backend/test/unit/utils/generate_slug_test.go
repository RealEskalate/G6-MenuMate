package utils_test

import (
	"regexp"
	"testing"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
)

func TestGenerateSlugBasic(t *testing.T) {
	slug := utils.GenerateSlug("Hello World!")
	if match, _ := regexp.MatchString(`^hello-world-[0-9a-f]{8}$`, slug); !match {
		t.Fatalf("unexpected slug format: %s", slug)
	}
}

func TestGenerateSlugUnicode(t *testing.T) {
	slug := utils.GenerateSlug("Äëî Ünicôde Test")
	if match, _ := regexp.MatchString(`^aei-unicode-test-[0-9a-f]{8}$`, slug); !match {
		t.Fatalf("unexpected unicode slug format: %s", slug)
	}
}

func TestGenerateSlugEmpty(t *testing.T) {
	slug := utils.GenerateSlug("   ")
	if match, _ := regexp.MatchString(`^item-[0-9a-f]{8}$`, slug); !match {
		t.Fatalf("unexpected empty slug format: %s", slug)
	}
}
