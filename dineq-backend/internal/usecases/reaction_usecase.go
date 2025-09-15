package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ...existing code...

type ReactionUsecase struct {
	repo       domain.IReactionRepository
	ctxtimeout time.Duration
}

// NewReactionUsecase initializes the usecase with a ReactionRepository.
func NewReactionUsecase(repo domain.IReactionRepository, timeout time.Duration) *ReactionUsecase {
	u := &ReactionUsecase{
		repo:       repo,
		ctxtimeout: timeout,
	}

	// setup indexes in background if repository supports it
	go func() {
		_ = u.setupIndex()
	}()

	return u
}

func (u *ReactionUsecase) setupIndex() error {
	ctx, cancel := context.WithTimeout(context.Background(), u.ctxtimeout)
	defer cancel()

	// if the repo implements a SetupIndexes(context.Context) error method, call it
	type indexer interface {
		SetupIndexes(context.Context) error
	}

	if ri, ok := u.repo.(indexer); ok {
		return ri.SetupIndexes(ctx)
	}

	// repository doesn't support index setup — nothing to do
	return nil
}

func (u *ReactionUsecase) SaveReaction(ctx context.Context, reviewID, userID string, rtype domain.ReactionType) (*domain.Reaction, error) {
	if reviewID == "" {
		return nil, errors.New("reviewID is required")
	}
	if userID == "" {
		return nil, errors.New("userID is required")
	}
	var cctx context.Context
	var cancel context.CancelFunc
	if u.ctxtimeout > 0 {
		cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
	} else {
		cctx, cancel = context.WithCancel(ctx)
	}
	defer cancel()
	prev, err := u.repo.GetUserReaction(cctx, reviewID, userID)
	if err != nil {
		return nil, err
	}
	now := time.Now()
	if prev == nil { // new
		if rtype == "" {
			return nil, nil
		}
		reaction := &domain.Reaction{ReviewID: reviewID, UserID: userID, Type: rtype, IsDeleted: false, CreatedAt: now, UpdatedAt: now}
		if err := u.repo.InsertReaction(cctx, reaction); err != nil {
			return nil, err
		}
		return reaction, nil
	}
	if rtype == "" { // explicit remove
		prev.IsDeleted = true
		prev.UpdatedAt = now
		if err := u.repo.UpdateReaction(cctx, prev); err != nil {
			return nil, err
		}
		updated, _ := u.repo.GetUserReaction(cctx, reviewID, userID)
		return updated, nil
	}
	if prev.Type == rtype && !prev.IsDeleted { // toggle off
		prev.IsDeleted = true
		prev.UpdatedAt = now
		if err := u.repo.UpdateReaction(cctx, prev); err != nil {
			return nil, err
		}
		updated, _ := u.repo.GetUserReaction(cctx, reviewID, userID)
		return updated, nil
	}
	// change / restore
	prev.Type = rtype
	prev.IsDeleted = false
	prev.UpdatedAt = now
	if err := u.repo.UpdateReaction(cctx, prev); err != nil {
		return nil, err
	}
	updated, _ := u.repo.GetUserReaction(cctx, reviewID, userID)
	return updated, nil
}

func (u *ReactionUsecase) GetReactionStats(ctx context.Context, reviewID, userID string) (int64, int64, *domain.Reaction, error) {
	if reviewID == "" {
		return 0, 0, nil, errors.New("reviewID is required")
	}
	var cctx context.Context
	var cancel context.CancelFunc
	if u.ctxtimeout > 0 {
		cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
	} else {
		cctx, cancel = context.WithCancel(ctx)
	}
	defer cancel()
	return u.repo.GetReactionStats(cctx, reviewID, userID)
}
