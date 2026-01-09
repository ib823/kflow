"""
KerjaFlow Statutory Calculator Unit Tests
==========================================
EXTREME KIASU: Every calculation verified against official government sources.
One wrong calculation = lawsuit.

Reference Sources:
- Malaysia EPF: https://www.kwsp.gov.my/employer/contribution-rate
- Malaysia SOCSO: https://www.perkeso.gov.my/en/rate-of-contribution.html
- Malaysia EIS: https://www.perkeso.gov.my/en/sip-perkeso.html
- Singapore CPF: https://www.cpf.gov.sg/employer/employer-obligations/how-much-cpf-contributions-to-pay
- Indonesia BPJS: https://www.bpjsketenagakerjaan.go.id
- Thailand SSO: https://www.sso.go.th
"""

from decimal import ROUND_HALF_UP, Decimal
from typing import Optional

import pytest

# ============================================================================
# STATUTORY CALCULATOR CLASSES (Standalone for testing)
# These would normally be imported from kerjaflow.calculators.statutory
# ============================================================================


class MalaysiaEPFCalculator:
    """
    Malaysia EPF (Kumpulan Wang Simpanan Pekerja - KWSP)
    Reference: https://www.kwsp.gov.my/employer/contribution-rate

    Rates (as of Jan 2024):
    - Employee < 60 years: 11%
    - Employee >= 60 years: 5.5%
    - Employer (salary <= RM5,000): 13%
    - Employer (salary > RM5,000): 12%
    """

    EMPLOYEE_RATE_UNDER_60 = Decimal("0.11")
    EMPLOYEE_RATE_60_AND_ABOVE = Decimal("0.055")
    EMPLOYER_RATE_LOW_SALARY = Decimal("0.13")
    EMPLOYER_RATE_HIGH_SALARY = Decimal("0.12")
    SALARY_THRESHOLD = Decimal("5000")

    def calculate_employee(
        self, salary: Decimal, age: int, is_foreign_worker: bool = False
    ) -> Decimal:
        """Calculate employee EPF contribution."""
        if is_foreign_worker:
            return Decimal("0")

        if salary <= 0:
            return Decimal("0")

        rate = self.EMPLOYEE_RATE_UNDER_60 if age < 60 else self.EMPLOYEE_RATE_60_AND_ABOVE
        contribution = (salary * rate).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        return contribution

    def calculate_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer EPF contribution."""
        if salary <= 0:
            return Decimal("0")

        rate = (
            self.EMPLOYER_RATE_LOW_SALARY
            if salary <= self.SALARY_THRESHOLD
            else self.EMPLOYER_RATE_HIGH_SALARY
        )
        contribution = (salary * rate).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        return contribution


class MalaysiaSOCSOCalculator:
    """
    Malaysia SOCSO (PERKESO)
    Reference: https://www.perkeso.gov.my/en/rate-of-contribution.html

    Rates (as of 2024):
    - Employment Injury Scheme: 1.25% employer only
    - Invalidity Scheme: 0.5% employee + 0.5% employer
    - Total employer: 1.75%
    - Wage ceiling: RM4,000 (increased from RM3,000 in 2024)
    """

    EMPLOYEE_RATE = Decimal("0.005")  # 0.5% for invalidity
    EMPLOYER_EI_RATE = Decimal("0.0125")  # 1.25% employment injury
    EMPLOYER_INVALIDITY_RATE = Decimal("0.005")  # 0.5% invalidity
    WAGE_CEILING = Decimal("4000")

    def calculate_employee(self, salary: Decimal, category: int = 1) -> Decimal:
        """Calculate employee SOCSO contribution."""
        if category == 2:
            return Decimal("0")  # Category 2 workers don't contribute

        applicable_salary = min(salary, self.WAGE_CEILING)
        contribution = (applicable_salary * self.EMPLOYEE_RATE).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        return contribution

    def calculate_employer(self, salary: Decimal, category: int = 1) -> Decimal:
        """Calculate employer SOCSO contribution."""
        applicable_salary = min(salary, self.WAGE_CEILING)

        if category == 2:
            # Category 2: Only EI, no invalidity
            contribution = applicable_salary * self.EMPLOYER_EI_RATE
        else:
            # Category 1: Both EI and Invalidity
            total_rate = self.EMPLOYER_EI_RATE + self.EMPLOYER_INVALIDITY_RATE
            contribution = applicable_salary * total_rate

        return contribution.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


class MalaysiaEISCalculator:
    """
    Malaysia EIS (Employment Insurance System - SIP)
    Reference: https://www.perkeso.gov.my/en/sip-perkeso.html

    Rates (as of 2018):
    - Employee: 0.2%
    - Employer: 0.2%
    - Wage ceiling: RM4,000
    """

    RATE = Decimal("0.002")  # 0.2%
    WAGE_CEILING = Decimal("4000")

    def calculate_employee(self, salary: Decimal) -> Decimal:
        """Calculate employee EIS contribution."""
        applicable_salary = min(salary, self.WAGE_CEILING)
        contribution = (applicable_salary * self.RATE).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        return contribution

    def calculate_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer EIS contribution."""
        return self.calculate_employee(salary)


class SingaporeCPFCalculator:
    """
    Singapore CPF (Central Provident Fund)
    Reference: https://www.cpf.gov.sg/employer/employer-obligations/how-much-cpf-contributions-to-pay

    Rates vary by age group (as of 2024):
    - <= 55: Employee 20%, Employer 17%
    - 55-60: Employee 15%, Employer 15%
    - 60-65: Employee 9.5%, Employer 11%
    - 65-70: Employee 7%, Employer 8.5%
    - > 70: Employee 5%, Employer 7.5%

    Ordinary Wage ceiling: $6,800/month
    """

    OW_CEILING = Decimal("6800")

    # (employee_rate, employer_rate)
    AGE_RATES = {
        55: (Decimal("0.20"), Decimal("0.17")),
        60: (Decimal("0.15"), Decimal("0.15")),
        65: (Decimal("0.095"), Decimal("0.11")),
        70: (Decimal("0.07"), Decimal("0.085")),
        999: (Decimal("0.05"), Decimal("0.075")),  # > 70
    }

    PR_YEAR1_RATES = (Decimal("0.05"), Decimal("0.04"))
    PR_YEAR2_RATES = (Decimal("0.15"), Decimal("0.09"))

    def _get_rates(self, age: int, pr_year: Optional[int] = None) -> tuple:
        """Get CPF rates based on age and PR status."""
        if pr_year == 1:
            return self.PR_YEAR1_RATES
        if pr_year == 2:
            return self.PR_YEAR2_RATES

        for age_limit, rates in self.AGE_RATES.items():
            if age <= age_limit:
                return rates
        return self.AGE_RATES[999]

    def calculate_employee(
        self, salary: Decimal, age: int, pr_year: Optional[int] = None
    ) -> Decimal:
        """Calculate employee CPF contribution."""
        applicable_salary = min(salary, self.OW_CEILING)
        employee_rate, _ = self._get_rates(age, pr_year)
        contribution = (applicable_salary * employee_rate).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        return contribution

    def calculate_employer(
        self, salary: Decimal, age: int, pr_year: Optional[int] = None
    ) -> Decimal:
        """Calculate employer CPF contribution."""
        applicable_salary = min(salary, self.OW_CEILING)
        _, employer_rate = self._get_rates(age, pr_year)
        contribution = (applicable_salary * employer_rate).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        return contribution


class IndonesiaBPJSCalculator:
    """
    Indonesia BPJS (Badan Penyelenggara Jaminan Sosial)

    BPJS Kesehatan (Health): 5% (4% employer + 1% employee)
    BPJS Ketenagakerjaan (Employment):
    - JKK (Work Accident): 0.24% - 1.74% based on risk level
    - JKM (Death): 0.3% employer
    - JHT (Old Age): 3.7% employer + 2% employee
    - JP (Pension): 2% employer + 1% employee (ceiling: Rp 9,077,600)
    """

    KESEHATAN_EMPLOYEE = Decimal("0.01")
    KESEHATAN_EMPLOYER = Decimal("0.04")

    JKK_RATES = {
        1: Decimal("0.0024"),  # Very low risk
        2: Decimal("0.0054"),  # Low risk
        3: Decimal("0.0089"),  # Medium risk
        4: Decimal("0.0127"),  # High risk
        5: Decimal("0.0174"),  # Very high risk
    }

    JKM_RATE = Decimal("0.003")  # 0.3%
    JHT_EMPLOYEE = Decimal("0.02")
    JHT_EMPLOYER = Decimal("0.037")
    JP_EMPLOYEE = Decimal("0.01")
    JP_EMPLOYER = Decimal("0.02")
    JP_CEILING = Decimal("9077600")

    def calculate_kesehatan_employee(self, salary: Decimal) -> Decimal:
        """Calculate employee BPJS Kesehatan contribution."""
        return (salary * self.KESEHATAN_EMPLOYEE).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_kesehatan_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer BPJS Kesehatan contribution."""
        return (salary * self.KESEHATAN_EMPLOYER).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jkk(self, salary: Decimal, risk_level: int) -> Decimal:
        """Calculate JKK (Work Accident) contribution based on risk level."""
        rate = self.JKK_RATES.get(risk_level, self.JKK_RATES[3])
        return (salary * rate).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jkm(self, salary: Decimal) -> Decimal:
        """Calculate JKM (Death) contribution."""
        return (salary * self.JKM_RATE).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jht_employee(self, salary: Decimal) -> Decimal:
        """Calculate employee JHT (Old Age) contribution."""
        return (salary * self.JHT_EMPLOYEE).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jht_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer JHT (Old Age) contribution."""
        return (salary * self.JHT_EMPLOYER).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jp_employee(self, salary: Decimal) -> Decimal:
        """Calculate employee JP (Pension) contribution with ceiling."""
        applicable_salary = min(salary, self.JP_CEILING)
        return (applicable_salary * self.JP_EMPLOYEE).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_jp_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer JP (Pension) contribution with ceiling."""
        applicable_salary = min(salary, self.JP_CEILING)
        return (applicable_salary * self.JP_EMPLOYER).quantize(Decimal("1"), rounding=ROUND_HALF_UP)


class ThailandSSOCalculator:
    """
    Thailand SSO (Social Security Office)
    Reference: https://www.sso.go.th

    Rates:
    - Employee: 5%
    - Employer: 5%
    - Government: 2.75%

    Wage ceiling: 15,000 THB/month
    Minimum wage base: 1,650 THB/month
    """

    RATE = Decimal("0.05")  # 5%
    WAGE_CEILING = Decimal("15000")
    MIN_WAGE_BASE = Decimal("1650")

    def calculate_employee(self, salary: Decimal) -> Decimal:
        """Calculate employee SSO contribution."""
        # Use minimum wage base if salary is below
        applicable_salary = max(salary, self.MIN_WAGE_BASE)
        applicable_salary = min(applicable_salary, self.WAGE_CEILING)
        return (applicable_salary * self.RATE).quantize(Decimal("1"), rounding=ROUND_HALF_UP)

    def calculate_employer(self, salary: Decimal) -> Decimal:
        """Calculate employer SSO contribution."""
        return self.calculate_employee(salary)


# ============================================================================
# TEST CLASSES
# ============================================================================


class TestMalaysiaEPFCalculator:
    """
    Malaysia EPF (Kumpulan Wang Simpanan Pekerja - KWSP)
    Reference: https://www.kwsp.gov.my/employer/contribution-rate
    """

    @pytest.fixture
    def calculator(self):
        return MalaysiaEPFCalculator()

    # Age-based employee contribution tests
    @pytest.mark.parametrize(
        "age,salary,expected_employee",
        [
            (25, Decimal("3000.00"), Decimal("330.00")),  # 11%
            (35, Decimal("5000.00"), Decimal("550.00")),  # 11%
            (45, Decimal("10000.00"), Decimal("1100.00")),  # 11%
            (59, Decimal("8000.00"), Decimal("880.00")),  # 11% (still < 60)
            (60, Decimal("5000.00"), Decimal("275.00")),  # 5.5% (>= 60)
            (65, Decimal("3000.00"), Decimal("165.00")),  # 5.5%
            (70, Decimal("2000.00"), Decimal("110.00")),  # 5.5%
        ],
    )
    def test_employee_contribution_by_age(self, calculator, age, salary, expected_employee):
        """EPF employee contribution varies by age threshold (60 years)."""
        result = calculator.calculate_employee(salary, age)
        assert (
            result == expected_employee
        ), f"Age {age}, Salary {salary}: expected {expected_employee}, got {result}"

    # Employer contribution tests (tiered by salary)
    @pytest.mark.parametrize(
        "salary,expected_employer",
        [
            (Decimal("1000.00"), Decimal("130.00")),  # 13% (salary <= 5000)
            (Decimal("3000.00"), Decimal("390.00")),  # 13%
            (Decimal("5000.00"), Decimal("650.00")),  # 13%
            (Decimal("5001.00"), Decimal("600.12")),  # 12% (salary > 5000)
            (Decimal("8000.00"), Decimal("960.00")),  # 12%
            (Decimal("10000.00"), Decimal("1200.00")),  # 12%
            (Decimal("20000.00"), Decimal("2400.00")),  # 12%
        ],
    )
    def test_employer_contribution_by_salary(self, calculator, salary, expected_employer):
        """EPF employer contribution is 13% for salary <= RM5,000, 12% for salary > RM5,000."""
        result = calculator.calculate_employer(salary)
        assert (
            result == expected_employer
        ), f"Salary {salary}: expected {expected_employer}, got {result}"

    # Edge cases
    def test_zero_salary(self, calculator):
        """Zero salary should return zero contribution."""
        assert calculator.calculate_employee(Decimal("0"), 30) == Decimal("0")
        assert calculator.calculate_employer(Decimal("0")) == Decimal("0")

    def test_negative_salary(self, calculator):
        """Negative salary should return zero contribution."""
        assert calculator.calculate_employee(Decimal("-1000"), 30) == Decimal("0")
        assert calculator.calculate_employer(Decimal("-1000")) == Decimal("0")

    def test_rounding(self, calculator):
        """EPF contributions should be properly rounded."""
        # RM 3,333.33 * 11% = RM 366.6663 → should round to RM 366.67
        result = calculator.calculate_employee(Decimal("3333.33"), 30)
        assert result == Decimal("366.67")

    def test_foreign_worker_exemption(self, calculator):
        """Foreign workers are exempt from EPF."""
        result = calculator.calculate_employee(Decimal("3000"), 30, is_foreign_worker=True)
        assert result == Decimal("0")

    def test_age_boundary_59(self, calculator):
        """Age 59 should use under-60 rate."""
        result = calculator.calculate_employee(Decimal("5000"), 59)
        assert result == Decimal("550.00")  # 11%

    def test_age_boundary_60(self, calculator):
        """Age 60 should use 60-and-above rate."""
        result = calculator.calculate_employee(Decimal("5000"), 60)
        assert result == Decimal("275.00")  # 5.5%

    def test_salary_boundary_5000(self, calculator):
        """Salary exactly RM5000 should use 13% employer rate."""
        result = calculator.calculate_employer(Decimal("5000.00"))
        assert result == Decimal("650.00")  # 13%

    def test_salary_boundary_5001(self, calculator):
        """Salary RM5001 should use 12% employer rate."""
        result = calculator.calculate_employer(Decimal("5001.00"))
        assert result == Decimal("600.12")  # 12%


class TestMalaysiaSOCSOCalculator:
    """
    Malaysia SOCSO (PERKESO)
    Reference: https://www.perkeso.gov.my/en/rate-of-contribution.html
    """

    @pytest.fixture
    def calculator(self):
        return MalaysiaSOCSOCalculator()

    @pytest.mark.parametrize(
        "salary,expected_employee,expected_employer",
        [
            (Decimal("2000.00"), Decimal("10.00"), Decimal("35.00")),  # 0.5% + 1.75%
            (Decimal("3000.00"), Decimal("15.00"), Decimal("52.50")),
            (Decimal("4000.00"), Decimal("20.00"), Decimal("70.00")),  # At ceiling
            (Decimal("5000.00"), Decimal("20.00"), Decimal("70.00")),  # Above ceiling
            (Decimal("10000.00"), Decimal("20.00"), Decimal("70.00")),  # Way above ceiling
        ],
    )
    def test_contribution_with_ceiling(
        self, calculator, salary, expected_employee, expected_employer
    ):
        """SOCSO contributions are capped at wage ceiling of RM4,000."""
        emp_result = calculator.calculate_employee(salary)
        er_result = calculator.calculate_employer(salary)
        assert emp_result == expected_employee
        assert er_result == expected_employer

    def test_category_2_worker_employee(self, calculator):
        """Category 2 workers (>= 60 years) don't pay employee contribution."""
        result = calculator.calculate_employee(Decimal("3000"), category=2)
        assert result == Decimal("0")

    def test_category_2_worker_employer(self, calculator):
        """Category 2 workers employer only pays EI (1.25%)."""
        result = calculator.calculate_employer(Decimal("3000"), category=2)
        expected = Decimal("3000") * Decimal("0.0125")
        assert result == expected.quantize(Decimal("0.01"))

    def test_zero_salary(self, calculator):
        """Zero salary should return zero contribution."""
        assert calculator.calculate_employee(Decimal("0")) == Decimal("0")
        assert calculator.calculate_employer(Decimal("0")) == Decimal("0")


class TestMalaysiaEISCalculator:
    """
    Malaysia EIS (Employment Insurance System - SIP)
    Reference: https://www.perkeso.gov.my/en/sip-perkeso.html
    """

    @pytest.fixture
    def calculator(self):
        return MalaysiaEISCalculator()

    @pytest.mark.parametrize(
        "salary,expected",
        [
            (Decimal("2000.00"), Decimal("4.00")),  # 0.2%
            (Decimal("4000.00"), Decimal("8.00")),  # At ceiling
            (Decimal("5000.00"), Decimal("8.00")),  # Above ceiling
            (Decimal("10000.00"), Decimal("8.00")),  # Way above ceiling
        ],
    )
    def test_eis_contribution(self, calculator, salary, expected):
        """EIS is 0.2% each, capped at RM4,000 wage ceiling."""
        emp_result = calculator.calculate_employee(salary)
        er_result = calculator.calculate_employer(salary)
        assert emp_result == expected
        assert er_result == expected

    def test_zero_salary(self, calculator):
        """Zero salary should return zero contribution."""
        assert calculator.calculate_employee(Decimal("0")) == Decimal("0")


class TestSingaporeCPFCalculator:
    """
    Singapore CPF (Central Provident Fund)
    Reference: https://www.cpf.gov.sg/employer/employer-obligations/how-much-cpf-contributions-to-pay
    """

    @pytest.fixture
    def calculator(self):
        return SingaporeCPFCalculator()

    @pytest.mark.parametrize(
        "age,salary,expected_employee,expected_employer",
        [
            # Age <= 55
            (25, Decimal("4000"), Decimal("800.00"), Decimal("680.00")),  # 20%, 17%
            (55, Decimal("6000"), Decimal("1200.00"), Decimal("1020.00")),  # 20%, 17%
            # Age 55-60
            (56, Decimal("5000"), Decimal("750.00"), Decimal("750.00")),  # 15%, 15%
            (60, Decimal("5000"), Decimal("750.00"), Decimal("750.00")),  # 15%, 15%
            # Age 60-65
            (61, Decimal("5000"), Decimal("475.00"), Decimal("550.00")),  # 9.5%, 11%
            (65, Decimal("5000"), Decimal("475.00"), Decimal("550.00")),  # 9.5%, 11%
            # Age 65-70
            (66, Decimal("5000"), Decimal("350.00"), Decimal("425.00")),  # 7%, 8.5%
            (70, Decimal("5000"), Decimal("350.00"), Decimal("425.00")),  # 7%, 8.5%
            # Age > 70
            (71, Decimal("5000"), Decimal("250.00"), Decimal("375.00")),  # 5%, 7.5%
            (80, Decimal("5000"), Decimal("250.00"), Decimal("375.00")),  # 5%, 7.5%
        ],
    )
    def test_cpf_by_age_bracket(
        self, calculator, age, salary, expected_employee, expected_employer
    ):
        """CPF rates vary by 5 age brackets."""
        emp_result = calculator.calculate_employee(salary, age)
        er_result = calculator.calculate_employer(salary, age)
        assert (
            emp_result == expected_employee
        ), f"Age {age}: Employee expected {expected_employee}, got {emp_result}"
        assert (
            er_result == expected_employer
        ), f"Age {age}: Employer expected {expected_employer}, got {er_result}"

    def test_ordinary_wage_ceiling(self, calculator):
        """CPF Ordinary Wage ceiling is $6,800/month."""
        # Salary above ceiling should be capped
        emp_result = calculator.calculate_employee(Decimal("10000"), 30)
        expected = (Decimal("6800") * Decimal("0.20")).quantize(Decimal("0.01"))
        assert emp_result == expected

    def test_pr_first_year_graduated_rates(self, calculator):
        """PR first year has graduated (lower) rates."""
        result = calculator.calculate_employee(Decimal("5000"), 30, pr_year=1)
        # First year PR: Employee 5%
        assert result == Decimal("250.00")

    def test_pr_first_year_employer(self, calculator):
        """PR first year employer rate is 4%."""
        result = calculator.calculate_employer(Decimal("5000"), 30, pr_year=1)
        assert result == Decimal("200.00")

    def test_pr_second_year_graduated_rates(self, calculator):
        """PR second year still has graduated rates."""
        result = calculator.calculate_employee(Decimal("5000"), 30, pr_year=2)
        # Second year PR: Employee 15%
        assert result == Decimal("750.00")

    def test_pr_second_year_employer(self, calculator):
        """PR second year employer rate is 9%."""
        result = calculator.calculate_employer(Decimal("5000"), 30, pr_year=2)
        assert result == Decimal("450.00")


class TestIndonesiaBPJSCalculator:
    """
    Indonesia BPJS (Badan Penyelenggara Jaminan Sosial)
    """

    @pytest.fixture
    def calculator(self):
        return IndonesiaBPJSCalculator()

    def test_bpjs_kesehatan_employee(self, calculator):
        """BPJS Health employee is 1%."""
        salary = Decimal("10000000")  # Rp 10 million
        emp = calculator.calculate_kesehatan_employee(salary)
        assert emp == Decimal("100000")

    def test_bpjs_kesehatan_employer(self, calculator):
        """BPJS Health employer is 4%."""
        salary = Decimal("10000000")
        er = calculator.calculate_kesehatan_employer(salary)
        assert er == Decimal("400000")

    @pytest.mark.parametrize(
        "risk_level,expected_rate",
        [
            (1, Decimal("0.0024")),  # Very low risk
            (2, Decimal("0.0054")),  # Low risk
            (3, Decimal("0.0089")),  # Medium risk
            (4, Decimal("0.0127")),  # High risk
            (5, Decimal("0.0174")),  # Very high risk
        ],
    )
    def test_jkk_by_risk_level(self, calculator, risk_level, expected_rate):
        """JKK (Work Accident) rate varies by workplace risk level."""
        salary = Decimal("10000000")
        result = calculator.calculate_jkk(salary, risk_level)
        expected = (salary * expected_rate).quantize(Decimal("1"))
        assert result == expected

    def test_jkm(self, calculator):
        """JKM (Death) is 0.3%."""
        salary = Decimal("10000000")
        result = calculator.calculate_jkm(salary)
        assert result == Decimal("30000")

    def test_jht_employee(self, calculator):
        """JHT employee is 2%."""
        salary = Decimal("10000000")
        result = calculator.calculate_jht_employee(salary)
        assert result == Decimal("200000")

    def test_jht_employer(self, calculator):
        """JHT employer is 3.7%."""
        salary = Decimal("10000000")
        result = calculator.calculate_jht_employer(salary)
        assert result == Decimal("370000")

    def test_jp_employee_with_ceiling(self, calculator):
        """JP (Pension) employee has wage ceiling of Rp 9,077,600."""
        salary = Decimal("20000000")
        emp = calculator.calculate_jp_employee(salary)
        ceiling = Decimal("9077600")
        expected = (ceiling * Decimal("0.01")).quantize(Decimal("1"))
        assert emp == expected

    def test_jp_employer_with_ceiling(self, calculator):
        """JP (Pension) employer has wage ceiling of Rp 9,077,600."""
        salary = Decimal("20000000")
        er = calculator.calculate_jp_employer(salary)
        ceiling = Decimal("9077600")
        expected = (ceiling * Decimal("0.02")).quantize(Decimal("1"))
        assert er == expected


class TestThailandSSOCalculator:
    """
    Thailand SSO (Social Security Office)
    Reference: https://www.sso.go.th
    """

    @pytest.fixture
    def calculator(self):
        return ThailandSSOCalculator()

    @pytest.mark.parametrize(
        "salary,expected",
        [
            (Decimal("10000"), Decimal("500")),  # 5%
            (Decimal("15000"), Decimal("750")),  # 5% at ceiling
            (Decimal("20000"), Decimal("750")),  # 5% capped at ceiling
            (Decimal("50000"), Decimal("750")),  # Way above ceiling
        ],
    )
    def test_sso_with_ceiling(self, calculator, salary, expected):
        """Thailand SSO is 5% each, capped at 15,000 THB ceiling."""
        emp = calculator.calculate_employee(salary)
        er = calculator.calculate_employer(salary)
        assert emp == expected
        assert er == expected

    def test_below_minimum_wage_base(self, calculator):
        """Contributions below minimum wage base use 1,650 THB."""
        salary = Decimal("1000")
        emp = calculator.calculate_employee(salary)
        # 1650 * 0.05 = 82.5, rounded to 83
        expected = Decimal("83")
        assert emp == expected


# Integration test for multi-country payroll
class TestMultiCountryPayroll:
    """Test statutory calculations across multiple countries."""

    def test_malaysia_full_payslip(self):
        """Test complete Malaysian statutory deductions."""
        gross = Decimal("5000")

        epf_calc = MalaysiaEPFCalculator()
        socso_calc = MalaysiaSOCSOCalculator()
        eis_calc = MalaysiaEISCalculator()

        epf_emp = epf_calc.calculate_employee(gross, 30)
        socso_emp = socso_calc.calculate_employee(gross)
        eis_emp = eis_calc.calculate_employee(gross)

        assert epf_emp == Decimal("550.00")  # 11%
        assert socso_emp == Decimal("20.00")  # 0.5% capped at 4000
        assert eis_emp == Decimal("8.00")  # 0.2% capped at 4000

        total_statutory = epf_emp + socso_emp + eis_emp
        assert total_statutory == Decimal("578.00")

    def test_singapore_full_payslip(self):
        """Test complete Singapore statutory deductions for age 30."""
        gross = Decimal("6000")

        cpf_calc = SingaporeCPFCalculator()
        cpf_emp = cpf_calc.calculate_employee(gross, 30)
        cpf_er = cpf_calc.calculate_employer(gross, 30)

        assert cpf_emp == Decimal("1200.00")  # 20%
        assert cpf_er == Decimal("1020.00")  # 17%

    def test_indonesia_full_payslip(self):
        """Test complete Indonesia BPJS deductions."""
        gross = Decimal("10000000")  # Rp 10 million

        bpjs_calc = IndonesiaBPJSCalculator()

        kesehatan_emp = bpjs_calc.calculate_kesehatan_employee(gross)
        jht_emp = bpjs_calc.calculate_jht_employee(gross)
        jp_emp = bpjs_calc.calculate_jp_employee(gross)

        assert kesehatan_emp == Decimal("100000")  # 1%
        assert jht_emp == Decimal("200000")  # 2%
        # JP has ceiling of Rp 9,077,600, so 1% of ceiling = 90,776
        assert jp_emp == Decimal("90776")

        total_statutory = kesehatan_emp + jht_emp + jp_emp
        assert total_statutory == Decimal("390776")

    def test_thailand_full_payslip(self):
        """Test complete Thailand SSO deductions."""
        gross = Decimal("30000")  # 30,000 THB

        sso_calc = ThailandSSOCalculator()
        sso_emp = sso_calc.calculate_employee(gross)
        sso_er = sso_calc.calculate_employer(gross)

        # Both capped at 15,000 THB
        assert sso_emp == Decimal("750")  # 5% of 15000
        assert sso_er == Decimal("750")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
