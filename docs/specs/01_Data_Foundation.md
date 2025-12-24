# KerjaFlow Data Foundation Specification

**ERD • Data Dictionary • RBAC Matrix**

Version 1.0 — December 2025

> **PURPOSE:** This document provides everything needed to write database migrations, define ORM models, and implement access controls. A developer can start coding from this specification.

---

## 1. Entity Relationship Diagram

### 1.1 Entity Summary

The KerjaFlow data model consists of 15 core entities organized into 4 domains:

| Domain | Entities | Count |
|--------|----------|-------|
| **Organization** | Company, Department, JobPosition | 3 |
| **Employee** | Employee, User, ForeignWorkerDetail, Document | 4 |
| **Leave** | LeaveType, LeaveBalance, LeaveRequest, PublicHoliday | 4 |
| **Payroll** | Payslip, PayslipLine | 2 |
| **System** | Notification, AuditLog | 2 |

### 1.2 Entity Relationship Diagram (Text Notation)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ORGANIZATION DOMAIN                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  1:N  ┌────────────┐  1:N  ┌───────────┐              │
│  │ Company  │──────▶│ Department │──────▶│ Employee  │              │
│  └──────────┘       └────────────┘       └───────────┘              │
│        │                  │                    │                    │
│        │ 1:N              │ N:1                │                    │
│        ▼                  ▼                    │                    │
│  ┌──────────┐       ┌────────────┐             │                    │
│  │LeaveType │       │JobPosition │◀────────────┘                    │
│  └──────────┘       └────────────┘                                  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         EMPLOYEE DOMAIN                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  1:1  ┌──────┐                                        │
│  │ Employee │◀─────▶│ User │  (login credentials)                   │
│  └──────────┘       └──────┘                                        │
│        │                                                            │
│        │ 1:0..1              1:N                                    │
│        ▼                     ▼                                      │
│  ┌──────────────────┐  ┌──────────┐                                 │
│  │ForeignWorkerDetail│  │ Document │  (IC, passport, MC, permit)    │
│  └──────────────────┘  └──────────┘                                 │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          LEAVE DOMAIN                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐       ┌──────────────┐                                │
│  │ Employee │───1:N───▶│ LeaveBalance │                             │
│  └──────────┘       └──────────────┘                                │
│        │                    ▲                                       │
│        │ 1:N                │ N:1                                   │
│        ▼                    │                                       │
│  ┌──────────────┐     ┌───────────┐                                 │
│  │ LeaveRequest │──N:1──▶│ LeaveType │                              │
│  └──────────────┘     └───────────┘                                 │
│                                                                     │
│  ┌───────────────┐                                                  │
│  │ PublicHoliday │  (per company, per state)                        │
│  └───────────────┘                                                  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         PAYROLL DOMAIN                              │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  1:N  ┌─────────┐  1:N  ┌─────────────┐               │
│  │ Employee │──────▶│ Payslip │──────▶│ PayslipLine │               │
│  └──────────┘       └─────────┘       └─────────────┘               │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.3 Relationship Summary

| Parent Entity | Cardinality | Child Entity | FK Column |
|---------------|-------------|--------------|-----------|
| Company | 1:N | Department | company_id |
| Company | 1:N | JobPosition | company_id |
| Company | 1:N | LeaveType | company_id |
| Company | 1:N | PublicHoliday | company_id |
| Department | 1:N | Employee | department_id |
| JobPosition | 1:N | Employee | job_position_id |
| Employee | 1:N | Employee (reports) | manager_id |
| Employee | 1:1 | User | employee_id |
| Employee | 1:0..1 | ForeignWorkerDetail | employee_id |
| Employee | 1:N | Document | employee_id |
| Employee | 1:N | LeaveBalance | employee_id |
| Employee | 1:N | LeaveRequest | employee_id |
| Employee | 1:N | Payslip | employee_id |
| LeaveType | 1:N | LeaveBalance | leave_type_id |
| LeaveType | 1:N | LeaveRequest | leave_type_id |
| Payslip | 1:N | PayslipLine | payslip_id |

---

## 2. Data Dictionary

All fields with types, constraints, and descriptions. Null = ✓ means nullable, Idx = ✓ means indexed.

### 2.1 Company

*Table:* `kf_company` — Organization/legal entity

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| code | VARCHAR(20) | | UQ | | Unique company code (e.g., 'ACME') |
| name | VARCHAR(200) | | ✓ | | Legal company name |
| registration_no | VARCHAR(50) | ✓ | | | SSM registration number |
| tax_no | VARCHAR(50) | ✓ | | | LHDN tax reference number |
| epf_no | VARCHAR(20) | ✓ | | | EPF employer number |
| socso_no | VARCHAR(20) | ✓ | | | SOCSO employer number |
| eis_no | VARCHAR(20) | ✓ | | | EIS employer number |
| address_line1 | VARCHAR(200) | ✓ | | | Street address line 1 |
| address_line2 | VARCHAR(200) | ✓ | | | Street address line 2 |
| city | VARCHAR(100) | ✓ | | | City |
| state | VARCHAR(50) | ✓ | | | State (for public holidays) |
| postcode | VARCHAR(10) | ✓ | | | Postcode |
| country | VARCHAR(50) | ✓ | | 'Malaysia' | Country (default Malaysia) |
| phone | VARCHAR(20) | ✓ | | | Contact phone |
| email | VARCHAR(100) | ✓ | | | Contact email |
| logo_url | VARCHAR(500) | ✓ | | | Company logo URL |
| leave_year_start | SMALLINT | | | 1 | Month (1-12) when leave year starts |
| timezone | VARCHAR(50) | | | 'Asia/KL' | Timezone for scheduling |
| is_active | BOOLEAN | | | true | Soft delete flag |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.2 Department

*Table:* `kf_department` — Organizational unit within company

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| company_id | BIGINT | | FK | | → kf_company.id |
| code | VARCHAR(20) | | ✓ | | Unique within company |
| name | VARCHAR(200) | | | | Department name |
| parent_id | BIGINT | ✓ | FK | | → kf_department.id (for hierarchy) |
| manager_id | BIGINT | ✓ | FK | | → kf_employee.id (dept head) |
| cost_center | VARCHAR(50) | ✓ | | | Cost center code |
| is_active | BOOLEAN | | | true | Soft delete flag |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

*Unique constraint:* (company_id, code)

### 2.3 JobPosition

*Table:* `kf_job_position` — Job title/role definition

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| company_id | BIGINT | | FK | | → kf_company.id |
| code | VARCHAR(20) | | ✓ | | Unique within company |
| name | VARCHAR(200) | | | | Job title (e.g., 'Senior Engineer') |
| description | TEXT | ✓ | | | Job description |
| grade | VARCHAR(20) | ✓ | | | Salary grade code |
| is_active | BOOLEAN | | | true | Soft delete flag |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.4 Employee

*Table:* `kf_employee` — Core employee master data

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| company_id | BIGINT | | FK,✓ | | → kf_company.id |
| department_id | BIGINT | ✓ | FK | | → kf_department.id |
| job_position_id | BIGINT | ✓ | FK | | → kf_job_position.id |
| manager_id | BIGINT | ✓ | FK | | → kf_employee.id (reporting mgr) |
| employee_no | VARCHAR(20) | | UQ | | Employee ID (unique per company) |
| badge_id | VARCHAR(20) | ✓ | ✓ | | Badge/access card ID |
| full_name | VARCHAR(200) | | ✓ | | Full name as per IC |
| preferred_name | VARCHAR(100) | ✓ | | | Preferred/call name |
| ic_no | VARCHAR(20) | ✓ | UQ | | MyKad IC number |
| passport_no | VARCHAR(20) | ✓ | ✓ | | Passport number (if foreign) |
| date_of_birth | DATE | ✓ | | | Date of birth |
| gender | VARCHAR(10) | ✓ | | | M/F/Other |
| marital_status | VARCHAR(20) | ✓ | | | Single/Married/Divorced/Widowed |
| nationality | VARCHAR(50) | | | 'Malaysian' | Nationality |
| race | VARCHAR(50) | ✓ | | | Malay/Chinese/Indian/Other |
| religion | VARCHAR(50) | ✓ | | | Religion |
| email | VARCHAR(100) | ✓ | ✓ | | Personal email |
| work_email | VARCHAR(100) | ✓ | ✓ | | Work email |
| mobile_phone | VARCHAR(20) | ✓ | ✓ | | Mobile number (for OTP) |
| address_line1 | VARCHAR(200) | ✓ | | | Home address line 1 |
| address_line2 | VARCHAR(200) | ✓ | | | Home address line 2 |
| city | VARCHAR(100) | ✓ | | | City |
| state | VARCHAR(50) | ✓ | | | State |
| postcode | VARCHAR(10) | ✓ | | | Postcode |
| emergency_name | VARCHAR(200) | ✓ | | | Emergency contact name |
| emergency_phone | VARCHAR(20) | ✓ | | | Emergency contact phone |
| emergency_relation | VARCHAR(50) | ✓ | | | Relationship (Spouse/Parent/etc) |
| employment_type | VARCHAR(20) | | | 'PERMANENT' | PERMANENT/CONTRACT/PARTTIME/INTERN |
| join_date | DATE | | | | First day of employment |
| confirm_date | DATE | ✓ | | | Confirmation date (if confirmed) |
| resign_date | DATE | ✓ | ✓ | | Last working day (if resigned) |
| probation_months | SMALLINT | | | 3 | Probation period in months |
| work_location | VARCHAR(100) | ✓ | | | Work location/site name |
| epf_no | VARCHAR(20) | ✓ | | | EPF member number |
| socso_no | VARCHAR(20) | ✓ | | | SOCSO member number |
| eis_no | VARCHAR(20) | ✓ | | | EIS number |
| tax_no | VARCHAR(20) | ✓ | | | LHDN income tax number |
| tax_category | VARCHAR(10) | ✓ | | | PCB category (1/2/3) |
| tax_resident | BOOLEAN | | | true | Malaysian tax resident status |
| epf_rate_employee | DECIMAL(5,2) | ✓ | | 11.00 | Employee EPF rate % |
| epf_rate_employer | DECIMAL(5,2) | ✓ | | | Employer EPF rate % (age-based) |
| bank_name | VARCHAR(100) | ✓ | | | Bank name |
| bank_account_no | VARCHAR(30) | ✓ | | | Bank account number |
| bank_account_name | VARCHAR(200) | ✓ | | | Account holder name |
| photo_url | VARCHAR(500) | ✓ | | | Profile photo URL |
| status | VARCHAR(20) | | | 'ACTIVE' | ACTIVE/INACTIVE/RESIGNED/TERMINATED |
| preferred_lang | VARCHAR(10) | | | 'en' | Preferred language code |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

*Unique constraint:* (company_id, employee_no)

### 2.5 User

*Table:* `kf_user` — Authentication & authorization

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,UQ | | → kf_employee.id (1:1) |
| username | VARCHAR(100) | | UQ | | Login username (usually email) |
| password_hash | VARCHAR(255) | | | | bcrypt password hash |
| pin_hash | VARCHAR(255) | ✓ | | | 6-digit PIN hash (mobile app) |
| role | VARCHAR(30) | | | 'EMPLOYEE' | ADMIN/HR_MANAGER/HR_EXEC/SUPERVISOR/EMPLOYEE |
| is_active | BOOLEAN | | | true | Can login? |
| last_login_at | TIMESTAMPTZ | ✓ | | | Last successful login |
| failed_attempts | SMALLINT | | | 0 | Failed login count (reset on success) |
| locked_until | TIMESTAMPTZ | ✓ | | | Account locked until (if too many fails) |
| fcm_token | VARCHAR(255) | ✓ | | | Firebase Cloud Messaging token |
| device_id | VARCHAR(100) | ✓ | | | Last known device ID |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.6 ForeignWorkerDetail

*Table:* `kf_foreign_worker_detail` — Foreign worker permit tracking

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,UQ | | → kf_employee.id (1:1) |
| passport_no | VARCHAR(20) | | ✓ | | Passport number |
| passport_expiry | DATE | | ✓ | | Passport expiry date |
| passport_country | VARCHAR(50) | | | | Issuing country |
| permit_no | VARCHAR(30) | | ✓ | | Work permit number |
| permit_type | VARCHAR(50) | | | | VP(TE)/PVP/Pas Lawatan etc |
| permit_issue_date | DATE | ✓ | | | Permit issue date |
| permit_expiry | DATE | | ✓ | | Permit expiry date |
| employer_on_permit | VARCHAR(200) | ✓ | | | Employer name on permit |
| levy_paid_until | DATE | ✓ | | | Levy paid until date |
| fomema_status | VARCHAR(20) | ✓ | | | FIT/UNFIT/PENDING |
| fomema_date | DATE | ✓ | | | Last FOMEMA date |
| immigration_ref | VARCHAR(50) | ✓ | | | Immigration reference number |
| notes | TEXT | ✓ | | | Additional notes |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.7 Document

*Table:* `kf_document` — Employee documents (IC, MC, permits)

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,✓ | | → kf_employee.id |
| doc_type | VARCHAR(30) | | ✓ | | IC/PASSPORT/PERMIT/MC/CERT/OTHER |
| doc_name | VARCHAR(200) | | | | Display name |
| file_url | VARCHAR(500) | | | | Storage URL (S3/local) |
| file_size | INTEGER | ✓ | | | File size in bytes |
| mime_type | VARCHAR(100) | ✓ | | | MIME type (image/jpeg, etc) |
| issue_date | DATE | ✓ | | | Document issue date |
| expiry_date | DATE | ✓ | ✓ | | Document expiry date (for alerts) |
| ocr_text | TEXT | ✓ | | | Extracted text from OCR (Phase 2) |
| ocr_status | VARCHAR(20) | ✓ | | | PENDING/COMPLETED/FAILED |
| uploaded_by | BIGINT | ✓ | FK | | → kf_user.id |
| verified_by | BIGINT | ✓ | FK | | → kf_user.id (HR who verified) |
| verified_at | TIMESTAMPTZ | ✓ | | | Verification timestamp |
| notes | TEXT | ✓ | | | Additional notes |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.8 LeaveType

*Table:* `kf_leave_type` — Leave type configuration

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| company_id | BIGINT | | FK,✓ | | → kf_company.id |
| code | VARCHAR(20) | | | | Short code (AL, MC, etc) |
| name | VARCHAR(100) | | | | Display name |
| description | TEXT | ✓ | | | Description for employees |
| is_paid | BOOLEAN | | | true | Paid leave? |
| is_deductible | BOOLEAN | | | true | Deducts from balance? |
| requires_attachment | BOOLEAN | | | false | Requires document (e.g., MC)? |
| default_entitlement | DECIMAL(5,2) | | | 0 | Default annual days |
| max_days_per_request | DECIMAL(5,2) | ✓ | | | Max days per single request |
| min_days_notice | SMALLINT | | | 0 | Min days advance notice required |
| allow_half_day | BOOLEAN | | | true | Allow 0.5 day requests? |
| allow_negative | BOOLEAN | | | false | Allow negative balance? |
| max_carry_forward | DECIMAL(5,2) | ✓ | | | Max days can carry to next year |
| carry_forward_expiry | SMALLINT | ✓ | | | Months until carried days expire |
| gender_restriction | VARCHAR(10) | ✓ | | | M/F/null (for maternity etc) |
| color | VARCHAR(7) | ✓ | | '#4CAF50' | Calendar color (hex) |
| sort_order | SMALLINT | | | 0 | Display order |
| is_active | BOOLEAN | | | true | Available for use? |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.9 LeaveBalance

*Table:* `kf_leave_balance` — Employee leave balance per type per year

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,✓ | | → kf_employee.id |
| leave_type_id | BIGINT | | FK,✓ | | → kf_leave_type.id |
| year | SMALLINT | | ✓ | | Leave year (e.g., 2025) |
| entitled | DECIMAL(5,2) | | | 0 | Total entitled days this year |
| carried | DECIMAL(5,2) | | | 0 | Days carried from prev year |
| adjustment | DECIMAL(5,2) | | | 0 | Manual adjustments (+/-) |
| taken | DECIMAL(5,2) | | | 0 | Days used (approved leave) |
| pending | DECIMAL(5,2) | | | 0 | Days pending approval |
| balance | DECIMAL(5,2) | | | 0 | Available = entitled+carried+adj-taken |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

*Unique constraint:* (employee_id, leave_type_id, year)

### 2.10 LeaveRequest

*Table:* `kf_leave_request` — Leave application transactions

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,✓ | | → kf_employee.id |
| leave_type_id | BIGINT | | FK,✓ | | → kf_leave_type.id |
| date_from | DATE | | ✓ | | Leave start date |
| date_to | DATE | | ✓ | | Leave end date |
| half_day_type | VARCHAR(10) | ✓ | | | AM/PM (if half day) |
| total_days | DECIMAL(5,2) | | | | Calculated working days |
| reason | TEXT | ✓ | | | Reason for leave |
| attachment_id | BIGINT | ✓ | FK | | → kf_document.id (MC etc) |
| status | VARCHAR(20) | | | 'PENDING' | PENDING/APPROVED/REJECTED/CANCELLED |
| submitted_at | TIMESTAMPTZ | | | NOW() | When request was submitted |
| approver_id | BIGINT | ✓ | FK | | → kf_employee.id (who will approve) |
| approved_at | TIMESTAMPTZ | ✓ | | | Approval/rejection timestamp |
| approved_by | BIGINT | ✓ | FK | | → kf_user.id (who actually approved) |
| rejection_reason | TEXT | ✓ | | | Reason if rejected |
| cancelled_at | TIMESTAMPTZ | ✓ | | | Cancellation timestamp |
| cancel_reason | TEXT | ✓ | | | Reason for cancellation |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

### 2.11 PublicHoliday

*Table:* `kf_public_holiday` — Public holidays by company/state

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| company_id | BIGINT | | FK,✓ | | → kf_company.id |
| date | DATE | | ✓ | | Holiday date |
| name | VARCHAR(200) | | | | Holiday name |
| name_ms | VARCHAR(200) | ✓ | | | Name in Malay |
| state | VARCHAR(50) | ✓ | | | Applicable state (null = all) |
| is_replacement | BOOLEAN | | | false | Replacement holiday? |
| year | SMALLINT | | ✓ | | Year for quick filtering |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

*Unique constraint:* (company_id, date, state)

### 2.12 Payslip

*Table:* `kf_payslip` — Monthly payslip header

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| employee_id | BIGINT | | FK,✓ | | → kf_employee.id |
| pay_period | VARCHAR(7) | | ✓ | | Period (YYYY-MM format) |
| pay_date | DATE | | ✓ | | Payment date |
| gross_salary | DECIMAL(12,2) | | | | Total gross |
| total_deductions | DECIMAL(12,2) | | | | Total deductions |
| net_salary | DECIMAL(12,2) | | | | Net pay |
| epf_employee | DECIMAL(10,2) | | | 0 | Employee EPF contribution |
| epf_employer | DECIMAL(10,2) | | | 0 | Employer EPF contribution |
| socso_employee | DECIMAL(10,2) | | | 0 | Employee SOCSO |
| socso_employer | DECIMAL(10,2) | | | 0 | Employer SOCSO |
| eis_employee | DECIMAL(10,2) | | | 0 | Employee EIS |
| eis_employer | DECIMAL(10,2) | | | 0 | Employer EIS |
| pcb | DECIMAL(10,2) | | | 0 | Monthly tax deduction |
| zakat | DECIMAL(10,2) | | | 0 | Zakat deduction |
| pdf_url | VARCHAR(500) | ✓ | | | Generated PDF URL |
| status | VARCHAR(20) | | | 'DRAFT' | DRAFT/PUBLISHED/ARCHIVED |
| published_at | TIMESTAMPTZ | ✓ | | | When made visible to employee |
| viewed_at | TIMESTAMPTZ | ✓ | | | When employee first viewed |
| imported_from | VARCHAR(100) | ✓ | | | Source system/file name |
| imported_at | TIMESTAMPTZ | ✓ | | | Import timestamp |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |
| updated_at | TIMESTAMPTZ | | | NOW() | Last update time |

*Unique constraint:* (employee_id, pay_period)

### 2.13 PayslipLine

*Table:* `kf_payslip_line` — Payslip line items (earnings/deductions)

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| payslip_id | BIGINT | | FK,✓ | | → kf_payslip.id |
| line_type | VARCHAR(20) | | | | EARNING/DEDUCTION/INFO |
| code | VARCHAR(30) | | | | Code (BASIC, OT, ALLOWANCE, etc) |
| description | VARCHAR(200) | | | | Display description |
| quantity | DECIMAL(10,2) | ✓ | | | Hours/units (for OT etc) |
| rate | DECIMAL(10,2) | ✓ | | | Rate per unit |
| amount | DECIMAL(12,2) | | | | Line amount (+earnings, -deductions) |
| sort_order | SMALLINT | | | 0 | Display order on payslip |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |

### 2.14 Notification

*Table:* `kf_notification` — Push notifications and in-app messages

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| user_id | BIGINT | | FK,✓ | | → kf_user.id (recipient) |
| type | VARCHAR(30) | | ✓ | | PAYSLIP/LEAVE/PERMIT/SYSTEM |
| title | VARCHAR(200) | | | | Notification title |
| body | TEXT | | | | Notification body |
| data | JSONB | ✓ | | | Additional payload (deep link etc) |
| is_read | BOOLEAN | | | false | Has user read it? |
| read_at | TIMESTAMPTZ | ✓ | | | When read |
| fcm_sent | BOOLEAN | | | false | Push notification sent? |
| fcm_sent_at | TIMESTAMPTZ | ✓ | | | When push was sent |
| fcm_error | TEXT | ✓ | | | FCM error message if failed |
| created_at | TIMESTAMPTZ | | | NOW() | Record creation time |

### 2.15 AuditLog

*Table:* `kf_audit_log` — Security and compliance audit trail

| Field | Type | Null | Idx | Default | Description |
|-------|------|------|-----|---------|-------------|
| id | BIGSERIAL | | PK | | Primary key |
| user_id | BIGINT | ✓ | FK,✓ | | → kf_user.id (who performed action) |
| action | VARCHAR(50) | | ✓ | | CREATE/UPDATE/DELETE/LOGIN/LOGOUT/VIEW |
| entity_type | VARCHAR(50) | | ✓ | | Table name (e.g., 'kf_employee') |
| entity_id | BIGINT | ✓ | ✓ | | Record ID affected |
| old_values | JSONB | ✓ | | | Previous values (for UPDATE) |
| new_values | JSONB | ✓ | | | New values (for CREATE/UPDATE) |
| ip_address | INET | ✓ | | | Client IP address |
| user_agent | VARCHAR(500) | ✓ | | | Browser/app user agent |
| request_id | VARCHAR(50) | ✓ | | | Request correlation ID |
| created_at | TIMESTAMPTZ | | | NOW() | Event timestamp |

*Indexes:* (user_id, created_at), (entity_type, entity_id), (created_at)

---

## 3. RBAC Matrix

Role-Based Access Control defines what each role can see (R) and do (CRUD). Scope: **O**=Own, **D**=Department, **C**=Company, **---**=No access

### 3.1 System Roles

| Role | Description |
|------|-------------|
| **ADMIN** | System administrator. Full access to all data and configuration. Typically IT department. |
| **HR_MANAGER** | HR Department Head. Company-wide access to all HR data. Can configure leave types, publish payslips. |
| **HR_EXEC** | HR Executive. Company-wide read access. Can create/update employees, process leave. Cannot configure system. |
| **SUPERVISOR** | Line manager. Can view and approve leave for direct reports. Cannot access payslips of reports. |
| **EMPLOYEE** | Regular employee. Can only view/edit own profile, own payslips, own leave. Default role. |

### 3.2 Permission Matrix by Entity

#### Employee Data

| Permission | ADMIN | HR_MGR | HR_EXEC | SUPV | EMP |
|------------|-------|--------|---------|------|-----|
| View employee list | C | C | C | D | O |
| View personal details | C | C | C | --- | O |
| View statutory info (EPF, tax) | C | C | C | --- | O |
| View banking info | C | C | --- | --- | O |
| Create employee | ✓ | ✓ | ✓ | --- | --- |
| Edit own profile | ✓ | ✓ | ✓ | ✓ | ✓* |
| Edit any employee | ✓ | ✓ | ✓ | --- | --- |
| Deactivate employee | ✓ | ✓ | --- | --- | --- |

*\* Employee can edit: phone, email, address, emergency contact, photo. Cannot edit: statutory, banking, employment details.*

#### Leave Management

| Permission | ADMIN | HR_MGR | HR_EXEC | SUPV | EMP |
|------------|-------|--------|---------|------|-----|
| Configure leave types | ✓ | ✓ | --- | --- | --- |
| View leave balances | C | C | C | D | O |
| Adjust leave balance | ✓ | ✓ | ✓ | --- | --- |
| Apply for leave | O | O | O | O | O |
| View leave requests | C | C | C | D† | O |
| Approve/reject leave | C | C | C | D† | --- |
| Cancel own leave | ✓ | ✓ | ✓ | ✓ | ✓ |

*† Supervisor can only view/approve direct reports (employee.manager_id = supervisor.employee_id)*

#### Payslip Management

| Permission | ADMIN | HR_MGR | HR_EXEC | SUPV | EMP |
|------------|-------|--------|---------|------|-----|
| Import payslips | ✓ | ✓ | ✓ | --- | --- |
| Publish payslips | ✓ | ✓ | --- | --- | --- |
| View any payslip | C | C | C | --- | --- |
| View own payslip | ✓ | ✓ | ✓ | ✓ | ✓ |
| Download payslip PDF | C | C | C | O | O |
| View reports payslip | --- | --- | --- | --- | --- |

*Note: Supervisors cannot view their direct reports' payslips. Payslip data is highly confidential.*

#### System Administration

| Permission | ADMIN | HR_MGR | HR_EXEC | SUPV | EMP |
|------------|-------|--------|---------|------|-----|
| Manage company settings | ✓ | --- | --- | --- | --- |
| Manage departments | ✓ | ✓ | --- | --- | --- |
| Manage job positions | ✓ | ✓ | --- | --- | --- |
| Manage public holidays | ✓ | ✓ | ✓ | --- | --- |
| Manage user accounts | ✓ | ✓ | --- | --- | --- |
| View audit logs | ✓ | ✓ | --- | --- | --- |
| Reset user password | ✓ | ✓ | ✓ | --- | --- |

---

## 4. Index Definitions

Required database indexes for performance. All foreign keys should have indexes (standard practice).

| Table | Index Columns | Purpose |
|-------|---------------|---------|
| kf_employee | (company_id, status) | Active employees per company |
| kf_employee | (manager_id) | Find direct reports |
| kf_employee | (resign_date) WHERE resign_date > NOW() | Upcoming leavers |
| kf_foreign_worker_detail | (permit_expiry) | Expiry alerts |
| kf_foreign_worker_detail | (passport_expiry) | Passport expiry alerts |
| kf_document | (expiry_date) WHERE expiry_date IS NOT NULL | Document expiry alerts |
| kf_leave_request | (approver_id, status) | Pending approvals queue |
| kf_leave_request | (employee_id, date_from, date_to) | Calendar view |
| kf_payslip | (employee_id, pay_period) | Payslip lookup (UNIQUE) |
| kf_notification | (user_id, is_read, created_at DESC) | Unread notifications |
| kf_audit_log | (created_at DESC) | Recent activity |
| kf_audit_log | (entity_type, entity_id) | Record history |

---

*— End of Data Foundation Specification —*
