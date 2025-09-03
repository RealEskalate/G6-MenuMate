package mapper

import (
    "time"

    "github.com/RealEskalate/G6-MenuMate/internal/domain"
    "go.mongodb.org/mongo-driver/v2/bson"
)

// ToCamelCaseReaction maps a MongoDB BSON document to a domain.Reaction struct using camelCase JSON tags.
func ToCamelCaseReaction(doc bson.M) *domain.Reaction {
    if doc == nil {
        return nil
    }
    reaction := &domain.Reaction{}
    if v, ok := doc["_id"].(string); ok {
        reaction.ID = v
    }
    if v, ok := doc["reviewId"].(string); ok {
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
    if v, ok := doc["createdAt"].(time.Time); ok {
        reaction.CreatedAt = v
    }
    if v, ok := doc["updatedAt"].(time.Time); ok {
        reaction.UpdatedAt = v
    }
    if v, ok := doc["isDeleted"].(bool); ok {
        reaction.IsDeleted = v
    }
    return reaction
}

// ToBsonReaction maps a domain.Reaction struct to a MongoDB BSON document using camelCase field names.
func ToBsonReaction(r *domain.Reaction) bson.M {
    if r == nil {
        return bson.M{}
    }
    return bson.M{
        "_id":       r.ID,
        "reviewId":  r.ReviewID,
        "itemId":    r.ItemID,
        "userId":    r.UserID,
        "type":      string(r.Type),
        "createdAt": r.CreatedAt,
        "updatedAt": r.UpdatedAt,
        "isDeleted": r.IsDeleted,
    }
}