package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
	"go.mongodb.org/mongo-driver/v2/bson"
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

func (r *ViewEventRepository) GetAnalyticsByEntity(ctx context.Context, entityID string, entityType string) ([]domain.VisitorPoint, error) {
	// Aggregate views by hour of day (0-23)
	pipeline := []bson.M{
		{"$match": bson.M{
			"entityId":   entityID,
			"entityType": entityType,
			"timestamp":  bson.M{"$gte": time.Now().Add(-24 * time.Hour)},
		}},
		{"$project": bson.M{
			"hour": bson.M{"$hour": "$timestamp"},
		}},
		{"$group": bson.M{
			"_id":   "$hour",
			"count": bson.M{"$sum": 1},
		}},
		{"$sort": bson.M{"_id": 1}},
	}

	cursor, err := r.db.Collection(r.collection).Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	type aggResult struct {
		Hour  int `bson:"_id"`
		Count int `bson:"count"`
	}
	var results []aggResult
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	// Map results to VisitorPoints
	points := make([]domain.VisitorPoint, 0, 24)
	hourMap := make(map[int]int)
	for _, res := range results {
		hourMap[res.Hour] = res.Count
	}

	// For specific hours of interest (6AM-10PM as shown in frontend)
	hours := []int{6, 8, 10, 12, 14, 16, 18, 20, 22}
	for _, h := range hours {
		label := fmt.Sprintf("%dAM", h)
		if h == 12 {
			label = "12PM"
		} else if h > 12 {
			label = fmt.Sprintf("%dPM", h-12)
		}
		points = append(points, domain.VisitorPoint{
			Label:    label,
			Value:    hourMap[h],
			Visitors: hourMap[h],
		})
	}

	return points, nil
}
