package usecase

import (
    "context"
    "errors"
    "time"

    "github.com/RealEskalate/G6-MenuMate/internal/domain"
)

// ...existing code...

type ReactionUsecase struct {
    repo domain.IReactionRepository
    ctxtimeout time.Duration
}

// NewReactionUsecase initializes the usecase with a ReactionRepository.
func NewReactionUsecase(repo domain.IReactionRepository, timeout time.Duration) *ReactionUsecase {
    u := &ReactionUsecase{
        repo: repo,
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

func (u *ReactionUsecase) SaveReaction(ctx context.Context, itemID, userID, reviewID string, rtype domain.ReactionType) (*domain.Reaction, error) {
    // basic validation
    if itemID == "" {
        return nil, errors.New("itemID is required")
    }
    if userID == "" {
        return nil, errors.New("userID is required")
    }

    // derive a context with timeout from the caller ctx
    var cctx context.Context
    var cancel context.CancelFunc
    if u.ctxtimeout > 0 {
        cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
    } else {
        cctx, cancel = context.WithCancel(ctx)
    }
    defer cancel()

    // Delegate to repository which is responsible for upsert / soft-delete logic.
    return u.repo.SaveReaction(cctx, itemID, userID, reviewID, rtype)
}

func (u *ReactionUsecase) GetReactionStats(ctx context.Context, itemID, userID string) (map[string]int64, int64, *domain.Reaction, error) {
    if itemID == "" {
        return nil, 0, nil, errors.New("itemID is required")
    }

    // derive context with timeout
    var cctx context.Context
    var cancel context.CancelFunc
    if u.ctxtimeout > 0 {
        cctx, cancel = context.WithTimeout(ctx, u.ctxtimeout)
    } else {
        cctx, cancel = context.WithCancel(ctx)
    }
    defer cancel()

    return u.repo.GetReactionStats(cctx, itemID, userID)
}