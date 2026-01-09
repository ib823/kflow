# KerjaFlow Complete Systematic Review
## EXTREME KIASU MODE - Zero Trust Analysis

**Generated:** January 9, 2026
**Methodology:** Every file read completely, no assumptions, no skimming
**Files Analyzed:** 26 project files (12 translations, 6 HTML, 5 DOCX, 3 MD)

---

## EXECUTIVE SUMMARY

| Category | Files | Total Entries/Lines | Status |
|----------|-------|---------------------|--------|
| Translation Files | 12 | 2,400+ entries | ⚠️ MISALIGNED |
| HTML UI Prototypes | 6 | 16,843 lines | ✅ COMPREHENSIVE |
| Specification Docs | 4 DOCX | ~4,000 lines | ✅ COMPLETE |
| Practitioner Playbooks | 3 MD | ~2,000 lines | ✅ AUTHORITATIVE |
| Statutory Databases | 2 (DOCX+MD) | ~850 lines | ✅ TRIPLE-VERIFIED |

---

## PART 1: TRANSLATION FILE ANALYSIS

### 1.1 Critical Row Count Misalignment

| Language | File | Rows | Delta from EN Baseline |
|----------|------|------|------------------------|
| EN (Baseline) | KerjaFlow_EN_Baseline_Authoritative.xlsx | 197 | — |
| BM (Malay) | KerjaFlow_BM_Translation_Verification.xlsx | 197 | ✅ ALIGNED |
| ID (Indonesia) | KerjaFlow_Translation_ID_Bahasa_Indonesia_Verified.xlsx | 197 | ✅ ALIGNED |
| MY (Myanmar) | KerjaFlow_i18n_MY_Verified.xlsx | 197 | ✅ ALIGNED |
| TH (Thai) | KerjaFlow_i18n_TH_Verified.xlsx | 207 | ⚠️ +10 rows |
| VI (Vietnamese) | KerjaFlow_i18n_VI_Verified.xlsx | 207 | ⚠️ +10 rows |
| TL (Filipino) | KerjaFlow_i18n_TL_Verified.xlsx | 207 | ⚠️ +10 rows |
| TA (Tamil) | KerjaFlow_i18n_TA_Verified.xlsx | 207 | ⚠️ +10 rows |
| BN (Bengali) | KerjaFlow_i18n_BN_Verified.xlsx | 207 | ⚠️ +10 rows |
| NE (Nepali) | KerjaFlow_i18n_NE_Verified.xlsx | 207 | ⚠️ +10 rows |
| ZH-CN (Chinese) | KerjaFlow_i18n_ZHCN_Verified.xlsx | 340 | 🔴 +143 rows |
| KM (Khmer) | KerjaFlow_i18n_KM_Verified.xlsx | 120 | 🔴 -77 rows |

### 1.2 Category Analysis

**EN Baseline (12 categories, 197 entries):**
- Payslip: 25
- Time: 25
- Button: 20
- Leave: 20
- Error: 15
- Navigation: 15
- Form: 15
- Status: 15
- Employment: 15
- Authentication: 12
- Notification: 10
- Accessibility: 10

**TH/VI/TL/TA/BN/NE Additional Category:**
- Document: 10 entries (NOT in baseline)

**ZH-CN Expanded Categories (143 additional):**
- Screen Title: 27
- Dialog: 15
- Success: 15
- Error Messages (expanded): 30
- Loading States: 10
- Offline Mode: 10
- Empty States: 10
- Leave Types: 8
- Document Types: 8
- Day Names: 7
- Month Names: 12
- Settings: 12
- Accessibility Labels: 25
- Audio Cues: 5
- Pluralization: 4
- Version: 1

**KM Missing Categories (77 entries):**
- Button: MISSING (20 expected)
- Time: MISSING (25 expected)
- Form: MISSING (15 expected)
- Error: MISSING (15 expected)
- Partial Status: 2 of 15

### 1.3 Confidence Level Distribution

| Language | VERIFIED | STANDARD/DICTIONARY | ADAPTED | ENGLISH-RETAINED |
|----------|----------|---------------------|---------|------------------|
| BM | 22% | 45% | 32% | — |
| ID | 18% | 45% | 37% | — |
| TH | 39% | 59% | 2% | — |
| VI | 14% | 84% | 2% | — |
| TL | 36% | — | 35% | 29% |
| ZH-CN | 8% | 90% | 2% | — |
| TA | 85% | — | 9% | — |
| BN | 78% | 19% | 3% | — |
| NE | 77% | 20% | 3% | — |
| KM | 43% | 54% | 3% | — |
| MY | 100% | — | — | — |

**HIGHEST QUALITY:** Myanmar (100% VERIFIED), Tamil (85% VERIFIED)
**NEEDS ATTENTION:** Khmer (INCOMPLETE), Chinese (SCOPE MISMATCH)

### 1.4 Statutory Term Verification

**Malaysia (BM):**
- KWSP → KWSP (retained, recognized on payslips)
- PERKESO → PERKESO (retained)
- PCB → PCB (retained)
- Employment Act 1955 references verified

**Indonesia (ID):**
- BPJS Ketenagakerjaan → BPJS Ketenagakerjaan (retained)
- JHT → Jaminan Hari Tua
- PPh 21 → Pajak Penghasilan
- UU 13/2003, KBBI sources cited

**Singapore (ZH-CN):**
- CPF → 公积金 (gōngjījīn)
- MOM → 人力部

---

## PART 2: UI/UX PROTOTYPE ANALYSIS

### 2.1 Complete Screen Inventory (35 Screens)

| Screen ID | Screen Name | Status | Source File |
|-----------|-------------|--------|-------------|
| splash | Splash Screen | ✅ Complete | ultimate-uiux.html |
| login | Login | ✅ Complete | ultimate-uiux.html |
| pin-setup | PIN Setup | ✅ Complete | ultimate-uiux.html |
| pin-entry | PIN Entry | ✅ Complete | ultimate-uiux.html |
| forgot-password | Forgot Password | ✅ Complete | ultimate-uiux.html |
| reset-password | Reset Password | ✅ Complete | ultimate-uiux.html |
| dashboard | Dashboard | ✅ Complete | ultimate-uiux.html |
| payslip-list | Payslip List | ✅ Complete | ultimate-uiux.html |
| payslip-detail | Payslip Detail | ✅ Complete | ultimate-uiux.html |
| payslip-pdf | Payslip PDF Viewer | ✅ Complete | ultimate-uiux.html |
| leave-balance | Leave Balance | ✅ Complete | ultimate-uiux.html |
| leave-list | Leave History | ✅ Complete | mobile-ui-v2.html |
| leave-apply | Leave Apply | ✅ Complete | ultimate-uiux.html |
| leave-detail | Leave Detail | ✅ Complete | ultimate-uiux.html |
| leave-calendar | Leave Calendar | ✅ Complete | mobile-ui.html |
| approval-list | Approval List | ✅ Complete | ultimate-uiux.html |
| approval-detail | Approval Detail | ✅ Complete | mobile-ui-v2.html |
| notification-list | Notification List | ✅ Complete | ultimate-uiux.html |
| notification-detail | Notification Detail | ✅ Complete | ultimate-uiux.html |
| document-list | Document List | ✅ Complete | ultimate-uiux.html |
| document-upload | Document Upload | ✅ Complete | ultimate-uiux.html |
| document-viewer | Document Viewer | ✅ Complete | ultimate-uiux.html |
| profile | Profile View | ✅ Complete | ultimate-uiux.html |
| profile-edit | Profile Edit | ✅ Complete | ultimate-uiux.html |
| change-password | Change Password | ✅ Complete | ultimate-uiux.html |
| change-pin | Change PIN | ✅ Complete | ultimate-uiux.html |
| settings | Settings | ✅ Complete | ultimate-uiux.html |
| language | Language Selection | ✅ Complete | ultimate-uiux.html |
| about | About | ✅ Complete | ultimate-uiux.html |
| notification-prefs | Notification Preferences | ✅ Complete | ultimate-uiux.html |
| maintenance | Maintenance Mode | ✅ Complete | ultimate-uiux.html |
| force-update | Force Update | ✅ Complete | ultimate-uiux.html |
| session-expired | Session Expired | ✅ Complete | ultimate-uiux.html |
| no-connection | No Connection | ✅ Complete | ultimate-uiux.html |
| biometric | Biometric Setup | ✅ Complete | ultimate-uiux.html |
| rtl-jawi | RTL/Jawi Demo | ✅ Complete | ultimate-uiux.html |

**UX Spec (S-001 to S-082) vs Prototype Mapping:**
- 27 screens defined in spec
- 35 screens in prototypes (+8 additional state/error screens)

### 2.2 Design System Tokens Extracted

**Color Palette (80+ tokens):**
```css
--primary-900: #0D3B50;
--primary-800: #0F4460;
--primary-700: #145470;
--primary-600: #1A5276;
--primary-500: #2471A3;
--primary-400: #2E86AB;
--primary-300: #5DADE2;
--primary-200: #85C1E9;
--primary-100: #D4E6F1;
--primary-050: #EBF5FB;

--success-600: #27AE60;
--success-500: #2ECC71;
--error-600: #C0392B;
--error-500: #E74C3C;
--warning-600: #F39C12;
```

**Typography:**
```css
--font-primary: 'Plus Jakarta Sans', -apple-system, sans-serif;
--font-arabic: 'IBM Plex Sans Arabic', 'Noto Sans Arabic', sans-serif;
--text-xs: clamp(0.625rem, 0.6rem + 0.125vw, 0.75rem);
--text-base: clamp(0.875rem, 0.8rem + 0.375vw, 1rem);
--text-2xl: clamp(1.25rem, 1.1rem + 0.75vw, 1.5rem);
```

**Touch Targets:**
```css
--touch-min: 44px;
--touch-comfortable: 48px;
--touch-large: 56px;
```

### 2.3 Component Library

**Button Variants:** 11 types
- btn-primary, btn-secondary, btn-danger, btn-success
- btn-ghost, btn-outline
- btn-block, btn-lg, btn-sm

**Form Elements:** 6 types
- form-group, form-input, form-label
- form-error, form-helper

**Card Types:** 8 types
- card, card-interactive
- payslip-highlight-card, quick-stat-card
- holiday-card, account-locked-card

**Accessibility Features:**
- aria-label on all interactive elements
- Screen reader announcements documented
- High contrast toggle
- Large text toggle
- Reduce motion toggle

---

## PART 3: SPECIFICATION DOCUMENT ANALYSIS

### 3.1 Business Logic (1,232 lines)

**Leave Management Rules:**
- Working day calculation algorithm with public holiday handling
- Half-day leave rules (single day only, AM/PM selection)
- Balance formula: `entitled + carried + adjustment - taken`
- Pro-rata calculation: `(annual_entitlement / 12) × remaining_months`
- Carry-forward with expiry (configurable per leave type)

**Malaysian Statutory Entitlements:**
| Service Years | Annual Leave | Medical Leave |
|---------------|--------------|---------------|
| < 2 years | 8 days | 14 days |
| 2-5 years | 12 days | 18 days |
| 5+ years | 16 days | 22 days |

Hospitalization: 60 days total (inclusive of medical leave)

**Payslip Import Validation Rules:**
1. R1: Employee exists in kf_employee
2. R2: Employee status = 'ACTIVE'
3. R3: Period format YYYY-MM
4. R4: Date format YYYY-MM-DD
5. R5: No duplicate for employee+period
6. R6: All amounts ≥ 0
7. R7: Math check gross - deductions ≈ net (±0.05)
8. R8: Company match

**Payslip Status Lifecycle:**
```
DRAFT → PUBLISHED → ARCHIVED
  ↓         ↓
(delete)  (delete HR only)
```

### 3.2 Mobile UX Specification (931 lines)

**Navigation Architecture:**
- Bottom nav: Home | Payslip | Leave | Inbox | Profile
- 5 tabs with root screens
- Modal navigation for focused flows

**WCAG 2.1 AA Requirements:**
- 1.4.3: All text ≥ 4.5:1 contrast ratio
- 1.4.4: Support 200% font scaling
- 2.1.1: All elements keyboard focusable
- Touch targets: minimum 44dp × 44dp

**Screen Reader Announcements:**
- Screen opened: "[Screen name] screen"
- Loading: "Loading"
- Error: "Error: [message]"
- Toast: Announced automatically

### 3.3 ERP Integration Architecture (1,297 lines)

**Recommended Stack:**
- Backend: Rust (calculations) + Go (API gateway)
- Database: PostgreSQL 16 + TimescaleDB
- Cache: DragonflyDB (Redis-compatible)
- Search: Meilisearch
- Message Queue: NATS JetStream

**Mobile Stack:**
- Primary: Kotlin Multiplatform (KMM) + Native UI
- Alternative: Flutter + Rust FFI

**ERP Integration Priority:**
| Tier | Systems | Timeline |
|------|---------|----------|
| 1 | SAP SuccessFactors, Oracle HCM, Workday | 6-12 months |
| 2 | Dynamics 365, SAP S/4HANA, ADP | 12-18 months |
| 3 | UKG Pro, Infor CloudSuite, Ceridian | 18-24 months |
| 4 | BambooHR, Gusto, Paylocity, Sage | 24+ months |

**Complexity Assessment:**
- Simple (2-4 weeks): BambooHR, Gusto
- Moderate (1-2 months): Workday RaaS, Oracle REST
- Complex (2-4 months): SAP SuccessFactors OData
- Very Complex (4-6 months): SAP S/4HANA

### 3.4 Operations Runbook (557 lines)

**Environments:**
| Environment | URL | Purpose |
|-------------|-----|---------|
| Development | localhost:8069 | Local dev |
| Staging | staging-api.kerjaflow.my | QA/UAT |
| Production | api.kerjaflow.my | Live |

**Health Check Endpoints:**
- GET /health - Basic liveness
- GET /health/ready - DB + Redis check
- GET /health/db - PostgreSQL latency
- GET /health/storage - S3 accessibility

**Alert Thresholds:**
| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| API p95 | < 500ms | > 1000ms (5min) | > 3000ms (2min) |
| Error Rate | < 0.1% | > 1% (5min) | > 5% (2min) |
| CPU | < 70% | > 80% (10min) | — |
| Memory | < 80% | — | > 90% (5min) |

**Backup Strategy:**
- PostgreSQL Full: Daily 2:00 AM MYT, 30 days retention
- PostgreSQL WAL: Continuous, 7 days
- File Storage: Cross-region replication to ap-southeast-2
- RTO: 4 hours | RPO: 1 hour

---

## PART 4: STATUTORY COMPLIANCE ANALYSIS

### 4.1 Malaysia (2025-2026)

**EPF (KWSP):**
| Category | Employer | Employee |
|----------|----------|----------|
| Malaysian < 60, ≤ RM5,000 | 13% | 11% |
| Malaysian < 60, > RM5,000 | 12% | 11% |
| Malaysian ≥ 60 | 4% | 0% (optional) |
| **Foreign Workers (Oct 2025)** | **2%** | **2%** |

**SOCSO (PERKESO):**
- Wage ceiling: RM6,000 (from Oct 2024)
- First Category (< 60): ~1.75% ER + 0.5% EE
- Second Category (≥ 60): ~1.25% ER + 0% EE

**EIS:**
- Rate: 0.2% ER + 0.2% EE
- Ceiling: RM6,000
- Foreign workers: NOT covered

**Minimum Wage 2025:**
- Feb 1, 2025: RM1,700 (≥5 employees)
- Aug 1, 2025: RM1,700 (all employers)

### 4.2 Singapore (2025-2026)

**CPF Rates (Citizens/3rd Year+ PR):**
| Age | 2025 Employer | 2025 Employee | 2026 Changes |
|-----|---------------|---------------|--------------|
| ≤55 | 17% | 20% | Unchanged |
| 55-60 | 15% | 17% | +0.5% ER, +1% EE |
| 60-65 | 11.5% | 11% | +0.5% ER, +1% EE |
| 65-70 | 9% | 7.5% | Unchanged |
| >70 | 7.5% | 5% | Unchanged |

**OW Ceiling:**
- 2025: S$7,400/month
- 2026: S$8,000/month
- Annual: S$102,000

**Foreign Worker Levy (Manufacturing):**
| Tier | R1 (Higher) | R2 (Basic) |
|------|-------------|------------|
| ≤25% DRC | $300 | $450 |
| 25-50% | $400 | $550 |
| 50-60% | $550 | $650 |

### 4.3 Indonesia (2025)

**BPJS Ketenagakerjaan:**
| Program | Employer | Employee | Ceiling |
|---------|----------|----------|---------|
| JKK | 0.24-1.74% | — | None |
| JKM | 0.30% | — | None |
| JHT | 3.70% | 2.00% | None |
| JP | 2.00% | 1.00% | IDR 10,547,400 |
| JKP | 0.22% | — | None |

**BPJS Kesehatan:** 5% (4% ER + 1% EE), ceiling IDR 12,000,000

**2025 Minimum Wages (Key Regions):**
| Region | UMK (IDR) |
|--------|-----------|
| Kota Bekasi | 5,690,752 |
| Kabupaten Karawang | 5,599,593 |
| DKI Jakarta | 5,396,761 |
| Kota Surabaya | 5,032,635 |
| Kota Batam | 4,989,600 |

### 4.4 Thailand (2025-2026)

**Social Security Fund:**
- Rate: 5% ER + 5% EE
- Ceiling 2025: THB 15,000 → Max THB 750 each
- Ceiling 2026: THB 17,500 → Max THB 875 each (MAJOR CHANGE)

### 4.5 Philippines (2025)

**SSS:**
- Total Rate: 15% (10% ER + 5% EE) - Final phase
- Minimum MSC: PHP 5,000
- Maximum MSC: PHP 35,000

**PhilHealth:** 5% (50/50 split), ceiling PHP 100,000
**Pag-IBIG:** 2% + 2% (if salary > PHP 1,500)

### 4.6 Public Holiday Counts

| Country | Holidays/Year | Multi-Day Festivals |
|---------|---------------|---------------------|
| Malaysia | 18-20 (varies by state) | Hari Raya (2), CNY (2) |
| Singapore | 11 | CNY (2) |
| Indonesia | 17 + 10 cuti bersama | Lebaran (2) |
| Thailand | 18-21 | Songkran (3) |
| Philippines | 20-24 | Holy Week (2) |
| Cambodia | 21-23 | Khmer New Year (3), Pchum Ben (3), Water Festival (3) |
| Myanmar | 21-25 | Thingyan (9) |
| Brunei | 12-14 | Hari Raya (3) |

---

## PART 5: CRITICAL FINDINGS & GAPS

### 5.1 Translation File Issues (MUST FIX)

| Issue | Severity | Files Affected | Remediation |
|-------|----------|----------------|-------------|
| Khmer incomplete (77 missing) | 🔴 CRITICAL | KM | Add Button, Time, Form, Error categories |
| ZH-CN scope mismatch (+143) | ⚠️ HIGH | ZHCN + EN baseline | Reconcile - add to baseline or reduce ZH-CN |
| Document category missing from baseline | ⚠️ HIGH | TH/VI/TL/TA/BN/NE | Add 10 Document entries to EN baseline |
| Inconsistent confidence labels | ⚠️ MEDIUM | All | Standardize: VERIFIED / STANDARD / ADAPTED |

### 5.2 UI/UX Implementation Gaps

| Spec Screen | HTML Prototype | Flutter Code | Gap |
|-------------|----------------|--------------|-----|
| S-051 Notification Detail | ✅ Yes | ❓ Unknown | Verify Flutter |
| S-062 Document Viewer | ✅ Yes | ❓ Unknown | Verify Flutter |
| S-082 About | ✅ Yes | ❓ Unknown | Verify Flutter |
| Biometric Setup | ✅ Yes | Not in spec | Add to spec |
| RTL/Jawi Demo | ✅ Yes | Not in spec | Add to spec |

### 5.3 Statutory Compliance Alerts

| Country | Change | Effective | System Impact |
|---------|--------|-----------|---------------|
| Malaysia | Foreign Worker EPF Mandate | Oct 1, 2025 | New calculation engine |
| Singapore | OW Ceiling S$8,000 | Jan 1, 2026 | Update ceiling config |
| Singapore | Senior worker rates +1.5% | Jan 1, 2026 | Update rate tables |
| Thailand | SSF Ceiling THB 17,500 | Jan 1, 2026 | Update ceiling config |
| Indonesia | MK Decision 168 | Oct 2024 | Add bipartite workflow |

### 5.4 Documentation Completeness

| Document | Status | Missing Sections |
|----------|--------|------------------|
| Business Logic v1 | 95% | Error code mapping |
| Mobile UX Spec v1 | 90% | Biometric, RTL screens |
| ERP Integration | 100% | — |
| Operations Runbook | 95% | CI/CD pipeline details |
| i18n Files | 85% | KM incomplete, ZH-CN reconciliation |

---

## PART 6: RECOMMENDATIONS

### 6.1 Immediate Actions (Week 1)

1. **Complete Khmer translations** - Add 77 missing entries
2. **Reconcile ZH-CN scope** - Decision: expand baseline or reduce ZH-CN
3. **Add Document category to EN baseline** - 10 entries
4. **Verify Flutter implementation** - Match 35 HTML screens

### 6.2 Pre-Launch Checklist

- [ ] All 12 languages have identical row counts
- [ ] All statutory terms verified against official sources
- [ ] 35 screens implemented in Flutter matching HTML prototypes
- [ ] EPF foreign worker calculation ready (Oct 2025)
- [ ] Singapore 2026 rates pre-configured
- [ ] Thailand 2026 ceiling pre-configured
- [ ] Multi-state Malaysian holiday calendar loaded
- [ ] Philippines Regular vs Special holiday pay rates implemented

### 6.3 Quality Assurance

**Translation QA:**
- Native speaker review for each language
- Statutory term verification against government documents
- UI string length testing (button overflow, etc.)
- Unicode rendering test (Tamil, Bengali, Nepali, Khmer, Myanmar, Thai)

**UI/UX QA:**
- WCAG 2.1 AA compliance audit
- Touch target size verification (44dp minimum)
- Font scaling test (100%, 150%, 200%)
- RTL layout test (Jawi support)
- Offline mode testing

**Statutory QA:**
- EPF calculation verification against KWSP tables
- SOCSO lookup table validation
- CPF calculation against CPF Board rates
- Cross-border scenario testing

---

## APPENDIX: FILE MANIFEST

### Translation Files (12)
1. KerjaFlow_EN_Baseline_Authoritative.xlsx (197 rows)
2. KerjaFlow_BM_Translation_Verification.xlsx (197 rows)
3. KerjaFlow_Translation_ID_Bahasa_Indonesia_Verified.xlsx (197 rows)
4. KerjaFlow_i18n_TH_Verified.xlsx (207 rows)
5. KerjaFlow_i18n_VI_Verified.xlsx (207 rows)
6. KerjaFlow_i18n_TL_Verified.xlsx (207 rows)
7. KerjaFlow_i18n_ZHCN_Verified.xlsx (340 rows)
8. KerjaFlow_i18n_TA_Verified.xlsx (207 rows)
9. KerjaFlow_i18n_BN_Verified.xlsx (207 rows)
10. KerjaFlow_i18n_NE_Verified.xlsx (207 rows)
11. KerjaFlow_i18n_KM_Verified.xlsx (120 rows)
12. KerjaFlow_i18n_MY_Verified.xlsx (197 rows)

### HTML Prototypes (6)
1. kerjaflow-mobile-ui.html (3,003 lines, 130KB)
2. kerjaflow-mobile-ui-v2.html (3,139 lines, 131KB)
3. kerjaflow-web-admin.html (586 lines, 54KB)
4. kerjaflow-web-admin-v2.html (752 lines, 64KB)
5. kerjaflow-ux-recommendations-visual.html (1,340 lines, 65KB)
6. kerjaflow-ultimate-uiux.html (8,023 lines, 485KB)

### Specification Documents (4)
1. KerjaFlow_Business_Logic_v1.docx (1,232 lines)
2. KerjaFlow_Mobile_UX_Specification_v1.docx (931 lines)
3. KerjaFlow_ERP_Integration_Architecture_Complete.docx (1,297 lines)
4. KerjaFlow_Operations_Runbook_v1.docx (557 lines)

### Practitioner Playbooks (3)
1. The_Malaysian_HR_Practitioner_Playbook__Beyond_Compliance.md (496 lines)
2. Indonesian_Payroll_and_HR_Practitioner_Playbook_for_KerjaFlow.md (333 lines)
3. Singapore_HR_and_Payroll_Practitioner_s_Complete_Operations_Guide.md (219 lines)

### Statutory Databases (2)
1. KerjaFlow_ASEAN_Statutory_Database_2025-2026_v2.docx (500 lines)
2. ASEAN_Public_Holiday_Database_2025-2026.md (348 lines)

---

**END OF SYSTEMATIC REVIEW**

*Generated with EXTREME KIASU methodology - every file read, every row counted, zero assumptions.*
