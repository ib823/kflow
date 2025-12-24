# KerjaFlow Business Logic Specification

**Leave Rules • Working Days • Pro-Rata • Payroll Import**

Version 1.0 — December 2025

> **PURPOSE:** This document specifies the business rules for leave management and payroll import. Includes pseudocode, formulas, and decision tables.

---

## PART 1: LEAVE MANAGEMENT RULES

### 1. Working Days Calculation

#### 1.1 Definition of Working Day

A **working day** is any day that meets ALL of the following conditions:
- Is NOT a Saturday or Sunday
- Is NOT a gazetted public holiday for the employee's work state
- Is NOT a company-defined non-working day (if configured)

#### 1.2 Malaysian Public Holidays

Malaysia has **federal** and **state-specific** public holidays. The calculation must consider the employee's work location state.

| Federal Holidays (All States) | State-Specific Examples |
|------------------------------|-------------------------|
| New Year's Day (1 Jan) | Thaipusam (most states except Sarawak, Sabah) |
| Chinese New Year (2 days) | Deepavali (most states except Sarawak) |
| Hari Raya Aidilfitri (2 days) | Birthday of Sultan (varies by state) |
| Hari Raya Aidiladha | Nuzul Al-Quran (most states) |
| Labour Day (1 May) | Good Friday (Sabah, Sarawak only) |
| Wesak Day | Harvest Festival (Sabah, Labuan) |
| Yang di-Pertuan Agong Birthday | Gawai Dayak (Sarawak) |
| Merdeka Day (31 Aug) | — |
| Malaysia Day (16 Sep) | — |
| Maulidur Rasul | — |
| Christmas Day (25 Dec) | — |

> **⚠️ IMPORTANT:** Islamic holidays (Hari Raya, Maulidur Rasul) vary each year based on lunar calendar and must be updated annually.

#### 1.3 Working Days Calculation Algorithm

```python
FUNCTION calculate_working_days(date_from, date_to, employee_id):
    # Get employee's company and work state
    employee = get_employee(employee_id)
    company_id = employee.company_id
    work_state = employee.state OR employee.company.state
    
    # Get all public holidays for the date range
    holidays = SELECT date FROM kf_public_holiday
               WHERE company_id = company_id
               AND date BETWEEN date_from AND date_to
               AND (state IS NULL OR state = work_state)
    
    working_days = 0
    current_date = date_from
    
    WHILE current_date <= date_to:
        day_of_week = current_date.weekday()  # 0=Mon, 6=Sun
        IF day_of_week NOT IN [5, 6]:  # Not Sat/Sun
            IF current_date NOT IN holidays:
                working_days += 1
        current_date += 1 day
    
    RETURN working_days
```

#### 1.4 Half-Day Calculation

Half-day leave is only allowed when:
- Leave type has `allow_half_day = true`
- Leave request is for a SINGLE day (`date_from = date_to`)
- The day is a working day

| Scenario | half_day_type | Calculation | total_days |
|----------|---------------|-------------|------------|
| Full day single | NULL | 1 working day | 1.0 |
| Morning half | AM | 0.5 working day | 0.5 |
| Afternoon half | PM | 0.5 working day | 0.5 |
| Multi-day | NOT ALLOWED | calculate_working_days() | N days |

---

### 2. Leave Balance Calculation

#### 2.1 Balance Components

| Component | Field | Description |
|-----------|-------|-------------|
| Entitled | entitled | Annual entitlement for the year (may be pro-rated) |
| Carried | carried | Days carried forward from previous year |
| Adjustment | adjustment | Manual adjustments (+ or -) by HR |
| Taken | taken | Days already used (APPROVED leaves that have passed) |
| Pending | pending | Days in PENDING approval status |
| Balance | balance | Available = entitled + carried + adjustment - taken |

> **FORMULA:** `balance = entitled + carried + adjustment - taken`
>
> **NOTE:** The `pending` field is NOT subtracted from balance. It is tracked separately for display purposes. Leave requests validate against `balance - pending` to prevent over-booking.

#### 2.2 Entitlement by Service Years (Malaysian Employment Act 1955)

| Years of Service | Minimum Annual Leave (Days) |
|------------------|----------------------------|
| Less than 2 years | 8 days |
| 2 years to less than 5 years | 12 days |
| 5 years or more | 16 days |

#### 2.3 Medical Leave Entitlement

| Years of Service | Without Hospitalization | With Hospitalization |
|------------------|------------------------|---------------------|
| Less than 2 years | 14 days | 60 days (total) |
| 2 years to less than 5 years | 18 days | 60 days (total) |
| 5 years or more | 22 days | 60 days (total) |

#### 2.4 Pro-Rata Calculation for New Joiners

```python
FUNCTION calculate_prorata_entitlement(employee_id, leave_type_id, year):
    employee = get_employee(employee_id)
    leave_type = get_leave_type(leave_type_id)
    company = get_company(employee.company_id)
    
    # Determine leave year start
    leave_year_start = DATE(year, company.leave_year_start, 1)
    leave_year_end = leave_year_start + 1 year - 1 day
    
    IF employee.join_date < leave_year_start:
        # Full year entitlement
        RETURN leave_type.default_entitlement
    
    IF employee.join_date > leave_year_end:
        # Not yet employed
        RETURN 0
    
    # Pro-rata calculation
    months_remaining = months_between(employee.join_date, leave_year_end)
    monthly_entitlement = leave_type.default_entitlement / 12
    
    # Round to nearest 0.5 (half-up rounding)
    pro_rata = ROUND(monthly_entitlement × months_remaining * 2) / 2
    
    RETURN pro_rata
```

**Examples:**

| Scenario | Calculation |
|----------|-------------|
| Employee joins 1 July | 16 days × (6/12) = 8.0 days |
| Employee joins 15 March | 16 days × (9.5/12) = 12.5 days |
| Employee joins 1 December | 16 days × (1/12) = 1.5 days |

---

### 3. Leave Request Validation Rules

#### 3.1 Validation Sequence

When a leave request is submitted, validations run in this order:

1. Date validity checks
2. Working days calculation
3. Balance sufficiency check
4. Overlap detection
5. Notice period check
6. Attachment requirement check
7. Maximum days per request check

#### 3.2 Validation Rules Detail

**Rule 1: Date Validity**

| Check | Condition | Error Code |
|-------|-----------|------------|
| date_from is valid | date_from is not null and valid date | VALIDATION_ERROR |
| date_to is valid | date_to is not null and valid date | VALIDATION_ERROR |
| date_to >= date_from | End date not before start date | VALIDATION_ERROR |
| Not in past | date_from >= today (for new requests) | VALIDATION_ERROR |

**Rule 2: Working Days > 0**

```python
working_days = calculate_working_days(date_from, date_to, employee_id)
IF working_days == 0:
    RAISE ValidationError('No working days in selected period')
```

**Rule 3: Balance Sufficiency**

```python
FUNCTION check_balance_sufficient(employee_id, leave_type_id, year, requested_days):
    balance = get_balance(employee_id, leave_type_id, year)
    leave_type = get_leave_type(leave_type_id)
    
    available = balance.balance - balance.pending
    
    IF requested_days > available:
        IF leave_type.allow_negative:
            LOG_WARNING('Negative balance will result')
        ELSE:
            RAISE InsufficientBalanceError(
                available=available,
                requested=requested_days
            )
```

**Rule 4: Overlap Detection**

```python
FUNCTION check_no_overlap(employee_id, date_from, date_to, exclude_request_id=None):
    overlapping = SELECT * FROM kf_leave_request
                  WHERE employee_id = employee_id
                  AND status IN ('PENDING', 'APPROVED')
                  AND id != exclude_request_id
                  AND (
                      (date_from BETWEEN request.date_from AND request.date_to)
                      OR (date_to BETWEEN request.date_from AND request.date_to)
                      OR (request.date_from BETWEEN date_from AND date_to)
                  )
    
    IF overlapping.count > 0:
        RAISE LeaveOverlapError(conflicting_request=overlapping[0])
```

**Rule 5: Notice Period**

```python
FUNCTION check_notice_period(leave_type_id, date_from):
    leave_type = get_leave_type(leave_type_id)
    
    IF leave_type.min_days_notice > 0:
        days_until_leave = days_between(today(), date_from)
        IF days_until_leave < leave_type.min_days_notice:
            RAISE InsufficientNoticeError(
                required=leave_type.min_days_notice,
                provided=days_until_leave
            )
```

**Rule 6: Attachment Required**

```python
FUNCTION check_attachment(leave_type_id, attachment_id):
    leave_type = get_leave_type(leave_type_id)
    
    IF leave_type.requires_attachment AND attachment_id IS NULL:
        RAISE AttachmentRequiredError(leave_type=leave_type.name)
```

**Rule 7: Maximum Days Per Request**

```python
FUNCTION check_max_days(leave_type_id, requested_days):
    leave_type = get_leave_type(leave_type_id)
    
    IF leave_type.max_days_per_request IS NOT NULL:
        IF requested_days > leave_type.max_days_per_request:
            RAISE MaxDaysExceededError(
                max_allowed=leave_type.max_days_per_request,
                requested=requested_days
            )
```

---

### 4. Approval Workflow

#### 4.1 State Machine

```
              ┌─────────────┐
    ┌─────────│   PENDING   │─────────┐
    │         └─────────────┘         │
    │ cancel        │        approve  │
    │               │                 │
    ▼               ▼                 ▼
┌─────────────┐  reject   ┌─────────────┐
│  CANCELLED  │◀──────────│  APPROVED   │
└─────────────┘           └─────────────┘
                               │
                               │ cancel (future only)
                               ▼
                          ┌─────────────┐
                          │  CANCELLED  │
                          └─────────────┘
```

#### 4.2 Valid Transitions

| From | To | Triggered By | Condition |
|------|----|--------------| --------- |
| PENDING | APPROVED | Approver | Has approval permission |
| PENDING | REJECTED | Approver | Has approval permission |
| PENDING | CANCELLED | Employee | Own request only |
| APPROVED | CANCELLED | Employee | date_from > today |
| APPROVED | CANCELLED | HR | Any approved leave |

#### 4.3 Approver Determination

```python
FUNCTION get_approvers(employee_id):
    employee = get_employee(employee_id)
    approvers = []
    
    # 1. Direct manager (primary approver)
    IF employee.manager_id IS NOT NULL:
        approvers.append(employee.manager)
    
    # 2. Department head (if different from manager)
    dept = employee.department
    IF dept.manager_id IS NOT NULL AND dept.manager_id != employee.manager_id:
        approvers.append(dept.manager)
    
    # 3. HR can always approve
    hr_users = SELECT user FROM kf_user
               WHERE role IN ('HR_MANAGER', 'HR_EXEC')
               AND company_id = employee.company_id
    approvers.extend(hr_users)
    
    RETURN approvers
```

#### 4.4 Balance Updates on Status Change

| Transition | Balance Update | Logic |
|------------|----------------|-------|
| → PENDING | +pending | pending += total_days |
| PENDING → APPROVED | -pending, +taken* | pending -= total_days; taken += total_days (when leave ends) |
| PENDING → REJECTED | -pending | pending -= total_days |
| PENDING → CANCELLED | -pending | pending -= total_days |
| APPROVED → CANCELLED | -taken* | taken -= total_days (if was already counted) |

> **NOTE:** The `taken` balance is only updated when the leave period has actually passed.

---

## PART 2: PAYROLL IMPORT SPECIFICATION

> **SCOPE:** KerjaFlow does NOT calculate payroll. It imports payslips from external payroll systems for employee viewing.

### 6. Payslip Import Format

#### 6.1 Supported Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| CSV (recommended) | .csv | UTF-8 encoding, comma-delimited |
| Excel | .xlsx | First sheet only, header in row 1 |
| JSON | .json | Array of payslip objects |

#### 6.2 Required Columns

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| employee_no | String | ✓ | Employee ID (must match kf_employee.employee_no) |
| pay_period | String | ✓ | Period in YYYY-MM format (e.g., '2025-01') |
| pay_date | Date | ✓ | Payment date (YYYY-MM-DD) |
| basic_salary | Decimal | ✓ | Basic monthly salary |
| gross_salary | Decimal | ✓ | Total gross earnings |
| total_deductions | Decimal | ✓ | Total deductions |
| net_salary | Decimal | ✓ | Net pay (gross - deductions) |
| epf_employee | Decimal | | Employee EPF contribution |
| epf_employer | Decimal | | Employer EPF contribution |
| socso_employee | Decimal | | Employee SOCSO contribution |
| socso_employer | Decimal | | Employer SOCSO contribution |
| eis_employee | Decimal | | Employee EIS contribution |
| eis_employer | Decimal | | Employer EIS contribution |
| pcb | Decimal | | Monthly tax deduction (PCB) |
| zakat | Decimal | | Zakat deduction |

#### 6.3 Standard Line Item Codes

**Earnings:**

| Code | Description |
|------|-------------|
| BASIC | Basic Salary |
| OT_1_5X | Overtime 1.5x (normal day) |
| OT_2_0X | Overtime 2.0x (rest day) |
| OT_3_0X | Overtime 3.0x (public holiday) |
| ALW_TRANSPORT | Transport Allowance |
| ALW_MEAL | Meal Allowance |
| ALW_PHONE | Phone Allowance |
| ALW_HOUSING | Housing Allowance |
| COMMISSION | Sales Commission |
| BONUS | Bonus Payment |

**Deductions:**

| Code | Description |
|------|-------------|
| EPF_EE | EPF Employee |
| SOCSO_EE | SOCSO Employee |
| EIS_EE | EIS Employee |
| PCB | Monthly Tax Deduction |
| ZAKAT | Zakat |
| LOAN | Company Loan Repayment |
| ADVANCE | Salary Advance Repayment |

---

### 7. Import Validation Rules

| Rule | Check | Error Action |
|------|-------|--------------|
| R1: Employee exists | employee_no exists in kf_employee | Skip row, log error |
| R2: Employee active | employee.status = 'ACTIVE' | Skip row, log warning |
| R3: Period format | pay_period matches YYYY-MM | Skip row, log error |
| R4: Date format | pay_date is valid YYYY-MM-DD | Skip row, log error |
| R5: No duplicate | No existing payslip for employee+period | Skip row, log error |
| R6: Amounts valid | All numeric fields are >= 0 | Skip row, log error |
| R7: Math check | gross - deductions ≈ net (±0.05) | Import with warning |
| R8: Company match | employee.company_id = import company | Skip row, log error |

---

### 8. Payslip Publish Workflow

#### 8.1 Status Lifecycle

```
┌─────────┐  publish  ┌───────────┐  archive  ┌──────────┐
│  DRAFT  │─────────▶│ PUBLISHED │──────────▶│ ARCHIVED │
└─────────┘          └───────────┘           └──────────┘
```

#### 8.2 Publish Process

1. Validate user has HR_MANAGER or HR_EXEC role
2. Get all DRAFT payslips for the period
3. For each payslip:
   - Generate PDF
   - Upload to storage
   - Update status to PUBLISHED
   - Send push notification to employee
4. Log audit trail

---

### 9. Malaysian Statutory Contribution Reference

> **⚠️ REFERENCE ONLY:** These rates are for validation. Always verify with KWSP, PERKESO, and LHDN.

#### 9.1 EPF Contribution Rates (2024)

| Category | Employee | Employer | Age |
|----------|----------|----------|-----|
| Standard (≤ RM5,000) | 11% | 13% | < 60 |
| Standard (> RM5,000) | 11% | 12% | < 60 |
| Above 60 (voluntary) | 0% or 5.5% | 4% | ≥ 60 |
| Foreign Worker | 11% | RM5 flat | Any |

#### 9.2 EIS Contribution Rates

| Applicable To | Employee | Employer |
|---------------|----------|----------|
| All employees (Malaysian) | 0.2% | 0.2% |
| Maximum insurable wage | RM5,000/month | — |

---

*— End of Business Logic Specification —*
