package services

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math"
	"strings"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
	"google.golang.org/genai"
)

// Interface kept for existing callers
type IAIService interface {
	StructureWithGemini(ctx context.Context, ocrText string) (*domain.Menu, error)
	TranslateAIBit(text, target string) (string, error)
}

type GeminiService struct {
	client *genai.Client
	model  string
	lastRaw string
}

func NewAIService(ctx context.Context, apiKey string, model string, _ IImageSearchService) (IAIService, error) {
	if model == "" { model = "gemini-1.5-flash" }
	client, err := genai.NewClient(ctx, &genai.ClientConfig{APIKey: apiKey})
	if err != nil { return nil, fmt.Errorf("failed to create Gemini client: %w", err) }
	return &GeminiService{client: client, model: model}, nil
}

// Internal DTOs matching expected JSON
type menuProcessingResults struct { MenuItems []menuItemResult `json:"menuItems"` }
type menuItemResult struct {
	ID                  string   `json:"id"`
	Name                string   `json:"name"`
	NameAmharic         string   `json:"nameAmharic"`
	Description         string   `json:"description"`
	DescriptionAmharic  string   `json:"descriptionAmharic"`
	Price               float64  `json:"price"`
	Currency            string   `json:"currency"`
	Tab                 string   `json:"tab"`
	TabTags             []string `json:"tab_tags"`
	TabTagsAm           []string `json:"tab_tags_am"`
	Ingredients         any      `json:"ingredients"`
	NutritionalInfo     any      `json:"nutritionalInfo"`
	Allergens           []string `json:"allergens"`
	Allergies           string   `json:"allergies"`
	AllergiesAm         string   `json:"allergies_am"`
	EatingInstructions  string   `json:"eatingInstructions"`
	EatingInstructionsAm string  `json:"eatingInstructionsAm"`
	IsAvailable         bool     `json:"isAvailable"`
	PreparationTime     int      `json:"preparationTime"`
}

// StructureWithGemini adapts ProcessOCRText style to existing domain.Menu output
func (gs *GeminiService) StructureWithGemini(ctx context.Context, ocrText string) (*domain.Menu, error) {
	prompt := gs.createMenuStructuringPrompt(ocrText, "")
	var lastErr error
	var raw string
	// exponential backoff for transient errors (429/503) only
	for attempt := 1; attempt <= 3; attempt++ {
		resp, err := gs.client.Models.GenerateContent(ctx, gs.model, genai.Text(prompt), nil)
		if err != nil {
			if transient(err) && attempt < 3 {
				backoff := time.Duration(math.Pow(2, float64(attempt-1))) * 500 * time.Millisecond
				time.Sleep(backoff)
				lastErr = err
				continue
			}
			return nil, fmt.Errorf("failed to generate content: %w", err)
		}
		if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
			lastErr = errors.New("no response from Gemini")
			continue
		}
		var buf strings.Builder
		for _, p := range resp.Candidates[0].Content.Parts { buf.WriteString(fmt.Sprintf("%v", p)) }
	raw = buf.String()
	gs.lastRaw = raw
		results, err := gs.parseGeminiResponse(raw)
		if err != nil {
			lastErr = fmt.Errorf("failed to parse Gemini response: %w", err)
			if attempt < 3 { time.Sleep(300 * time.Millisecond); continue }
			return nil, lastErr
		}
		// Build menu
		menu := &domain.Menu{ID: bson.NewObjectID().Hex(), RestaurantID: bson.NewObjectID().Hex(), Version: 1, CreatedAt: time.Now().UTC(), UpdatedAt: time.Now().UTC()}
		tabIndex := map[string]*domain.Tab{}
		for _, mi := range results.MenuItems {
			if strings.TrimSpace(mi.Name) == "" { continue }
			// bound prep time 1..60 (default 15 if zero)
			prep := mi.PreparationTime
			if prep <= 0 { prep = 15 }
			if prep < 1 { prep = 1 }
			if prep > 60 { prep = 60 }
			// derive tab from tags
			var firstTab string
			if len(mi.TabTags) > 0 { firstTab = mi.TabTags[0] }
			tabName := firstNonEmpty(mi.Tab, firstTab, "General")
			t, ok := tabIndex[tabName]
			if !ok {
				// attempt Amharic name mapping for tab
				amTab := amharicScriptForLabel(tabName)
				t = &domain.Tab{ID: bson.NewObjectID().Hex(), MenuID: menu.ID, Name: tabName, NameAm: amTab}
				tabIndex[tabName] = t
			}
			// classify category heuristically
			catName := classifyCategory(mi.Name, mi.Description)
			amCat := amharicScriptForLabel(catName)
			var cat *domain.Category
			for i := range t.Categories { if t.Categories[i].Name == catName { cat = &t.Categories[i]; break } }
			if cat == nil { t.Categories = append(t.Categories, domain.Category{ID: bson.NewObjectID().Hex(), TabID: t.ID, Name: catName, NameAm: amCat}); cat = &t.Categories[len(t.Categories)-1] }
			// Combine legacy array 'Allergens' with new scalar 'Allergies'
			allergySlice := mi.Allergens
			if len(allergySlice) == 0 && strings.TrimSpace(mi.Allergies) != "" {
				// Create a single entry slice from full sentence; could be improved to parse ingredients list
				allergySlice = []string{mi.Allergies}
			}
			// Extract nutritional info if object
			var calories, protein, carbs, fat int
			if m, ok := mi.NutritionalInfo.(map[string]any); ok {
				if v, ok2 := m["calories"]; ok2 { if f, ok3 := toInt(v); ok3 { calories = f } }
				if v, ok2 := m["protein"]; ok2 { if f, ok3 := toInt(v); ok3 { protein = f } }
				if v, ok2 := m["carbs"]; ok2 { if f, ok3 := toInt(v); ok3 { carbs = f } }
				if v, ok2 := m["fat"]; ok2 { if f, ok3 := toInt(v); ok3 { fat = f } }
			}
			var nutri *domain.NutritionalInfo
			if calories > 0 || protein > 0 || carbs > 0 || fat > 0 {
				nutri = &domain.NutritionalInfo{Calories: calories, Protein: protein, Carbs: carbs, Fat: fat}
			}
			item := domain.Item{ID: bson.NewObjectID().Hex(), Name: mi.Name, NameAm: mi.NameAmharic, Description: mi.Description, DescriptionAm: mi.DescriptionAmharic, Price: mi.Price, Currency: firstNonEmpty(mi.Currency, "ETB"), PreparationTime: prep, Allergies: allergySlice, AllergiesAm: mi.AllergiesAm, HowToEat: mi.EatingInstructions, HowToEatAm: mi.EatingInstructionsAm, Calories: calories, Protein: protein, Carbs: carbs, Fat: fat, NutritionalInfo: nutri, TabTags: mi.TabTags, TabTagsAm: mi.TabTagsAm, IsDeleted: false}
			cat.Items = append(cat.Items, item)
		}
		for _, t := range tabIndex { menu.Tabs = append(menu.Tabs, *t) }
		// attach raw JSON to menu in a placeholder way (could be stored elsewhere via caller)
		// The caller (usecase) will capture raw JSON via job.Results.RawAIJSON if integrated.
		_ = raw
		return menu, nil
	}
	if lastErr != nil { return nil, lastErr }
	return nil, errors.New("AI structuring failed with unknown error")
}

// RawLastAIJSON returns the last raw AI JSON (best-effort) produced by StructureWithGemini
func (gs *GeminiService) RawLastAIJSON() string { return gs.lastRaw }

func (gs *GeminiService) createMenuStructuringPrompt(ocrText, restaurantName string) string {
	return fmt.Sprintf(`You are an expert Ethiopian menu structuring AI. Produce ONLY one valid JSON object. No markdown, no commentary.

SCHEMA (exact field names):
{
	"menuItems": [
		{
			"name": "English dish name",
			"nameAmharic": "Amharic script dish name",
			"description": "Concise English description (<=18 words).",
			"descriptionAmharic": "Amharic script translation of description",
			"tab_tags": ["Breakfast","Lunch"],
			"tab_tags_am": ["ቁርስ","ምሳ"],
			"price": 60.0,
			"currency": "ETB",
			"allergies": "Contains Dairy, Gluten. Please inform staff of any allergies.",
			"allergies_am": "ይዟል ወተት, ግሉተን። እባክዎን ስለ አለርጂ ለሰራተኞች ያሳውቁ።",
			"ingredients": ["Tomato","Berbere","Injera"],
			"ingredients_am": ["ቲማቲም","በርበሬ","እንጀራ"],
			"nutritional_info": {"calories": 320, "protein": 15, "carbs": 28, "fat": 14},
			"preparation_time": 25,
			"how_to_eat": "Tear injera, scoop stew, eat by hand.",
			"how_to_eat_am": "እንጀራ ቁርጠው ወጡን ይውሰዱ በእጅ ይበሉ።"
		}
	]
}

TRANSLATION & NAME RULES:
1. name (English): If a widely accepted English menu term exists (e.g. "Shiro Stew", "Lentil Sambusa"), use it. If not, use a clear Latin transliteration of the Amharic (e.g. "Doro Wot", "Yebeg Tibs"). No Amharic script in the English name.
2. nameAmharic: ALWAYS true Amharic Ethiopic script (ግዕዝ letters). Never leave blank. Must not repeat Latin letters. If OCR only had Latin form, translate or transliterate into proper Amharic script.
3. description: Natural English sentence (<=18 words), no leading dish name repetition unless needed for clarity.
4. descriptionAmharic: Faithful Amharic translation (script), not Latin. If unsure, concise neutral descriptive translation.
5. *_am lists (tab_tags_am, ingredients_am): each element translated into Amharic script (not Latin). If no direct Amharic for a foreign brand term, transliterate into script.
6. Never output null; use [] or "". *_am fields must never be missing or empty unless the English counterpart is also empty AND genuinely unknowable.
7. If an English ingredient lacks direct translation, keep English in ingredients and provide best Amharic transliteration in ingredients_am.

ALLERGEN RULES:
English: "Contains X, Y, Z. Please inform staff of any allergies." If none: "Contains none commonly recognized. Please inform staff of any allergies."
Amharic: "ይዟል X, Y, Z። እባክዎን ስለ አለርጂ ለሰራተኞች ያሳውቁ።" or for none: "ታዋቂ አለርጂ አልተገኘም። እባክዎን ስለ አለርጂ ለሰራተኞች ያሳውቁ።".

NUTRITION:
Estimate realistic positive integers: calories 80–1200; macros consistent (protein+carbs+fat*9 ~= calories within 15%%).

OTHER RULES:
- preparation_time integer 1–60.
- currency: ETB default if absent.
- Deduplicate identical (name+price) items by merging ingredients.
- NO images if not present in text -> set image arrays empty (but still output fields as empty arrays if schema demands—they are not in this reduced schema so omit).
- Absolutely NO null, markdown fences, or commentary. Output only JSON.
- Ensure EVERY menu item has nameAmharic & descriptionAmharic filled (never identical Latin copy of English).
- Absolutely forbid returning English words inside *_am fields when a standard Amharic equivalent exists; use Ethiopic characters (e.g. Breakfast -> ቁርስ, Lunch -> ምሳ, Meat -> ስጋ, Vegetable -> አትክልት, Stew -> ወጥ, Soup -> ሾርባ, Egg(s) -> እንቁላል, Combination -> ቅልቅል, Specialty -> ልዩ, Vegetarian -> በተክል).

Restaurant: %s
OCR TEXT:
%s`, restaurantName, ocrText)
}

func (gs *GeminiService) parseGeminiResponse(response string) (*menuProcessingResults, error) {
	response = strings.TrimSpace(response)
	// Preserve newlines initially for better pattern detection, then clean.
	log.Printf("[DEBUG] Raw Gemini response (original): %.500s", response)

	// If response contains a Go fmt of struct (&{... ```json{ ... }```}) we try to isolate the JSON code block
	// Remove any leading Go struct prefix up to first code fence or '{'
	if idx := strings.Index(response, "```json"); idx > 0 {
		response = response[idx:]
	}
	if !strings.HasPrefix(response, "{" ) {
		// attempt to find first '{' that begins a JSON object containing "menuItems"
		if start := strings.Index(response, "{\n"); start != -1 {
			response = response[start:]
		}
	}

	// Strip fences
	response = strings.TrimPrefix(response, "```json")
	response = strings.TrimPrefix(response, "```")
	response = strings.TrimSuffix(response, "```")

	// Now collapse whitespace
	response = strings.TrimSpace(response)
	response = strings.Trim(response, "`\"")
	response = strings.ReplaceAll(response, "\r", "")

	// Some models wrap again inside text; extract largest JSON object containing "menuItems"
	if !strings.HasPrefix(response, "{") || !strings.Contains(response, "menuItems") {
		if start := strings.Index(response, "{"); start != -1 {
			if end := strings.LastIndex(response, "}"); end != -1 && end > start {
				candidate := response[start : end+1]
				if strings.Contains(candidate, "menuItems") { response = candidate }
			}
		}
	}

	log.Printf("[DEBUG] Gemini JSON candidate: %.500s", response)
	// Normalize field aliases (snake_case to camelCase expected by struct tags)
	normalized := normalizeAIJSONAliases(response)
	var results menuProcessingResults
	dec := json.NewDecoder(bytes.NewReader([]byte(normalized)))
	if err := dec.Decode(&results); err != nil {
		start := strings.Index(normalized, "{")
		end := strings.LastIndex(normalized, "}")
		if start != -1 && end != -1 && end > start {
			jsonStr := normalized[start : end+1]
			dec2 := json.NewDecoder(bytes.NewReader([]byte(jsonStr)))
			if err2 := dec2.Decode(&results); err2 == nil { return &results, nil } else { return nil, fmt.Errorf("failed to decode JSON response: %v, response: %s", err2, normalized) }
		}
		return nil, fmt.Errorf("failed to decode JSON response: %v, response: %s", err, normalized)
	}
	return &results, nil
}

// normalizeAIJSONAliases replaces snake_case keys produced by prompt with the camelCase keys expected by the parser structs.
func normalizeAIJSONAliases(s string) string {
	replacer := strings.NewReplacer(
		"\"name_am\"", "\"nameAmharic\"",
		"\"description_am\"", "\"descriptionAmharic\"",
		"\"nutritional_info\"", "\"nutritionalInfo\"",
		"\"how_to_eat\"", "\"eatingInstructions\"",
		"\"how_to_eat_am\"", "\"eatingInstructionsAm\"",
	)
	return replacer.Replace(s)
}

// toInt attempts to coerce numeric JSON (float64, int, string) to int
func toInt(v any) (int, bool) {
	switch n := v.(type) {
	case float64:
		return int(n), true
	case int:
		return n, true
	case int32:
		return int(n), true
	case int64:
		return int(n), true
	case string:
		if strings.TrimSpace(n) == "" { return 0, false }
		var f float64
		_, err := fmt.Sscanf(n, "%f", &f)
		if err != nil { return 0, false }
		return int(f), true
	default:
		return 0, false
	}
}

// TranslateAIBit simple translation using same model
func (gs *GeminiService) TranslateAIBit(text, target string) (string, error) {
	ctx := context.Background()
	var langName string
	switch target { case "am": langName = "Amharic"; case "or": langName = "Oromo"; case "en": langName = "English"; default: langName = "English" }
	prompt := fmt.Sprintf("Translate the following text to %s. Return only the translation without any additional text:\n\n%s", langName, text)
	resp, err := gs.client.Models.GenerateContent(ctx, gs.model, genai.Text(prompt), nil)
	if err != nil { return text, fmt.Errorf("failed to translate text: %w", err) }
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 { return text, fmt.Errorf("no translation response from Gemini") }
	var out string
	for _, part := range resp.Candidates[0].Content.Parts { out += fmt.Sprintf("%v", part) }
	return strings.TrimSpace(out), nil
}

func firstNonEmpty(vals ...string) string { for _, v := range vals { if strings.TrimSpace(v) != "" { return v } }; return "" }

// transient determines if an error is a retryable transient AI error (HTTP 429/503)
func transient(err error) bool {
	if err == nil { return false }
	msg := err.Error()
	if strings.Contains(msg, "429") || strings.Contains(strings.ToLower(msg), "too many requests") { return true }
	if strings.Contains(msg, "503") || strings.Contains(strings.ToLower(msg), "unavailable") { return true }
	if strings.Contains(strings.ToLower(msg), "overloaded") { return true }
	return false
}

// classifyCategory provides a lightweight heuristic categorization when category tags removed.
func classifyCategory(name, desc string) string {
 	n := strings.ToLower(name + " " + desc)
 	switch {
 	case strings.Contains(n, "soup") || strings.Contains(n, "ቅቅል") || strings.Contains(n, "broth"):
 		return "Soup"
 	case strings.Contains(n, "stew") || strings.Contains(n, "wot") || strings.Contains(n, "ወጥ"):
 		return "Stew"
 	case strings.Contains(n, "egg") || strings.Contains(n, "እንቁላል"):
 		return "Eggs"
 	case strings.Contains(n, "kitfo") || strings.Contains(n, "tibs") || strings.Contains(n, "beef") || strings.Contains(n, "meat") || strings.Contains(n, "ስጋ"):
 		return "Meat"
 	case strings.Contains(n, "gomen") || strings.Contains(n, "greens") || strings.Contains(n, "አትክልት"):
 		return "Vegetable"
 	case strings.Contains(n, "firfir") || strings.Contains(n, "combination") || strings.Contains(n, "mahber"):
 		return "Combination"
 	case strings.Contains(n, "genfo") || strings.Contains(n, "porridge"):
 		return "Vegetarian"
 	default:
 		return "General"
 	}
}

// amharicScriptForLabel maps known English category/tab labels to Amharic script.
func amharicScriptForLabel(label string) string {
 	switch strings.ToLower(strings.TrimSpace(label)) {
 	case "breakfast": return "ቁርስ"
 	case "lunch": return "ምሳ"
 	case "meat": return "ስጋ"
 	case "vegetable": return "አትክልት"
 	case "vegetarian": return "በተክል"
 	case "stew": return "ወጥ"
 	case "soup": return "ሾርባ"
 	case "eggs", "egg": return "እንቁላል"
 	case "combination": return "ቅልቅል"
 	case "specialty": return "ልዩ"
 	case "general": return "አጠቃላይ"
 	default: return "" // unknown -> let caller fallback
 	}
}
