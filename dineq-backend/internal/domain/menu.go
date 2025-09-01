package domain

type Menu struct {
	ID           string `json:"id"`
	RestaurantID string `json:"restaurant_id"`
	Name         string `json:"name"`
	Items        []Item `json:"items,omitempty"`
}

type MenuRepository interface {
	GetByID(id string) (*Menu, error)
	Create(m *Menu) error
	Update(m *Menu) error
	Delete(id string) error
	ListByRestaurant(restaurantID string) ([]Menu, error)
}
