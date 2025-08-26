package domain

type Restaurant struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Address string `json:"address"`
	Menus   []Menu `json:"menus,omitempty"`
}

type RestaurantRepository interface {
	GetByID(id string) (*Restaurant, error)
	Create(r *Restaurant) error
	Update(r *Restaurant) error
	Delete(id string) error
	List() ([]Restaurant, error)
}
