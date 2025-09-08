# DineQ - MenuMate Platform

This project provides a modular restaurant menu service built with Go. It is designed to be flexible and scalable for modern web applications.

## Architecture Overview

- **Domain:** Core entities and repository interfaces.
- **Use Case:** Business logic and service orchestration.
- **Infrastructure:** Database interactions, security services, and repository implementations.
- **Interfaces:** HTTP endpoints, routers, and middleware layers.

## Getting Started

1. Duplicate the sample environment file:
    ```bash
    cp config/.env.example .env
    ```
2. For rapid development, use Air:
    ```bash
    air
    ```
3. Alternatively, build and run the application:
    ```bash
    go build -o tmp/app ./cmd/api && ./tmp/app
    ```

## Technologies Used

- Gin for HTTP routing.
- MongoDB for data storage.
- JWT for authentication.
- bcrypt/scrypt for secure password hashing.

## Next Steps

- Complete repository methods.
- Implement additional use cases.
- Build out HTTP handlers and middleware.
- Further testing and optimization.

