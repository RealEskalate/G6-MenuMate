package exchange

import (
	"sync"
	"time"

	"github.com/google/uuid"
)

type oneTimeEntry struct {
    AccessToken  string
    RefreshToken string
    AccessExpiresAt  time.Time
    RefreshExpiresAt time.Time
}

type CodeStore struct {
    mu    sync.Mutex
    store map[string]oneTimeEntry
}

var global = &CodeStore{store: make(map[string]oneTimeEntry)}

// CreateCode stores a one-time code that expires after ttlSeconds and returns the code
// It also stores the token expiry times so the exchange endpoint can set cookies with correct TTLs.
func CreateCode(access, refresh string, accessExpiry, refreshExpiry time.Time, ttlSeconds int) string {
    code := uuid.New().String()
    global.mu.Lock()
    defer global.mu.Unlock()
    global.store[code] = oneTimeEntry{
        AccessToken:      access,
        RefreshToken:     refresh,
        AccessExpiresAt:  accessExpiry,
        RefreshExpiresAt: refreshExpiry,
    }
    // schedule removal in case ExchangeCode is never called
    go func(c string, ttl int) {
        time.Sleep(time.Duration(ttl) * time.Second)
        global.mu.Lock()
        defer global.mu.Unlock()
        delete(global.store, c)
    }(code, ttlSeconds)
    return code
}

// ExchangeCode returns tokens for a code if valid and deletes the code
// ExchangeCode returns tokens and their expiries for a code if valid and deletes the code
func ExchangeCode(code string) (access, refresh string, accessExpiry, refreshExpiry time.Time, ok bool) {
    global.mu.Lock()
    defer global.mu.Unlock()
    e, found := global.store[code]
    if !found {
        return "", "", time.Time{}, time.Time{}, false
    }
    // consume
    delete(global.store, code)
    return e.AccessToken, e.RefreshToken, e.AccessExpiresAt, e.RefreshExpiresAt, true
}