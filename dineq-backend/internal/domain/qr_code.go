package domain

import "time"

type QRCode struct {
	ID            string      `json:"id"`
	MenuID        string      `json:"menuId" validate:"required"`
	BranchID      string      `json:"branchId" validate:"required"`
	CodeURL       string      `json:"codeUrl" validate:"required"`
	Customization interface{} `json:"customization,omitempty"`
	CreatedAt     time.Time   `json:"createdAt"`
	ExpiresAt     time.Time   `json:"expiresAt,omitempty"`
	IsActive      bool        `json:"isActive"`
}

type IQRCodeUseCase interface {
	CreateQRCode(qr *QRCode) error
	GetQRCodeByID(id string) (*QRCode, error)
	ActivateQRCode(id string) error
}

// repository
type IQRCodeRepository interface {
	Create(qr *QRCode) error
	GetByID(id string) (*QRCode, error)
	UpdateActivation(id string, isActive bool) error
	Delete(id string) error
}
