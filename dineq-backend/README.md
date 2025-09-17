# DineQ — MenuMate Backend (Detailed README)

Status: production-ready backend for MenuMate. This document is a detailed developer and ops guide covering the codebase, features, endpoints, environment variables, local dev, testing, deployment guidance, and troubleshooting.

---

## Overview

MenuMate (DineQ) is a restaurant management and discovery backend that supports:

- Restaurants and menus management (create, update, publish, QR codes).
- Menu items and item-level operations (search, reviews, reactions).
- Authentication: JWT access/refresh tokens, OTP, password reset, Google OAuth.
- OCR ingestion for menu uploads and automated parsing + retry jobs.
- Image search aggregation (Google Custom Search + Unsplash + Pexels) with optional AI classifier.
- Notifications (HTTP + WS), background job orchestration, and index management for MongoDB.

This README supplements the Postman collection at `postman-collections/` and the light `docs/` directory.

---

## Maintainers / Ownership

- Primary owner: Backend Team
- For urgent production issues, the lead coordinates rollback and hotfixes.

---

## High-level architecture

- Language: Go (module under `dineq-backend`).
- HTTP server: Gin (router in `internal/interfaces/http/routers`).
- Persistence: MongoDB (drivers and repositories in `internal/infrastructure/database` and `internal/infrastructure/repositories`).
- Third-party services and integrations: Google Custom Search, Unsplash, Pexels, Gemini AI (via `internal/infrastructure/service`), Cloudinary, Veryfi.
- Background jobs: OCR ingestion and retry logic in `internal/usecases` and `internal/infrastructure/service/ocr`.
- Config: environment-driven (see `internal/bootstrap/env.go`).

---

## Key features (summary)

- Auth: registration, login, refresh tokens, logout, Google OAuth, password reset, OTP flows.
- Restaurants: create, update, delete, search, nearby geo queries, indexing for performance.
- Menus & Items: publish/unpublish, CRUD, QR generation, public endpoints to view published menus.
- OCR pipeline: upload menu image/PDF, queue OCR job, retry, parse and map to restaurant/menu.
- Image search: aggregated results from Google/Unsplash/Pexels with per-source caps and confidence sorting; optional GEMINI classifier to tune provider selection for Ethiopian items.
- Reviews & Reactions: review CRUD, cascade updates, reaction counts and stats.
- Notifications: create, list by user, mark as read, WebSocket endpoint for real-time notifications.
- Dev experience: hot-reload via `air` (`dineq-backend/air.toml`).

---

## API / Endpoints

The app exposes a v1 API under `/api/v1`. Below is a representative (non-exhaustive) list of endpoints discovered from the running router and Postman collection. Refer to `postman-collections/MenuMate API v1 - Comprehensive Collection.postman_collection.json` for the complete collection and examples.

Authentication

- POST /api/v1/auth/register
- POST /api/v1/auth/login
- POST /api/v1/auth/logout
- POST /api/v1/auth/forgot-password
- POST /api/v1/auth/verify-reset-token
- POST /api/v1/auth/reset-password
- POST /api/v1/auth/refresh
- GET /api/v1/auth/google/login
- GET /api/v1/auth/google/callback
- POST /api/v1/auth/verify-email
- POST /api/v1/auth/resend-otp
- PATCH /api/v1/auth/verify-otp

Users

- GET /api/v1/me
- GET /api/v1/users/:id
- GET /api/v1/users/avatar-options
- PATCH /api/v1/users/update-profile
- PATCH /api/v1/users/change-password

OCR (menu ingestion)

- POST /api/v1/ocr/upload
- GET /api/v1/ocr/:id
- DELETE /api/v1/ocr/:id
- POST /api/v1/ocr/:id/retry

Notifications

- POST /api/v1/notifications/
- GET /api/v1/notifications/:userId
- PUT /api/v1/notifications/:userId/read
- GET /api/v1/notifications/ws (WebSocket)

Restaurants

- GET /api/v1/restaurants
- GET /api/v1/restaurants/search
- GET /api/v1/restaurants/search/advanced
- GET /api/v1/restaurants/:slug
- GET /api/v1/restaurants/nearby
- POST /api/v1/restaurants
- GET /api/v1/restaurants/me
- PATCH /api/v1/restaurants/:slug
- DELETE /api/v1/restaurants/:id

Menus & Public Menus

- GET /api/v1/public/menus/:restaurant_slug
- GET /api/v1/public/menus/:restaurant_slug/:id
- GET /api/v1/menus/:restaurant_slug
- GET /api/v1/menus/:restaurant_slug/:id
- POST /api/v1/menus/:restaurant_slug
- PATCH /api/v1/menus/:restaurant_slug/:id
- DELETE /api/v1/menus/:restaurant_slug/:id
- POST /api/v1/menus/:restaurant_slug/qrcode/:id
- POST /api/v1/menus/:restaurant_slug/publish/:id

Menu items

- GET /api/v1/menu-items/:menu_slug
- GET /api/v1/menu-items/:menu_slug/:id
- GET /api/v1/menu-items/search/advanced
- GET /api/v1/menu-items/:menu_slug/search
- POST /api/v1/menu-items/:menu_slug/
- PATCH /api/v1/menu-items/:menu_slug/:id
- POST /api/v1/menu-items/:menu_slug/:id/reviews
- DELETE /api/v1/menu-items/:menu_slug/:id

Reviews & Reactions

- POST /api/v1/restaurants/id/:restaurant_id/items/:item_id/reviews/:review_id/reaction
- GET /api/v1/restaurants/id/:restaurant_id/items/:item_id/reviews/:review_id/reaction
- POST /api/v1/reviews
- PATCH /api/v1/reviews/:id
- DELETE /api/v1/reviews/:id
- GET /api/v1/reviews/:id
- GET /api/v1/items/:item_id/reviews
- GET /api/v1/items/:item_id/average-rating
- GET /api/v1/restaurants/v/:restaurant_id/average-rating

Image search

- GET /api/v1/images/search?item={name}&restaurant={slug}
- POST /api/v1/images/search

Uploads

- POST /api/v1/uploads/logo
- POST /api/v1/uploads/image

Health

- GET /api/v1/health

Notes

- Most endpoints require JWT authentication (Bearer token) or cookies (`access_token`/`refresh_token`). See Postman collection for request bodies and examples.

---

## Environment variables (important subset)

The application is configured entirely via environment variables. `internal/bootstrap/env.go` enumerates available settings. Below are the important ones to set for local development and staging.

Core

- PORT (default `:8080`)
- APP_ENV (development|staging|production)
- DB_URI (mongodb connection string, e.g. `mongodb://localhost:27017`)
- DB_NAME (e.g. `dineq_db`)

Auth/security

- REFRESH_TOKEN_SECRET
- ACCESS_TOKEN_SECRET
- REFRESH_TOKEN_EXPIRE_HOURS
- ACCESS_TOKEN_EXPIRE_MINUTES
- COOKIE_SECURE (true/false)
- COOKIE_DOMAIN

Third-party / optional integrations

- GEMINI_API_KEY (Gemini AI model key)
- GEMINI_MODEL_NAME
- SEARCH_ENGINE_ID (Google Programmable Search Engine)
- SEARCH_ENGINE_API_KEY
- UNSPLASH_API_KEY
- PEXELS_API_KEY
- CLD_API_KEY / CLD_SECRET / CLD_NAME (Cloudinary)
- VERIFY_CLIENT_ID / VERIFY_CLIENT_SECRET / VERIFY_API_KEY / VERIFY_USERNAME (Veryfi)
- RAPIDAPI_KEY / RAPIDAPI_HOST (translation/external APIs)
- SMTP_HOST / SMTP_PORT / SMTP_FROM / SMTP_USERNAME / SMTP_PASSWORD

Redis / caching

- REDIS_HOST / REDIS_PORT / REDIS_PASSWORD / REDIS_DB
- CACHE_EXPIRATION_SECONDS

Misc collections and names (optional)

- USER_COLLECTION, MENU_COLLECTION, RESTAURANT_COLLECTION, OTP_COLLECTION, OCR_JOB_COLLECTION, NOTIFICATION_COLLECTION, etc.

Tip: use a `.env` file in development and `godotenv` loader will pick it up. Sensitive keys should be injected by your CI/CD system for staging/production.

---

## Local development (quick start)

Prereqs

- Go 1.20+ (project uses modern Go modules)
- MongoDB running locally
- Optional: Redis if you use caching / sessions
- Optional: Air installed for hot reload: `go install github.com/air-verse/air@latest`

Steps

1. Copy `.env.example` to `.env` and fill values:

```bash
cp .env.example .env
# edit .env
```

2. Build and run (no hot reload):

```bash
cd dineq-backend
go run ./cmd/api

```

3. Run with hot-reload (recommended):

```bash
cd dineq-backend
air -c air.toml
# or from repo root: air -c dineq-backend/air.toml
```

4. Use Postman collection `postman-collections/MenuMate API v1 - Comprehensive Collection.postman_collection.json` to exercise endpoints.

Skip DB mode (quick CORS/middleware test)

- Set `SKIP_DB=true` to start the server without connecting to MongoDB (useful for testing CORS or middleware changes):

```bash
SKIP_DB=true go run ./cmd/api
```

---

## Build & CI

- Standard build: `go build ./...` from `dineq-backend`.
- For CI: run `go test ./...` (unit tests under `test/unit`) and run integration tests in `test/integration` against a test MongoDB instance.
- Lint and vet as part of CI (recommend `golangci-lint`).

---

## Database & Indexes

The app ensures indexes on startup (look at `internal/infrastructure/database/indexes.go`). Representative indexes created:

- restaurants: `ux_slug`, `ix_previous_slugs`, `ix_location_2dsphere`, `ix_name`, `ix_tags`, `ix_averageRating`, `ix_viewCount`
- users: `ux_email`, `ux_phone_number`, `ux_username`
- refresh_tokens and password_reset_tokens: token hash and TTL fields

Indexes are idempotent and safe to ensure on startup.

---

## Third-party services & optional features

- AI classification and parsing (Gemini): optional — will be used if `GEMINI_API_KEY` is set.
- Image search aggregation: slices results from Google, Unsplash, and Pexels. API keys required for each provider.
- OCR: integrations may use Veryfi or other OCR processing; configure via env.
- Cloudinary for uploads (images) — optional keys required.

The code gracefully degrades when keys are missing (services are nil and fallbacks apply).

---

## Postman & API documentation

Postman collection: `postman-collections/MenuMate API v1 - Comprehensive Collection.postman_collection.json`.

- Import to Postman to get example requests, collections and environment examples are in `postman-collections/environments/`.
- The Postman collection includes expected request/response formats, and auth flows.

---

## Testing

- Unit tests: `test/unit` — run with `go test ./...` or target files.
- Integration tests: `test/integration` — requires a running MongoDB instance; run via `go test ./test/integration -run TestName`.

---

## Troubleshooting

- "no Go files in /path": run `cd dineq-backend && go build ./cmd/api` — ensure you're running commands from correct module root.
- Port in use (default `:8080`): check `ss -ltnp | grep 8080` and stop conflicting process or change `PORT`.
- External API failures: check logs — services log warnings and the app falls back to alternate behavior where applicable.
- MongoDB connection issues: verify `DB_URI` and that Mongo is reachable.

---

## Deployment notes

- Ensure environment variables for third-party integrations are set in staging/production.
- Run migration/index-creation job or rely on app startup (indexes are ensured at startup).
- Monitor endpoints and background job queue (OCR jobs) in staging before production cutover.

---

## Security & Privacy

- Keep secrets out of the repository (`.env` files should be ignored in git). Use secrets manager for production.
- Access tokens and refresh tokens are signed using environment-provided secrets.
- Rate limits and API keys/proxying should be enforced at the API gateway/reverse-proxy layer.

---

## Contributing & Workflow

- Feature branches should be merged into `Backend_develop` first, then we perform integration and QA before merging to `main`.
- Follow the PR template and include unit tests for new behavior. Add Postman examples for new endpoints.

---

## Useful commands

```bash
# Build & run
cd dineq-backend
go run ./cmd/api

# Hot reload (Air)
air -c air.toml
# or from repo root
air -c dineq-backend/air.toml

# Tests
cd dineq-backend
go test ./...

# Run a single integration test (example)
cd dineq-backend
go test ./test/integration -run TestRestaurantIntegration
```

---

## Further improvements / TODOs

- Add full automated integration pipeline in CI with ephemeral MongoDB instances.
- Add API rate-limiting middleware and request tracing (OpenTelemetry).
- Add swagger generation from router/DTO annotations to keep API docs DRY.

---
