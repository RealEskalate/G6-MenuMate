package handlers_test

import (
	"context"
	"testing"
	"time"

	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	usecase "github.com/RealEskalate/G6-MenuMate/internal/usecases"
)

// stubUserRepo implements the subset of IUserRepository needed for identifier lookup tests.
type stubUserRepo struct{ users []domain.User }

func (s *stubUserRepo) CreateUser(ctx context.Context, u *domain.User) error {
	s.users = append(s.users, *u)
	return nil
}
func (s *stubUserRepo) FindUserByID(ctx context.Context, id string) (*domain.User, error) {
	return nil, domain.ErrNotFound
}
func (s *stubUserRepo) GetUserByUsername(ctx context.Context, username string) (*domain.User, error) {
	return nil, domain.ErrNotFound
}
func (s *stubUserRepo) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	return nil, domain.ErrNotFound
}
func (s *stubUserRepo) GetUserByPhone(ctx context.Context, phone string) (*domain.User, error) {
	return nil, domain.ErrNotFound
}
func (s *stubUserRepo) UpdateUser(ctx context.Context, id string, u *domain.User) error { return nil }
func (s *stubUserRepo) GetAllUsers(ctx context.Context) ([]*domain.User, error)         { return nil, nil }
func (s *stubUserRepo) FindByUsernameOrEmail(ctx context.Context, key string) (domain.User, error) {
	for _, u := range s.users {
		if u.Username == key || u.Email == key || u.PhoneNumber == key {
			return u, nil
		}
	}
	return domain.User{}, domain.ErrNotFound
}
func (s *stubUserRepo) InvalidateTokens(ctx context.Context, id string) error { return nil }
func (s *stubUserRepo) ChangeRole(ctx context.Context, targetUserID, role, username string) error {
	return nil
}
func (s *stubUserRepo) AssignRole(ctx context.Context, userID, branchID string, role domain.UserRole) error {
	return nil
}

// storage stub
type noopStorage struct{}

// Updated to satisfy services.StorageService (UploadFile returns url, publicID, error)
func (n noopStorage) UploadFile(ctx context.Context, fileName string, data []byte, folder string) (string, string, error) {
	return "", "", nil
}
func (n noopStorage) DeleteFile(ctx context.Context, publicID string) error { return nil }

func TestFindByIdentifier_UserEmailUsernamePhone(t *testing.T) {
	repo := &stubUserRepo{}
	uc := usecase.NewUserUsecase(repo, noopStorage{}, 2*time.Second)

	user := domain.User{ID: "1", Username: "alpha", Email: "alpha@example.com", PhoneNumber: "+15551234567", Password: "hash"}
	repo.CreateUser(context.Background(), &user)

	cases := []struct{ in, field string }{
		{"alpha", "username"},
		{"alpha@example.com", "email"},
		{"+15551234567", "phone"},
	}
	for _, c := range cases {
		got, err := uc.FindByUsernameOrEmail(context.Background(), c.in)
		if err != nil {
			t.Fatalf("expected success for %s lookup, got error: %v", c.field, err)
		}
		if got.ID != user.ID {
			t.Fatalf("expected user ID %s for %s lookup, got %s", user.ID, c.field, got.ID)
		}
	}

	if _, err := uc.FindByUsernameOrEmail(context.Background(), "missing"); err == nil {
		t.Fatalf("expected error for missing identifier")
	}
}
