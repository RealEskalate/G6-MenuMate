# API Testing Checklist - MenuMate Backend

## 🔧 Pre-Testing Setup

- [ ] Backend server is running (`air` or `go run ./cmd/api`)
- [ ] Database is connected and accessible
- [ ] Environment variables are properly configured (.env file)
- [ ] Postman collection imported with correct environment selected

## 🔐 Authentication Flow Testing

### User Registration

- [ ] Register with valid data → Should return 201 with user object
- [ ] Register with existing email → Should return 400/409 error
- [ ] Register with invalid email format → Should return 400 error
- [ ] Register with short password → Should return 400 error
- [ ] Register with missing required fields → Should return 400 error

### User Login

- [ ] Login with valid credentials → Should return 200 with tokens
- [ ] Login with invalid password → Should return 401 error
- [ ] Login with non-existent user → Should return 401 error
- [ ] Login with empty credentials → Should return 400 error
- [ ] Tokens are automatically stored in environment variables

### Token Management

- [ ] Access token is included in Authorization header automatically
- [ ] Token refresh works when access token expires
- [ ] Invalid tokens return 401 errors
- [ ] Logout invalidates refresh tokens

### Password Management

- [ ] Forgot password sends email (check logs if email not configured)
- [ ] Reset password with valid token works
- [ ] Reset password with invalid/expired token fails
- [ ] Change password with correct old password works
- [ ] Change password with incorrect old password fails

### Email Verification & OTP

- [ ] Verify email request sends OTP (check logs)
- [ ] Verify OTP with correct code works
- [ ] Verify OTP with incorrect code fails
- [ ] Resend OTP generates new code
- [ ] OTP expires after configured time

### Google OAuth (if configured)

- [ ] Google login redirect works
- [ ] Google callback handles successful authentication
- [ ] Google callback creates new user for first-time login
- [ ] Google callback links to existing account with same email

## 👤 User Management Testing

### Profile Updates

- [ ] Update profile with valid data works
- [ ] Update profile with invalid data fails validation
- [ ] File upload for avatar works (if implemented)
- [ ] Profile update requires authentication
- [ ] Updated fields are reflected in response

### Password Changes

- [ ] Change password with valid old password works
- [ ] Change password with invalid old password fails
- [ ] New password meets security requirements
- [ ] User can login with new password

## 🏪 Restaurant Management Testing

### Restaurant Creation

- [ ] Create restaurant with valid data → Should return 201
- [ ] Create restaurant requires authentication
- [ ] Restaurant slug is auto-generated from name
- [ ] Manager ID is set from authenticated user
- [ ] Verification status defaults to "pending"
- [ ] Created restaurant appears in database

### Restaurant Retrieval

- [ ] Get restaurant by slug works (public endpoint)
- [ ] Get non-existent restaurant returns 404
- [ ] Restaurant data includes all expected fields
- [ ] View count increments on each request

### Restaurant Updates

- [ ] Update restaurant by owner/manager works
- [ ] Update restaurant by non-owner fails with 403
- [ ] Update with valid data succeeds
- [ ] Update with invalid data fails validation
- [ ] Slug regenerated if name changes
- [ ] Update timestamp is modified

### Restaurant Deletion

- [ ] Delete restaurant by owner works
- [ ] Delete restaurant by non-owner fails with 403
- [ ] Delete with valid ObjectID works
- [ ] Delete with invalid ObjectID fails
- [ ] Soft delete preserves data (is_deleted flag)

### Restaurant Listing

- [ ] Get unique restaurants returns paginated results
- [ ] Get restaurant branches works with valid slug
- [ ] Pagination parameters work correctly
- [ ] Response includes pagination metadata
- [ ] Results are properly sorted

## 📊 Data Validation Testing

### Input Validation

- [ ] Email format validation works
- [ ] Phone number format validation works
- [ ] Required fields are enforced
- [ ] String length limits are enforced
- [ ] Array fields accept valid arrays
- [ ] Invalid JSON returns proper error

### MongoDB ObjectID Validation

- [ ] Invalid ObjectID format returns 400 error
- [ ] Valid ObjectID format is accepted
- [ ] Non-existent ObjectID returns 404

### Authorization Testing

- [ ] Protected endpoints require valid tokens
- [ ] Expired tokens are rejected
- [ ] Invalid tokens are rejected
- [ ] Role-based access works where implemented

## 🌐 HTTP Status Codes

### Success Codes

- [ ] 200: Successful GET, PUT, PATCH requests
- [ ] 201: Successful POST requests (creation)
- [ ] 204: Successful DELETE requests (if no content returned)

### Client Error Codes

- [ ] 400: Bad request (invalid data, validation errors)
- [ ] 401: Unauthorized (missing/invalid auth token)
- [ ] 403: Forbidden (insufficient permissions)
- [ ] 404: Not found (invalid routes, non-existent resources)
- [ ] 409: Conflict (duplicate email, username, etc.)
- [ ] 422: Unprocessable entity (validation errors)

### Server Error Codes

- [ ] 500: Internal server error (check logs for details)

## 🔍 Response Format Testing

### Success Responses

- [ ] Consistent JSON structure
- [ ] Proper data types (strings, numbers, booleans, arrays)
- [ ] Timestamps in ISO 8601 format
- [ ] No sensitive data in responses (passwords, etc.)

### Error Responses

- [ ] Consistent error format with message field
- [ ] Helpful error messages
- [ ] Proper error codes
- [ ] No sensitive information leaked in errors

## 🚀 Performance Testing

### Response Times

- [ ] Authentication endpoints respond within 2 seconds
- [ ] CRUD operations respond within 3 seconds
- [ ] List operations respond within 5 seconds
- [ ] No memory leaks during extended testing

### Concurrent Requests

- [ ] Multiple simultaneous requests handled correctly
- [ ] No race conditions in data creation/updates
- [ ] Database connections managed properly

## 🔒 Security Testing

### Authentication Security

- [ ] Passwords are hashed in database
- [ ] JWT tokens have reasonable expiration times
- [ ] Sensitive endpoints require authentication
- [ ] CORS configured for allowed origins

### Input Security

- [ ] SQL injection attempts are blocked
- [ ] XSS attempts are sanitized
- [ ] Large payloads are rejected
- [ ] Special characters handled properly

## 📝 Documentation Verification

### API Documentation

- [ ] All endpoints documented in Postman collection
- [ ] Request/response examples are accurate
- [ ] Authentication requirements clearly stated
- [ ] Error scenarios documented

### Code Documentation

- [ ] Handler functions have clear comments
- [ ] DTO structures are well-defined
- [ ] Use case interfaces are documented
- [ ] Repository methods have proper descriptions

## 🐛 Error Handling

### Database Errors

- [ ] Database connection failures handled gracefully
- [ ] Duplicate key errors return appropriate status codes
- [ ] Validation errors from database are caught

### External Service Errors

- [ ] Email service failures don't crash the application
- [ ] File upload service errors are handled
- [ ] OAuth service errors are managed properly

## 📊 Monitoring & Logging

### Logging

- [ ] Request/response logging works
- [ ] Error logging captures stack traces
- [ ] Authentication events are logged
- [ ] No sensitive data in logs

### Health Monitoring

- [ ] Application starts successfully
- [ ] Database connectivity maintained
- [ ] Memory usage stays within limits
- [ ] No goroutine leaks

## 🔄 Environment Testing

### Development Environment

- [ ] All endpoints work with localhost
- [ ] Debug logging is enabled
- [ ] Test credentials work properly
- [ ] Hot reload works with Air

### Production Environment (when deployed)

- [ ] HTTPS enforced
- [ ] Production database connected
- [ ] Environment variables loaded correctly
- [ ] Error logging configured
- [ ] Performance optimized

---

## 📋 Testing Notes

**Date:** ****\_\_\_****  
**Tester:** ****\_\_\_****  
**Backend Version:** ****\_\_\_****  
**Database:** ****\_\_\_****

**Issues Found:**

- [ ] Issue 1: ****************\_****************
- [ ] Issue 2: ****************\_****************
- [ ] Issue 3: ****************\_****************

**Overall Status:**

- [ ] ✅ All tests passed
- [ ] ⚠️ Minor issues found
- [ ] ❌ Critical issues require fixes

**Next Actions:**

1. ***
2. ***
3. ***
