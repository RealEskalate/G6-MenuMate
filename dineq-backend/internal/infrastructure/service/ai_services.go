package services

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/v2/bson"
	"google.golang.org/genai"
)

type IAIService interface {
	StructureWithGemini(ctx context.Context, ocrText string) (*domain.Menu, error)
	// EnhanceWithGemini(ctx context.Context, text string) (string, error)
	TranslateAIBit(text, target string) (string, error)
}

type AiService struct {
	Client             *genai.Client
	Model              string
	ImageSearchService IImageSearchService
}

func NewAIService(ctx context.Context, apiKey string, model string, imageSearchService IImageSearchService) (IAIService, error) {
	// Initialize the GenAI client with the provided API key
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey: apiKey,
	})

	if err != nil {
		return nil, fmt.Errorf("failed to create GenAI client: %w", err)
	}
	return &AiService{
		Client:             client,
		Model:              model,
		ImageSearchService: imageSearchService,
	}, nil
}
func (s *AiService) StructureWithGemini(ctx context.Context, ocrText string) (*domain.Menu, error) {
	itemsJSON, _ := json.MarshalIndent(ocrText, "", "  ")

	data, err := os.ReadFile("prompt.txt")
	if err != nil {
		return nil, err
	}
	prompt := string(data)
	oid := bson.NewObjectID()
	prompt = strings.ReplaceAll(prompt, "{{MenuID}}", oid.Hex())
	prompt = strings.ReplaceAll(prompt, "{{TabID}}", bson.NewObjectID().Hex())
	prompt = strings.ReplaceAll(prompt, "{{CategoryID}}", bson.NewObjectID().Hex())
	prompt = strings.ReplaceAll(prompt, "{{OCR_TEXT}}", string(itemsJSON))

	const maxRetries = 3
	baseDelay := time.Second
	var resp *genai.GenerateContentResponse

	for attempt := 0; attempt < maxRetries; attempt++ {
		resp, err = s.Client.Models.GenerateContent(
			ctx,
			s.Model,
			genai.Text(prompt),
			nil,
		)
		if err == nil {
			// Success, proceed with the rest of the code
			break
		}

		fmt.Printf("GenAI Error on attempt %d: %v\n", attempt+1, err)

		if attempt == maxRetries-1 {
			// Last attempt failed
			return nil, err
		}

		// Exponential backoff
		delay := baseDelay * time.Duration(1<<attempt)
		select {
		case <-time.After(delay):
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}

	if resp != nil && (len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0) {
		return nil, fmt.Errorf("empty response from model")
	}

	responseText := resp.Candidates[0].Content.Parts[0].Text

	// Clean the response text to remove markdown formatting
	cleanedText := strings.TrimSpace(responseText)
	// Remove markdown code block markers
	cleanedText = strings.TrimPrefix(cleanedText, "```json")
	cleanedText = strings.TrimPrefix(cleanedText, "```")
	cleanedText = strings.TrimSuffix(cleanedText, "```")
	// Remove any remaining backticks
	cleanedText = strings.ReplaceAll(cleanedText, "`", "")
	cleanedText = strings.TrimSpace(cleanedText)

	var menuItem domain.Menu
	if err := json.Unmarshal([]byte(cleanedText), &menuItem); err != nil {
		fmt.Printf("Failed to parse AI response as JSON: %v\n", err)
		fmt.Printf("Raw response: %s\n", responseText)
		fmt.Printf("Cleaned response: %s\n", cleanedText)
		// return fallbackStructure(ocrText), err
	}

	if len(menuItem.Tabs) == 0 {
		fmt.Printf("AI returned an empty menu, using fallback\n")
		// menuItem = *fallbackStructure(ocrText)
	}

	// Update the IDs for menu items
	menuItem.RestaurantID = bson.NewObjectID().Hex()
	for i := range menuItem.Tabs {
		menuItem.Tabs[i].ID = bson.NewObjectID().Hex()
		for j := range menuItem.Tabs[i].Categories {
			menuItem.Tabs[i].Categories[j].ID = bson.NewObjectID().Hex()
			for k := range menuItem.Tabs[i].Categories[j].Items {
				menuItem.Tabs[i].Categories[j].Items[k].ID = bson.NewObjectID().Hex()
			}
		}
	}

	// Assign images to menu items
	if err := AssignImagesToMenu(ctx, s.ImageSearchService, &menuItem); err != nil {
		return nil, err
	}
	// fmt.Println("_________________Final Menu with Images:_______________\n", menuItem)
	return &menuItem, nil
}

// func (s *aiService) EnhanceWithGemini(ctx context.Context, text string) (string, error) {
// 	geminiURL := "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyCBRSoLk2_mjiU1UZubHwbqIuPYW957Gok"
// 	prompt := fmt.Sprintf(`Refine this description to be engaging, concise, and informative for an Ethiopian cuisine menu:
// %s

// Include:
// - A vivid, appealing description of the dish.
// - Key ingredients (infer based on the dish name or typical Ethiopian cuisine).
// - An estimated calorie range (e.g., 300-500 kcal).
// - Keep the culinary context of Ethiopian cuisine.
// - Return plain text without markdown or backticks.`, text)

// 	reqBody, _ := json.Marshal(map[string]interface{}{
// 		"contents": []map[string]interface{}{
// 			{
// 				"parts": []map[string]string{
// 					{"text": prompt},
// 				},
// 			},
// 		},
// 	})

// 	req, _ := http.NewRequest("POST", geminiURL, strings.NewReader(string(reqBody)))
// 	req.Header.Set("Content-Type", "application/json")

// 	client := &http.Client{}
// 	resp, err := client.Do(req)
// 	if err != nil {
// 		return text, err
// 	}
// 	defer resp.Body.Close()

// 	var result GeminiResponse
// 	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
// 		return text, err
// 	}

// 	responseText := result.Candidates[0].Content.Parts[0].Text
// 	responseText = strings.Trim(responseText, "` \n\t")
// 	re := regexp.MustCompile("(?s)```(?:json|text)?\n?(.*?)\n?```")
// 	if matches := re.FindStringSubmatch(responseText); len(matches) > 1 {
// 		responseText = matches[1]
// 	}
// 	return responseText, nil
// }

func (s *AiService) TranslateAIBit(text, target string) (string, error) {
	url := "https://aibit-translator.p.rapidapi.com/api/v1/translator/text"
	payload := struct {
		From     string `json:"from"`
		To       string `json:"to"`
		Text     string `json:"text"`
		Provider string `json:"provider"`
	}{
		From:     "auto",
		To:       target,
		Text:     text,
		Provider: "google",
	}
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return text, err
	}
	req, err := http.NewRequest("POST", url, strings.NewReader(string(payloadBytes)))
	if err != nil {
		return text, err
	}

	req.Header.Add("x-rapidapi-key", "29440ed5ccmsha8462d51777b4cdp18e853jsnac8279828a68")
	req.Header.Add("x-rapidapi-host", "aibit-translator.p.rapidapi.com")
	req.Header.Add("Content-Type", "application/json")

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return text, err
	}
	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return text, err
	}

	var result struct {
		Translated string `json:"trans"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return text, err
	}

	return result.Translated, nil
}

// func fallbackStructure(ocrText string) *domain.Menu {
// 		lines := strings.Split(ocrText, "\n")
// 		var items []domain.Item

// 		menuID := bson.NewObjectID().Hex()
// 		tabID := bson.NewObjectID().Hex()
// 		categoryID := bson.NewObjectID().Hex()

// 		// Create a default tab
// 		tab := domain.Tab{
// 			ID:        tabID,
// 			MenuID:    menuID,
// 			Name:      "Food",
// 			IsDeleted: false,
// 			Categories: []domain.Category{
// 				{
// 					ID:    categoryID,
// 					TabID: tabID,
// 					Name:  "MENU ITEM (ምግብ ዝርዝር)",
// 					Items: []domain.Item{},
// 				},
// 			},
// 		}

// 		for _, line := range lines {
// 			line = strings.TrimSpace(line)
// 			if line == "" || !strings.Contains(line, "$") {
// 				continue
// 			}

// 			// Split by $ to get name and price
// 			parts := strings.Split(line, "$")
// 			if len(parts) != 2 {
// 				continue
// 			}
// 			name := strings.TrimSpace(parts[0])
// 			priceStr := strings.TrimSpace(parts[1])

// 			// Remove number prefix if present (e.g., "2 ", "3 ")
// 			if strings.HasPrefix(name, "1 ") || strings.HasPrefix(name, "2 ") || strings.HasPrefix(name, "3 ") ||
// 				strings.HasPrefix(name, "4 ") || strings.HasPrefix(name, "5 ") || strings.HasPrefix(name, "6 ") ||
// 				strings.HasPrefix(name, "7 ") || strings.HasPrefix(name, "8 ") || strings.HasPrefix(name, "9 ") ||
// 				strings.HasPrefix(name, "10 ") || strings.HasPrefix(name, "11 ") || strings.HasPrefix(name, "12 ") ||
// 				strings.HasPrefix(name, "13 ") || strings.HasPrefix(name, "14 ") || strings.HasPrefix(name, "15 ") ||
// 				strings.HasPrefix(name, "16 ") || strings.HasPrefix(name, "17 ") {
// 				name = strings.TrimSpace(name[2:])
// 			}

// 			// Parse price
// 			priceStr = strings.ReplaceAll(priceStr, ",", "") // Remove commas if any
// 			var price float64
// 			if p, err := strconv.ParseFloat(priceStr, 64); err == nil {
// 				price = p
// 			} else {
// 				price = 0.0
// 			}

// 			// Detect if Amharic (contains Ethiopic script)
// 			isAmharic := strings.ContainsAny(name, "አኡኢኤእኦኧበቡቢባቤብቦቧቨቩቪቫቬቭቮቯኀኁኂኃኄኅኆኈኊኋኌኍነኑኒናኔንኖኗኘኙኚኛኜኝኞኟአኡኢኤእኦኧበቡቢባቤብቦቧቨቩቪቫቬቭቮቯኀኁኂኃኄኅኆኈኊኋኌኍነኑኒናኔንኖኗኘኙኚኛኜኝኞኟወዉዊዋዌውዎዏዐዑዒዓዔዕዖዘዙዚዛዜዝዞዟዠዡዢዣዤዥዦዧየዩዪያዬይዮዯደዱዲዳዴድዶዷጀጁጂጃጄጅጆጇገጉጊጋጌግጎጏጐ጑ጒጓጔጕ጖ጘጙጚጛጜጝጞጟጠጡጢጣጤጥጦጧጨጩጪጫጬጭጮጯጰጱጲጳጴጵጶጷጸጹጺጻጼጽጾጿፀፁፂፃፄፅፆፈፉፊፋፌፍፎፏፐፑፒፓፔፕፖፗፘፙፚ")
// 			description := "Traditional Ethiopian dish"
// 			if !isAmharic {
// 				description = "Ethiopian dish"
// 			}

// 			menuItem := domain.Item{
// 				ID:              bson.NewObjectID().Hex(),
// 				CategoryID:      categoryID,
// 				Name:            name,
// 				Description:     description,
// 				Price:           price,
// 				Allergies:       []string{},
// 				HowToEat:        "Serve as usual",
// 				PreparationTime: 0,
// 				Calories:        0,
// 				Image:           []string{"https://placeholder.com/image.jpg"},
// 			}

// 			// Append to default category
// 			tab.Categories[0].Items = append(tab.Categories[0].Items, menuItem)
// 		}

// 		menu := &domain.Menu{
// 			ID:           menuID,
// 			RestaurantID: bson.NewObjectID().Hex(),
// 			Version:      1,
// 			IsPublished:  false,
// 			PublishedAt:  time.Now(),
// 			Tabs:         []domain.Tab{tab},
// 			CreatedAt:    time.Now(),
// 			UpdatedAt:    time.Now(),
// 			UpdatedBy:    "system",
// 			IsDeleted:    false,
// 			ViewCount:    0,
// 		}

// 		return menu
// 	}

func AssignImagesToMenu(ctx context.Context, s IImageSearchService, menu *domain.Menu) error {
	// 1. Flatten all items into a slice of pointers
	type ItemPointer struct {
		Item *domain.Item
	}
	var itemsList []ItemPointer
	for ti := range menu.Tabs {
		tab := &menu.Tabs[ti]
		for ci := range tab.Categories {
			cat := &tab.Categories[ci]
			for ii := range cat.Items {
				itemsList = append(itemsList, ItemPointer{
					Item: &cat.Items[ii],
				})
			}
		}
	}

	// 2. Concurrency setup
	var wg sync.WaitGroup
	sem := make(chan struct{}, 5) // max 5 concurrent API calls
	cache := sync.Map{}           // cache for repeated item names

	for _, ptr := range itemsList {
		wg.Add(1)
		go func(item *domain.Item) {
			defer wg.Done()

			// Skip if already has image
			if len(item.Image) != 0 {
				return
			}

			// Use cache if already searched
			if url, ok := cache.Load(item.Name); ok {
				item.Image = []string{url.(string)}
				return
			}

			// Acquire semaphore
			sem <- struct{}{}
			defer func() { <-sem }()

			// Use name or description for query
			query := item.Name
			if query == "" && item.Description != "" {
				query = item.Description
			}

			url, err := s.SearchImage(ctx, query)
			if err != nil || url == "" {
				url = "https://placeholder.com/image.jpg"
			}

			item.Image = []string{url}
			cache.Store(item.Name, url)
		}(ptr.Item)
	}

	wg.Wait() // wait for all goroutines
	return nil
}
