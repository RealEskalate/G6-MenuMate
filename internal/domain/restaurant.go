package domain

import "time"

// Document represents a verification document.
type Document struct {
    URL string // URL of the document.
}

// VerificationStatus represents the restaurant verification status.
type VerificationStatus string

const (
    Pending  VerificationStatus = "pending"
    Verified VerificationStatus = "verified"
    Rejected VerificationStatus = "rejected"
)

// URL is a string alias to represent a URL.
type URL string

// Contact contains contact details.
type Contact struct {
    Phone  string
    Email  string
    Social []URL
}

// Restaurant represents a restaurant entity.
type Restaurant struct {
    ID                 string
    Name               string
    About              string           // Optional business overview.
    VerificationDocs   []Document       // Array of verification documents.
    VerificationStatus VerificationStatus // Enum: pending, verified, rejected.
    Contact            Contact
    Owner              string           // Owner user id (uuid).
    LogoImage          string           // Optional logo URL.
    BranchIDs          []string         // List of branch uuids.
    AverageRating      float64          // Derived average rating.
    Tags               []string         // Optional list of tag ids.
    IsOpen             bool             // Overall open status. Default is false.
    CreatedAt          time.Time        // Creation time.
    UpdatedAt          time.Time        // Last update time.
    IsDeleted          bool             // Default false.
    ViewCount          int              // Default 0.
}

// IRestaurantUseCase defines restaurant-related use cases.
type IRestaurantUseCase interface {
    CreateRestaurant(restaurant *Restaurant) error
    UpdateRestaurant(id string, restaurant *Restaurant) error
    GetRestaurantByID(id string) (*Restaurant, error)
    DeleteRestaurant(id string) error
    AddBranch(restaurantID, branchID string) error
    VerifyRestaurant(id string, status VerificationStatus) error
}

// IRestaurantRepository defines repository operations for restaurants.
type IRestaurantRepository interface {
    Create(restaurant *Restaurant) error
    Update(id string, restaurant *Restaurant) error
    GetByID(id string) (*Restaurant, error)
    Delete(id string) error
    AddBranch(restaurantID, branchID string) error
    VerifyRestaurant(id string, status VerificationStatus) error
}

// You can use some of this i copied from the branch model if you need to implement the restaurant branch functionality.
// type IRestaurantBranchUseCase interface {
// 	CreateBranch(branch *RestaurantBranch) error
// 	UpdateBranch(id string, branch *RestaurantBranch) error
// 	GetBranchByID(id string) (*RestaurantBranch, error)
// 	DeleteBranch(id string) error
// 	AssignStaff(branchID, userID, role string) error
// 	// LinkMenu(branchID, menuID string) error
// }

// // repository
// type IRestaurantBranchRepository interface {
// 	Create(branch *RestaurantBranch) error
// 	Update(id string, branch *RestaurantBranch) error
// 	GetByID(id string) (*RestaurantBranch, error)
// 	Delete(id string) error
// 	AssignStaff(branchID, userID, role string) error
// 	// LinkMenu(branchID, menuID string) error
// }
