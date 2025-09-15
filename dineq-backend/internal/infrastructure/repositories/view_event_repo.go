package repositories

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
)

type ViewEventRepository struct {
	db         mongo.Database
	collection string
}

func NewViewEventRepository(db mongo.Database, collection string) domain.IViewEventRepository {
	return &ViewEventRepository{db: db, collection: collection}
}

func (r *ViewEventRepository) LogView(event *domain.ViewEvent) error {
	if event.Timestamp.IsZero() {
		event.Timestamp = time.Now()
	}
	_, err := r.db.Collection(r.collection).InsertOne(context.Background(), event)
	return err
}
