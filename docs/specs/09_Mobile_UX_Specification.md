# KerjaFlow Mobile UX Specification

**Wireframes • Navigation • Design System • Component Library**

Version 1.0 — December 2025

---

## PART 1: SCREEN INVENTORY

### 1.1 Screen Summary (27 Screens)

| ID | Screen Name | Description | Access |
|----|-------------|-------------|--------|
| S-001 | Splash Screen | App loading, token check | All users |
| S-002 | Login | Username/password entry | Unauthenticated |
| S-003 | PIN Setup | First-time PIN creation | New users |
| S-004 | PIN Entry | Quick login / verification | Returning users |
| S-005 | Forgot Password | Password reset request | Unauthenticated |
| S-006 | Reset Password | New password entry (from email) | Unauthenticated |
| S-010 | Dashboard | Home screen with summary | Authenticated |
| S-020 | Payslip List | Monthly payslips grid | Authenticated |
| S-021 | Payslip Detail | Full payslip breakdown | PIN verified |
| S-022 | Payslip PDF Viewer | In-app PDF display | PIN verified |
| S-030 | Leave Balance | All leave type balances | Authenticated |
| S-031 | Leave Request List | My leave history | Authenticated |
| S-032 | Leave Apply | New leave application form | Authenticated |
| S-033 | Leave Detail | Single request details | Authenticated |
| S-034 | Leave Calendar | Calendar view of leaves | Authenticated |
| S-040 | Approval List | Pending approvals queue | Supervisor/HR |
| S-041 | Approval Detail | Review and approve/reject | Supervisor/HR |
| S-050 | Notification List | All notifications | Authenticated |
| S-051 | Notification Detail | Single notification view | Authenticated |
| S-060 | Document List | My documents | Authenticated |
| S-061 | Document Upload | Upload new document | Authenticated |
| S-062 | Document Viewer | View document image/PDF | Authenticated |
| S-070 | Profile View | My profile details | Authenticated |
| S-071 | Profile Edit | Edit allowed fields | Authenticated |
| S-072 | Change Password | Password change form | Authenticated |
| S-073 | Change PIN | PIN change form | Authenticated |
| S-080 | Settings | App settings | Authenticated |
| S-081 | Language Selection | Choose EN/MS/ID | Authenticated |
| S-082 | About | App info, version, legal | Authenticated |

---

## PART 2: NAVIGATION ARCHITECTURE

### 2.1 Bottom Navigation Tabs

| Position | Tab Name | Icon | Root Screen |
|----------|----------|------|-------------|
| 1 (Left) | Home | home_outlined | S-010 Dashboard |
| 2 | Payslip | receipt_long_outlined | S-020 Payslip List |
| 3 (Center) | Leave | event_note_outlined | S-030 Leave Balance |
| 4 | Inbox | notifications_outlined | S-050 Notification List |
| 5 (Right) | Profile | person_outlined | S-070 Profile View |

### 2.2 Navigation Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                               │
│                             │                                    │
│                    [S-001 Splash]                                │
│                             │                                    │
│              ┌──────────────┴──────────────┐                     │
│           No Token                      Has Token                │
│              │                              │                    │
│        [S-002 Login]              ┌────────┴────────┐            │
│              │                  Has PIN         No PIN           │
│              │                    │                │             │
│       Login Success        [S-004 PIN]    [S-003 PIN Setup]      │
│              │                    │                │             │
│              └────────────────────┴────────────────┘             │
│                             │                                    │
│                    [S-010 Dashboard]                             │
│         ┌──────────┬──────────┬──────────┬──────────┐            │
│       Home      Payslip     Leave      Inbox     Profile         │
└─────────────────────────────────────────────────────────────────┘
```

---

## PART 3: DESIGN SYSTEM

### 3.1 Color Palette

**Primary Colors**

| Token Name | Hex Value | Usage |
|------------|-----------|-------|
| primary | #1A5276 | Primary buttons, headers |
| primary-light | #2E86AB | Hover states, links |
| primary-dark | #0D3B50 | Pressed states |
| primary-surface | #E8F4F8 | Light backgrounds |

**Semantic Colors**

| Token Name | Hex Value | Usage |
|------------|-----------|-------|
| success | #27AE60 | Success messages, approved |
| success-surface | #E8F8F0 | Success background |
| warning | #F39C12 | Warnings, pending |
| warning-surface | #FEF9E7 | Warning background |
| error | #E74C3C | Errors, rejected |
| error-surface | #FDEDEC | Error background |
| info | #3498DB | Information, tips |

**Neutral Colors**

| Token Name | Hex Value | Usage |
|------------|-----------|-------|
| text-primary | #2C3E50 | Primary text, headings |
| text-secondary | #7F8C8D | Secondary text, captions |
| text-disabled | #BDC3C7 | Disabled text |
| text-inverse | #FFFFFF | Text on dark backgrounds |
| background | #FAFAFA | App background |
| surface | #FFFFFF | Cards, dialogs, sheets |
| divider | #ECEFF1 | Divider lines, borders |

### 3.2 Typography Scale

Font family: Inter (primary), SF Pro (iOS fallback), Roboto (Android fallback)

| Style Name | Size | Weight | Line Height | Usage |
|------------|------|--------|-------------|-------|
| displayLarge | 32sp | 700 | 40sp | Screen titles |
| displayMedium | 28sp | 600 | 36sp | Section headers |
| displaySmall | 24sp | 600 | 32sp | Card titles |
| headlineLarge | 22sp | 600 | 28sp | Dialog titles |
| headlineMedium | 20sp | 600 | 26sp | List item titles |
| headlineSmall | 18sp | 600 | 24sp | Form labels |
| bodyLarge | 16sp | 400 | 24sp | Primary body text |
| bodyMedium | 14sp | 400 | 20sp | Secondary body text |
| bodySmall | 12sp | 400 | 16sp | Captions, timestamps |
| labelLarge | 14sp | 500 | 20sp | Button text |
| labelMedium | 12sp | 500 | 16sp | Chips, tabs |
| labelSmall | 10sp | 500 | 14sp | Overlines, badges |

### 3.3 Spacing Scale

Base unit: 4dp

| Token | Value | Usage Examples |
|-------|-------|----------------|
| space-xxs | 2dp | Icon padding, tight layouts |
| space-xs | 4dp | Between icon and text, input padding vertical |
| space-sm | 8dp | Between related elements, chip padding |
| space-md | 16dp | Card padding, screen horizontal margins |
| space-lg | 24dp | Between sections, form field spacing |
| space-xl | 32dp | Major section breaks, screen top padding |
| space-xxl | 48dp | Empty state spacing, between screen sections |

### 3.4 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| radius-none | 0dp | Sharp corners (dividers) |
| radius-sm | 4dp | Chips, small buttons, input fields |
| radius-md | 8dp | Cards, dialogs, buttons |
| radius-lg | 16dp | Bottom sheets, modal headers |
| radius-full | 9999dp | Circular elements (avatar, FAB) |

---

## PART 4: COMPONENT LIBRARY

### 4.1 Primary Button

| Property | Value |
|----------|-------|
| Background | primary (#1A5276) |
| Text Color | text-inverse (#FFFFFF) |
| Text Style | labelLarge (14sp, weight 500) |
| Height | 48dp |
| Horizontal Padding | 24dp |
| Border Radius | radius-md (8dp) |
| Pressed State | primary-dark (#0D3B50) |
| Disabled State | Background: disabled (#E0E0E0), Text: text-disabled |
| Loading State | CircularProgressIndicator (white, 20dp) centered |

### 4.2 Standard Card

| Property | Value |
|----------|-------|
| Background | surface (#FFFFFF) |
| Border Radius | radius-md (8dp) |
| Elevation | elevation-1 |
| Padding | space-md (16dp) |
| Margin | Horizontal: space-md, Vertical: space-sm |
| Pressed State | Elevation: elevation-2, slight scale (1.01) |

### 4.3 Input Fields

| Property | Value |
|----------|-------|
| Style | Outlined (Material 3) |
| Height | 56dp |
| Border | 1dp, divider default, primary focused |
| Border Radius | radius-sm (4dp) |
| Label | bodyMedium, text-secondary, floats on focus |
| Input Text | bodyLarge, text-primary |
| Error State | Border: error, Helper text: error color |

### 4.4 Bottom Navigation

| Property | Value |
|----------|-------|
| Height | 80dp (including safe area on iOS) |
| Background | surface (#FFFFFF) |
| Top Border | 1dp, divider |
| Icon Size | 24dp |
| Label Style | labelSmall (10sp) |
| Active Color | primary (#1A5276) |
| Inactive Color | text-secondary (#7F8C8D) |
| Badge | 8dp circle, error color, top-right of icon |

---

## PART 5: SCREEN STATES

### 5.1 Loading States

| Context | Loading Indicator | Behavior |
|---------|-------------------|----------|
| Initial Screen Load | Skeleton shimmer | Show content shape placeholders |
| Pull to Refresh | RefreshIndicator (primary) | Standard Material pull-down |
| Button Action | Button loading state | Spinner replaces text, button disabled |
| Form Submit | Full screen overlay + spinner | Semi-transparent overlay |
| Infinite Scroll | Bottom spinner | Small spinner at list bottom |

### 5.2 Empty States

| Screen | Illustration | Title | Description |
|--------|--------------|-------|-------------|
| Payslip List | Empty folder icon | No Payslips Yet | Your payslips will appear here once published |
| Leave Requests | Calendar icon | No Leave Requests | Apply for leave using the button below |
| Notifications | Bell icon | All Caught Up! | You have no new notifications |
| Documents | Document icon | No Documents | Upload your first document |
| Approvals | Checkmark icon | No Pending Approvals | All leave requests have been processed |

### 5.3 Error States

| Error Type | Display | Message | Action |
|------------|---------|---------|--------|
| Network Error | Full screen error view | No internet connection | Retry button |
| Server Error (5xx) | Full screen error view | Something went wrong | Retry button |
| Validation Error | Inline field error | Specific field message | None |
| Business Error | Snackbar or dialog | e.g., Insufficient balance | Dismiss |
| Session Expired | Dialog | Session expired, please login again | OK → Login |

### 5.4 Offline State

**Offline Banner:**

| Property | Value |
|----------|-------|
| Position | Below app bar, above content |
| Height | 40dp |
| Background | warning-surface |
| Icon | wifi_off, 20dp, warning color |
| Text | 'You are offline', bodySmall, warning color |

**Offline Behavior by Feature:**

| Feature | Offline Capability | UI Treatment |
|---------|-------------------|--------------|
| Dashboard | Read cached data | Show stale data with timestamp |
| Payslip List | Read cached list | Show cached, disable view detail |
| Leave Balance | Read cached balances | Show stale data with timestamp |
| Apply Leave | Queue locally | Show 'Will submit when online' toast |
| Notifications | Read cached | Show cached, hide mark-as-read |
| Profile | Read cached | Disable edit button |

---

## PART 6: ACCESSIBILITY REQUIREMENTS

### 6.1 WCAG 2.1 AA Compliance

| Criterion | Requirement | Implementation |
|-----------|-------------|----------------|
| 1.1.1 | Non-text Content | All images have contentDescription, icons have semanticLabel |
| 1.3.1 | Info and Relationships | Use Semantics widget, proper heading hierarchy |
| 1.4.1 | Use of Color | Never rely on color alone; use icons/text with status colors |
| 1.4.3 | Contrast (Minimum) | All text ≥ 4.5:1 ratio, large text ≥ 3:1 |
| 1.4.4 | Resize Text | Support system font scaling up to 200% |
| 2.1.1 | Keyboard | All interactive elements focusable via Tab/D-pad |
| 2.4.3 | Focus Order | Logical focus traversal matching visual layout |
| 3.3.1 | Error Identification | Errors announced to screen reader, field highlighted |

### 6.2 Touch Target Sizes

| Element | Minimum Size | Recommended Size |
|---------|--------------|------------------|
| Buttons | 44dp × 44dp | 48dp × 48dp |
| List Items | 44dp height | 56dp height |
| Icon Buttons | 44dp × 44dp | 48dp × 48dp |
| Checkbox/Radio | 44dp × 44dp | 48dp × 48dp |
| Text Links | 44dp × 44dp tap area | 44dp × 44dp tap area |

---

*— End of Mobile UX Specification —*
