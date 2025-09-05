package dto

import (
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

type RestaurantResponse struct {
	ID                 string          `json:"id"`
	Slug               string          `json:"slug"`
	Name               string          `json:"name"`
	ManagerID          string          `json:"manager_id"`
	Phone              string          `json:"phone"`
	PreviousSlugs      []string        `json:"previous_slugs,omitempty"`
	Tags               []string        `json:"tags,omitempty"`
	About              *string         `json:"about,omitempty"`
	LogoImage          *string         `json:"logo_image,omitempty"`
	VerificationStatus string          `json:"verification_status"`
	VerificationDocs   *string         `json:"verification_docs,omitempty"`
	DefaultCurrency    string          `json:"default_currency,omitempty"`
	DefaultLanguage    string          `json:"default_language,omitempty"`
	DefaultVat         float64         `json:"default_vat,omitempty"`
	TaxId              string          `json:"tax_id,omitempty"`
	PrimaryColor       string          `json:"primary_color,omitempty"`
	AccentColor        string          `json:"accent_color,omitempty"`
	Schedule           []ScheduleDTO   `json:"schedule,omitempty"`
	SpecialDays        []SpecialDayDTO `json:"special_days,omitempty"`
	Location           *LocationDTO    `json:"location,omitempty"`
	CoverImage         *string         `json:"cover_image,omitempty"`
	AverageRating      float64         `json:"average_rating"`
	ViewCount          int64           `json:"view_count"`
	CreatedAt          time.Time       `json:"created_at"`
	UpdatedAt          time.Time       `json:"updated_at"`
}

type ScheduleDTO struct {
	Day       string `json:"day"`
	IsOpen    bool   `json:"is_open"`
	StartTime string `json:"start_time,omitempty"`
	EndTime   string `json:"end_time,omitempty"`
}

type SpecialDayDTO struct {
	Date      string `json:"date"`
	IsOpen    bool   `json:"is_open"`
	StartTime string `json:"start_time,omitempty"`
	EndTime   string `json:"end_time,omitempty"`
}

func ToRestaurantResponse(r *domain.Restaurant) *RestaurantResponse {
	if r == nil {
		return nil
	}
	// map schedule
	var scheduleDTO []ScheduleDTO
	for _, s := range r.Schedule {
		scheduleDTO = append(scheduleDTO, ScheduleDTO{
			Day:       s.Day,
			IsOpen:    s.IsOpen,
			StartTime: s.StartTime,
			EndTime:   s.EndTime,
		})
	}

	// map special days
	var specialDTO []SpecialDayDTO
	for _, sd := range r.SpecialDays {
		specialDTO = append(specialDTO, SpecialDayDTO{
			Date:      sd.Date,
			IsOpen:    sd.IsOpen,
			StartTime: sd.StartTime,
			EndTime:   sd.EndTime,
		})
	}
	var location *LocationDTO
	if r.Location != nil {
		location = &LocationDTO{
			Coordinates: r.Location.Coordinates,
		}
	}

	return &RestaurantResponse{
		ID:                 r.ID,
		Slug:               r.Slug,
		Name:               r.RestaurantName,
		ManagerID:          r.ManagerID,
		Phone:              r.RestaurantPhone,
		Tags:               r.Tags,
		PreviousSlugs:      r.PreviousSlugs,
		About:              r.About,
		LogoImage:          r.LogoImage,
		VerificationStatus: string(r.VerificationStatus),
		VerificationDocs:   r.VerificationDocs,
		Schedule:           scheduleDTO,
		SpecialDays:        specialDTO,
		DefaultCurrency:    r.DefaultCurrency,
		DefaultLanguage:    r.DefaultLanguage,
		DefaultVat:         r.DefaultVat,
		TaxId:              r.TaxId,
		PrimaryColor:       r.PrimaryColor,
		AccentColor:        r.AccentColor,
		CoverImage:         r.CoverImage,
		Location:           location,
		AverageRating:      r.AverageRating,
		ViewCount:          r.ViewCount,
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}
}

func ToDomainRestaurant(r *RestaurantResponse) *domain.Restaurant {
	if r == nil {
		return nil
	}
	// map schedule
	var schedule []domain.Schedule
	for _, s := range r.Schedule {
		schedule = append(schedule, domain.Schedule{
			Day:       s.Day,
			IsOpen:    s.IsOpen,
			StartTime: s.StartTime,
			EndTime:   s.EndTime,
		})
	}

	// map special days
	var specialDay []domain.SpecialDay
	for _, sd := range r.SpecialDays {
		specialDay = append(specialDay, domain.SpecialDay{
			Date:      sd.Date,
			IsOpen:    sd.IsOpen,
			StartTime: sd.StartTime,
			EndTime:   sd.EndTime,
		})
	}
	restaurant := &domain.Restaurant{
		ID:                 r.ID,
		Slug:               r.Slug,
		RestaurantName:     r.Name,
		ManagerID:          r.ManagerID,
		RestaurantPhone:    r.Phone,
		Tags:               r.Tags,
		PreviousSlugs:      r.PreviousSlugs,
		About:              r.About,
		LogoImage:          r.LogoImage,
		VerificationStatus: domain.VerificationStatus(r.VerificationStatus),
		Schedule:           schedule,
		SpecialDays:        specialDay,
		DefaultCurrency:    r.DefaultCurrency,
		DefaultLanguage:    r.DefaultLanguage,
		DefaultVat:         r.DefaultVat,
		TaxId:              r.TaxId,
		PrimaryColor:       r.PrimaryColor,
		AccentColor:        r.AccentColor,
		VerificationDocs:   r.VerificationDocs,
		CoverImage:         r.CoverImage,
		AverageRating:      r.AverageRating,
		ViewCount:          r.ViewCount,
		CreatedAt:          r.CreatedAt,
		UpdatedAt:          r.UpdatedAt,
	}

	// Only set location if it's provided
	if r.Location != nil {
		restaurant.Location = &domain.Address{
			Type:        "Point",
			Coordinates: r.Location.Coordinates,
		}
	}

	return restaurant
}

// Map a slice of domain.Restaurant to DTOs
func ToRestaurantResponseList(restaurants []*domain.Restaurant) []*RestaurantResponse {
	dtos := make([]*RestaurantResponse, len(restaurants))
	for i, r := range restaurants {
		dtos[i] = ToRestaurantResponse(r)
	}
	return dtos
}

type LocationDTO struct {
	Coordinates [2]float64 `json:"coordinates"`
}
