# KerjaFlow Technical Addendum

**Offline Sync • Auth Edge Cases • Notifications • Integrations • Clarifications**

Version 1.0 — December 2025

---

## PART 1: OFFLINE SYNC ARCHITECTURE

### 1.1 Offline Strategy Overview

| Setting | Value |
|---------|-------|
| Strategy | Offline-First with Background Sync |
| Local Database | SQLite via drift package |
| Sync Engine | Custom SyncManager with queue-based operations |
| Conflict Resolution | Last-Write-Wins with User Notification |
| Cache Invalidation | Time-based + Push-triggered |

### 1.2 Local Database Schema

| Table Name | Contents | TTL (Time To Live) |
|------------|----------|-------------------|
| cached_profile | User profile data | 24 hours |
| cached_dashboard | Dashboard summary data | 15 minutes |
| cached_payslips | Payslip list (metadata only) | 7 days |
| cached_payslip_detail | Full payslip with line items | 30 days |
| cached_leave_balances | Leave balance per type | 1 hour |
| cached_leave_requests | User's leave request history | 15 minutes |
| cached_leave_types | Available leave types config | 24 hours |
| cached_notifications | User notifications | 15 minutes |
| cached_public_holidays | Public holidays for year | 7 days |

### 1.3 Sync Queue Table

```sql
CREATE TABLE pending_operations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation_type TEXT NOT NULL,     -- CREATE, UPDATE, DELETE
  entity_type TEXT NOT NULL,        -- leave_request, document, etc
  entity_id TEXT,                   -- null for CREATE (assigned by server)
  payload TEXT NOT NULL,            -- JSON request body
  created_at INTEGER NOT NULL,      -- Unix timestamp
  retry_count INTEGER DEFAULT 0,    -- Number of failed attempts
  last_error TEXT,                  -- Last error message
  status TEXT DEFAULT 'PENDING'     -- PENDING, SYNCING, FAILED, COMPLETED
);
```

### 1.4 Sync Manager Algorithm

```dart
class SyncManager {
  // Trigger sync when:
  // 1. App comes to foreground
  // 2. Network connectivity restored
  // 3. Push notification received
  // 4. Manual pull-to-refresh

  async syncAll() {
    if (!isOnline) return;
    
    // 1. Push local changes first (FIFO order)
    await pushPendingOperations();
    
    // 2. Pull fresh data from server
    await pullDashboard();
    await pullLeaveBalances();
    await pullNotificationCount();
  }
}
```

### 1.5 Conflict Resolution

| Scenario | Detection | Resolution |
|----------|-----------|------------|
| Leave request submitted offline, already approved online | Server returns 409 CONFLICT | Discard local, show toast explaining conflict |
| Leave cancelled offline, already rejected online | Server returns 400 ALREADY_PROCESSED | Discard local, refresh state |
| Profile update while offline | None (no server-side changes) | Local changes pushed on reconnect |
| Document uploaded offline | None | Upload queued, uploaded on reconnect |

### 1.6 Retry Policy

| Setting | Value |
|---------|-------|
| Initial Delay | 1 second |
| Backoff Multiplier | 2x (exponential) |
| Max Delay | 30 minutes |
| Max Retries | 5 attempts |
| After Max Retries | Mark as FAILED, show in pending queue UI for manual retry |
| Jitter | +/- 10% random jitter to prevent thundering herd |

---

## PART 2: AUTHENTICATION EDGE CASES

### 2.1 Forgot Password Flow

1. User taps 'Forgot Password?' on Login screen
2. App shows email input
3. User enters registered email and taps 'Send Reset Link'
4. API POST /auth/password/forgot
5. Backend sends email with reset link (valid for 1 hour)
6. App shows confirmation: 'Check your email for reset instructions'
7. User clicks link in email, opens app via deep link
8. App shows Reset Password screen with new password fields
9. API POST /auth/password/reset with token and new password
10. On success, navigate to Login screen with success message

### 2.2 Forgot PIN Flow

- PIN Entry Dialog shows 'Use password instead' link
- Tapping navigates to password entry dialog
- On successful password verification, PIN verification token is issued
- User can optionally reset PIN from Settings > Security > Change PIN

### 2.3 Multi-Device Policy

| Setting | Value |
|---------|-------|
| Policy | Single Active Session Only |
| Behavior | New login invalidates previous session |
| Previous Device | Receives SESSION_REVOKED error on next API call |
| UX on Revoked Device | Dialog: 'Session ended. You logged in on another device.' → OK → Login screen |
| Push Token | FCM token updated to new device only |

### 2.4 Session Timeout UX

| Scenario | Behavior |
|----------|----------|
| Access token < 1 hour remaining | Silent refresh in background using refresh token |
| Access token expired, refresh valid | Automatic refresh, retry original request |
| Both tokens expired | Show session expired dialog, redirect to Login |
| App in background > 30 min | Show PIN entry on resume (if PIN is set) |
| App killed and reopened | Show PIN entry if token valid, else Login screen |

### 2.5 Biometric Authentication (Phase 2)

| Setting | Value |
|---------|-------|
| Scope | Phase 2 Feature (Not MVP) |
| Behavior | Biometric can replace PIN entry if device supports and user enables |
| Fallback | Always allow PIN entry as fallback if biometric fails |
| Storage | PIN stored in secure enclave, unlocked by biometric |
| Settings | Settings > Security > Enable Fingerprint/Face ID |

---

## PART 3: NOTIFICATION SPECIFICATION

### 3.1 Push Notification Templates

| Type | Title | Body |
|------|-------|------|
| LEAVE_SUBMITTED | New Leave Request | {employee_name} requested {leave_type} ({total_days} days) |
| (Malay) | Permohonan Cuti Baru | {employee_name} memohon {leave_type} ({total_days} hari) |
| LEAVE_APPROVED | Leave Approved | Your {leave_type} ({date_from} - {date_to}) has been approved |
| (Malay) | Cuti Diluluskan | Cuti {leave_type} anda ({date_from} - {date_to}) telah diluluskan |
| LEAVE_REJECTED | Leave Declined | Your {leave_type} request was declined. Reason: {reason} |
| (Malay) | Cuti Ditolak | Permohonan {leave_type} anda ditolak. Sebab: {reason} |
| PAYSLIP_PUBLISHED | Payslip Available | Your payslip for {pay_period} is now available |
| (Malay) | Slip Gaji Tersedia | Slip gaji anda untuk {pay_period} kini tersedia |
| PERMIT_EXPIRY | Permit Expiring Soon | {employee_name}'s {permit_type} expires on {expiry_date} |
| (Malay) | Permit Akan Tamat | {permit_type} {employee_name} akan tamat pada {expiry_date} |

### 3.2 Deep Link URI Scheme

| Notification Type | Deep Link | Target Screen |
|-------------------|-----------|---------------|
| LEAVE_SUBMITTED | kerjaflow://approvals/{id} | S-041 Approval Detail |
| LEAVE_APPROVED | kerjaflow://leave/{id} | S-033 Leave Detail |
| LEAVE_REJECTED | kerjaflow://leave/{id} | S-033 Leave Detail |
| PAYSLIP_PUBLISHED | kerjaflow://payslip/{id} | S-021 Payslip Detail (with PIN) |
| LEAVE_REMINDER | kerjaflow://leave/{id} | S-033 Leave Detail |
| PERMIT_EXPIRY | kerjaflow://documents | S-060 Document List |
| Generic/System | kerjaflow://notifications | S-050 Notification List |

### 3.3 Android Notification Channels

| Channel ID | Name | Importance | Description |
|------------|------|------------|-------------|
| kf_leave | Leave Updates | HIGH | Leave request notifications |
| kf_payslip | Payslip | HIGH | Payslip availability |
| kf_approvals | Approvals | HIGH | Pending approval alerts |
| kf_reminders | Reminders | DEFAULT | Leave reminders, expiry alerts |
| kf_system | System | LOW | System announcements |

---

## PART 4: INTEGRATION CONFIGURATION

### 4.1 Firebase Cloud Messaging (FCM)

| Setting | Value |
|---------|-------|
| Project Name | kerjaflow-prod / kerjaflow-staging / kerjaflow-dev |
| Server Key Location | Firebase Console > Project Settings > Cloud Messaging > Server key |
| Backend Storage | Environment variable: FIREBASE_SERVER_KEY |
| Android Config File | google-services.json → android/app/ |
| iOS Config File | GoogleService-Info.plist → ios/Runner/ |
| Required Permissions | Android: POST_NOTIFICATIONS (Android 13+), iOS: Request via firebase_messaging |

### 4.2 Huawei Push Kit (HMS)

| Setting | Value |
|---------|-------|
| App ID | Obtained from AppGallery Connect > App Information |
| Client Secret | AppGallery Connect > App Information > OAuth 2.0 client ID secret |
| Config File | agconnect-services.json → android/app/ |
| Backend Storage | Environment variables: HMS_APP_ID, HMS_CLIENT_SECRET |
| Detection Logic | Check HuaweiApiAvailability.isHuaweiMobileServicesAvailable() |

### 4.3 File Storage Configuration

| Setting | Value |
|---------|-------|
| Provider | AWS S3 (or S3-compatible: MinIO, DigitalOcean Spaces) |
| Bucket Name | kerjaflow-{env}-files (e.g., kerjaflow-prod-files) |
| Region | ap-southeast-1 (Singapore) |

**Folder Structure:**
```
kerjaflow-prod-files/
├── companies/{company_id}/
│   └── logo.{ext}                    # Company logo
├── employees/{employee_id}/
│   ├── photo.{ext}                   # Profile photo
│   └── documents/{doc_id}.{ext}      # Uploaded documents
└── payslips/{company_id}/{period}/
    └── {employee_id}.pdf             # Generated payslip PDFs
```

---

## PART 5: BUSINESS RULE CLARIFICATIONS

### 5.1 Leave Year Definition

| Question | Answer |
|----------|--------|
| Is leave year calendar year or anniversary based? | CONFIGURABLE per company via kf_company.leave_year_start |
| Default | 1 (January) - Calendar year |
| Example | If leave_year_start = 4, leave year is April 1 to March 31 |

### 5.2 Carry-Forward Expiry Calculation

| Question | Answer |
|----------|--------|
| When exactly do carried days expire? | End of the Nth month after leave year starts |
| Example | If leave_year_start=1 and carry_forward_expiry=3, carried days expire March 31 |
| Deduction Order | FIFO - Carried days are used before entitled days |
| Scheduler Job | Run monthly on 1st to expire carried balances |

### 5.3 Pro-Rata Rounding

| Question | Answer |
|----------|--------|
| How to round pro-rata entitlement? | Round to nearest 0.5 (half-up rounding) |
| Formula | ROUND(value * 2) / 2 |
| Examples | 8.24 → 8.0, 8.25 → 8.5, 8.74 → 8.5, 8.75 → 9.0 |

### 5.4 Half-Day Leave Hours

| Question | Answer |
|----------|--------|
| What hours constitute AM vs PM half-day? | Company-configurable, but defaults below |
| AM Half-Day | Work start time to 1:00 PM (e.g., 9:00 AM - 1:00 PM) |
| PM Half-Day | 2:00 PM to work end time (e.g., 2:00 PM - 6:00 PM) |
| Display Only | These times are for display; balance deduction is always 0.5 days |

### 5.5 Manager Hierarchy Edge Cases

| Question | Answer |
|----------|--------|
| Can an employee approve their own leave? | NO - System prevents self-approval |
| Top Manager Case | If employee has no manager, approver_id is set to HR Manager |
| HR/CEO Leave | HR Manager/CEO leave requires another HR or Admin to approve |

### 5.6 Concurrent Leave Requests

| Question | Answer |
|----------|--------|
| Can employee have multiple pending requests? | YES - Multiple pending requests allowed for different dates |
| Overlap Rule | Cannot submit request overlapping with PENDING or APPROVED leave |
| Different Types | Same date cannot have two requests even if different leave types |

---

## PART 6: API CLARIFICATIONS

### 6.1 File Upload Handling

| Setting | Value |
|---------|-------|
| Max Size | 10 MB (configurable server-side) |
| Chunked Upload | NOT SUPPORTED in MVP (single request upload) |
| Resume Support | NOT SUPPORTED in MVP |
| Timeout | 120 seconds for file upload endpoints |
| Progress | Mobile app shows progress via Dio onSendProgress |

### 6.2 Date/Time Handling

| Setting | Value |
|---------|-------|
| Wire Format | ISO 8601 with timezone: 2025-12-20T10:30:00+08:00 |
| Storage | PostgreSQL TIMESTAMPTZ (UTC internally) |
| Date-Only Fields | YYYY-MM-DD format (leave dates, DOB, etc.) |
| Response Timezone | Convert to company timezone (kf_company.timezone) before sending |
| Mobile Display | Format using device locale |

### 6.3 PATCH Request Behavior

| Field State | Behavior |
|-------------|----------|
| Missing Field | NO CHANGE (field is not updated) |
| Null Value | SET TO NULL (if field is nullable) |
| Empty String | SET TO EMPTY STRING (treated as value) |
| Non-Nullable Null | Return 400 validation error |

---

*— End of Technical Addendum —*
