# KerjaFlow Manual QA Checklist

**Version:** 3.0
**Last Updated:** December 26, 2025

---

## Pre-Release Testing Checklist

Use this checklist before every release. All items must pass before store submission.

---

## 1. Authentication Flow

### 1.1 Login
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Login with valid credentials | [ ] | [ ] | |
| Login with invalid password | [ ] | [ ] | Error message shown |
| Login with non-existent email | [ ] | [ ] | Error message shown |
| Password visibility toggle | [ ] | [ ] | Eye icon works |
| Remember me checkbox | [ ] | [ ] | Email persists |
| Forgot password link | [ ] | [ ] | Opens email flow |
| Login loading indicator | [ ] | [ ] | Spinner shown |
| Network error handling | [ ] | [ ] | Airplane mode test |

### 1.2 PIN Authentication
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Set 6-digit PIN first time | [ ] | [ ] | |
| Confirm PIN (must match) | [ ] | [ ] | |
| PIN mismatch error | [ ] | [ ] | Shows error |
| Enter correct PIN | [ ] | [ ] | Unlocks app |
| Enter wrong PIN (1st attempt) | [ ] | [ ] | 2 attempts left |
| Enter wrong PIN (2nd attempt) | [ ] | [ ] | 1 attempt left |
| Enter wrong PIN (3rd attempt) | [ ] | [ ] | **Lockout 15 min** |
| Lockout countdown visible | [ ] | [ ] | Timer shows |
| Lockout expires, retry works | [ ] | [ ] | After 15 min |
| Change PIN in settings | [ ] | [ ] | Requires old PIN |
| Reset PIN via forgot | [ ] | [ ] | Requires re-login |

### 1.3 Biometric Authentication
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Enable fingerprint | [ ] | [ ] | Prompts system auth |
| Enable Face ID | [ ] | [ ] | iOS only |
| Login with biometric | [ ] | [ ] | Shows prompt |
| Biometric cancel → PIN fallback | [ ] | [ ] | |
| Disable biometric | [ ] | [ ] | |
| Biometric after phone restart | [ ] | [ ] | Requires PIN first |

### 1.4 Session Management
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Token refresh (wait 15+ min) | [ ] | [ ] | Auto-refresh |
| Session expires (7 days) | [ ] | [ ] | Redirect to login |
| Logout button works | [ ] | [ ] | Clears tokens |
| Force logout from server | [ ] | [ ] | 401 handling |
| Multiple device login | [ ] | [ ] | Per org policy |

---

## 2. Leave Management

### 2.1 Leave Balance
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| View all leave types | [ ] | [ ] | Annual, Medical, etc. |
| Balance shows correctly | [ ] | [ ] | Match backend |
| Balance after approved leave | [ ] | [ ] | Decremented |
| Balance after rejected leave | [ ] | [ ] | Unchanged |
| Balance carry forward (if applicable) | [ ] | [ ] | |
| Pull to refresh balances | [ ] | [ ] | Updates from server |

### 2.2 Leave Request
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Create new leave request | [ ] | [ ] | |
| Select leave type | [ ] | [ ] | Dropdown works |
| Select start date | [ ] | [ ] | Date picker |
| Select end date | [ ] | [ ] | Date picker |
| End date < start date error | [ ] | [ ] | Validation |
| Half-day toggle | [ ] | [ ] | AM/PM option |
| Add reason/notes | [ ] | [ ] | Optional field |
| Attach supporting doc | [ ] | [ ] | Medical cert |
| Submit request | [ ] | [ ] | Success message |
| Insufficient balance error | [ ] | [ ] | |
| Overlap with existing leave | [ ] | [ ] | Warning/error |
| Request on public holiday | [ ] | [ ] | Warning |
| Request on weekend | [ ] | [ ] | Per org policy |

### 2.3 Leave History
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| View pending requests | [ ] | [ ] | |
| View approved requests | [ ] | [ ] | |
| View rejected requests | [ ] | [ ] | |
| View cancelled requests | [ ] | [ ] | |
| Filter by status | [ ] | [ ] | Dropdown |
| Filter by date range | [ ] | [ ] | Date picker |
| View request details | [ ] | [ ] | Tap to expand |
| Cancel pending request | [ ] | [ ] | Confirm dialog |

### 2.4 Leave Approval (Manager)
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| View pending approvals | [ ] | [ ] | Manager only |
| Approve request | [ ] | [ ] | Success message |
| Reject request | [ ] | [ ] | Requires reason |
| Bulk approve | [ ] | [ ] | Select multiple |
| Notification after approval | [ ] | [ ] | Push to employee |

---

## 3. Payslip

### 3.1 Payslip List
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| View current month payslip | [ ] | [ ] | |
| View historical payslips | [ ] | [ ] | Scrollable list |
| Filter by year | [ ] | [ ] | |
| Filter by month | [ ] | [ ] | |
| No payslip message | [ ] | [ ] | For new employees |
| Payslip loading indicator | [ ] | [ ] | |

### 3.2 Payslip Detail (PIN Required)
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| PIN prompt before viewing | [ ] | [ ] | **Critical** |
| Biometric fallback | [ ] | [ ] | If enabled |
| View gross salary | [ ] | [ ] | |
| View allowances breakdown | [ ] | [ ] | All items listed |
| View deductions breakdown | [ ] | [ ] | All items listed |
| View net salary | [ ] | [ ] | Calculated correctly |
| View statutory contributions | [ ] | [ ] | EPF/CPF/BPJS etc. |
| Salary masking before PIN | [ ] | [ ] | Shows *** |

### 3.3 Payslip Download
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Download as PDF | [ ] | [ ] | |
| PDF opens correctly | [ ] | [ ] | |
| PDF contains all info | [ ] | [ ] | Match screen |
| Share PDF | [ ] | [ ] | Share sheet |
| Download audit logged | [ ] | [ ] | Check backend |

---

## 4. Offline Mode

### 4.1 Offline Access
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Enable airplane mode | [ ] | [ ] | |
| View cached leave balance | [ ] | [ ] | Last synced |
| View cached payslip | [ ] | [ ] | Last synced |
| View cached profile | [ ] | [ ] | Last synced |
| Offline indicator shown | [ ] | [ ] | Banner/icon |
| Create offline leave request | [ ] | [ ] | Queued |
| Pending sync indicator | [ ] | [ ] | Shows count |

### 4.2 Sync on Reconnect
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Disable airplane mode | [ ] | [ ] | |
| Auto-sync triggers | [ ] | [ ] | Background |
| Queued requests synced | [ ] | [ ] | In order |
| Conflict resolution | [ ] | [ ] | Server wins |
| Sync success notification | [ ] | [ ] | |
| Sync failure retry | [ ] | [ ] | Exponential backoff |
| Manual sync button | [ ] | [ ] | Pull to refresh |

---

## 5. Push Notifications

### 5.1 Notification Permission
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Permission prompt on first launch | [ ] | [ ] | |
| Accept notification permission | [ ] | [ ] | |
| Deny → prompt in settings | [ ] | [ ] | |
| Android 13+ POST_NOTIFICATIONS | [ ] | [ ] | Runtime permission |

### 5.2 Notification Types
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| New payslip available | [ ] | [ ] | Monthly |
| Leave request approved | [ ] | [ ] | |
| Leave request rejected | [ ] | [ ] | |
| New leave request (manager) | [ ] | [ ] | |
| Password expiry warning | [ ] | [ ] | |
| Security alert | [ ] | [ ] | Cannot disable |

### 5.3 Notification Behavior
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Tap opens relevant screen | [ ] | [ ] | Deep link |
| Badge count updates | [ ] | [ ] | |
| Sound plays | [ ] | [ ] | Per settings |
| Vibration works | [ ] | [ ] | Per settings |
| DND respects | [ ] | [ ] | System setting |
| Background notification | [ ] | [ ] | App not running |
| Foreground notification | [ ] | [ ] | App open |

---

## 6. Security Checklist

### 6.1 Data Protection
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| IC/NRIC masked on list views | [ ] | [ ] | Show last 4 only |
| Bank account masked | [ ] | [ ] | Show last 4 only |
| Salary masked until PIN | [ ] | [ ] | Shows *** |
| No sensitive data in logs | [ ] | [ ] | Check logcat/console |
| Screen capture blocked (payslip) | [ ] | [ ] | FLAG_SECURE |
| App switcher blur | [ ] | [ ] | Hide content |

### 6.2 Token Security
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| Access token expires (15 min) | [ ] | [ ] | Auto-refresh |
| Refresh token expires (7 days) | [ ] | [ ] | Re-login required |
| Tokens stored securely | [ ] | [ ] | Keychain/Keystore |
| Tokens cleared on logout | [ ] | [ ] | |
| Invalid token handling | [ ] | [ ] | 401 → login |

### 6.3 Network Security
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| HTTPS only | [ ] | [ ] | No HTTP |
| Certificate pinning | [ ] | [ ] | If implemented |
| MITM detection | [ ] | [ ] | Proxy blocked |
| API error messages generic | [ ] | [ ] | No stack traces |

### 6.4 Local Security
| Test | Android | iOS | Notes |
|------|:-------:|:---:|-------|
| No sensitive data in SharedPrefs | [ ] | [ ] | Check file system |
| SQLite encrypted | [ ] | [ ] | If used |
| Cache cleared on logout | [ ] | [ ] | |
| Backup excludes sensitive | [ ] | [ ] | backup_rules.xml |
| Root/jailbreak detection | [ ] | [ ] | Warning shown |

---

## 7. Device Testing Matrix

### 7.1 Android Devices

| Device | OS Version | Screen | Status | Tester | Date |
|--------|------------|--------|:------:|--------|------|
| Samsung Galaxy S24 | Android 14 | 1080x2340 | [ ] | | |
| Samsung Galaxy A54 | Android 14 | 1080x2400 | [ ] | | |
| Samsung Galaxy A14 | Android 13 | 1080x2408 | [ ] | | |
| Google Pixel 8 | Android 14 | 1080x2400 | [ ] | | |
| Google Pixel 6a | Android 14 | 1080x2400 | [ ] | | |
| Xiaomi Redmi Note 12 | Android 13 | 1080x2400 | [ ] | | |
| OPPO A78 | Android 13 | 1080x2400 | [ ] | | |
| Vivo Y36 | Android 13 | 1080x2408 | [ ] | | |
| Huawei Nova 11i | Android 12 | 1080x2400 | [ ] | | |
| Samsung Galaxy A12 | Android 11 | 720x1600 | [ ] | | |
| Older device | Android 10 | Variable | [ ] | | |

**Minimum Android Version:** Android 10 (API 29)
**Target Android Version:** Android 14 (API 34)

### 7.2 iOS Devices

| Device | iOS Version | Screen | Status | Tester | Date |
|--------|-------------|--------|:------:|--------|------|
| iPhone 15 Pro Max | iOS 17 | 1290x2796 | [ ] | | |
| iPhone 15 | iOS 17 | 1179x2556 | [ ] | | |
| iPhone 14 | iOS 17 | 1170x2532 | [ ] | | |
| iPhone 13 | iOS 17 | 1170x2532 | [ ] | | |
| iPhone 12 | iOS 17 | 1170x2532 | [ ] | | |
| iPhone SE (3rd gen) | iOS 17 | 750x1334 | [ ] | | |
| iPhone 11 | iOS 16 | 828x1792 | [ ] | | |
| iPhone XR | iOS 16 | 828x1792 | [ ] | | |
| iPad Pro 12.9" | iOS 17 | 2048x2732 | [ ] | | |
| iPad Air | iOS 16 | 1640x2360 | [ ] | | |
| iPhone 8 | iOS 15 | 750x1334 | [ ] | | |

**Minimum iOS Version:** iOS 15.0
**Target iOS Version:** iOS 17.x

---

## 8. Localization Spot-Check

### 8.1 Language Verification

For each language, verify these key screens are translated:

| Language | Login | Leave | Payslip | Profile | Settings | Tester |
|----------|:-----:|:-----:|:-------:|:-------:|:--------:|--------|
| English (en) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Bahasa Malaysia (ms_MY) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Bahasa Indonesia (id_ID) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Chinese Simplified (zh_CN) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Tamil (ta_IN) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Thai (th_TH) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Vietnamese (vi_VN) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Filipino (tl_PH) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Lao (lo_LA) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Khmer (km_KH) | [ ] | [ ] | [ ] | [ ] | [ ] | |
| Bengali (bn_BD) | [ ] | [ ] | [ ] | [ ] | [ ] | |

### 8.2 Language-Specific Tests

| Test | Status | Notes |
|------|:------:|-------|
| RTL layout (if applicable) | [ ] | N/A for current languages |
| Font rendering (Thai script) | [ ] | NotoSansThai |
| Font rendering (Lao script) | [ ] | NotoSansLao |
| Font rendering (Khmer script) | [ ] | NotoSansKhmer |
| Font rendering (Bengali script) | [ ] | NotoSansBengali |
| Font rendering (Tamil script) | [ ] | NotoSansTamil |
| Date format localized | [ ] | Per locale |
| Currency format localized | [ ] | Per country |
| Number format localized | [ ] | Decimal separator |
| Long text truncation | [ ] | No clipping |

---

## 9. Build Verification

### 9.1 Android Build

```bash
# Build commands to run
cd mobile

# Dev build
flutter build apk --debug --flavor dev

# Google Play release
flutter build appbundle --release --flavor google

# Huawei release
flutter build apk --release --flavor huawei
```

| Check | Status | Notes |
|-------|:------:|-------|
| Dev APK builds successfully | [ ] | |
| Dev APK installs | [ ] | |
| Dev APK launches | [ ] | |
| Google AAB builds successfully | [ ] | |
| Huawei APK builds successfully | [ ] | |
| Version code correct | [ ] | Check build.gradle |
| Version name correct | [ ] | Check build.gradle |
| Signing key valid | [ ] | Not debug key |
| ProGuard/R8 working | [ ] | No crashes |
| APK size acceptable | [ ] | < 50 MB |

### 9.2 iOS Build

```bash
# Build commands to run
cd mobile

# Debug build
flutter build ios --debug

# Release build
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

| Check | Status | Notes |
|-------|:------:|-------|
| iOS debug builds | [ ] | Simulator |
| iOS runs on simulator | [ ] | |
| iOS archive builds | [ ] | Xcode |
| iOS runs on device | [ ] | Real device |
| Provisioning profile valid | [ ] | |
| Signing certificate valid | [ ] | |
| App Store Connect upload | [ ] | TestFlight |
| IPA size acceptable | [ ] | < 100 MB |

---

## 10. Regression Checklist

Quick smoke test for each release:

| Area | Critical Path | Status |
|------|---------------|:------:|
| Login | Email + password → home screen | [ ] |
| PIN | Set PIN → verify PIN unlock | [ ] |
| Leave | Request → submit → view in pending | [ ] |
| Payslip | View list → enter PIN → see details | [ ] |
| Offline | Airplane mode → view cached data | [ ] |
| Sync | Reconnect → pending actions sync | [ ] |
| Logout | Logout → tokens cleared | [ ] |

---

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| QA Lead | | | |
| Dev Lead | | | |
| Product Owner | | | |

**Release Approved:** [ ] Yes [ ] No

**Notes:**

---

*Document Version: 3.0*
*Template maintained by KerjaFlow QA Team*
