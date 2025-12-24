# KerjaFlow API Contract Specification

**OpenAPI 3.0 • Authentication Design • Error Handling**

Version 1.0 — December 2025

> **PURPOSE:** This document defines the complete API contract for KerjaFlow mobile app. Includes authentication flow, all endpoints, request/response schemas, and error codes.
>
> **COMPANION FILE:** `03_OpenAPI.yaml` — Machine-readable OpenAPI 3.0 specification

---

## 1. Authentication Architecture

### 1.1 Authentication Strategy

KerjaFlow uses a **dual-layer authentication** approach:

| Layer | Mechanism | Purpose |
|-------|-----------|---------|
| **Primary** | JWT Bearer Token | API access authentication |
| **Secondary** | 6-digit PIN | Sensitive data access (payslips) |

### 1.2 Token Lifecycle

| Token Type | Lifetime | Storage | Refresh Strategy |
|------------|----------|---------|------------------|
| Access Token | 24 hours | flutter_secure_storage | Auto-refresh when <1 hour remaining |
| Refresh Token | 7 days | flutter_secure_storage | Re-login required when expired |
| PIN Verification | 5 minutes | Memory only | Re-verify for each sensitive op |

### 1.3 JWT Token Structure

Access token payload contains:

```json
{
  "sub": "user_id",       // User ID (integer)
  "emp": "employee_id",   // Employee ID (integer)
  "cid": "company_id",    // Company ID (integer)
  "role": "EMPLOYEE",     // Role string
  "iat": 1703059200,      // Issued at (Unix timestamp)
  "exp": 1703145600       // Expires at (Unix timestamp)
}
```

### 1.4 Authentication Flow Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                           LOGIN FLOW                                │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  [Mobile App]                            [Backend API]             │
│       │                                        │                   │
│       │──── POST /auth/login ─────────────────▶│                   │
│       │     {username, password, device_id}    │                   │
│       │                                        │                   │
│       │◀─── 200 OK ────────────────────────────│                   │
│       │     {access_token, refresh_token,      │                   │
│       │      expires_at, user, has_pin}        │                   │
│       │                                        │                   │
│       │──── Store tokens in SecureStorage ────▶│  (local)          │
│       │                                        │                   │
│       │──── GET /dashboard ───────────────────▶│                   │
│       │     Authorization: Bearer {token}      │                   │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                   SENSITIVE DATA FLOW (Payslip)                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  [Mobile App]                            [Backend API]             │
│       │                                        │                   │
│       │──── User taps "View Payslip" ─────────▶│                   │
│       │                                        │                   │
│       │◀─── Show PIN entry dialog ─────────────│  (local UI)       │
│       │                                        │                   │
│       │──── POST /auth/pin/verify ────────────▶│                   │
│       │     {pin: "123456"}                    │                   │
│       │                                        │                   │
│       │◀─── 200 OK ────────────────────────────│                   │
│       │     {verification_token, expires_at}   │                   │
│       │                                        │                   │
│       │──── GET /payslips/{id} ───────────────▶│                   │
│       │     Authorization: Bearer {access_token}                   │
│       │     X-Verification-Token: {pin_token}  │                   │
│       │                                        │                   │
│       │◀─── 200 OK (Payslip data) ─────────────│                   │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### 1.5 Security Rules

| Rule | Implementation |
|------|----------------|
| Failed login lockout | 5 failed attempts → 15 minute lockout |
| Failed PIN lockout | 5 failed attempts → require password re-auth |
| Password requirements | Min 8 chars, 1 uppercase, 1 number |
| Token storage | flutter_secure_storage (Keychain/EncryptedPrefs) |
| Concurrent sessions | Single device only (new login invalidates old) |
| Sensitive endpoints | Payslip view/download requires PIN verification |

---

## 2. API Endpoints Summary

Complete endpoint list organized by domain. Full schemas in `03_OpenAPI.yaml`

### 2.1 Authentication (6 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **POST** | /auth/login | Login with username/password |
| **POST** | /auth/refresh | Refresh access token |
| **POST** | /auth/logout | Logout and invalidate tokens |
| **POST** | /auth/pin/setup | Set up 6-digit PIN |
| **POST** | /auth/pin/verify | Verify PIN for sensitive ops |
| **POST** | /auth/password/change | Change password |

### 2.2 Profile (4 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /profile | Get current user profile |
| **PATCH** | /profile | Update profile (limited fields) |
| **POST** | /profile/photo | Upload profile photo |
| **GET** | /dashboard | Dashboard summary data |

### 2.3 Payslips (3 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /payslips | List payslips (paginated) |
| **GET** | /payslips/{id} | Get payslip details (PIN required) |
| **GET** | /payslips/{id}/pdf | Download payslip PDF (PIN required) |

### 2.4 Leave (8 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /leave/balances | Get leave balances |
| **GET** | /leave/types | Get available leave types |
| **GET** | /leave/requests | List my leave requests |
| **POST** | /leave/requests | Submit leave request |
| **GET** | /leave/requests/{id} | Get leave request details |
| **POST** | /leave/requests/{id}/cancel | Cancel leave request |
| **GET** | /leave/calendar | Get leave calendar |
| **GET** | /public-holidays | Get public holidays |

### 2.5 Approvals (3 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /approvals/pending | Get pending approvals (SUPV/HR) |
| **POST** | /approvals/{id}/approve | Approve leave request |
| **POST** | /approvals/{id}/reject | Reject leave request |

### 2.6 Notifications (4 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /notifications | Get notifications (cursor pagination) |
| **GET** | /notifications/unread-count | Get unread count (for badge) |
| **POST** | /notifications/{id}/read | Mark as read |
| **POST** | /notifications/read-all | Mark all as read |

### 2.7 Documents (4 endpoints)

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | /documents | List my documents |
| **POST** | /documents | Upload document |
| **GET** | /documents/{id} | Get document details |
| **GET** | /documents/{id}/download | Download document file |

**TOTAL: 32 endpoints** covering all MVP functionality

---

## 3. Error Handling

### 3.1 Error Response Format

All errors return consistent JSON structure:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Validation failed",
  "details": { ... },
  "field_errors": [
    { "field": "date_from", "message": "Must be future date" }
  ]
}
```

### 3.2 HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| **200** | OK | Successful GET, PUT, PATCH, DELETE |
| **201** | Created | Successful POST (resource created) |
| **204** | No Content | Successful DELETE, logout, mark-as-read |
| **400** | Bad Request | Validation error, malformed request |
| **401** | Unauthorized | Invalid/expired token, bad credentials |
| **403** | Forbidden | Valid token but insufficient permissions |
| **404** | Not Found | Resource doesn't exist or user can't access |
| **413** | Payload Too Large | File upload exceeds limit |
| **423** | Locked | Account locked due to failed attempts |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Internal Error | Unexpected server error (log and alert) |

### 3.3 Application Error Codes

| Error Code | Description |
|------------|-------------|
| INVALID_CREDENTIALS | Username or password incorrect |
| ACCOUNT_LOCKED | Too many failed attempts, try later |
| TOKEN_EXPIRED | Access token expired, use refresh |
| INVALID_PIN | PIN verification failed |
| PIN_REQUIRED | Sensitive operation requires PIN |
| INSUFFICIENT_BALANCE | Not enough leave balance |
| LEAVE_OVERLAP | Dates overlap with existing leave |
| INSUFFICIENT_NOTICE | Leave requires more advance notice |
| ATTACHMENT_REQUIRED | This leave type requires document |
| CANNOT_CANCEL | Leave already started or rejected |
| FILE_TOO_LARGE | Upload exceeds size limit |
| INVALID_FILE_TYPE | File type not allowed |
| VALIDATION_ERROR | Request body validation failed |

---

## 4. Pagination Strategy

### 4.1 Offset Pagination

Used for bounded, infrequently changing datasets.

**Endpoints using offset pagination:**
- Payslips (GET /payslips)
- Leave requests (GET /leave/requests)
- Documents (GET /documents)
- Approvals (GET /approvals/pending)

**Request parameters:**
```
GET /payslips?page=2&per_page=12&year=2025
```

**Response metadata:**
```json
"meta": {
  "current_page": 2,
  "per_page": 12,
  "total_pages": 4,
  "total_count": 48
}
```

### 4.2 Cursor Pagination

Used for unbounded, frequently updated datasets.

**Endpoints using cursor pagination:**
- Notifications (GET /notifications)

**Request parameters:**
```
GET /notifications?cursor=eyJpZCI6MTIzfQ&limit=20
```

**Response metadata:**
```json
"meta": {
  "next_cursor": "eyJpZCI6MTQzfQ",
  "has_more": true
}
```

### 4.3 Limits

| Parameter | Value |
|-----------|-------|
| Default page size | 20 |
| Maximum page size | 100 |
| Payslips per page (default) | 12 (shows 1 year) |
| Notifications limit (max) | 50 |

---

## 5. Rate Limiting

| Endpoint Category | Rate Limit | Scope |
|-------------------|------------|-------|
| Authentication (/auth/*) | 10 requests/minute | Per IP address |
| File uploads (/documents, /profile/photo) | 10 requests/minute | Per user |
| General API | 60 requests/minute | Per user |

**Rate limit headers returned:**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1703059260
```

---

## 6. File Upload Constraints

| Upload Type | Max Size | Allowed Types | Notes |
|-------------|----------|---------------|-------|
| Profile photo | 5 MB | JPEG, PNG | Auto-resized to 500x500 |
| Documents | 10 MB | JPEG, PNG, PDF | Original preserved |
| MC attachment | 10 MB | JPEG, PNG, PDF | Links to leave request |

---

*— End of API Contract Specification —*
