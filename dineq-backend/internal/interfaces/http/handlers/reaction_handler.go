package handler

import (
	"net/http"
	"strings"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/RealEskalate/G6-MenuMate/internal/interfaces/http/dto"
	"github.com/gin-gonic/gin"
)

func reactionError(c *gin.Context, status int, code, message string, field string, internal error) {
	resp := dto.ErrorResponse{Message: message, Code: code}
	if field != "" {
		resp.Field = field
	}
	if internal != nil {
		resp.Error = internal.Error()
	}
	c.JSON(status, resp)
}

// ReactionHandler aggregates all reaction related handlers.
type ReactionHandler struct {
	reactionUC domain.IReactionUsecase
	reviewUC   domain.IReviewUsecase
}

// NewReactionHandler now also requires a review usecase to derive item & restaurant IDs.
func NewReactionHandler(reactionUC domain.IReactionUsecase, reviewUC domain.IReviewUsecase) *ReactionHandler {
	return &ReactionHandler{reactionUC: reactionUC, reviewUC: reviewUC}
}

func (ctrl *ReactionHandler) SaveReaction(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	itemID := c.Param("item_id")
	reviewID := c.Param("review_id")
	if restaurantID == "" {
		reactionError(c, http.StatusBadRequest, "restaurant_id_required", "restaurant_id is required", "restaurant_id", nil)
		return
	}
	if itemID == "" {
		reactionError(c, http.StatusBadRequest, "item_id_required", "item_id is required", "item_id", nil)
		return
	}
	if reviewID == "" {
		reactionError(c, http.StatusBadRequest, "review_id_required", "review_id is required", "review_id", nil)
		return
	}
	userID := c.GetString("user_id")
	if userID == "" { // must be authenticated
		reactionError(c, http.StatusUnauthorized, "unauthorized", "authentication required", "", nil)
		return
	}
	var body dto.ReactionRequest
	if err := c.ShouldBindJSON(&body); err != nil {
		reactionError(c, http.StatusBadRequest, "invalid_request", "invalid request body", "", err)
		return
	}
	normalized := strings.TrimSpace(body.Type)
	rtype := domain.ParseReactionType(normalized)
	if normalized != "" && rtype == "" {
		reactionError(c, http.StatusBadRequest, "invalid_reaction_type", "invalid reaction type", "type", nil)
		return
	}
	// Load review and validate hierarchy integrity
	review, err := ctrl.reviewUC.GetReviewByID(c.Request.Context(), reviewID)
	if err != nil || review == nil || review.IsDeleted {
		reactionError(c, http.StatusNotFound, "review_not_found", "review not found", "review_id", err)
		return
	}
	if review.ItemID != itemID {
		reactionError(c, http.StatusBadRequest, "item_id_mismatch", "item_id mismatch between path and review", "item_id", nil)
		return
	}
	if review.RestaurantID != "" && review.RestaurantID != restaurantID { // if restaurant ID stored
		reactionError(c, http.StatusBadRequest, "restaurant_id_mismatch", "restaurant_id mismatch between path and review", "restaurant_id", nil)
		return
	}
	reaction, err := ctrl.reactionUC.SaveReaction(c.Request.Context(), reviewID, userID, rtype)
	if err != nil {
		reactionError(c, http.StatusInternalServerError, "save_reaction_failed", "failed to save reaction", "", err)
		return
	}
	if reaction == nil {
		reactionError(c, http.StatusNotFound, "reaction_not_found", "reaction not found", "", nil)
		return
	}
	// Ensure ItemID populated
	if reaction.ItemID == "" {
		reaction.ItemID = review.ItemID
	}
	resp := dto.ReactionDTO{ID: reaction.ID, ReviewID: reaction.ReviewID, ItemID: reaction.ItemID, UserID: reaction.UserID, Type: reaction.Type.ToAPI(), CreatedAt: reaction.CreatedAt, UpdatedAt: reaction.UpdatedAt, IsDeleted: reaction.IsDeleted}
	c.JSON(http.StatusOK, resp)
}

func (ctrl *ReactionHandler) GetReactionStats(c *gin.Context) {
	restaurantID := c.Param("restaurant_id")
	itemID := c.Param("item_id")
	reviewID := c.Param("review_id")
	if restaurantID == "" || itemID == "" || reviewID == "" {
		reactionError(c, http.StatusBadRequest, "path_params_required", "restaurant_id, item_id, and review_id are required", "", nil)
		return
	}
	userID := c.GetString("user_id")
	// Validate review relationship (best-effort; errors still return stats error)
	if review, err := ctrl.reviewUC.GetReviewByID(c.Request.Context(), reviewID); err == nil && review != nil {
		if review.ItemID != itemID || (review.RestaurantID != "" && review.RestaurantID != restaurantID) {
			reactionError(c, http.StatusBadRequest, "hierarchy_mismatch", "path hierarchy does not match stored review", "", nil)
			return
		}
	}
	likeCnt, dislikeCnt, me, err := ctrl.reactionUC.GetReactionStats(c.Request.Context(), reviewID, userID)
	if err != nil {
		reactionError(c, http.StatusInternalServerError, "get_reaction_stats_failed", "failed to get reaction stats", "", err)
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
	resp := dto.ReactionStatsDTO{ReviewID: reviewID, ItemID: itemID, LikeCounts: likeCnt, DislikeCounts: dislikeCnt, Me: meStr}
	c.JSON(http.StatusOK, resp)
}
