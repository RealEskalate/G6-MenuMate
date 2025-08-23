# MenuMate Clean Architecture

Scaffold of a restaurant menu platform using Go with Clean Architecture principles.

## Layers

- Domain: Entities & repository interfaces
- Usecase: Application business logic
- Infrastructure: DB, security, repository implementations
- Interfaces: HTTP handlers, router, middleware

## Quick Start

```powershell
# copy env
cp config/.env.example .env
# run with air (if installed)
air
# or build & run
go build -o tmp/app ./cmd/api && ./tmp/app
```

## Tech

- Fiber (HTTP)
- MongoDB
- JWT (auth)
- bcrypt / scrypt (password hashing)

## TODO

Implement repository methods, usecases, handlers.
