# KerjaFlow ASEAN Statutory Framework

Comprehensive statutory contribution calculation engine for 9 ASEAN countries.

## Countries Supported

| Country | Code | Schemes | Status |
|---------|------|---------|--------|
| Malaysia | MY | EPF, SOCSO, EIS, HRDF | ✅ Complete |
| Singapore | SG | CPF, SDL | ✅ Complete |
| Indonesia | ID | BPJS TK, BPJS Kesehatan | ✅ Complete |
| Thailand | TH | SSF | ✅ Complete |
| Philippines | PH | SSS, PhilHealth, Pag-IBIG | ✅ Complete |
| Vietnam | VN | BHXH, Trade Union | ✅ Complete |
| Cambodia | KH | NSSF | ✅ Complete |
| Myanmar | MM | SSB | ✅ Complete |
| Brunei | BN | SPK | ✅ Complete |

## Features

- ✅ **14 SQL migrations** with comprehensive seed data
- ✅ **Date-based rate lookup** (auto-activates future rates)
- ✅ **Age-tiered rates** (Singapore CPF, Malaysia EPF)
- ✅ **Salary-tiered rates** (Brunei SPK, Philippines Pag-IBIG)
- ✅ **Risk-based rates** (Indonesia JKK)
- ✅ **Nationality-based rates** (Vietnam local vs foreign)
- ✅ **Wage ceilings** with automatic application
- ✅ **Phased rate increases** (Cambodia 2027/2032, Thailand 2026/2029/2032, Singapore 2026)
- ✅ **Comprehensive test suite** (95%+ coverage target)
- ✅ **Validation scripts** for all countries

## Quick Start

### 1. Database Setup

```bash
# Set environment variables
export KFLOW_DB_HOST=localhost
export KFLOW_DB_NAME=kerjaflow
export KFLOW_DB_USER=postgres
export KFLOW_DB_PASSWORD=your_password

# Run migrations
make migrate
```

### 2. Install Dependencies

```bash
make setup
```

### 3. Run Tests

```bash
make test
```

### 4. Validate Rates

```bash
make validate
```

## Usage Example

```python
from kerjaflow.services import StatutoryCalculator
from kerjaflow.models import EmployeeContext, NationalityType
from decimal import Decimal
from datetime import date
import psycopg2

# Connect to database
conn = psycopg2.connect(
    host="localhost",
    database="kerjaflow",
    user="postgres",
    password="password"
)

# Create calculator
calculator = StatutoryCalculator(conn)

# Define employee
employee = EmployeeContext(
    country_code="MY",
    nationality=NationalityType.CITIZEN,
    age=30,
    gross_salary=Decimal("5000.00"),
    calculation_date=date(2025, 6, 1)
)

# Calculate all contributions
result = calculator.calculate_all(employee)

# Print results
for contribution in result.contributions:
    print(f"{contribution.scheme_name}:")
    print(f"  Employee: RM{contribution.employee_amount}")
    print(f"  Employer: RM{contribution.employer_amount}")
    print(f"  Total: RM{contribution.total_amount}")

print(f"\nTotal Deductions: RM{result.total_employee_amount}")
print(f"Total Employer: RM{result.total_employer_amount}")
```

## Critical Implementation Details

### Malaysia

- **EPF Foreign Worker Mandate**: Effective Oct 1, 2025 (2% + 2%)
- **EIS Reduction**: Oct 1, 2024 (reduced from 0.4% to 0.2% each)
- **EIS Ceiling Increase**: Oct 1, 2024 (RM4,000 → RM6,000)

### Singapore

- **CPF 2026 Increases**: Senior worker rates increase Jan 1, 2026
- **OW Ceiling Increase**: SGD7,400 (2025) → SGD8,000 (2026)

### Thailand

- **3-Phase Ceiling Increases**:
  - Jan 2026: ฿15,000 → ฿17,500
  - Jan 2029: ฿17,500 → ฿20,000
  - Jan 2032: ฿20,000 → ฿23,000

### Vietnam

- **July 2025 Changes**:
  - BHXH Vietnamese: 10.5% + 21.5% (32% total)
  - BHXH Foreign: 9.5% + 20.5% (30% total, no UI)
  - Trade Union: Reduced from 1% to 0.5%

### Cambodia

- **Phased NSSF Pension Increases**:
  - Phase 1 (Oct 2022-Sep 2027): 4% total
  - Phase 2 (Oct 2027-Sep 2032): 6% total
  - Phase 3 (Oct 2032+): 8% total

## Testing

```bash
# Run all tests
make test

# Generate coverage report
make coverage

# Run specific country tests
pytest kerjaflow/tests/test_malaysia_statutory.py -v
```

## Validation

```bash
# Validate all countries
make validate

# Validate specific country
make validate-my  # Malaysia
make validate-sg  # Singapore
make validate-kh  # Cambodia
```

## Data Verification

All rates verified as of **2025-12-27** against official sources:
- Malaysia: KWSP, PERKESO, EIS
- Singapore: CPF Board
- Indonesia: BPJS TK, BPJS Kesehatan
- Thailand: SSO Thailand, Royal Gazette
- Philippines: SSS, PhilHealth, Pag-IBIG
- Vietnam: VSS
- Cambodia: NSSF Cambodia
- Myanmar: SSB
- Brunei: TAP Board

## License

MIT
