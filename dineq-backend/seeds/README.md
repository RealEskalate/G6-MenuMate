# DineQ Comprehensive Seed Data

This folder contains an exhaustive, realistic Mongo seed script aligned to backend collections and mapper field names.

## File

- [realistic_full_seed.mongosh.js](realistic_full_seed.mongosh.js)

## What gets seeded

- users (admin, owners/managers, customers)
- restaurants (branding, schedule, geo location, verification docs)
- menus (published versions + embedded items)
- items (full nutritional/allergen/translations/metadata)
- review + reaction
- qr
- notifications
- refresh_tokens
- otp
- password_reset_tokens
- password_reset_session_collections
- ocr_jobs (completed, processing, failed states + phase history)
- views (restaurant/menu/item analytics events over time)

## Run

From backend root:

mongosh "mongodb://localhost:27017/dineq_db" --file seeds/realistic_full_seed.mongosh.js

## Important

- The script **deletes existing data** in seeded collections before insert.
- Collection names match backend env defaults used in bootstrap config.
- Seeded user `passwordHash` is a demo hash for testing seeded documents; use normal auth/reset flow for password-based login tests.
