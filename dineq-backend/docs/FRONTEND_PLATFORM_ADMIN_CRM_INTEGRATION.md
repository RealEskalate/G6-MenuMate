<!-- markdownlint-disable -->

# DineQ Frontend Integration Guide (Platform Admin, CRM, Waiter, Staff, Customer Experience)

This document is the backend contract for the newly completed platform features:
- Super Admin system control and approvals
- Restaurant CRM analytics and customer insights
- Waiter operational flow (orders, sessions, post-meal logs)
- Owner/Manager staff lifecycle (manager/staff/waiter onboarding)
- Customer preference/history endpoints for tailored experiences

Base URL: `{{BASE_URL}}/api/v1`

Auth:
- Protected endpoints require `Authorization: Bearer <access_token>` or access token cookie.
- Role checks are enforced server-side.

---

## 1) Role Matrix (Backend-Enforced)

- `SUPER_ADMIN`: global platform control
- `OWNER`: restaurant-level management + CRM + staffing
- `MANAGER`: restaurant-level management + CRM + staffing
- `WAITER`: orders, sessions, waiter logs
- `STAFF`: limited customer profile operational access
- `CUSTOMER`: self-history and preferences

---

## 2) Super Admin API (`/super-admin`)

All endpoints below require `SUPER_ADMIN` role.

### 2.1 Dashboard Analytics
- `GET /super-admin/dashboard?period=today|week|month|year`
- Response includes:
  - `overview` (users, restaurants, approvals, orders)
  - `usersByRole`
  - `restaurantsByStatus`
  - `topRestaurants`
  - `pendingApprovalList`
  - `recentRegistrations`
  - `systemHealth`

### 2.2 User Governance
- `GET /super-admin/users?role=&status=&search=&page=1&pageSize=20`
- `PATCH /super-admin/users/:userId/status`
  - Body: `{ "status": "ACTIVE|INACTIVE|SUSPENDED", "reason": "..." }`
- `PATCH /super-admin/users/:userId/role`
  - Body: `{ "role": "ADMIN|OWNER|MANAGER|STAFF|WAITER|CUSTOMER|SUPER_ADMIN" }`
- `DELETE /super-admin/users/:userId`
  - Body (optional): `{ "reason": "..." }`

### 2.3 Restaurant Approvals & Governance
- `GET /super-admin/restaurants?status=pending|verified|rejected&search=&page=1&pageSize=20`
- `POST /super-admin/restaurants/:restaurantId/approve`
  - Body (optional): `{ "comment": "..." }`
- `POST /super-admin/restaurants/:restaurantId/reject`
  - Body: `{ "reason": "..." }`
- `GET /super-admin/approvals/pending?page=1&pageSize=20`

### 2.4 Audit Trail
- `GET /super-admin/audit-logs?actorId=&entityType=&entityId=&action=&dateFrom=<RFC3339>&dateTo=<RFC3339>&page=1&pageSize=50`

---

## 3) CRM API (`/crm`)

Access: `OWNER`, `MANAGER`, `SUPER_ADMIN`

### 3.1 CRM Dashboard
- `GET /crm/restaurants/:restaurantId/dashboard?period=today|week|month|year`
- Response includes:
  - customer totals (`new`, `returning`, `atRisk`, `lost`)
  - retention and loyalty distributions
  - top spenders, recent visitors
  - customer growth trend
  - revenue, AOV, peak hours
  - top items
  - waiter performance
  - food consumption insights
  - satisfaction/NPS estimate

### 3.2 CRM Customer Views
- `GET /crm/restaurants/:restaurantId/customers?segment=&loyaltyTier=&search=&tag=&sortBy=&order=-1&page=1&pageSize=20`
- `GET /crm/customers/:profileId`
- `GET /crm/restaurants/:restaurantId/customers/export`
  - Returns export-ready customer summary rows

---

## 4) Waiter Intelligence API (`/waiter/logs`)

Access: `WAITER`, `MANAGER`, `OWNER`, `SUPER_ADMIN`

### 4.1 Create Post-Meal Waiter Log
- `POST /waiter/logs`
- Body example:
```json
{
  "orderId": "...",
  "sessionId": "...",
  "restaurantId": "...",
  "tableNumber": "A-03",
  "customerId": "...",
  "customerName": "Optional Name",
  "observations": [
    {
      "itemId": "...",
      "itemName": "Margherita Pizza",
      "consumptionStatus": "COMPLETE|PARTIAL|NOT_EATEN|RETURNED",
      "leftoverPercentage": 15,
      "customerComment": "Tasted great",
      "reason": "too_spicy"
    }
  ],
  "customerMood": "HAPPY|NEUTRAL|DISSATISFIED|ANGRY",
  "serviceRating": 5,
  "willLikelyReturn": true,
  "tableDuration": 58,
  "totalCoversCount": 2,
  "upsellAttempted": true,
  "upsellSucceeded": true,
  "notes": "Requested less spice next time"
}
```

### 4.2 Query/Update Logs
- `PUT /waiter/logs/:logId`
- `GET /waiter/logs/:logId`
- `GET /waiter/logs?restaurantId=&waiterId=&orderId=&customerMood=&dateFrom=<RFC3339>&dateTo=<RFC3339>&page=1&pageSize=20`
- `GET /waiter/logs/orders/:orderId`

### 4.3 Waiter/Food Analytics
- `GET /waiter/logs/restaurants/:restaurantId/insights/food?period=month`
- `GET /waiter/logs/waiters/:waiterId/stats?period=month`

---

## 5) Orders API (`/orders`)

Access: `WAITER`, `MANAGER`, `OWNER`, `SUPER_ADMIN`

### 5.1 Core Order Flow
- `POST /orders` (waiter creates order)
- `GET /orders/:orderId`
- `PUT /orders/:orderId`
- `PATCH /orders/:orderId/status`
  - Body: `{ "status": "PENDING|CONFIRMED|PREPARING|READY|SERVED|COMPLETED|CANCELLED" }`
- `DELETE /orders/:orderId`

### 5.2 Listing + Session Linking + KPIs
- `GET /orders?restaurantId=&waiterId=&customerId=&status=&tableNumber=&dateFrom=<RFC3339>&dateTo=<RFC3339>&page=1&pageSize=20`
- `GET /orders/session/:sessionId`
- `GET /orders/analytics/revenue?restaurantId=&period=today|week|month|year`
- `GET /orders/analytics/count?restaurantId=&period=today|week|month|year`

---

## 6) Table Session API (`/table-sessions`)

Access: `WAITER`, `MANAGER`, `OWNER`, `SUPER_ADMIN`

### 6.1 Session Lifecycle
- `POST /table-sessions` (open table)
- `GET /table-sessions/:sessionId`
- `PUT /table-sessions/:sessionId`
- `POST /table-sessions/:sessionId/close` (close table + finalize spend)

### 6.2 Session Discovery
- `GET /table-sessions?restaurantId=&page=1&pageSize=20`
- `GET /table-sessions/active?restaurantId=&tableNumber=`
- `GET /table-sessions/waiters/:waiterId/active`

---

## 7) Staff Management API (`/staff`)

### 7.1 Owner/Manager/SuperAdmin Capabilities
Access: `OWNER`, `MANAGER`, `SUPER_ADMIN`

- `POST /staff/invitations`
  - Body:
  ```json
  {
    "restaurantId": "...",
    "email": "person@example.com",
    "name": "Person",
    "role": "MANAGER|STAFF|WAITER"
  }
  ```
- `POST /staff/invitations/:invitationId/revoke`
- `GET /staff/invitations?restaurantId=`
- `DELETE /staff/restaurants/:restaurantId/members/:staffId`
- `GET /staff/restaurants/:restaurantId/members?role=MANAGER|STAFF|WAITER`

### 7.2 Any Authenticated User
- `POST /staff/invitations/accept`
  - Body: `{ "token": "..." }`
- `GET /staff/my-assignments`

---

## 8) Customer Profile + Personalization API (`/customer-profiles`)

### 8.1 Restaurant Ops Access
Access: `OWNER`, `MANAGER`, `WAITER`, `STAFF`, `SUPER_ADMIN`

- `GET /customer-profiles/:profileId`
- `PUT /customer-profiles/:profileId`
- `POST /customer-profiles/:profileId/notes`
  - Body: `{ "note": "Customer asked for low-salt options" }`
- `GET /customer-profiles/restaurants/:restaurantId/customers?segment=&loyaltyTier=&search=&tag=&sortBy=&order=&page=1&pageSize=20`
- `GET /customer-profiles/restaurants/:restaurantId/top?limit=10`
- `GET /customer-profiles/restaurants/:restaurantId/at-risk`
- `POST /customer-profiles/restaurants/:restaurantId/users/:userId/visits`
  - Body: `{ "orderAmount": 1234.5 }`
- `GET /customer-profiles/restaurants/:restaurantId/users/:userId`
  - Get-or-create customer profile for restaurant

### 8.2 Customer Self-Service
Any authenticated user:
- `PATCH /customer-profiles/me/preferences`
  - Body is `DietaryPreferences`:
  ```json
  {
    "isVegetarian": false,
    "isVegan": false,
    "isGlutenFree": true,
    "allergies": ["nuts"],
    "restrictions": ["low sodium"],
    "preferences": ["mild spice", "ethiopian cuisine"]
  }
  ```
- `GET /customer-profiles/me/history?page=1&pageSize=20`

---

## 9) Frontend Implementation Notes

1. Always store role from login token and gate UI routes by role.
2. Super Admin pages should consume `/super-admin/*` only.
3. CRM owner/manager dashboard should consume `/crm/*` and `/customer-profiles/*` for customer operations.
4. Waiter tablet/mobile flow should use:
   - `/table-sessions/*` to open/manage tables
   - `/orders/*` to add and progress orders
   - `/waiter/logs/*` for post-meal intelligence
5. For personalization/voice assistant, consume:
   - `/customer-profiles/me/history`
   - `/customer-profiles/me/preferences`
   - CRM dashboard insights for recommendation tuning.

---

## 10) Error Contract

Validation and domain errors use the unified error envelope:

```json
{
  "message": "human readable message",
  "code": "machine_readable_code",
  "field": "optional_field_name",
  "error": "optional_internal_details_non_production"
}
```

Use `code` for frontend branching logic.
