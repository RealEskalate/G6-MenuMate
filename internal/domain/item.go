package domain

type Item struct {
	ID      string  `json:"id"`
	MenuID  string  `json:"menu_id"`
	Name    string  `json:"name"`
	Price   float64 `json:"price"`
	PhotoID *string `json:"photo_id,omitempty"`
}

type ItemRepository interface {
	GetByID(id string) (*Item, error)
	Create(i *Item) error
	Update(i *Item) error
	Delete(id string) error
	ListByMenu(menuID string) ([]Item, error)
}
