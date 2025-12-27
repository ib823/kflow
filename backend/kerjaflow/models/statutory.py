"""
Statutory Data Models
=====================
Python data models for KerjaFlow ASEAN Statutory Framework
"""

from dataclasses import dataclass, field
from datetime import date
from decimal import Decimal
from enum import Enum
from typing import Optional, List, Dict, Any


class NationalityType(str, Enum):
    """Employee nationality classification"""
    CITIZEN = "CITIZEN"
    PR = "PR"
    FOREIGN = "FOREIGN"
    ALL = "ALL"


class SchemeType(str, Enum):
    """Type of statutory scheme"""
    RETIREMENT = "RETIREMENT"
    SOCIAL_SECURITY = "SOCIAL_SECURITY"
    HEALTH = "HEALTH"
    UNEMPLOYMENT = "UNEMPLOYMENT"
    TAX = "TAX"
    LEVY = "LEVY"
    TRADE_UNION = "TRADE_UNION"


class CalculationMethod(str, Enum):
    """Method used to calculate contributions"""
    PERCENTAGE = "PERCENTAGE"
    TIERED_PERCENTAGE = "TIERED_PERCENTAGE"
    TABLE_LOOKUP = "TABLE_LOOKUP"
    FORMULA = "FORMULA"
    FIXED_AMOUNT = "FIXED_AMOUNT"


class CalculationBase(str, Enum):
    """Wage component used as calculation base"""
    GROSS = "GROSS"
    BASIC = "BASIC"
    BASIC_FIXED_ALLOWANCES = "BASIC_FIXED_ALLOWANCES"
    ORDINARY_WAGES = "ORDINARY_WAGES"
    ADDITIONAL_WAGES = "ADDITIONAL_WAGES"
    TOTAL_WAGES = "TOTAL_WAGES"
    NET_SALARY = "NET_SALARY"


class RoundingMethod(str, Enum):
    """Method for rounding calculated amounts"""
    NEAREST = "NEAREST"
    NEAREST_RINGGIT = "NEAREST_RINGGIT"
    FLOOR = "FLOOR"
    CEILING = "CEILING"


class RiskCategory(str, Enum):
    """Risk categories for Indonesian JKK"""
    VERY_LOW = "VERY_LOW"
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    VERY_HIGH = "VERY_HIGH"


@dataclass
class Country:
    """Country master data"""
    code: str
    name_en: str
    name_local: Optional[str] = None
    currency_code: str = ""
    currency_symbol: str = ""
    currency_decimal_places: int = 2
    default_locale: str = "en"
    timezone: str = "UTC"
    data_residency_required: bool = False


@dataclass
class StatutoryAuthority:
    """Government agency administering statutory contributions"""
    id: int
    country_code: str
    code: str
    name_en: str
    name_local: Optional[str] = None
    acronym: Optional[str] = None
    website_url: Optional[str] = None


@dataclass
class StatutoryScheme:
    """Statutory contribution scheme definition"""
    id: int
    country_code: str
    authority_id: Optional[int]
    code: str
    name_en: str
    name_local: Optional[str] = None
    description: Optional[str] = None
    scheme_type: SchemeType = SchemeType.SOCIAL_SECURITY
    calculation_method: CalculationMethod = CalculationMethod.PERCENTAGE
    calculation_base: CalculationBase = CalculationBase.GROSS

    # Contribution parties
    employee_contribution: bool = True
    employer_contribution: bool = True

    # Applicability
    citizen_applicable: bool = True
    pr_applicable: bool = True
    foreign_worker_applicable: bool = False

    # Administrative
    member_number_required: bool = False
    member_number_label: Optional[str] = None

    # Calculation settings
    rounding_method: RoundingMethod = RoundingMethod.NEAREST
    rounding_precision: int = 2

    # Dates
    effective_from: date = field(default_factory=date.today)
    effective_until: Optional[date] = None

    # Metadata
    legal_reference: Optional[str] = None
    notes: Optional[str] = None


@dataclass
class StatutoryRate:
    """Contribution rate with tier conditions"""
    id: int
    scheme_id: int
    tier_code: str
    tier_description: Optional[str] = None

    # Age conditions
    min_age: Optional[int] = None
    max_age: Optional[int] = None

    # Salary conditions
    min_salary: Optional[Decimal] = None
    max_salary: Optional[Decimal] = None

    # Worker type conditions
    nationality_condition: NationalityType = NationalityType.ALL
    pr_year_condition: Optional[int] = None

    # Industry/risk conditions
    risk_category: Optional[RiskCategory] = None
    employee_count_min: Optional[int] = None
    employee_count_max: Optional[int] = None

    # Rates (use None if not applicable)
    employee_rate: Optional[Decimal] = None
    employer_rate: Optional[Decimal] = None
    employee_fixed: Optional[Decimal] = None
    employer_fixed: Optional[Decimal] = None
    total_rate: Optional[Decimal] = None

    # Validity
    effective_from: date = field(default_factory=date.today)
    effective_until: Optional[date] = None

    # Metadata
    source_reference: Optional[str] = None
    verified_date: Optional[date] = None
    notes: Optional[str] = None


@dataclass
class StatutoryCeiling:
    """Wage ceiling for contribution calculations"""
    id: int
    scheme_id: int
    ceiling_type: str  # MONTHLY, ANNUAL, OW_MONTHLY, AW_ANNUAL, DAILY
    ceiling_amount: Decimal
    min_amount: Optional[Decimal] = None
    effective_from: date = field(default_factory=date.today)
    effective_until: Optional[date] = None


@dataclass
class EmployeeContext:
    """Employee context for statutory calculations"""
    country_code: str
    nationality: NationalityType
    age: int
    gross_salary: Decimal
    basic_salary: Optional[Decimal] = None
    ordinary_wages: Optional[Decimal] = None
    additional_wages: Optional[Decimal] = None

    # Additional context
    pr_years: Optional[int] = None
    risk_category: Optional[RiskCategory] = None
    company_employee_count: Optional[int] = None

    # Date context
    calculation_date: date = field(default_factory=date.today)


@dataclass
class StatutoryContribution:
    """Calculated statutory contribution result"""
    scheme_code: str
    scheme_name: str

    # Calculation details
    calculation_base_amount: Decimal
    applied_salary: Decimal
    capped: bool

    # Contribution amounts
    employee_amount: Decimal
    employer_amount: Decimal
    total_amount: Decimal

    # Rate information
    employee_rate: Optional[Decimal] = None
    employer_rate: Optional[Decimal] = None
    tier_code: Optional[str] = None
    tier_description: Optional[str] = None

    # Metadata
    calculation_method: CalculationMethod = CalculationMethod.PERCENTAGE
    rounding_applied: bool = False
    notes: Optional[str] = None


@dataclass
class ContributionSummary:
    """Summary of all statutory contributions for an employee"""
    country_code: str
    employee_context: EmployeeContext
    contributions: List[StatutoryContribution]

    # Totals
    total_employee_amount: Decimal = Decimal("0.00")
    total_employer_amount: Decimal = Decimal("0.00")
    total_combined_amount: Decimal = Decimal("0.00")

    # Calculation metadata
    calculation_date: date = field(default_factory=date.today)
    calculation_timestamp: Optional[str] = None

    def __post_init__(self):
        """Calculate totals"""
        self.total_employee_amount = sum(
            (c.employee_amount for c in self.contributions),
            Decimal("0.00")
        )
        self.total_employer_amount = sum(
            (c.employer_amount for c in self.contributions),
            Decimal("0.00")
        )
        self.total_combined_amount = self.total_employee_amount + self.total_employer_amount
