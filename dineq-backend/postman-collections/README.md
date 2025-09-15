# MenuMate API - Postman Collection Documentation

## Overview

This directory contains comprehensive Postman collections and environments for testing and documenting the MenuMate API. The collection is designed to be production-ready, well-organized, and future-proof.

## Contents

- `MenuMate-API-Collection.json` - Main Postman collection with all API endpoints
- `environments/development.json` - Development environment configuration
- `environments/production.json` - Production environment configuration
- `README.md` - This documentation file

## Collection Features

### 🔧 **Automatic Token Management**

- Automatically stores access and refresh tokens after login
- Pre-request scripts handle token refresh automatically
- No manual token management required

### 📊 **Comprehensive Testing**

- Built-in response validation tests
- Status code verification
- Response time monitoring
- JSON structure validation

### 🎯 **Well-Organized Structure**

The collection is organized into logical groups:

1. **Authentication** - Login, registration, password management, OAuth
2. **User Management** - Profile updates, password changes
3. **Restaurant Management** - CRUD operations for restaurants
4. **Menu Management** - Menu and menu item operations (future)
5. **Reviews & Ratings** - Review system (future)
6. **Staff Management** - Employee management (future)
7. **Analytics & Reports** - Business intelligence (future)
8. **Admin** - Administrative functions (future)

### 🚀 **Future-Proof Design**

- Includes placeholder endpoints for planned features
- Extensible structure for new modules
- Detailed documentation for each endpoint
- Examples and use cases provided

## Setup Instructions

### 1. Import the Collection

1. Open Postman
2. Click "Import" button
3. Select `MenuMate-API-Collection.json`
4. The collection will be imported with all folders and requests

### 2. Import Environment

1. Click on "Environments" in the left sidebar
2. Click "Import"
3. Select the appropriate environment file:
   - `environments/development.json` for local development
   - `environments/production.json` for production testing

### 3. Select Environment

1. In the top-right corner of Postman, select the imported environment
2. The base URL and other variables will be automatically configured

### 4. Test the API

1. Start with the Authentication folder
2. Use "Register User" to create a test account
3. Use "Login User" to authenticate (tokens will be stored automatically). The `identifier` field accepts a username, email, or phone number used during registration.
4. Test other endpoints that require authentication

## Environment Variables

### Automatically Managed

These variables are automatically set by the collection scripts:

- `access_token` - JWT access token
- `refresh_token` - JWT refresh token
- `token_expiry` - Token expiration timestamp
- `user_id` - Current user ID

### Manual Configuration

You may need to set these based on your testing needs:

- `restaurant_id` - ID of restaurant for testing
- `restaurant_slug` - Slug of restaurant for testing
- `test_user_email` - Email for test user accounts
- `test_user_password` - Password for test user accounts

## API Endpoints Overview

### 🔐 Authentication Endpoints

| Method | Endpoint                | Description               | Auth Required |
| ------ | ----------------------- | ------------------------- | ------------- |
| POST   | `/auth/register`        | Register new user         | No            |
| POST   | `/auth/login`           | User login                | No            |
| POST   | `/auth/logout`          | User logout               | No            |
| POST   | `/auth/refresh`         | Refresh access token      | No            |
| POST   | `/auth/forgot-password` | Request password reset    | No            |
| POST   | `/auth/reset-password`  | Reset password with token | No            |
| GET    | `/auth/google/login`    | Google OAuth login        | No            |
| GET    | `/auth/google/callback` | Google OAuth callback     | No            |
| POST   | `/auth/verify-email`    | Send verification email   | Yes           |
| POST   | `/auth/resend-otp`      | Resend OTP code           | Yes           |
| PATCH  | `/auth/verify-otp`      | Verify OTP code           | Yes           |

### 👤 User Management Endpoints

| Method | Endpoint                 | Description         | Auth Required |
| ------ | ------------------------ | ------------------- | ------------- |
| PATCH  | `/users/update-profile`  | Update user profile | Yes           |
| PATCH  | `/users/change-password` | Change password     | Yes           |

### 🏪 Restaurant Management Endpoints

| Method | Endpoint                      | Description             | Auth Required |
| ------ | ----------------------------- | ----------------------- | ------------- |
| POST   | `/restaurants`                | Create restaurant       | Yes           |
| GET    | `/restaurants/:slug`          | Get restaurant by slug  | No            |
| PUT    | `/restaurants/:slug`          | Update restaurant       | Yes           |
| DELETE | `/restaurants/:id`            | Delete restaurant       | Yes           |
| GET    | `/restaurants/:slug/branches` | Get restaurant branches | No            |
| GET    | `/restaurants`                | List unique restaurants | No            |

### 🔮 Future Endpoints

The collection includes detailed documentation for planned features:

- Menu and menu item management
- Review and rating system
- Staff management
- Analytics and reporting
- Administrative functions

## Testing Workflow

### 1. Authentication Flow

```
Register User → Login → Verify Email → Send OTP → Verify OTP
```

### 2. Restaurant Management Flow

```
Create Restaurant → Get Restaurant → Update Restaurant → List Restaurants
```

### 3. OAuth Flow

```
Google Login → Google Callback → Automatic Account Creation/Link
```

## Error Handling

The API uses consistent error response format:

```json
{
  "message": "Error description",
  "error": "Detailed error information (optional)"
}
```

Common HTTP status codes:

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

## Security Considerations

### Development Environment

- Uses HTTP for local development
- Includes test credentials for convenience
- All tokens are automatically managed

### Production Environment

- Uses HTTPS for all requests
- No test credentials included
- Requires manual configuration of sensitive data
- Extra validation tests included

## Advanced Features

### Pre-request Scripts

- Automatic token refresh before each request
- Token expiry checking
- Environment-specific configurations

### Test Scripts

- Response validation
- Token extraction and storage
- Performance monitoring
- Error detection

### Variables and Scoping

- Collection-level variables for common data
- Environment-specific overrides
- Automatic variable management

## Contributing

When adding new endpoints to the collection:

1. **Follow the naming convention**: Use descriptive names with action verbs
2. **Add comprehensive documentation**: Include request/response examples
3. **Include proper tests**: Add validation scripts
4. **Update this README**: Document new endpoints and features
5. **Consider future expansion**: Design with scalability in mind

## Troubleshooting

### Common Issues

**Token Expired Errors**

- Solution: The pre-request script should handle this automatically
- Manual fix: Clear `access_token` variable and login again

**Environment Not Selected**

- Solution: Select the appropriate environment in the top-right dropdown

**Base URL Not Set**

- Solution: Verify the environment is selected and `base_url` variable is set

**Request Failing**

- Check if the backend server is running
- Verify the environment variables are correct
- Check the console for script errors

### Debug Mode

Enable Postman Console (View → Show Postman Console) to see:

- Pre-request script logs
- Test script outputs
- Network request details
- Variable values

## Version History

- **v1.0** - Initial collection with authentication and restaurant management
- **Future versions** - Will include menu management, reviews, staff management, etc.

## Support

For issues related to:

- **API endpoints**: Check the backend repository documentation
- **Postman collection**: Create an issue in the project repository
- **Authentication problems**: Verify your environment configuration
- **Feature requests**: Submit through the project's issue tracker

---

_This collection is maintained alongside the MenuMate backend development and is updated regularly with new features and improvements._
