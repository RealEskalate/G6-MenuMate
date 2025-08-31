# MenuMate API Documentation

## Overview

This API documentation provides details for integrating with the MenuMate backend. The API is built with REST principles and uses JSON for request and response bodies.

## Base URL

```
https://localhost.com/api/v1
```

## Authentication

Most endpoints require authentication via JWT tokens. Include the access token in the Authorization header:

```
Authorization: Bearer <access_token>
```

Tokens can be obtained via login or refresh endpoints.

## Response Format

All responses follow a consistent format:

**Success Response:**

```json
{
  "message": "Success message",
  "data": { ... }
}
```

**Error Response:**

```json
{
  "message": "Error message",
  "error": "Detailed error"
}
```

## Endpoints

### Authentication

#### Register User

- **Method:** POST
- **Path:** `/auth/register`
- **Description:** Register a new user account
- **Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "authProvider": "EMAIL",
  "role": "USER"
}
```

- **Response:**

```json
{
  "message": "User registered successfully",
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "isVerified": false,
    "createdAt": "2025-08-28T10:00:00Z"
  }
}
```

- **Errors:** 400 (Invalid input), 409 (User exists)

#### Login

- **Method:** POST
- **Path:** `/auth/login`
- **Description:** Authenticate user and get tokens
- **Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

- **Response:**

```json
{
  "message": "Login successful",
  "data": {
    "accessToken": "jwt-access-token",
    "refreshToken": "jwt-refresh-token"
  }
}
```

- **Errors:** 400 (Invalid credentials), 401 (Unauthorized)

#### Logout

- **Method:** POST
- **Path:** `/auth/logout`
- **Description:** Logout user (client-side token removal recommended)
- **Headers:** Authorization: Bearer <token>
- **Response:**

```json
{
  "message": "Logged out successfully"
}
```

#### Refresh Token

- **Method:** POST
- **Path:** `/auth/refresh`
- **Description:** Get new access token using refresh token
- **Request Body:**

```json
{
  "refreshToken": "refresh-token-here"
}
```

- **Response:**

```json
{
  "data": {
    "accessToken": "new-jwt-access-token",
    "refreshToken": "new-jwt-refresh-token"
  }
}
```

#### Forgot Password

- **Method:** POST
- **Path:** `/auth/forgot-password`
- **Description:** Request password reset
- **Request Body:**

```json
{
  "email": "user@example.com"
}
```

- **Response:**

```json
{
  "message": "Password reset email sent"
}
```

#### Reset Password

- **Method:** POST
- **Path:** `/auth/reset-password`
- **Description:** Reset password with token
- **Request Body:**

```json
{
  "email": "user@example.com",
  "token": "reset-token",
  "newPassword": "newpassword123"
}
```

- **Response:**

```json
{
  "message": "Password reset successfully"
}
```

#### Google OAuth Login

- **Method:** GET
- **Path:** `/auth/google/login`
- **Description:** Initiate Google OAuth login
- **Response:** Redirect to Google OAuth page

#### Google OAuth Callback

- **Method:** GET
- **Path:** `/auth/google/callback`
- **Description:** Handle Google OAuth callback
- **Response:** Redirect with tokens or error

#### Verify Email

- **Method:** POST
- **Path:** `/auth/verify-email`
- **Description:** Request email verification OTP
- **Headers:** Authorization: Bearer <token>
- **Request Body:**

```json
{
  "email": "user@example.com"
}
```

- **Response:**

```json
{
  "message": "Verification email sent"
}
```

#### Resend OTP

- **Method:** POST
- **Path:** `/auth/resend-otp`
- **Description:** Resend OTP for verification
- **Headers:** Authorization: Bearer <token>
- **Response:**

```json
{
  "message": "OTP resent"
}
```

#### Verify OTP

- **Method:** PATCH
- **Path:** `/auth/verify-otp`
- **Description:** Verify OTP code
- **Headers:** Authorization: Bearer <token>
- **Request Body:**

```json
{
  "code": "123456"
}
```

- **Response:**

```json
{
  "message": "OTP verified successfully"
}
```

### User Management

#### Update Profile

- **Method:** PATCH
- **Path:** `/users/update-profile`
- **Description:** Update user profile information
- **Headers:** Authorization: Bearer <token>
- **Request Body:**

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "profileImage": "image-url",
  "preferences": {
    "language": "en-US",
    "theme": "dark",
    "notifications": true
  }
}
```

- **Response:**

```json
{
  "message": "Profile updated successfully",
  "data": { ...user object... }
}
```

#### Change Password

- **Method:** PATCH
- **Path:** `/users/change-password`
- **Description:** Change user password
- **Headers:** Authorization: Bearer <token>
- **Request Body:**

```json
{
  "oldPassword": "oldpassword",
  "newPassword": "newpassword123"
}
```

- **Response:**

```json
{
  "message": "Password changed successfully"
}
```

### OCR Jobs

#### Upload Menu Image

- **Method:** POST
- **Path:** `/ocr/upload`
- **Description:** Upload image for OCR processing
- **Headers:** Authorization: Bearer <token>
- **Request Body:** Multipart form data with image file
- **Response:**

```json
{
  "message": "OCR job created",
  "data": {
    "id": "job-id",
    "status": "processing",
    "createdAt": "2025-08-28T10:00:00Z"
  }
}
```

#### Get OCR Job

- **Method:** GET
- **Path:** `/ocr/{id}`
- **Description:** Get OCR job status and results
- **Headers:** Authorization: Bearer <token>
- **Response:**

```json
{
  "data": {
    "id": "job-id",
    "restaurantId": "restaurant-id",
    "imageUrl": "image-url",
    "status": "completed",
    "resultText": "extracted text",
    "structuredMenuId": "menu-id",
    "createdAt": "2025-08-28T10:00:00Z",
    "updatedAt": "2025-08-28T10:05:00Z"
  }
}
```

#### Delete OCR Job

- **Method:** DELETE
- **Path:** `/ocr/{id}`
- **Description:** Delete OCR job
- **Headers:** Authorization: Bearer <token>
- **Response:**

```json
{
  "message": "OCR job deleted"
}
```

### Notifications

#### Register FCM Token

- **Method:** POST
- **Path:** `notification/fcm-token`
- **Description:** Register FCM token for push notifications
- **Request Body:**

```json
{
  "user_id": "user-id",
  "token": "fcm-token"
}
```

- **Response:**

```json
{
  "status": "ok"
}
```

## Error Codes

- **400:** Bad Request - Invalid input
- **401:** Unauthorized - Invalid or missing token
- **403:** Forbidden - Insufficient permissions
- **404:** Not Found - Resource not found
- **409:** Conflict - Resource already exists
- **500:** Internal Server Error - Server error

## Rate Limiting

API endpoints may have rate limiting. Check response headers for rate limit information.

## Support

For questions or issues, contact the development team.</content>
<parameter name="filePath">c:\Users\yih\Documents\SwEg\GO\Menu-Mate\docs\API_ENDPOINT_USER_AUTH.md
