# Quick Setup Guide - MenuMate API Testing

## 🚀 Quick Start (5 minutes)

### Step 1: Import Collection

1. Open Postman
2. Click **Import** → Select `MenuMate-API-Collection.json`
3. Click **Import** → Select `environments/development.json`

### Step 2: Select Environment

1. Top-right dropdown → Select "MenuMate Development Environment"

### Step 3: Test Authentication

1. Open **Authentication** → **Public Auth** → **Register User**
2. Click **Send** (uses pre-filled test data)
3. Open **Login User** → Click **Send**
4. ✅ Tokens are automatically stored!

### Step 4: Test Restaurant API

1. Open **Restaurant Management** → **Create Restaurant**
2. Click **Send** (automatically uses your auth token)
3. Test other restaurant endpoints

## 🔑 Key Features

- **Auto Token Management**: Login once, tokens handled automatically
- **Pre-filled Test Data**: Ready-to-use examples in every request
- **Environment Variables**: Switch between dev/prod easily
- **Future-Proof**: Includes planned features with documentation

## 📝 Common Tasks

### Register & Login

```json
// Email Registration (already in collection)
{
  "username": "johndoe",
  "email": "john.doe@example.com",
  "password": "securepassword123",
  "auth_provider": "EMAIL"
}

// Phone Registration (alternative)
{
  "username": "janedoe",
  "phone_number": "+15551234567",
  "password": "securepassword123",
  "auth_provider": "PHONE"
}
```

### Create Restaurant

```json
// Create Restaurant (already in collection)
{
  "name": "The Italian Corner",
  "phone": "+1234567890",
  "about": "Authentic Italian cuisine...",
  "tags": ["Italian", "Pizza", "Pasta"]
}
```

## 🛠 Environment Variables

| Variable          | Auto-Set | Description                |
| ----------------- | -------- | -------------------------- |
| `access_token`    | ✅       | JWT token (auto-refreshed) |
| `refresh_token`   | ✅       | Refresh token              |
| `user_id`         | ✅       | Current user ID            |
| `restaurant_slug` | ❌       | Set manually for testing   |

## 🐛 Troubleshooting

**401 Unauthorized?**
→ Use Login request, tokens will auto-save

**Environment not working?**
→ Check top-right dropdown is set to "MenuMate Development Environment"

**Backend not responding?**
→ Ensure Go backend is running: `air` or `go run ./cmd/api`

## 📚 What's Included

### ✅ Currently Implemented

- User registration & authentication
- Password reset & email verification
- Google OAuth integration
- Restaurant CRUD operations
- Profile management

### 🔮 Future Features (Documented)

- Menu & menu item management
- Review & rating system
- Staff management
- Analytics & reports
- Admin panel functions

---

**Need help?** Check the full `README.md` in this folder or ask the team! 🎉
