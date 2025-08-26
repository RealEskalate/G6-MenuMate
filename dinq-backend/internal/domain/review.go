package domain

type Review struct {
	ID           string `json:"id"`
	RestaurantID string `json:"restaurant_id"`
	Rating       int    `json:"rating"`
	Comment      string `json:"comment"`
	UserID       string `json:"user_id"`
}

type ReviewRepository interface {
	GetByID(id string) (*Review, error)
	Create(r *Review) error
	Delete(id string) error
	ListByRestaurant(restaurantID string) ([]Review, error)
}
