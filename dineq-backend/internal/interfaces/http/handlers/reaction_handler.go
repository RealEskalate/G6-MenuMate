package handler

import (
	"fmt"
	"net/http"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	// "github.com/RealEskalate/G6-MenuMate"

	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
	// "go.uber.org/zap"
)

// ReactionHandler aggregates all reaction related handlers.
type ReactionHandler struct {
	reactionUC domain.IReactionUsecase
}

func NewReactionHandler(reactionUC domain.IReactionUsecase) *ReactionHandler {
	return &ReactionHandler{reactionUC: reactionUC}
}

func (ctrl *ReactionHandler) SaveReaction(c *gin.Context) {
	itemID := c.Param("item_id")
	fmt.Println("[DEBUG] itemID:", itemID)
	userID := c.GetString("user_id")
	fmt.Println("[DEBUG] userID:", userID)

	var req struct {
		Type     *string `json:"type"`
		ReviewID *string `json:"review_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	fmt.Println("[DEBUG] type: ", req.Type)
	allowedTypes := map[string]bool{"LIKE": true, "DISLIKE": true}
	if req.Type == nil || !allowedTypes[*req.Type] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid reaction type"})
		return
	}
	if req.ReviewID != nil && len(*req.ReviewID) > 100 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ReviewID too long"})
		return
	}

	reviewID := ""
	if req.ReviewID != nil {
		reviewID = *req.ReviewID
	}
	reaction, err := ctrl.reactionUC.SaveReaction(c.Request.Context(), itemID, userID, reviewID, domain.ReactionType(*req.Type))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save reaction"})
		return
	}
	if reaction == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "reaction not found"})
		return
	}

	resp := gin.H{
		"id":         reaction.ID,
		"item_id":    reaction.ItemID,
		"user_id":    reaction.UserID,
		"type":       string(reaction.Type),
		"created_at": reaction.CreatedAt,
		"updated_at": reaction.UpdatedAt,
		"active":     !reaction.IsDeleted,
	}
	if reaction.ReviewID != "" { // only include when non-empty
		resp["review_id"] = reaction.ReviewID
	}
	c.JSON(http.StatusOK, resp)
}

func (ctrl *ReactionHandler) GetReactionStats(c *gin.Context) {
	fmt.Println("[DEBUG] GetReactionStats called")
	itemID := c.Param("item_id")
	fmt.Println("[DEBUG] itemID:", itemID)
	userID := c.GetString("user_id")
	fmt.Println("[DEBUG] userID:", userID)

	like_count, dislike_count, me, err := ctrl.reactionUC.GetReactionStats(c.Request.Context(), itemID, userID)
	if err != nil {
		fmt.Println("[DEBUG] GetReactionStats error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get reaction stats"})
		return
	}
	var meStr *string
	if me != nil && !me.IsDeleted {
		s := string(me.Type)
		meStr = &s
	} else {
		empty := ""
		meStr = &empty
	}
	resp := dto.ReactionStatsDTO{
		ItemID:        itemID,
		LikeCounts:    like_count,
		DislikeCounts: dislike_count,
		Me:            meStr,
	}
	c.JSON(http.StatusOK, resp)
}
