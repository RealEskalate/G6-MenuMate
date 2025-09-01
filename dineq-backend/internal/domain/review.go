package domain

<<<<<<< HEAD
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
=======
import "time"

type Review struct {
	ID           string
	ItemID       string
	UserID       string
	Picture      string
	Description  string
	Rating       float64
	ReactionIDs  []string
	LikeCount    int
	DislikeCount int
	IsApproved   bool
	CreatedAt    time.Time
	UpdatedAt    time.Time
	IsDeleted    bool
	FlagCount    int
}

type Reaction struct {
	ID        string
	ReviewID  string
	UserID    string
	Type      string
	CreatedAt time.Time
	IsDeleted bool
}

type IReviewUseCase interface {
	CreateReview(review *Review) error
	UpdateReview(id string, review *Review) error
	AddReaction(reviewID, reactionID string) error
	GetReviewByID(id string) (*Review, error)
	ModerateReview(id string, isApproved bool) error
	DeleteReview(id string) error
}

// repository
type IReviewRepository interface {
	Create(review *Review) error
	Update(id string, review *Review) error
	GetByID(id string) (*Review, error)
	Delete(id string) error
	AddReaction(reviewID, reactionID string) error
>>>>>>> Backend_develop
}
