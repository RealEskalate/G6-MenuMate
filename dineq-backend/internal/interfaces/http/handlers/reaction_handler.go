package handler

import (
    "net/http"

    "github.com/RealEskalate/G6-MenuMate/internal/domain"
    "github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
    "github.com/gin-gonic/gin"
)

// ReactionHandler aggregates all reaction related handlers.
type ReactionHandler struct {
    reactionUC domain.IReactionUsecase
}

func NewReactionHandler(reactionUC domain.IReactionUsecase) *ReactionHandler {
    return &ReactionHandler{reactionUC: reactionUC}
}

// POST /items/:item_id/reaction
func (ctrl *ReactionHandler) SaveReaction(c *gin.Context) {
    itemID := c.Param("item_id")
    userID := c.GetString("user_id")

    var req struct {
        Type *string `json:"type"` // pointer: nil or "" means remove
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
        return
    }

    var rtype domain.ReactionType
    if req.Type != nil && *req.Type != "" {
        rtype = domain.ParseReactionType(*req.Type)
        if rtype == "" {
            c.JSON(http.StatusBadRequest, gin.H{"error": "invalid reaction type"})
            return
        }
    }

    reviewID := "" // You can extract from body/query if needed

    reaction, err := ctrl.reactionUC.SaveReaction(c.Request.Context(), itemID, userID, reviewID, rtype)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save reaction"})
        return
    }
    if reaction == nil {
        c.Status(http.StatusNoContent)
        return
    }

    resp := dto.ReactionDTO{
        ID:        reaction.ID,
        ReviewID:  reaction.ReviewID,
        ItemID:    reaction.ItemID,
        UserID:    reaction.UserID,
        Type:      string(reaction.Type),
        CreatedAt: reaction.CreatedAt,
        UpdatedAt: reaction.UpdatedAt,
        IsDeleted: reaction.IsDeleted,
    }
    c.JSON(http.StatusOK, resp)
}

// GET /items/:item_id/reaction
func (ctrl *ReactionHandler) GetReactionStats(c *gin.Context) {
    itemID := c.Param("item_id")
    userID := c.GetString("user_id")

    counts, total, me, err := ctrl.reactionUC.GetReactionStats(c.Request.Context(), itemID, userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get reaction stats"})
        return
    }
    var meStr *string
    if me != nil {
        s := string(me.Type)
        meStr = &s
    }
    resp := dto.ReactionStatsDTO{
        ItemID: itemID,
        Counts: counts,
        Total:  total,
        Me:     meStr,
    }
    c.JSON(http.StatusOK, resp)
}