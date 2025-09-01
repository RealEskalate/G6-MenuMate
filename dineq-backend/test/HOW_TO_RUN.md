# How to Run the MenuMate Project

This mono-repo contains three main components:

- Backend (Go) at `dinq-backend/`
- Frontend (Next.js) at `dineq-frontend/`
- Mobile (Flutter) at `dinq-mobile/`

Below are concise steps and commands to get each piece running plus how to execute tests.

---

## 1. Prerequisites

Install the following tools:

- Go >= 1.22 (module uses modern toolchain)
- Node.js (LTS) & npm (or pnpm/yarn) for frontend
- Flutter SDK (matching versions in `pubspec.yaml`)
- MongoDB instance (local or remote) reachable via `DB_URI`
- (Optional) Air for hot reload of Go backend: `go install github.com/air-verse/air@latest`

Copy or create environment files (adjust values):

```bash
# Backend
cp dinq-backend/.env.example dinq-backend/.env   # if example present

# Frontend (create .env.local if needed)
# touch dineq-frontend/.env.local

# Mobile (create .env style if you adopt env vars via --dart-define)
```
Ensure backend `.env` includes (example minimal):

```env
PORT=:8080
APP_ENV=development
DB_URI=mongodb://localhost:27017
DB_NAME=dinq_db
ACCESS_TOKEN_SECRET=dev_access_secret
REFRESH_TOKEN_SECRET=dev_refresh_secret
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_HOURS=720
CONTEXT_TIMEOUT_SECONDS=10
RESTAURANT_COLLECTION=restaurants
USER_COLLECTION=users
REFRESH_TOKEN_COLLECTION=refresh_tokens
PASSWORD_RESET_TOKEN_COLLECTION=password_resets
```

---

## 2. Run the Backend (Go)

From the repository root:

```bash
cd dinq-backend
# Hot reload (preferred in dev)
air
# OR plain run
go run ./cmd/api
# OR build optimized binary
go build -o tmp/app ./cmd/api && ./tmp/app
```
The API will listen on the `PORT` value (e.g. :8080). Visit `http://localhost:8080/api/v1` routes.

### 2.1 Run Unit & Integration Tests

```bash
cd dinq-backend
# All tests
go test ./... -count=1
# Only unit tests
go test ./test/unit/... -count=1
# Only integration tests (requires reachable Mongo specified in env)
go test ./test/integration -count=1
```
Integration tests use real Mongo and will `Skip` if required env vars are missing.

### 2.2 Common Troubleshooting

- InvalidNamespace / empty collection name: ensure `RESTAURANT_COLLECTION` is set.
- 401 Unauthorized: make sure your Authorization header is `Bearer <access_token>`.
- Slug redirect: Old restaurant slug returns HTTP 308 with `Location` header to new slug.
- Deleted restaurant slug returns HTTP 410.

---

## 3. Run the Frontend (Next.js)

```bash
cd dineq-frontend
npm install
npm run dev            # starts Next.js dev server (default http://localhost:3000)
# Production build
npm run build && npm start
```
Adjust any required API base URLs via environment variables (e.g. NEXT_PUBLIC_API_BASE_URL) in `.env.local`.

---

## 4. Run the Mobile App (Flutter)

```bash
cd dinq-mobile/dinq
flutter pub get
flutter run            # auto-detects a connected device or emulator
# Web (optional)
flutter run -d chrome
```
Add any API endpoint configuration using `--dart-define` flags if required:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```
For Android emulator, `10.0.2.2` maps to host loopback.

---

## 5. Linting & Formatting

(If configured) Typical commands:

```bash
# Go
cd dinq-backend && go vet ./... && go fmt ./...
# Frontend
cd dineq-frontend && npm run lint
# Flutter (format + analyze)
cd dinq-mobile/dinq && flutter format . && flutter analyze
```

---

## 6. Postman Collection

Import `dinq-backend/postman-collections/MenuMate-API-Collection.json` into Postman. Use the environment files under `postman-collections/environments` for quick variable setup.

---

## 7. Key Behaviors

- Slug changes maintain a capped history for redirects (HTTP 308).
- Soft delete sets `is_deleted` and future GET returns 410 for that slug.
- Unique index on `slug`, supporting index on `previous_slugs` for redirects.

---

## 8. Clean Up Test Data

If integration tests leave residual data (should delete, but just in case):
Use Mongo shell or Compass to remove documents created today in the `restaurants` collection.

---

## 9. Quick Reference

| Task | Command |
|------|---------|
| Run backend (Air) | `air` |
| Run backend (direct) | `go run ./cmd/api` |
| All Go tests | `go test ./... -count=1` |
| Integration tests | `go test ./test/integration -count=1` |
| Frontend dev | `npm run dev` |
| Flutter run | `flutter run` |

---

Feel free to expand this guide as new services or commands are introduced.
