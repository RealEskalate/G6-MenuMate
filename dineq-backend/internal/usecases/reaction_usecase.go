package usecase

// import (
// 	"context"
// 	"errors"
// 	"fmt"
// 	"time"

// 	"github.com/RealEskalate/G6-MenuMate/internal/domain"
// )

// // ...existing code...

// type ReactionUsecase struct {
// 	repo       domain.IReactionRepository
// 	ctxtimeout time.Duration
// }

// // NewReactionUsecase initializes the usecase with a ReactionRepository.
// func NewReactionUsecase(repo domain.IReactionRepository, timeout time.Duration) *ReactionUsecase {
// 	u := &ReactionUsecase{
// 		repo:       repo,
// 		ctxtimeout: timeout,
// 	}

// 	// setup indexes in background if repository supports it
// 	go func() {
// 		_ = u.setupIndex()
// 	}()

// 	return u
// }

// func (u *ReactionUsecase) setupIndex() error {
// 	ctx, cancel := context.WithTimeout(context.Background(), u.ctxtimeout)
// 	defer cancel()

// 	// if the repo implements a SetupIndexes(context.Context) error method, call it
// 	type indexer interface {
// 		SetupIndexes(context.Context) error
// 	}

// 	if ri, ok := u.repo.(indexer); ok {
// 		return ri.SetupIndexes(ctx)
// 	}

// 	// repository doesn't support index setup — nothing to do
// 	return nil
// }

// func (u *ReactionUsecase) SaveReaction(ctx context.Context, itemID, userID, reviewID string, rtype domain.ReactionType) (*domain.Reaction, error) {
    
//     // basic validation
// 	if itemID == "" {
// 		return nil, errors.New("itemID is required")
// 	}
// 	if userID == "" {
// 		return nil, errors.New("userID is required")
// 	}

// 	// derive a context with timeout from the caller ctx
// 	var cctx context.Context
// 	var cancel context.CancelFunc
// 	if u.ctxtimeout > 0 {
// 		cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
// 	} else {
// 		cctx, cancel = context.WithCancel(ctx)
// 	}
// 	defer cancel()

// 	// 1. Get previous reaction (if any)
// 	fmt.Println("[DEBUG][usecase] reviewID:", reviewID)
// 	prev, err := u.repo.GetUserReaction(cctx, itemID, userID)
// 	if err != nil {
// 		return nil, err
// 	}

// 	now := time.Now()

// 	// 2. Business logic: toggle, update, or insert
// 	if prev == nil {
// 		if rtype == "" {
// 			// Nothing to delete
// 			return nil, nil
// 		}
// 		// Insert new reaction
// 		fmt.Println("[DEBUG][usecase] Creating new reaction with reviewID:", reviewID)
// 		reaction := &domain.Reaction{
// 			ItemID:    itemID,
// 			UserID:    userID,
// 			ReviewID:  reviewID,
// 			Type:      rtype,
// 			IsDeleted: false,
// 			CreatedAt: now,
// 			UpdatedAt: now,
// 		}
// 		err := u.repo.InsertReaction(cctx, reaction)
// 		if err != nil {
// 			return nil, err
// 		}
// 		fmt.Println("[DEBUG][usecase] Inserted reaction:", reaction)
// 		return reaction, nil
// 	}

// 	// If rtype is empty, soft delete
// 	if rtype == "" {
// 		fmt.Println("[DEBUG][usecase] Soft deleting reaction with reviewID:", prev.ReviewID)
// 		prev.IsDeleted = true
// 		prev.UpdatedAt = now
//         prev.ReviewID = reviewID
// 		err := u.repo.UpdateReaction(cctx, prev)
// 		if err != nil {
// 			return nil, err
// 		}
// 		// Fetch and return the updated reaction
// 		updated, _ := u.repo.GetUserReaction(cctx, itemID, userID)
// 		fmt.Println("[DEBUG][usecase] After soft delete, updated reaction:", updated)
// 		return updated, nil
// 	}

// 	if prev.Type == rtype && !prev.IsDeleted {
// 		fmt.Println("[DEBUG][usecase] Toggling off existing reaction with reviewID:", prev.ReviewID)
// 		// Toggle off: user clicked the same reaction, so remove it (soft delete)
// 		prev.IsDeleted = true
// 		prev.UpdatedAt = now
//         prev.ReviewID = reviewID
// 		err := u.repo.UpdateReaction(cctx, prev)
// 		if err != nil {
// 			return nil, err
// 		}
// 		updated, _ := u.repo.GetUserReaction(cctx, itemID, userID)
// 		fmt.Println("[DEBUG][usecase] After toggle off, updated reaction:", updated)
// 		return updated, nil
// 	} else {
// 		// Change type or restore deleted
// 		fmt.Println("[DEBUG][usecase] Changing type/restoring deleted, reviewID:", prev.ReviewID)
// 		prev.Type = rtype
// 		prev.IsDeleted = false
// 		prev.UpdatedAt = now
//         prev.ReviewID = reviewID
// 		err := u.repo.UpdateReaction(cctx, prev)
// 		if err != nil {
// 			return nil, err
// 		}
// 		updated, _ := u.repo.GetUserReaction(cctx, itemID, userID)
// 		fmt.Println("[DEBUG][usecase] After change/restore, updated reaction:", updated)
// 		return updated, nil
// 	}
// }

// func (u *ReactionUsecase) GetReactionStats(ctx context.Context, itemID, userID string) (int64, int64, *domain.Reaction, error) {
// 	if itemID == "" {
// 		return 0, 0, nil, errors.New("itemID is required")
// 	}

// 	// derive context with timeout
// 	var cctx context.Context
// 	var cancel context.CancelFunc
// 	if u.ctxtimeout > 0 {
// 		cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
// 	} else {
// 		cctx, cancel = context.WithCancel(ctx)
// 	}
// 	defer cancel()

// 	return u.repo.GetReactionStats(cctx, itemID, userID)
// }
