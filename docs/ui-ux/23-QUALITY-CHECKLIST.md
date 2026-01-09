# KERJAFLOW UI/UX QUALITY CHECKLIST
## Pixel-Perfect Verification - Extreme Kiasu Edition

---

## PRE-LAUNCH VERIFICATION

### 1. DESIGN TOKENS VERIFICATION

| Check | Status | Notes |
|-------|--------|-------|
| All colors from design_tokens.dart | ☐ | No hardcoded hex values |
| All fonts from typography tokens | ☐ | No inline font sizes |
| All spacing from spacing scale | ☐ | No magic numbers |
| All shadows from shadow tokens | ☐ | No inline shadows |
| All animations from animation tokens | ☐ | Consistent timing |
| All border radius from radius tokens | ☐ | Consistent corners |

### 2. ACCESSIBILITY COMPLIANCE (WCAG 2.2 AA)

| Check | Status | Target | Actual |
|-------|--------|--------|--------|
| Color contrast (text) | ☐ | ≥ 4.5:1 | |
| Color contrast (large text) | ☐ | ≥ 3:1 | |
| Touch target size | ☐ | ≥ 44×44dp | |
| Focus indicators visible | ☐ | Yes | |
| Screen reader labels | ☐ | All interactive | |
| Keyboard navigation | ☐ | All features | |
| Reduced motion support | ☐ | Yes | |
| Text scaling (200%) | ☐ | No overflow | |
| Color-blind safe | ☐ | Not color-only | |

### 3. RESPONSIVE BREAKPOINTS

| Breakpoint | Width | Tested | Status |
|------------|-------|--------|--------|
| Watch | <200px | ☐ | |
| Phone Small | 320-359px | ☐ | |
| Phone Medium | 360-389px | ☐ | |
| Phone Large | 390-427px | ☐ | |
| Phone XL | 428-599px | ☐ | |
| Tablet Small | 600-743px | ☐ | |
| Tablet Medium | 744-833px | ☐ | |
| Tablet Large | 834-1023px | ☐ | |
| Desktop | 1024-1279px | ☐ | |
| Desktop Large | 1280-1439px | ☐ | |
| Desktop XL | 1440-1919px | ☐ | |
| 4K | 2560-3839px | ☐ | |
| Stadium | 3840px+ | ☐ | |

### 4. PLATFORM-SPECIFIC VERIFICATION

#### iOS (iPhone)
| Check | Status |
|-------|--------|
| iPhone SE (small) layout | ☐ |
| iPhone 14/15 layout | ☐ |
| iPhone Pro Max layout | ☐ |
| Dynamic Island awareness | ☐ |
| Home indicator safe area | ☐ |
| Status bar handling | ☐ |
| System font fallback | ☐ |
| Haptic feedback | ☐ |
| Cupertino widgets where appropriate | ☐ |

#### iOS (iPad)
| Check | Status |
|-------|--------|
| Portrait mode | ☐ |
| Landscape mode | ☐ |
| Split View (1/3) | ☐ |
| Split View (1/2) | ☐ |
| Split View (2/3) | ☐ |
| Slide Over | ☐ |
| Keyboard support | ☐ |
| Trackpad support | ☐ |
| Stage Manager | ☐ |

#### iOS (Apple Watch)
| Check | Status |
|-------|--------|
| 40mm layout | ☐ |
| 44mm layout | ☐ |
| 45mm layout | ☐ |
| 49mm Ultra layout | ☐ |
| Complications | ☐ |
| Crown input | ☐ |
| Glance support | ☐ |

#### Android (Phone)
| Check | Status |
|-------|--------|
| HDPI (1x) | ☐ |
| XHDPI (2x) | ☐ |
| XXHDPI (3x) | ☐ |
| XXXHDPI (4x) | ☐ |
| Display cutout handling | ☐ |
| Gesture navigation | ☐ |
| 3-button navigation | ☐ |
| Material 3 compliance | ☐ |
| Edge-to-edge | ☐ |

#### Android (Tablet)
| Check | Status |
|-------|--------|
| 7" tablet | ☐ |
| 10" tablet | ☐ |
| 12" tablet | ☐ |
| Multi-window | ☐ |
| Navigation rail | ☐ |
| Keyboard shortcuts | ☐ |

#### Android (Wear OS)
| Check | Status |
|-------|--------|
| Round layout | ☐ |
| Square layout | ☐ |
| Rotary input | ☐ |
| Tiles | ☐ |
| Complications | ☐ |

#### Huawei (Phone)
| Check | Status |
|-------|--------|
| HMS Push Kit | ☐ |
| HMS Account Kit | ☐ |
| HMS Analytics | ☐ |
| AppGallery assets | ☐ |
| EMUI design compliance | ☐ |
| Display cutout | ☐ |

#### Huawei (Tablet)
| Check | Status |
|-------|--------|
| Multi-Window | ☐ |
| App Multiplier | ☐ |
| PC Mode | ☐ |
| M-Pencil | ☐ |

#### Huawei (Watch)
| Check | Status |
|-------|--------|
| Watch 4 Pro | ☐ |
| Watch GT 4 | ☐ |
| Watch Fit 3 | ☐ |
| HarmonyOS app | ☐ |

### 5. SCREEN STATE VERIFICATION

For EACH of the 27 screens, verify ALL states:

| Screen | Loading | Success | Empty | Error | Offline | Refresh |
|--------|---------|---------|-------|-------|---------|---------|
| S-001 Splash | ☐ | ☐ | - | ☐ | ☐ | - |
| S-002 Login | ☐ | ☐ | - | ☐ | ☐ | - |
| S-003 PIN Setup | ☐ | ☐ | - | ☐ | - | - |
| S-004 PIN Entry | ☐ | ☐ | - | ☐ | - | - |
| S-005 Forgot Password | ☐ | ☐ | - | ☐ | ☐ | - |
| S-006 Reset Password | ☐ | ☐ | - | ☐ | ☐ | - |
| S-010 Dashboard | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-020 Payslip List | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-021 Payslip Detail | ☐ | ☐ | - | ☐ | ☐ | - |
| S-022 Payslip PDF | ☐ | ☐ | - | ☐ | ☐ | - |
| S-030 Leave Balance | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-031 Leave History | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-032 Leave Apply | ☐ | ☐ | - | ☐ | ☐ | - |
| S-033 Leave Detail | ☐ | ☐ | - | ☐ | ☐ | - |
| S-034 Leave Calendar | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-040 Approval List | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-041 Approval Detail | ☐ | ☐ | - | ☐ | ☐ | - |
| S-050 Notification List | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-051 Notification Detail | ☐ | ☐ | - | ☐ | - | - |
| S-060 Document List | ☐ | ☐ | ☐ | ☐ | ☐ | ☐ |
| S-061 Document Upload | ☐ | ☐ | - | ☐ | - | - |
| S-062 Document Viewer | ☐ | ☐ | - | ☐ | ☐ | - |
| S-070 Profile View | ☐ | ☐ | - | ☐ | ☐ | ☐ |
| S-071 Profile Edit | ☐ | ☐ | - | ☐ | - | - |
| S-072 Change Password | ☐ | ☐ | - | ☐ | - | - |
| S-073 Change PIN | ☐ | ☐ | - | ☐ | - | - |
| S-080 Settings | ☐ | ☐ | - | ☐ | ☐ | - |
| S-081 Language Selection | ☐ | ☐ | - | ☐ | - | - |
| S-082 About | ☐ | ☐ | - | ☐ | - | - |

### 6. LANGUAGE VERIFICATION

| Language | Code | All Strings | RTL | Fonts | Tested |
|----------|------|-------------|-----|-------|--------|
| English | en | ☐ | N/A | ☐ | ☐ |
| Bahasa Malaysia | ms | ☐ | N/A | ☐ | ☐ |
| Bahasa Indonesia | id | ☐ | N/A | ☐ | ☐ |
| Simplified Chinese | zh-CN | ☐ | N/A | ☐ | ☐ |
| Thai | th | ☐ | N/A | ☐ | ☐ |
| Vietnamese | vi | ☐ | N/A | ☐ | ☐ |
| Tagalog | tl | ☐ | N/A | ☐ | ☐ |
| Tamil | ta | ☐ | N/A | ☐ | ☐ |
| Nepali | ne | ☐ | N/A | ☐ | ☐ |
| Bengali | bn | ☐ | N/A | ☐ | ☐ |
| Khmer | km | ☐ | N/A | ☐ | ☐ |
| Myanmar | my | ☐ | N/A | ☐ | ☐ |
| Jawi | ms-Arab | ☐ | ☐ RTL | ☐ | ☐ |

### 7. ANIMATION VERIFICATION

| Animation | Duration | Easing | FPS | Tested |
|-----------|----------|--------|-----|--------|
| Page transitions | 300ms | easeInOut | 60 | ☐ |
| Button press | 100ms | easeOut | 60 | ☐ |
| Card hover/tap | 150ms | easeOut | 60 | ☐ |
| Loading spinner | infinite | linear | 60 | ☐ |
| Skeleton shimmer | 1500ms | linear | 60 | ☐ |
| Modal appear | 300ms | spring | 60 | ☐ |
| Modal dismiss | 200ms | easeIn | 60 | ☐ |
| Pull to refresh | spring | spring | 60 | ☐ |
| List item appear | 200ms | easeOut | 60 | ☐ |
| Tab switch | 200ms | easeInOut | 60 | ☐ |
| FAB expand | 250ms | spring | 60 | ☐ |
| Snackbar | 250ms | easeOut | 60 | ☐ |

### 8. PERFORMANCE METRICS

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| First Contentful Paint | < 1.5s | | ☐ |
| Time to Interactive | < 3.0s | | ☐ |
| Largest Contentful Paint | < 2.5s | | ☐ |
| Cumulative Layout Shift | < 0.1 | | ☐ |
| First Input Delay | < 100ms | | ☐ |
| Animation frame rate | 60 fps | | ☐ |
| App cold start (Android) | < 2s | | ☐ |
| App cold start (iOS) | < 2s | | ☐ |
| APK size | < 50MB | | ☐ |
| IPA size | < 100MB | | ☐ |
| Memory usage (idle) | < 100MB | | ☐ |
| Memory usage (active) | < 200MB | | ☐ |

### 9. DARK MODE VERIFICATION

| Element | Light | Dark | Tested |
|---------|-------|------|--------|
| Background | gray-50 | darkBackground | ☐ |
| Surface | white | darkSurface | ☐ |
| Text primary | gray-900 | white | ☐ |
| Text secondary | gray-600 | gray-400 | ☐ |
| Borders | gray-200 | darkBorder | ☐ |
| Cards | white | darkSurface | ☐ |
| Buttons | primary-600 | primary-400 | ☐ |
| Icons | gray-700 | gray-300 | ☐ |
| Status bar | dark icons | light icons | ☐ |
| Charts | proper colors | proper colors | ☐ |
| Images | no filter | no filter | ☐ |

### 10. OFFLINE MODE VERIFICATION

| Feature | Offline Behavior | Tested |
|---------|------------------|--------|
| Dashboard | Show cached | ☐ |
| Payslip list | Show cached | ☐ |
| Payslip detail | Show cached | ☐ |
| Leave balance | Show cached | ☐ |
| Leave apply | Queue for sync | ☐ |
| Notifications | Show cached | ☐ |
| Profile | Show cached | ☐ |
| Offline indicator | Show banner | ☐ |
| Retry mechanism | Auto retry | ☐ |
| Sync on reconnect | Automatic | ☐ |

### 11. ERROR HANDLING VERIFICATION

| Error Type | Message | Action | Tested |
|------------|---------|--------|--------|
| Network error | "Unable to connect" | Retry button | ☐ |
| Server error (500) | "Something went wrong" | Retry button | ☐ |
| Unauthorized (401) | Redirect to login | Auto redirect | ☐ |
| Forbidden (403) | "Access denied" | Contact HR | ☐ |
| Not found (404) | "Not found" | Go back | ☐ |
| Timeout | "Request timed out" | Retry button | ☐ |
| Validation error | Field-specific | Highlight field | ☐ |
| File too large | "File exceeds limit" | Size hint | ☐ |
| Invalid file type | "Invalid format" | Format hint | ☐ |

### 12. USER SEGMENT VERIFICATION

| Segment | Touch Size | Font Size | Complexity | Tested |
|---------|------------|-----------|------------|--------|
| Blue-collar workers | 56dp | Large | Low | ☐ |
| Foreign workers | 56dp | Large | Low | ☐ |
| Factory workers | 64dp (gloves) | Large | Low | ☐ |
| Office workers | 48dp | Normal | High | ☐ |
| Supervisors | 48dp | Normal | Medium | ☐ |
| HR Staff | 48dp | Normal | High | ☐ |
| Management | 48dp | Normal | High | ☐ |
| Elderly workers | 56dp | Extra large | Low | ☐ |
| Visually impaired | 64dp | System large | Screen reader | ☐ |

---

## SIGN-OFF

| Role | Name | Date | Signature |
|------|------|------|-----------|
| UX Designer | | | |
| UI Developer | | | |
| QA Lead | | | |
| Accessibility Auditor | | | |
| Product Manager | | | |

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Total Checks:** 500+
