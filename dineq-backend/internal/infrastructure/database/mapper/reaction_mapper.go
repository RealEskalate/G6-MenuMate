package mapper

import (
	"fmt"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// // ToCamelCaseReaction maps a MongoDB BSON document to a domain.Reaction struct using camelCase JSON tags.
// import (
//     "time"
//     "go.mongodb.org/mongo-driver/v2/bson"
//     "go.mongodb.org/mongo-driver/bson/primitive"
// )

func ToCamelCaseReaction(doc bson.M) *domain.Reaction {
	fmt.Println("[DEBUG] ToCamelCaseReaction input doc:", doc)
	if doc == nil {
		return nil
	}
	reaction := &domain.Reaction{}
	if v, ok := doc["_id"].(primitive.ObjectID); ok {
		reaction.ID = v.Hex()
	} else if v, ok := doc["_id"].(string); ok {
		reaction.ID = v
	}
	if v, ok := doc["reviewId"].(string); ok {
		fmt.Println("[DEBUG][mapper] ToCamelCaseReaction reviewId:", v)
		reaction.ReviewID = v
	}
	if v, ok := doc["itemId"].(string); ok {
		reaction.ItemID = v
	}
	if v, ok := doc["userId"].(string); ok {
		reaction.UserID = v
	}
	if v, ok := doc["type"].(string); ok {
		reaction.Type = domain.ReactionType(v)
	}
	// --- Fix for createdAt ---
	if v, ok := doc["createdAt"].(primitive.DateTime); ok {
		reaction.CreatedAt = v.Time()
	} else if v, ok := doc["createdAt"].(time.Time); ok {
		reaction.CreatedAt = v
	} else if v, ok := doc["createdAt"].(bson.RawValue); ok {
		t, ok := v.TimeOK()
		if ok {
			reaction.CreatedAt = t
		}
	}
	// --- Fix for updatedAt ---
	if v, ok := doc["updatedAt"].(primitive.DateTime); ok {
		reaction.UpdatedAt = v.Time()
	} else if v, ok := doc["updatedAt"].(time.Time); ok {
		reaction.UpdatedAt = v
	} else if v, ok := doc["updatedAt"].(bson.RawValue); ok {
		t, ok := v.TimeOK()
		if ok {
			reaction.UpdatedAt = t
		}
	}
	if v, ok := doc["isDeleted"].(bool); ok {
		reaction.IsDeleted = v
	}
	fmt.Println("[DEBUG] ToCamelCaseReaction output:", reaction)
	return reaction
}

// ToBsonReaction maps a domain.Reaction struct to a MongoDB BSON document using camelCase field names.
func ToBsonReaction(r *domain.Reaction) bson.M {
	if r == nil {
		return bson.M{}
	}
	fmt.Println("[DEBUG][mapper] ToBsonReaction input:", r)
	doc := bson.M{
		"reviewId":  r.ReviewID,
		"itemId":    r.ItemID,
		"userId":    r.UserID,
		"type":      string(r.Type),
		"createdAt": r.CreatedAt,
		"updatedAt": r.UpdatedAt,
		"isDeleted": r.IsDeleted,
	}
	fmt.Println("[DEBUG][mapper] ToBsonReaction doc:", doc)
	// Only set _id if it's a valid ObjectID hex
	if oid, err := primitive.ObjectIDFromHex(r.ID); err == nil && r.ID != "" {
		doc["_id"] = oid
	}
	return doc
}
