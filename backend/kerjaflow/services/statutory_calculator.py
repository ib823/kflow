"""
Statutory Calculator Service
============================
Core calculation engine for ASEAN statutory contributions
"""

from datetime import date
from decimal import Decimal, ROUND_HALF_UP, ROUND_DOWN, ROUND_UP
from typing import List, Optional, Dict, Any
import logging

from ..models.statutory import (
    StatutoryScheme,
    StatutoryRate,
    StatutoryCeiling,
    StatutoryContribution,
    ContributionSummary,
    EmployeeContext,
    NationalityType,
    CalculationMethod,
    RoundingMethod,
    RiskCategory,
)

logger = logging.getLogger(__name__)


class StatutoryCalculator:
    """
    Statutory contribution calculator for 9 ASEAN countries

    Features:
    - Date-based rate lookup
    - Tiered rates (age, salary, nationality, risk)
    - Wage ceilings
    - Multiple rounding methods
    - Comprehensive logging
    """

    def __init__(self, db_connection):
        """
        Initialize calculator with database connection

        Args:
            db_connection: Database connection object (psycopg2 or similar)
        """
        self.db = db_connection

    def calculate_all(
        self,
        employee: EmployeeContext,
        calculation_date: Optional[date] = None
    ) -> ContributionSummary:
        """
        Calculate ALL statutory contributions for an employee

        Args:
            employee: Employee context with salary and demographics
            calculation_date: Date for rate lookup (defaults to today)

        Returns:
            ContributionSummary with all applicable contributions
        """
        if calculation_date is None:
            calculation_date = employee.calculation_date or date.today()

        # Get all applicable schemes for this country
        schemes = self._get_applicable_schemes(
            employee.country_code,
            employee.nationality,
            calculation_date
        )

        contributions = []
        for scheme in schemes:
            try:
                contribution = self.calculate_scheme(employee, scheme, calculation_date)
                if contribution:
                    contributions.append(contribution)
            except Exception as e:
                logger.error(
                    f"Failed to calculate {scheme.code} for {employee.country_code}: {e}"
                )
                continue

        return ContributionSummary(
            country_code=employee.country_code,
            employee_context=employee,
            contributions=contributions,
            calculation_date=calculation_date
        )

    def calculate_scheme(
        self,
        employee: EmployeeContext,
        scheme: StatutoryScheme,
        calculation_date: date
    ) -> Optional[StatutoryContribution]:
        """
        Calculate contribution for a single scheme

        Args:
            employee: Employee context
            scheme: Statutory scheme definition
            calculation_date: Calculation date

        Returns:
            StatutoryContribution or None if not applicable
        """
        # Get calculation base amount
        base_amount = self._get_calculation_base(employee, scheme)

        # Apply ceiling if exists
        ceiling = self._get_ceiling(scheme.id, calculation_date)
        applied_salary = base_amount
        capped = False

        if ceiling:
            if base_amount > ceiling.ceiling_amount:
                applied_salary = ceiling.ceiling_amount
                capped = True

        # Find matching rate tier
        rate = self._find_matching_rate(
            scheme.id,
            employee,
            calculation_date
        )

        if not rate:
            logger.warning(
                f"No matching rate found for {scheme.code} "
                f"(age={employee.age}, nationality={employee.nationality})"
            )
            return None

        # Calculate amounts based on method
        if scheme.calculation_method == CalculationMethod.PERCENTAGE:
            employee_amount, employer_amount = self._calculate_percentage(
                applied_salary, rate
            )
        elif scheme.calculation_method == CalculationMethod.TIERED_PERCENTAGE:
            employee_amount, employer_amount = self._calculate_tiered_percentage(
                applied_salary, rate, employee, scheme
            )
        elif scheme.calculation_method == CalculationMethod.TABLE_LOOKUP:
            employee_amount, employer_amount = self._calculate_table_lookup(
                base_amount, scheme, calculation_date
            )
        else:
            logger.error(f"Unsupported calculation method: {scheme.calculation_method}")
            return None

        # Apply rounding
        employee_amount = self._apply_rounding(
            employee_amount,
            scheme.rounding_method,
            scheme.rounding_precision
        )
        employer_amount = self._apply_rounding(
            employer_amount,
            scheme.rounding_method,
            scheme.rounding_precision
        )

        return StatutoryContribution(
            scheme_code=scheme.code,
            scheme_name=scheme.name_en,
            calculation_base_amount=base_amount,
            applied_salary=applied_salary,
            capped=capped,
            employee_amount=employee_amount,
            employer_amount=employer_amount,
            total_amount=employee_amount + employer_amount,
            employee_rate=rate.employee_rate,
            employer_rate=rate.employer_rate,
            tier_code=rate.tier_code,
            tier_description=rate.tier_description,
            calculation_method=scheme.calculation_method,
            rounding_applied=True
        )

    def _get_applicable_schemes(
        self,
        country_code: str,
        nationality: NationalityType,
        calculation_date: date
    ) -> List[StatutoryScheme]:
        """Get all applicable schemes for country and nationality"""
        cursor = self.db.cursor()

        # Build nationality filter
        nationality_filter = ""
        if nationality == NationalityType.CITIZEN:
            nationality_filter = "AND citizen_applicable = true"
        elif nationality == NationalityType.PR:
            nationality_filter = "AND pr_applicable = true"
        elif nationality == NationalityType.FOREIGN:
            nationality_filter = "AND foreign_worker_applicable = true"

        query = f"""
            SELECT
                id, country_id, authority_id, code, name_en, name_local,
                description, scheme_type, calculation_method, calculation_base,
                employee_contribution, employer_contribution,
                citizen_applicable, pr_applicable, foreign_worker_applicable,
                member_number_required, member_number_label,
                rounding_method, rounding_precision,
                effective_from, effective_until, legal_reference, notes
            FROM kf_statutory_scheme
            WHERE country_id = (SELECT id FROM kf_country WHERE code = %s)
              AND effective_from <= %s
              AND (effective_until IS NULL OR effective_until >= %s)
              AND is_active = true
              {nationality_filter}
            ORDER BY sort_order, code
        """

        cursor.execute(query, (country_code, calculation_date, calculation_date))
        rows = cursor.fetchall()

        schemes = []
        for row in rows:
            # Parse row into StatutoryScheme object
            scheme = self._parse_scheme_row(row)
            schemes.append(scheme)

        cursor.close()
        return schemes

    def _find_matching_rate(
        self,
        scheme_id: int,
        employee: EmployeeContext,
        calculation_date: date
    ) -> Optional[StatutoryRate]:
        """
        Find the matching rate tier for an employee

        Matches on:
        - Age range
        - Salary range
        - Nationality
        - Risk category
        - Employee count
        """
        cursor = self.db.cursor()

        query = """
            SELECT
                id, scheme_id, tier_code, tier_description,
                min_age, max_age, min_salary, max_salary,
                nationality_condition, pr_year_condition,
                risk_category, employee_count_min, employee_count_max,
                employee_rate, employer_rate, employee_fixed, employer_fixed, total_rate,
                effective_from, effective_until,
                source_reference, verified_date, notes
            FROM kf_statutory_rate
            WHERE scheme_id = %s
              AND effective_from <= %s
              AND (effective_until IS NULL OR effective_until >= %s)
              AND (min_age IS NULL OR min_age <= %s)
              AND (max_age IS NULL OR max_age >= %s)
              AND (min_salary IS NULL OR min_salary <= %s)
              AND (max_salary IS NULL OR max_salary >= %s)
              AND (nationality_condition = 'ALL' OR nationality_condition = %s)
              AND (risk_category IS NULL OR risk_category = %s)
              AND (employee_count_min IS NULL OR employee_count_min <= %s)
              AND (employee_count_max IS NULL OR employee_count_max >= %s)
            ORDER BY
                -- Prioritize more specific matches
                CASE WHEN min_age IS NOT NULL THEN 1 ELSE 2 END,
                CASE WHEN min_salary IS NOT NULL THEN 1 ELSE 2 END,
                CASE WHEN nationality_condition != 'ALL' THEN 1 ELSE 2 END,
                effective_from DESC
            LIMIT 1
        """

        cursor.execute(query, (
            scheme_id,
            calculation_date,
            calculation_date,
            employee.age,
            employee.age,
            employee.gross_salary,
            employee.gross_salary,
            employee.nationality.value if employee.nationality else 'ALL',
            employee.risk_category.value if employee.risk_category else None,
            employee.company_employee_count or 0,
            employee.company_employee_count or 999999
        ))

        row = cursor.fetchone()
        cursor.close()

        if not row:
            return None

        return self._parse_rate_row(row)

    def _get_ceiling(
        self,
        scheme_id: int,
        calculation_date: date,
        ceiling_type: str = "MONTHLY"
    ) -> Optional[StatutoryCeiling]:
        """Get wage ceiling for a scheme"""
        cursor = self.db.cursor()

        query = """
            SELECT id, scheme_id, ceiling_type, ceiling_amount, min_amount,
                   effective_from, effective_until
            FROM kf_statutory_ceiling
            WHERE scheme_id = %s
              AND ceiling_type = %s
              AND effective_from <= %s
              AND (effective_until IS NULL OR effective_until >= %s)
            ORDER BY effective_from DESC
            LIMIT 1
        """

        cursor.execute(query, (scheme_id, ceiling_type, calculation_date, calculation_date))
        row = cursor.fetchone()
        cursor.close()

        if not row:
            return None

        return StatutoryCeiling(
            id=row[0],
            scheme_id=row[1],
            ceiling_type=row[2],
            ceiling_amount=Decimal(str(row[3])),
            min_amount=Decimal(str(row[4])) if row[4] else None,
            effective_from=row[5],
            effective_until=row[6]
        )

    def _get_calculation_base(
        self,
        employee: EmployeeContext,
        scheme: StatutoryScheme
    ) -> Decimal:
        """Get the wage amount to use as calculation base"""
        if scheme.calculation_base.value == "GROSS":
            return employee.gross_salary
        elif scheme.calculation_base.value == "BASIC":
            return employee.basic_salary or employee.gross_salary
        elif scheme.calculation_base.value == "ORDINARY_WAGES":
            return employee.ordinary_wages or employee.gross_salary
        elif scheme.calculation_base.value == "ADDITIONAL_WAGES":
            return employee.additional_wages or Decimal("0.00")
        else:
            return employee.gross_salary

    def _calculate_percentage(
        self,
        salary: Decimal,
        rate: StatutoryRate
    ) -> tuple[Decimal, Decimal]:
        """Calculate using simple percentage rates"""
        employee_amount = Decimal("0.00")
        employer_amount = Decimal("0.00")

        if rate.employee_rate:
            employee_amount = salary * rate.employee_rate

        if rate.employer_rate:
            employer_amount = salary * rate.employer_rate

        # Handle fixed amounts
        if rate.employee_fixed:
            employee_amount = rate.employee_fixed

        if rate.employer_fixed:
            employer_amount = rate.employer_fixed

        return employee_amount, employer_amount

    def _calculate_tiered_percentage(
        self,
        salary: Decimal,
        rate: StatutoryRate,
        employee: EmployeeContext,
        scheme: StatutoryScheme
    ) -> tuple[Decimal, Decimal]:
        """Calculate using tiered percentage (same as percentage for most cases)"""
        # For most countries, tiered percentage works the same as percentage
        # The tier matching happens in _find_matching_rate
        return self._calculate_percentage(salary, rate)

    def _calculate_table_lookup(
        self,
        salary: Decimal,
        scheme: StatutoryScheme,
        calculation_date: date
    ) -> tuple[Decimal, Decimal]:
        """Calculate using SOCSO-style table lookup"""
        cursor = self.db.cursor()

        query = """
            SELECT employee_amount, employer_amount
            FROM kf_statutory_table_lookup
            WHERE scheme_id = %s
              AND wage_from <= %s
              AND wage_to >= %s
              AND effective_from <= %s
              AND (effective_until IS NULL OR effective_until >= %s)
            ORDER BY effective_from DESC
            LIMIT 1
        """

        cursor.execute(query, (
            scheme.id,
            salary,
            salary,
            calculation_date,
            calculation_date
        ))

        row = cursor.fetchone()
        cursor.close()

        if not row:
            logger.warning(f"No table lookup found for salary {salary} in {scheme.code}")
            return Decimal("0.00"), Decimal("0.00")

        return Decimal(str(row[0])), Decimal(str(row[1]))

    def _apply_rounding(
        self,
        amount: Decimal,
        method: RoundingMethod,
        precision: int
    ) -> Decimal:
        """Apply rounding based on method"""
        if method == RoundingMethod.NEAREST:
            return amount.quantize(
                Decimal(10) ** -precision,
                rounding=ROUND_HALF_UP
            )
        elif method == RoundingMethod.FLOOR:
            return amount.quantize(
                Decimal(10) ** -precision,
                rounding=ROUND_DOWN
            )
        elif method == RoundingMethod.CEILING:
            return amount.quantize(
                Decimal(10) ** -precision,
                rounding=ROUND_UP
            )
        elif method == RoundingMethod.NEAREST_RINGGIT:
            # Round to nearest whole number (for Malaysia)
            return amount.quantize(Decimal("1"), rounding=ROUND_HALF_UP)
        else:
            return amount

    def _parse_scheme_row(self, row: tuple) -> StatutoryScheme:
        """Parse database row into StatutoryScheme object"""
        # This is a simplified parser - in production, use proper ORM
        return StatutoryScheme(
            id=row[0],
            country_code="",  # Would need to join to get this
            authority_id=row[2],
            code=row[3],
            name_en=row[4],
            name_local=row[5],
            description=row[6],
            scheme_type=row[7],
            calculation_method=CalculationMethod(row[8]),
            calculation_base=row[9],
            employee_contribution=row[10],
            employer_contribution=row[11],
            citizen_applicable=row[12],
            pr_applicable=row[13],
            foreign_worker_applicable=row[14],
            member_number_required=row[15],
            member_number_label=row[16],
            rounding_method=RoundingMethod(row[17]),
            rounding_precision=row[18],
            effective_from=row[19],
            effective_until=row[20],
            legal_reference=row[21],
            notes=row[22]
        )

    def _parse_rate_row(self, row: tuple) -> StatutoryRate:
        """Parse database row into StatutoryRate object"""
        return StatutoryRate(
            id=row[0],
            scheme_id=row[1],
            tier_code=row[2],
            tier_description=row[3],
            min_age=row[4],
            max_age=row[5],
            min_salary=Decimal(str(row[6])) if row[6] else None,
            max_salary=Decimal(str(row[7])) if row[7] else None,
            nationality_condition=NationalityType(row[8]) if row[8] else NationalityType.ALL,
            pr_year_condition=row[9],
            risk_category=RiskCategory(row[10]) if row[10] else None,
            employee_count_min=row[11],
            employee_count_max=row[12],
            employee_rate=Decimal(str(row[13])) if row[13] else None,
            employer_rate=Decimal(str(row[14])) if row[14] else None,
            employee_fixed=Decimal(str(row[15])) if row[15] else None,
            employer_fixed=Decimal(str(row[16])) if row[16] else None,
            total_rate=Decimal(str(row[17])) if row[17] else None,
            effective_from=row[18],
            effective_until=row[19],
            source_reference=row[20],
            verified_date=row[21],
            notes=row[22]
        )
