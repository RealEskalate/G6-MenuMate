package domain

type Photo struct {
	ID           string  `json:"id"`
	URL          string  `json:"url"`
	ItemID       *string `json:"item_id,omitempty"`
	RestaurantID *string `json:"restaurant_id,omitempty"`
}

type PhotoRepository interface {
	GetByID(id string) (*Photo, error)
	Create(p *Photo) error
	Delete(id string) error
}
