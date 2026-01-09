# KEJA REMEDIATION REQUIREMENTS SPECIFICATION

> **Purpose:** Complete requirements that must be provided before implementation can proceed with 100% confidence.
>
> **Created:** 2026-01-09
>
> **Status:** AWAITING YOUR INPUT

---

## TABLE OF CONTENTS

1. [Tax Calculation Engines](#section-1-tax-calculation-engines)
   - [1.1 Malaysia PCB](#11-malaysia-pcb-potongan-cukai-bulanan--mtd)
   - [1.2 Singapore Income Tax](#12-singapore-income-tax-ir8a--form-ir21)
   - [1.3 Indonesia PPh 21](#13-indonesia-pph-21)
   - [1.4 Thailand PIT](#14-thailand-pit-personal-income-tax)
   - [1.5 Philippines Withholding Tax](#15-philippines-withholding-tax)
   - [1.6 Vietnam PIT](#16-vietnam-pit)
2. [Certificate Pinning](#section-2-certificate-pinning)
3. [Government API Integrations](#section-3-government-api-integrations)
4. [Statutory Rate Verification](#section-4-statutory-rate-verification)
5. [Foreign Worker Levy Tables](#section-5-foreign-worker-levy-tables)
6. [Holiday Pay Differential Rules](#section-6-holiday-pay-differential-rules)
7. [Data Protection Decisions](#section-7-data-protection-decisions)
8. [Notification Content](#section-8-notification-content)
9. [Business Rules Edge Cases](#section-9-business-rules-edge-cases)
10. [Infrastructure Decisions](#section-10-infrastructure-decisions)
11. [Testing & Validation](#section-11-testing--validation)
12. [UX/UI Specifications](#section-12-uxui-specifications)
13. [Acceptance Criteria](#section-13-acceptance-criteria)
14. [Sign-Off Checklist](#section-14-sign-off-checklist)

---

## SECTION 1: TAX CALCULATION ENGINES

### 1.1 Malaysia PCB (Potongan Cukai Bulanan / MTD)

I need the **complete e-PCB calculation specification**.

#### 1.1.1 Tax Resident Categories

```
REQUIRED: Define ALL resident status categories

├── Resident (≥182 days)
├── Non-Resident (<182 days)
├── Knowledge Worker (special rate)
├── Returning Expert Programme
└── [Any other categories used in your client base]

For EACH category, provide:
- Tax rate table (percentage per bracket)
- Applicable reliefs
- Withholding rules
```

#### 1.1.2 MTD Calculation Tables

```
REQUIRED: Provide the COMPLETE 2025/2026 MTD tables

Table Structure Needed:
┌─────────────────────────────────────────────────────────────────────────────┐
│ Monthly Chargeable Income │ Category 1 │ Category 2 │ Category 3 │ ...     │
│ (After EPF deduction)     │ (Single)   │ (Married)  │ (M+1 child)│ ...     │
├─────────────────────────────────────────────────────────────────────────────┤
│ RM 0 - RM 833             │ RM X.XX    │ RM X.XX    │ RM X.XX    │         │
│ RM 834 - RM 1,667         │ RM X.XX    │ RM X.XX    │ RM X.XX    │         │
│ RM 1,668 - RM 2,500       │ RM X.XX    │ RM X.XX    │ RM X.XX    │         │
│ ... [EVERY SINGLE BRACKET up to RM 100,000+]                               │
└─────────────────────────────────────────────────────────────────────────────┘

Total Categories I need (typically 15-20 official LHDN categories):
1. Single / Widower / Divorcee (no children)
2. Single / Widower / Divorcee (with children)
3. Married (spouse not working, no children)
4. Married (spouse not working, 1 child)
5. Married (spouse not working, 2 children)
... [Continue for ALL official LHDN categories]
```

#### 1.1.3 Relief Types and Amounts

```
REQUIRED: Complete list of tax reliefs for 2025/2026

For EACH relief type:
├── Relief Code (your internal code)
├── Relief Name (English)
├── Relief Name (Malay)
├── Maximum Amount (RM)
├── Eligibility Criteria (who qualifies)
├── Documentation Required (what proof)
├── Effective Date Range
└── Special Rules (any gotchas)

Expected reliefs include:
- Individual relief (RM9,000)
- Spouse relief
- Child relief (per child, age brackets)
- Disabled individual relief
- Disabled spouse relief
- Disabled child relief
- Medical expenses (parents)
- Medical expenses (self/spouse/children - serious diseases)
- EPF/approved scheme
- Life insurance / Takaful
- Education fees (self)
- Medical insurance
- SSPN savings
- Lifestyle (books, computer, sports, internet)
- EV charging facilities
- Breastfeeding equipment
- Childcare fees
- Domestic tourism
- [Any others I'm missing]

CRITICAL: Provide the EXACT maximum amounts and any changes between 2025 and 2026
```

#### 1.1.4 Bonus/Additional Remuneration Handling

```
REQUIRED: How to calculate PCB on irregular income

Scenarios I need rules for:
1. Annual bonus paid in single month
2. Commission payments (monthly vs quarterly vs annual)
3. Director fees
4. Gratuity payments
5. Compensation for loss of employment
6. Arrears of salary (paid in current year for past periods)
7. Leave encashment
8. Overtime (is it PCB-able?)

For EACH scenario provide:
- Calculation method (annualization? separate rate?)
- Whether to combine with regular salary or calculate separately
- Any caps or special rates
```

#### 1.1.5 Zakat Offset Rules

```
REQUIRED: Zakat deduction handling

Questions to answer:
1. Is zakat deductible before or after PCB calculation?
2. Maximum zakat offset against PCB? (100%? capped?)
3. Which zakat types are recognized? (fitrah, income, savings, business, etc.)
4. Documentation requirements
5. Monthly vs annual zakat handling
```

#### 1.1.6 MTD Variation Orders (CP38)

```
REQUIRED: How to handle LHDN-issued variation orders

Provide:
1. Data structure for CP38 orders (fields needed)
2. How variations override calculated PCB
3. Effective date handling
4. Expiry/renewal logic
```

#### 1.1.7 Non-Resident Tax Rates

```
REQUIRED: Non-resident withholding rates

For each income type:
├── Employment income: ___%
├── Director fees: ___%
├── Public entertainer: ___%
├── Interest: ___%
├── Royalties: ___%
├── Technical fees: ___%
└── Other: ___%
```

---

### 1.2 Singapore Income Tax (IR8A / Form IR21)

#### 1.2.1 Tax Rate Tables

```
REQUIRED: 2025/2026 Singapore resident tax rates

Chargeable Income    │ Tax Rate │ Gross Tax Payable
─────────────────────┼──────────┼──────────────────
$0 - $20,000         │ 0%       │ $0
$20,001 - $30,000    │ 2%       │ [Calculate]
$30,001 - $40,000    │ 3.5%     │ [Calculate]
... [COMPLETE TABLE through $1,000,000+]

Also provide:
- Non-resident flat rate: ___%
- Non-resident director rate: ___%
- Any concessionary rates (Not Ordinarily Resident, etc.)
```

#### 1.2.2 Taxable vs Non-Taxable Benefits

```
REQUIRED: Classification of ALL benefit types

For EACH benefit type, specify:
├── Benefit Name
├── Taxable? (Yes/No/Partial)
├── If Partial: How to calculate taxable portion
├── Exempt threshold (if any)
└── Reporting code for IR8A

Benefits to classify:
- Housing benefit / Rent-free accommodation
- Car benefit
- Driver benefit
- Club membership
- Share options / ESOP / RSU
- Insurance premiums (group vs individual)
- Medical benefits
- Educational assistance
- Relocation allowance
- Home leave passage
- Per diem / allowances
- Meals provided
- Gifts and awards
- Long service awards
- Entertainment allowance
- Transport allowance
- [Any others]
```

#### 1.2.3 SRS (Supplementary Retirement Scheme)

```
REQUIRED: SRS contribution handling

Provide:
- Maximum contribution amount (citizen vs PR vs foreigner)
- Tax relief calculation method
- Withdrawal tax treatment
```

---

### 1.3 Indonesia PPh 21

#### 1.3.1 Progressive Tax Brackets

```
REQUIRED: 2025/2026 PPh 21 brackets

PKP (Taxable Income)       │ Rate
───────────────────────────┼──────
Rp 0 - Rp 60,000,000       │ 5%
Rp 60M - Rp 250,000,000    │ 15%
Rp 250M - Rp 500,000,000   │ 25%
Rp 500M - Rp 5,000,000,000 │ 30%
> Rp 5,000,000,000         │ 35%

CONFIRM: Are these still current? Any changes for 2025/2026?
```

#### 1.3.2 PTKP (Personal Tax Exemption)

```
REQUIRED: Complete PTKP table

Status Code │ Description                       │ Amount (Rp/year)
────────────┼───────────────────────────────────┼─────────────────
TK/0        │ Single, no dependents             │ Rp ___________
TK/1        │ Single, 1 dependent               │ Rp ___________
TK/2        │ Single, 2 dependents              │ Rp ___________
TK/3        │ Single, 3 dependents              │ Rp ___________
K/0         │ Married, no dependents            │ Rp ___________
K/1         │ Married, 1 dependent              │ Rp ___________
K/2         │ Married, 2 dependents             │ Rp ___________
K/3         │ Married, 3 dependents             │ Rp ___________
K/I/0       │ Married, spouse's income combined │ Rp ___________
K/I/1       │ ... (continue all variations)     │ Rp ___________
```

#### 1.3.3 TER (Tarif Efektif Rata-rata) vs Non-TER

```
REQUIRED: TER calculation method (if applicable)

Starting 2024, Indonesia introduced simplified TER rates.
Provide:
1. When to use TER vs gross-up method
2. TER rate tables (A, B, C categories)
3. Transition rules
4. Which employers must use TER
```

#### 1.3.4 Non-NPWP Surcharge

```
REQUIRED: Penalty for no tax ID

- Rate increase for non-NPWP holders: ___% surcharge
- How to handle foreigners without NPWP
- NPWP validation rules
```

#### 1.3.5 THR (Religious Holiday Allowance) Tax Treatment

```
REQUIRED: THR tax calculation

- Is THR combined with regular salary for tax?
- Or calculated separately?
- Any exempt portion?
```

---

### 1.4 Thailand PIT (Personal Income Tax)

#### 1.4.1 Tax Brackets

```
REQUIRED: 2025/2026 Thailand PIT rates

Net Income (THB)           │ Rate
───────────────────────────┼──────
0 - 150,000                │ Exempt
150,001 - 300,000          │ 5%
300,001 - 500,000          │ 10%
500,001 - 750,000          │ 15%
750,001 - 1,000,000        │ 20%
1,000,001 - 2,000,000      │ 25%
2,000,001 - 5,000,000      │ 30%
> 5,000,000                │ 35%

CONFIRM: Current for 2025/2026?
```

#### 1.4.2 Allowances and Deductions

```
REQUIRED: Complete list of allowable deductions

- Personal allowance: THB ___
- Spouse allowance: THB ___
- Child allowance (per child): THB ___
- Parent support (per parent): THB ___
- Disabled person care: THB ___
- Insurance premium deduction (cap): THB ___
- Provident fund deduction (cap): THB ___
- SSF deduction (cap): THB ___
- Home mortgage interest (cap): THB ___
- Charitable donations (cap): ___% of net income
- [Any others]
```

#### 1.4.3 Withholding Tax Calculation

```
REQUIRED: Monthly WHT calculation method

Options:
A. Annualization method (project full year, calculate tax, divide by 12)
B. Cumulative method (year-to-date calculation each month)
C. Fixed percentage method

Which method should Keja use?
Provide step-by-step calculation example.
```

---

### 1.5 Philippines Withholding Tax

#### 1.5.1 TRAIN Law Tax Table

```
REQUIRED: 2025/2026 BIR tax tables

Taxable Income (PHP)       │ Rate
───────────────────────────┼──────
≤ 250,000                  │ 0%
250,001 - 400,000          │ 15% of excess over 250,000
400,001 - 800,000          │ PHP 22,500 + 20% of excess over 400,000
800,001 - 2,000,000        │ PHP 102,500 + 25% of excess over 800,000
2,000,001 - 8,000,000      │ PHP 402,500 + 30% of excess over 2,000,000
> 8,000,000                │ PHP 2,202,500 + 35% of excess over 8,000,000

CONFIRM: Current rates under TRAIN law for 2025/2026?
```

#### 1.5.2 De Minimis Benefits

```
REQUIRED: Complete de minimis benefit list with thresholds

Benefit                          │ Exempt up to (PHP/year)
─────────────────────────────────┼────────────────────────
Monetized unused vacation leave  │ 10 days
Medical cash allowance           │ PHP 1,500/month
Rice subsidy                     │ PHP 2,000/month OR 1 sack 50kg/month
Uniform/clothing allowance       │ PHP 6,000/year
Achievement awards (non-cash)    │ PHP 10,000/year
Gifts (Christmas/anniversary)    │ PHP 5,000/year
Laundry allowance                │ PHP 300/month
... [COMPLETE LIST]
```

#### 1.5.3 13th Month Pay and Other Benefits

```
REQUIRED: Tax treatment of mandatory benefits

1. 13th Month Pay
   - Exempt threshold: PHP ___
   - Excess taxed how?

2. Other bonuses/incentives
   - Combined ceiling with 13th month?
   - Treatment of productivity incentives

3. Separation pay
   - When taxable vs exempt?
   - DOLE certificate requirements
```

---

### 1.6 Vietnam PIT

#### 1.6.1 Progressive Tax Table

```
REQUIRED: 2025/2026 Vietnam PIT rates

Monthly Taxable Income (VND) │ Rate
─────────────────────────────┼──────
≤ 5,000,000                  │ 5%
5,000,001 - 10,000,000       │ 10%
10,000,001 - 18,000,000      │ 15%
18,000,001 - 32,000,000      │ 20%
32,000,001 - 52,000,000      │ 25%
52,000,001 - 80,000,000      │ 30%
> 80,000,000                 │ 35%

CONFIRM: Current for 2025/2026? (Note: New PIT law Jan 2026?)
```

#### 1.6.2 Personal Deductions

```
REQUIRED: 2025/2026 deduction amounts

- Personal deduction: VND ___ /month (Jan 2026: VND 15,500,000?)
- Dependent deduction: VND ___ /month per dependent (Jan 2026: VND 6,200,000?)
- Insurance contributions (SI, HI, UI): Deductible? Cap?
- Voluntary pension fund: Deductible? Cap?
- Charitable contributions: Deductible? Cap?
```

#### 1.6.3 Foreign Employee Tax Treatment

```
REQUIRED: Resident vs non-resident determination

- 183-day rule application
- Tax treaty benefits (which countries?)
- Non-resident flat rate: ___%
- Start date for residency counting
```

---

## SECTION 2: CERTIFICATE PINNING

### 2.1 Production SSL Certificates

```
REQUIRED: I need the following for EACH environment

For PRODUCTION:
├── Primary Certificate Chain
│   ├── Root CA certificate (PEM format)
│   ├── Intermediate CA certificate(s) (PEM format)
│   └── Leaf/server certificate (PEM format)
├── SPKI (Subject Public Key Info) hash
│   └── SHA-256 fingerprint of the public key
├── Certificate expiry date
└── Backup certificate chain (if you have one)

For STAGING (if different):
└── [Same structure as above]

For API domains:
├── api.keja.com (or whatever your production API domain is)
├── auth.keja.com (if separate auth service)
├── files.keja.com (if separate file storage)
└── [Any other domains the mobile app connects to]
```

**HOW TO EXTRACT** (run on your server):

```bash
# Get SPKI pin for certificate pinning
openssl s_client -connect api.keja.com:443 -servername api.keja.com 2>/dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform DER | \
  openssl dgst -sha256 -binary | \
  base64
```

**Provide output for EACH domain.**

### 2.2 Certificate Rotation Plan

```
REQUIRED: Your certificate management policy

Questions:
1. When do your certificates expire?
2. How far in advance do you rotate?
3. Do you use Let's Encrypt (90-day) or commercial CA (1-2 year)?
4. Do you have backup pins (for rotation)?
5. What's your certificate revocation procedure?

I need this to implement proper pin rotation in the app without breaking existing users.
```

---

## SECTION 3: GOVERNMENT API INTEGRATIONS

### 3.1 Malaysia FWCMS

```
REQUIRED: Foreign Worker Centralized Management System access

Provide:
1. API documentation (official from JIM or your integration partner)
2. Sandbox/test environment credentials
3. Production credentials (when ready)
4. API endpoint URLs (sandbox and production)
5. Authentication method (API key? OAuth? Certificate?)
6. Rate limits
7. Data format specifications (request/response schemas)
8. Error code documentation
9. Webhook/callback specifications (if any)

If NO direct API access:
- Do you use a third-party integration provider?
- What's their API documentation?
- Or is this manual-only (upload CSV to portal)?

If MANUAL ONLY:
- What export format does FWCMS accept?
- I'll build CSV/Excel export instead
```

### 3.2 Malaysia ePPAx (Levy Payment)

```
REQUIRED: Levy payment integration

Same questions as FWCMS:
1. Is there an API? Documentation?
2. Sandbox credentials?
3. Or is this bank payment + manual reconciliation?

If MANUAL:
- What's the levy payment reference format?
- How do you reconcile payments?
- I'll build levy calculation + payment instruction generation
```

### 3.3 Singapore MOM API

```
REQUIRED: Ministry of Manpower integration

Questions:
1. Do you have CorpPass integration?
2. Do you use any MOM APIs?
   - COMPASS score checking?
   - Work pass status verification?
   - Quota checking?
3. API documentation?
4. Test credentials?

If NO API access:
- I'll build COMPASS score calculator based on published rules
- Manual verification workflow
```

### 3.4 Other Government Systems

```
For EACH country where you want government integration:

□ Indonesia: BPJS online portal access?
□ Indonesia: DJP (tax) e-filing integration?
□ Thailand: SSO e-Service access?
□ Philippines: SSS/PhilHealth/Pag-IBIG portal access?
□ Philippines: BIR eFPS integration?
□ Vietnam: BHXH portal access?

For each YES:
- API documentation
- Test credentials
- Production credentials
- Data format specs
```

---

## SECTION 4: STATUTORY RATE VERIFICATION

### 4.1 Rate Verification Sources

```
REQUIRED: For EACH statutory rate in the system, provide:

1. Official source document (PDF/URL)
2. Effective date
3. Your verification date
4. Verified by (name/role)

I need this for:
□ Malaysia: EPF rates (all tiers)
□ Malaysia: SOCSO rates and ceiling
□ Malaysia: EIS rates and ceiling
□ Malaysia: HRDF rates
□ Singapore: CPF rates (all age bands)
□ Singapore: SDL rates
□ Indonesia: BPJS-TK all components
□ Indonesia: BPJS-KES rates
□ Thailand: SSF rates and ceilings (all phases)
□ Philippines: SSS contribution table
□ Philippines: PhilHealth rates
□ Philippines: Pag-IBIG rates
□ Vietnam: SI/HI/UI rates
□ Vietnam: Trade union rates
□ Cambodia: NSSF all components
□ Myanmar: SSB rates
□ Brunei: SPK rates (all tiers)
```

**FORMAT NEEDED:**

```
┌────────────────────────────────────────────────────────────────┐
│ Country: Malaysia                                              │
│ Contribution: EPF Employee Rate                                │
│ Rate: 11%                                                      │
│ Effective: 2024-01-01                                          │
│ Source: KWSP Employer Contribution Guide 2024                  │
│ URL: https://www.kwsp.gov.my/...                               │
│ Verified By: [Your Name]                                       │
│ Verified Date: 2025-01-09                                      │
└────────────────────────────────────────────────────────────────┘
```

### 4.2 Upcoming Rate Changes

```
REQUIRED: Any known rate changes not yet in the system

For EACH upcoming change:
- Country
- Contribution type
- Current rate
- New rate
- Effective date
- Source document
- Official gazette/circular reference
```

---

## SECTION 5: FOREIGN WORKER LEVY TABLES

### 5.1 Malaysia Levy Rates

```
REQUIRED: Complete levy rate matrix

MANUFACTURING SECTOR:
┌────────────────────┬──────────────────────────────────────────────┐
│ Source Country     │ Monthly Levy (RM)                            │
├────────────────────┼──────────────────────────────────────────────┤
│ Indonesia          │ RM ___                                       │
│ Bangladesh         │ RM ___                                       │
│ Nepal              │ RM ___                                       │
│ Myanmar            │ RM ___                                       │
│ India              │ RM ___                                       │
│ Vietnam            │ RM ___                                       │
│ Philippines        │ RM ___                                       │
│ Pakistan           │ RM ___                                       │
│ Cambodia           │ RM ___                                       │
│ Sri Lanka          │ RM ___                                       │
│ Thailand           │ RM ___                                       │
│ [Others]           │ RM ___                                       │
└────────────────────┴──────────────────────────────────────────────┘

CONSTRUCTION SECTOR:
[Same matrix - rates differ]

PLANTATION SECTOR:
[Same matrix - rates differ]

AGRICULTURE SECTOR:
[Same matrix - rates differ]

SERVICES SECTOR:
[Same matrix - rates differ]

DOMESTIC HELPER:
[Same matrix - different rate structure]

Also provide:
- Levy reduction for skilled workers (if any)
- Levy exemption rules
- Payment frequency (monthly/annual?)
- Grace period for payment
- Penalty for late payment
```

### 5.2 Singapore Foreign Worker Levy

```
REQUIRED: Complete levy rate structure

WORK PERMIT (WP):
┌────────────────────┬────────────┬──────────────┬───────────────┐
│ Sector             │ Basic Tier │ Higher Tier  │ Highest Tier  │
├────────────────────┼────────────┼──────────────┼───────────────┤
│ Manufacturing      │ $___       │ $___         │ $___          │
│ Construction       │ $___       │ $___         │ $___          │
│ Marine Shipyard    │ $___       │ $___         │ $___          │
│ Process            │ $___       │ $___         │ $___          │
│ Services           │ $___       │ $___         │ $___          │
└────────────────────┴────────────┴──────────────┴───────────────┘

S PASS:
- Tier 1 (up to X%): $___/month
- Tier 2 (above X%): $___/month

Also provide:
- Dependency Ratio Ceiling (DRC) by sector
- How to calculate which tier applies
- Foreign Worker Levy rebates (if any)
```

---

## SECTION 6: HOLIDAY PAY DIFFERENTIAL RULES

### 6.1 Malaysia

```
REQUIRED: Holiday pay calculation rules

For work on PUBLIC HOLIDAY:
- Regular rate multiplier: ___x (I believe 2x)
- Plus replacement day off? (Yes/No)
- If no replacement day: Additional ___x?

For work on REST DAY:
- Regular rate multiplier: ___x
- Overtime on rest day: ___x

For work on REST DAY that is also PUBLIC HOLIDAY:
- Rate multiplier: ___x

Calculation base:
- Basic salary only? Or basic + fixed allowances?
- Formula: [PROVIDE EXACT FORMULA]

Example calculation:
Employee basic salary: RM 3,000/month
Works on public holiday (8 hours):
Show me the EXACT calculation you expect.
```

### 6.2 Philippines

```
REQUIRED: Holiday pay rules (Labor Code + DOLE guidelines)

REGULAR HOLIDAY (worked):
- Rate: 200% of daily rate
- First 8 hours: ___%
- Overtime (excess of 8 hours): ___% additional
- Night shift differential on holiday: ___% additional

REGULAR HOLIDAY (not worked):
- Paid? (Yes/No)
- At what rate?

SPECIAL NON-WORKING HOLIDAY (worked):
- Rate: 130% of daily rate
- Overtime: ___% additional

SPECIAL NON-WORKING HOLIDAY (not worked):
- Paid? (Yes/No) - I believe "no work, no pay"

SPECIAL WORKING HOLIDAY (worked):
- Rate: ___%

Double holiday (regular + special on same day):
- Rate: ___%

Provide EXACT calculation examples for each scenario.
```

### 6.3 Indonesia

```
REQUIRED: Overtime and holiday pay (PP 35/2021)

REGULAR OVERTIME:
- First hour: ___x hourly rate
- Subsequent hours: ___x hourly rate

OVERTIME ON REST DAY (7-day work week):
- Hours 1-7: ___x
- Hour 8: ___x
- Hours 9+: ___x

OVERTIME ON REST DAY (6-day work week):
- Hours 1-5: ___x
- Hour 6: ___x
- Hour 7: ___x
- Hours 8+: ___x

OVERTIME ON PUBLIC HOLIDAY:
- [Similar structure]

Hourly rate formula:
1/173 × monthly wage? Or different formula?
```

### 6.4 Thailand

```
REQUIRED: Overtime and holiday pay (Labor Protection Act)

REGULAR OVERTIME:
- Rate: ___x hourly rate

HOLIDAY WORK:
- Traditional holiday: ___x
- Weekly holiday: ___x

OVERTIME ON HOLIDAY:
- Rate: ___x

Hourly rate formula: ___
```

### 6.5 Vietnam

```
REQUIRED: Overtime rates (Labor Code 2019)

REGULAR OVERTIME:
- Weekday: ___% of normal wage
- Weekend: ___% of normal wage
- Public holiday: ___% of normal wage

NIGHT SHIFT (22:00 - 06:00):
- Additional: ___% of normal wage
- Night overtime: ___% of normal wage
```

---

## SECTION 7: DATA PROTECTION DECISIONS

### 7.1 Consent Management

```
REQUIRED: Business decisions for consent system

1. What data processing activities require explicit consent?
   □ Payroll processing (statutory)
   □ Performance data
   □ Health/medical data
   □ Biometric data
   □ Location tracking (attendance)
   □ Device information
   □ Analytics/usage data
   □ Marketing communications
   □ Third-party sharing
   □ Cross-border transfers
   □ [Others?]

2. Consent granularity:
   - Single consent for all? OR
   - Separate consent per activity?

3. Consent withdrawal:
   - What happens when employee withdraws consent?
   - Grace period?
   - Data deletion timeline?

4. Re-consent:
   - How often to refresh consent?
   - Trigger events for re-consent?
```

### 7.2 Data Breach Response Plan

```
REQUIRED: Your incident response decisions

1. Breach severity levels:
   - Level 1 (Critical): [Define - e.g., >1000 records, financial data]
   - Level 2 (High): [Define]
   - Level 3 (Medium): [Define]
   - Level 4 (Low): [Define]

2. Notification timelines (by severity):
   - Internal notification: __ hours
   - DPO notification: __ hours
   - Regulatory notification: __ hours (must meet 72h/3-day requirements)
   - Affected individuals: __ hours/days

3. Notification recipients:
   - DPO email: ___@___
   - Security team email: ___@___
   - Legal team email: ___@___
   - Executive notification: Who? When?

4. Breach notification templates:
   - Regulatory authority template (per country)
   - Affected individual template (per country, per language)
   - Do you want me to draft these? Or provide existing ones?

5. Post-breach actions:
   - Mandatory password reset?
   - Session invalidation?
   - Account lockdown?
   - Credit monitoring offer?
```

### 7.3 Data Retention Decisions

```
REQUIRED: Retention period confirmations

Data Type                    │ Retention Period │ Source/Justification
─────────────────────────────┼──────────────────┼─────────────────────
Active employee records      │ Employment + __ years │ [Regulation]
Terminated employee records  │ Termination + __ years │ [Regulation]
Payslips                     │ __ years │ [Tax law requirement]
Leave records                │ __ years │ [Labor law]
Attendance records           │ __ years │ [Your policy]
Medical certificates         │ __ years │ [Your policy]
Performance reviews          │ __ years │ [Your policy]
Disciplinary records         │ __ years │ [Legal advice]
Audit logs                   │ __ years │ [Security policy]
Session logs                 │ __ days │ [Security policy]
Failed login attempts        │ __ days │ [Security policy]
API request logs             │ __ days │ [Your policy]
Backup data                  │ __ days/months │ [Your policy]
Anonymized analytics         │ __ years / indefinite │ [Your policy]

For EACH entry, confirm the retention period and legal/business justification.
```

---

## SECTION 8: NOTIFICATION CONTENT

### 8.1 Email Templates

```
REQUIRED: Content for ALL system emails

For EACH email type, provide in ALL 12 languages:
- Subject line
- Body content (HTML and plain text)
- Sender name
- Reply-to address

Email types needed:

AUTHENTICATION:
□ Welcome email (new employee)
□ Password reset request
□ Password reset confirmation
□ PIN setup confirmation
□ Account locked notification
□ Suspicious login alert
□ New device login notification

PAYROLL:
□ Payslip available notification
□ Payslip correction notification

LEAVE:
□ Leave request submitted (to employee)
□ Leave request submitted (to approver)
□ Leave approved notification
□ Leave rejected notification
□ Leave cancelled notification
□ Leave balance reminder (low balance)

DOCUMENTS:
□ Document uploaded confirmation
□ Document expiring soon (permit, medical, etc.)
□ Document expired alert

COMPLIANCE:
□ Data subject request received
□ Data subject request completed
□ Data deletion confirmation
□ Consent expiry reminder
□ Breach notification (if affected)

FOREIGN WORKER:
□ Permit expiring (30/60/90 days)
□ Permit expired
□ FOMEMA due reminder
□ Levy payment reminder

Provide templates or specify that I should draft them (I'll create drafts for your review).
```

### 8.2 Push Notification Content

```
REQUIRED: Push notification copy

For EACH notification type in ALL 12 languages:
- Title (max 50 characters)
- Body (max 150 characters)
- Action button text (if applicable)

Notification types:
□ Payslip ready
□ Leave request action needed
□ Leave request approved/rejected
□ Document expiring
□ New message/announcement
□ Attendance reminder
□ Session expired
□ [Others?]
```

---

## SECTION 9: BUSINESS RULES EDGE CASES

### 9.1 Payroll Edge Cases

```
REQUIRED: Decisions for ambiguous scenarios

1. Mid-month joiner:
   - Pro-rata calculation: By calendar days? Working days?
   - Formula: ___

2. Mid-month termination:
   - Final pay calculation: ___
   - Include unused leave? At what rate?
   - Statutory contribution: Full month or pro-rata?

3. Unpaid leave:
   - Salary deduction formula: ___
   - Statutory contribution: On actual pay or full salary?

4. Backdated salary adjustment:
   - Recalculate past statutory contributions?
   - How far back?

5. Salary advance deduction:
   - Before or after statutory deductions?

6. Multiple salary revisions in same month:
   - Which rate for statutory calculation?

7. Overtime calculation base:
   - Basic only? Or basic + fixed allowances?
   - Formula for hourly rate: ___

8. Commission employees:
   - Statutory contribution on commission?
   - How to handle variable income?

9. Part-time employees:
   - Statutory contribution calculation?
   - Minimum working hours threshold?

10. Probation period:
    - Different statutory rules?
    - Leave accrual during probation?
```

### 9.2 Leave Edge Cases

```
REQUIRED: Leave calculation decisions

1. Negative leave balance:
   - Allow? For which leave types?
   - Maximum negative days?
   - Deduction from final pay if not covered?

2. Leave during notice period:
   - Allow annual leave?
   - Allow medical leave?
   - Special rules?

3. Public holiday during leave:
   - Count as leave day? (I believe: No)
   - Different by country?

4. Weekend during leave:
   - Count as leave day?
   - For which leave types?

5. Half-day leave combinations:
   - AM + PM on same day = 1 day?
   - Cross-day half-days (PM + next AM)?

6. Compassionate leave triggers:
   - Death of whom? (parent, spouse, child, sibling, in-law, grandparent?)
   - Days per relationship?
   - Documentation required?

7. Maternity leave:
   - Earliest start date (before due date)?
   - What if premature birth?
   - What if stillbirth? (different entitlement?)
   - Hospitalization extension rules?

8. Encashment of unused leave:
   - Which leave types?
   - Rate (basic? gross?)
   - When? (termination only? year-end?)
```

### 9.3 Foreign Worker Edge Cases

```
REQUIRED: Foreign worker handling decisions

1. Permit expiry during employment:
   - Grace period before blocking access?
   - Manager notification timeline?

2. Permit type change (e.g., WP to S Pass):
   - How to handle contribution rate change mid-month?

3. Nationality change (naturalization):
   - When does citizen rate apply?

4. Backdated permit renewal:
   - How to handle gap period?

5. Multiple employers (moonlighting):
   - How to handle statutory contributions?
```

---

## SECTION 10: INFRASTRUCTURE DECISIONS

### 10.1 Email Service

```
REQUIRED: Email sending configuration

Options:
A. SMTP (provide credentials)
   - SMTP host: ___
   - SMTP port: ___
   - Username: ___
   - Password: ___
   - Encryption: TLS/SSL/STARTTLS?
   - From address: ___
   - Reply-to address: ___

B. Transactional email service (provide API key)
   - Service: SendGrid / Mailgun / AWS SES / Postmark / other?
   - API key: ___
   - Domain verified?
   - Sender domain: ___

C. I should NOT implement email (you have another system)
   - How should Keja trigger emails?
   - Webhook? Message queue?
```

### 10.2 Push Notification Service

```
REQUIRED: Push notification configuration

For iOS:
- APNs certificate (.p8 file) OR
- APNs key ID + Team ID + Bundle ID

For Android:
- Firebase project credentials (google-services.json)
- FCM server key OR Firebase Admin SDK service account

OR if using a wrapper service:
- OneSignal / Pusher / Firebase Cloud Messaging?
- API credentials
```

### 10.3 File Storage

```
REQUIRED: Document storage configuration

Current: S3-compatible storage

Provide:
- S3 endpoint URL: ___
- Bucket name: ___
- Access key ID: ___
- Secret access key: ___
- Region: ___
- Custom domain (if using CDN): ___
- Encryption at rest enabled?
- Encryption key management: AWS KMS / custom?
```

### 10.4 Database Encryption

```
REQUIRED: Database encryption decisions

1. Are you using PostgreSQL native encryption?
   - TDE (Transparent Data Encryption)?
   - pgcrypto for field-level?

2. Which fields should be encrypted at rest?
   □ IC/NRIC numbers
   □ Passport numbers
   □ Bank account numbers
   □ Salary amounts
   □ Home addresses
   □ Medical information
   □ [Others?]

3. Encryption key management:
   - AWS KMS?
   - HashiCorp Vault?
   - Environment variables?
   - Hardware Security Module (HSM)?

4. Key rotation policy:
   - Rotation frequency?
   - Re-encryption procedure?
```

### 10.5 Redis/Cache Configuration

```
REQUIRED: Caching infrastructure

- Redis host: ___
- Redis port: ___
- Redis password: ___
- SSL/TLS enabled?
- Cluster mode?
- Memory limit: ___
- Eviction policy: ___
```

---

## SECTION 11: TESTING & VALIDATION

### 11.1 Tax Calculation Test Cases

```
REQUIRED: Validated test cases for tax engines

For EACH country's tax calculation, provide:

TEST CASE FORMAT:
┌────────────────────────────────────────────────────────────────────────────┐
│ Test ID: MY-PCB-001                                                        │
│ Description: Single employee, no dependents, RM 5,000 basic                │
│ Country: Malaysia                                                          │
│ Tax Type: PCB                                                              │
│                                                                            │
│ INPUT:                                                                     │
│ - Gross salary: RM 5,000                                                   │
│ - EPF employee: RM 550                                                     │
│ - Marital status: Single                                                   │
│ - Number of children: 0                                                    │
│ - Tax reliefs claimed: None                                                │
│ - YTD gross: RM 25,000 (month 5)                                           │
│ - YTD PCB paid: RM 100                                                     │
│                                                                            │
│ EXPECTED OUTPUT:                                                           │
│ - Monthly PCB: RM ___                                                      │
│ - Calculation breakdown: [step-by-step]                                    │
│                                                                            │
│ SOURCE: Validated against [e-PCB calculator / payroll software / manual]   │
│ VALIDATED BY: [Name]                                                       │
│ VALIDATED DATE: [Date]                                                     │
└────────────────────────────────────────────────────────────────────────────┘

MINIMUM TEST CASES NEEDED (per country):
- 10 basic scenarios (varying salary levels)
- 5 with dependents/reliefs
- 5 with bonuses/irregular income
- 3 non-resident scenarios
- 3 edge cases (boundary values, maximum brackets)

Total: ~25 test cases per country × 6 countries = 150 validated test cases
```

### 11.2 Statutory Contribution Test Cases

```
REQUIRED: Validated test cases for statutory calculations

Same format as above, for:
- EPF (all tiers: young, senior, foreign worker)
- SOCSO (below ceiling, at ceiling, above ceiling)
- EIS (below ceiling, at ceiling, above ceiling)
- CPF (each age band)
- BPJS-TK (each component, each risk level)
- SSF (each ceiling phase)
- SSS (various MSC brackets)
- PhilHealth
- Pag-IBIG
- Vietnam SI (local vs foreign)
- Cambodia NSSF (each phase)
- Myanmar SSB
- Brunei SPK (each tier)

MINIMUM: 5 test cases per contribution type × ~30 types = 150 test cases
```

### 11.3 Leave Calculation Test Cases

```
REQUIRED: Validated leave calculation scenarios

Test scenarios needed:
- New joiner pro-rata (various join dates)
- Tenure upgrade (boundary dates)
- Carry forward calculation
- Leave balance after requests
- Holiday exclusion during leave
- Half-day scenarios
- Negative balance scenarios

MINIMUM: 30 test cases with expected outcomes
```

### 11.4 Payroll End-to-End Test Cases

```
REQUIRED: Complete payroll calculation scenarios

For EACH country, provide at least 5 complete payroll scenarios:

SCENARIO FORMAT:
┌────────────────────────────────────────────────────────────────────────────┐
│ Scenario ID: MY-PAYROLL-001                                                │
│ Description: Standard Malaysian employee, mid-career                       │
│                                                                            │
│ EMPLOYEE PROFILE:                                                          │
│ - Country: Malaysia                                                        │
│ - Age: 35                                                                  │
│ - Nationality: Malaysian                                                   │
│ - Join date: 2020-01-15                                                    │
│ - Basic salary: RM 5,000                                                   │
│ - Fixed allowances: RM 500                                                 │
│ - Marital status: Married                                                  │
│ - Children: 2                                                              │
│                                                                            │
│ PAYSLIP MONTH: January 2026                                                │
│                                                                            │
│ EARNINGS:                                                                  │
│ - Basic: RM 5,000                                                          │
│ - Fixed allowance: RM 500                                                  │
│ - Overtime (10 hours): RM ___                                              │
│ - Total gross: RM ___                                                      │
│                                                                            │
│ STATUTORY DEDUCTIONS:                                                      │
│ - EPF Employee (11%): RM ___                                               │
│ - SOCSO Employee: RM ___                                                   │
│ - EIS Employee: RM ___                                                     │
│ - PCB: RM ___                                                              │
│ - Total deductions: RM ___                                                 │
│                                                                            │
│ EMPLOYER CONTRIBUTIONS:                                                    │
│ - EPF Employer (12%): RM ___                                               │
│ - SOCSO Employer: RM ___                                                   │
│ - EIS Employer: RM ___                                                     │
│ - HRDF (if applicable): RM ___                                             │
│ - Total employer cost: RM ___                                              │
│                                                                            │
│ NET PAY: RM ___                                                            │
│                                                                            │
│ VALIDATED BY: [Name]                                                       │
│ VALIDATED DATE: [Date]                                                     │
│ VALIDATION SOURCE: [e-PCB / existing payroll / manual calculation]         │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## SECTION 12: UX/UI SPECIFICATIONS

### 12.1 New Screens Needed

```
REQUIRED: Design specifications for new screens

If you want me to implement UI, provide:

For EACH new screen:
- Wireframe or mockup (Figma/Sketch/image)
- User flow diagram
- State variations (loading, empty, error, success)
- Responsive breakpoints
- Animation specifications
- Accessibility requirements

New screens that may be needed:
□ Compliance dashboard (admin)
□ Tax calculation details (employee)
□ Levy management (admin)
□ Foreign worker quota monitor (admin)
□ Consent management (employee)
□ Data export request (employee)
□ Breach notification display
□ [Others?]

OR specify: "Use existing design patterns, I'll review later"
```

### 12.2 Error Message Content

```
REQUIRED: User-facing error messages

For EACH error scenario, provide copy in ALL 12 languages:

Error categories:
- Authentication errors (wrong password, locked account, expired session)
- Validation errors (invalid input, missing fields)
- Business rule errors (insufficient leave, exceeded quota)
- System errors (network, server, timeout)
- Permission errors (unauthorized access)

FORMAT:
┌────────────────────────────────────────────────────────────────┐
│ Error Code: AUTH_001                                           │
│ Scenario: Invalid password                                     │
│ English: "The password you entered is incorrect. Please try    │
│           again or reset your password."                       │
│ Malay: "[Translation]"                                         │
│ Indonesian: "[Translation]"                                    │
│ ... [all 12 languages]                                         │
│ Tone: Helpful, not blaming                                     │
│ Action Button: "Reset Password" / "Try Again"                  │
└────────────────────────────────────────────────────────────────┘
```

---

## SECTION 13: ACCEPTANCE CRITERIA

### 13.1 Definition of Done

```
REQUIRED: Your quality standards

For a feature to be considered "complete," must it:

□ Pass all unit tests (coverage threshold: __%)
□ Pass all integration tests
□ Pass security scan (Bandit/safety)
□ Pass linting (zero warnings? or threshold?)
□ Have documentation updated
□ Have changelog entry
□ Be reviewed by: [who?]
□ Be tested in staging by: [who?]
□ Have rollback plan documented
□ [Other criteria?]
```

### 13.2 Performance Requirements

```
REQUIRED: Performance benchmarks

API Response Times:
- Authentication: < ___ ms
- Payslip list: < ___ ms
- Payslip detail: < ___ ms
- Leave request: < ___ ms
- Dashboard load: < ___ ms

Batch Operations:
- Payroll calculation (per employee): < ___ ms
- Bulk import (1000 records): < ___ seconds

Mobile:
- App cold start: < ___ seconds
- Screen transition: < ___ ms
- Offline sync: < ___ seconds for ___ records
```

### 13.3 Security Requirements

```
REQUIRED: Security standards confirmation

Confirm or modify these requirements:

□ Access token TTL: 15 minutes (change to: ___)
□ Refresh token TTL: 7 days (change to: ___)
□ PIN bcrypt cost: 12 (change to: ___)
□ Password bcrypt cost: 12 (change to: ___)
□ Session timeout: 5 minutes (change to: ___)
□ Rate limit (auth): 10/minute (change to: ___)
□ Rate limit (API): 60/minute (change to: ___)
□ Account lockout after: 5 attempts (change to: ___)
□ Lockout duration: Progressive 15/30/60 min (change to: ___)
```

---

## SECTION 14: SIGN-OFF CHECKLIST

### Before I Proceed, Confirm You Will Provide:

#### MUST HAVE (Blocking Implementation)

| Item | Section | Your Response |
|------|---------|---------------|
| □ Tax calculation tables - Malaysia PCB | 1.1 | ___ |
| □ Tax calculation tables - Singapore | 1.2 | ___ |
| □ Tax calculation tables - Indonesia PPh 21 | 1.3 | ___ |
| □ Tax calculation tables - Thailand PIT | 1.4 | ___ |
| □ Tax calculation tables - Philippines | 1.5 | ___ |
| □ Tax calculation tables - Vietnam PIT | 1.6 | ___ |
| □ Production SSL certificates | 2.1 | ___ |
| □ Statutory rate verification | 4.1 | ___ |
| □ Foreign worker levy tables | 5.1, 5.2 | ___ |
| □ Holiday pay calculation rules | 6.1-6.5 | ___ |
| □ Data protection decisions | 7.1-7.3 | ___ |
| □ Email service credentials | 10.1 | ___ |
| □ Tax calculation test cases | 11.1 | ___ |

#### SHOULD HAVE (High Priority)

| Item | Section | Your Response |
|------|---------|---------------|
| □ Government API access OR manual confirmation | 3.1-3.4 | ___ |
| □ Push notification credentials | 10.2 | ___ |
| □ Notification templates | 8.1, 8.2 | ___ |
| □ Business rule edge case decisions | 9.1-9.3 | ___ |
| □ Statutory contribution test cases | 11.2 | ___ |
| □ Leave calculation test cases | 11.3 | ___ |

#### NICE TO HAVE (Can Iterate)

| Item | Section | Your Response |
|------|---------|---------------|
| □ UX/UI specifications | 12.1 | ___ |
| □ Complete test case suite | 11.4 | ___ |
| □ Error message translations | 12.2 | ___ |
| □ Performance benchmarks | 13.2 | ___ |

---

### Timeline

```
Please provide your timeline for delivering these requirements:

MUST HAVE items: ___ days/weeks
SHOULD HAVE items: ___ days/weeks
NICE TO HAVE items: ___ days/weeks

I will NOT proceed until I have at minimum the "MUST HAVE" items.
```

---

### Delivery Format

```
Provide responses in whatever format works for you:

□ Spreadsheet (Excel/Google Sheets)
□ PDF documents
□ Figma links
□ Confluence/Notion pages
□ JSON/YAML configuration files
□ Direct answers in follow-up messages
□ Other: ___
```

---

## APPENDIX A: CURRENT COMPLIANCE AUDIT SUMMARY

For reference, here's what the audit found:

| Domain | Score | Key Gaps |
|--------|-------|----------|
| Statutory Contributions | 81% | Tax engines missing (6 countries) |
| Data Protection | 42% | Missing models, no breach system |
| Foreign Worker | 29% | Malaysia only, no levy calculation |
| Leave Management | 86% | Holiday pay differentials missing |
| Security | 72% | Token TTLs wrong, cert pinning placeholder |
| Internationalization | 100% | Complete |
| Compliance Calendar | 47% | Wrong deadlines, no reminders |

**Full audit report:** `/workspaces/kflow/docs/specs/COMPLIANCE_AUDIT_REPORT.md` (if you want me to create it)

---

## APPENDIX B: CONTACT FOR QUESTIONS

If you have questions about any requirement in this document:

- Create specific questions in a follow-up message
- Reference the section number (e.g., "Section 1.1.3 - Relief Types")
- I will clarify before you spend time gathering wrong information

---

**END OF REQUIREMENTS SPECIFICATION**

*Document Version: 1.0*
*Last Updated: 2026-01-09*
