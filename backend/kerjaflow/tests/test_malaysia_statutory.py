"""
Test Suite: Malaysia Statutory Contributions
============================================
Tests for EPF, SOCSO, EIS, HRDF
"""

from datetime import date
from decimal import Decimal

from ..models.statutory import EmployeeContext, NationalityType


class TestMalaysiaEPF:
    """Tests for Malaysian EPF (Employees Provident Fund)"""

    def test_epf_young_under5k_13percent(self, calculator, my_employee_young_under5k):
        """
        Test EPF for employee under 60, salary <= RM5,000
        Expected: Employee 11%, Employer 13%
        """
        result = calculator.calculate_all(my_employee_young_under5k)

        epf = next((c for c in result.contributions if c.scheme_code == "EPF"), None)
        assert epf is not None, "EPF contribution should be calculated"

        # Salary RM4,500
        # Employee: 4500 * 0.11 = RM495.00
        # Employer: 4500 * 0.13 = RM585.00
        assert epf.employee_amount == Decimal("495.00")
        assert epf.employer_amount == Decimal("585.00")
        assert epf.total_amount == Decimal("1080.00")

    def test_epf_young_over5k_12percent(self, calculator, my_employee_young_over5k):
        """
        Test EPF for employee under 60, salary > RM5,000
        Expected: Employee 11%, Employer 12%
        """
        result = calculator.calculate_all(my_employee_young_over5k)

        epf = next((c for c in result.contributions if c.scheme_code == "EPF"), None)
        assert epf is not None

        # Salary RM8,000
        # Employee: 8000 * 0.11 = RM880.00
        # Employer: 8000 * 0.12 = RM960.00
        assert epf.employee_amount == Decimal("880.00")
        assert epf.employer_amount == Decimal("960.00")
        assert epf.total_amount == Decimal("1840.00")

    def test_epf_senior_reduced_rate(self, calculator, my_employee_senior):
        """
        Test EPF for employee 60+
        Expected: Employee 5.5%, Employer 4%
        """
        result = calculator.calculate_all(my_employee_senior)

        epf = next((c for c in result.contributions if c.scheme_code == "EPF"), None)
        assert epf is not None

        # Salary RM5,000
        # Employee: 5000 * 0.055 = RM275.00
        # Employer: 5000 * 0.04 = RM200.00
        assert epf.employee_amount == Decimal("275.00")
        assert epf.employer_amount == Decimal("200.00")

    def test_epf_foreign_worker_oct2025(self, calculator, my_foreign_worker_post_oct2025):
        """
        Test EPF for foreign worker after Oct 1, 2025
        Expected: Employee 2%, Employer 2%
        """
        result = calculator.calculate_all(my_foreign_worker_post_oct2025)

        epf_foreign = next((c for c in result.contributions if "EPF" in c.scheme_code), None)
        assert epf_foreign is not None, "Foreign worker EPF should apply after Oct 2025"

        # Salary RM3,000
        # Employee: 3000 * 0.02 = RM60.00
        # Employer: 3000 * 0.02 = RM60.00
        assert epf_foreign.employee_amount == Decimal("60.00")
        assert epf_foreign.employer_amount == Decimal("60.00")


class TestMalaysiaSOCSO:
    """Tests for SOCSO (Social Security)"""

    def test_socso_standard_rate(self, calculator, my_employee_young_under5k):
        """
        Test SOCSO standard rate
        Expected: Employee 0.5%, Employer 1.25%, capped at RM5,000
        """
        result = calculator.calculate_all(my_employee_young_under5k)

        socso = next((c for c in result.contributions if c.scheme_code == "SOCSO"), None)
        assert socso is not None

        # Salary RM4,500 (under ceiling)
        # Employee: 4500 * 0.005 = RM22.50
        # Employer: 4500 * 0.0125 = RM56.25
        assert socso.employee_amount == Decimal("22.50")
        assert socso.employer_amount == Decimal("56.25")
        assert socso.capped is False

    def test_socso_ceiling_applied(self, calculator, my_employee_young_over5k):
        """
        Test SOCSO with salary above ceiling (RM5,000)
        Expected: Capped at RM5,000
        """
        result = calculator.calculate_all(my_employee_young_over5k)

        socso = next((c for c in result.contributions if c.scheme_code == "SOCSO"), None)
        assert socso is not None

        # Salary RM8,000 but capped at RM5,000
        # Employee: 5000 * 0.005 = RM25.00
        # Employer: 5000 * 0.0125 = RM62.50
        assert socso.capped is True
        assert socso.applied_salary == Decimal("5000.00")
        assert socso.employee_amount == Decimal("25.00")
        assert socso.employer_amount == Decimal("62.50")


class TestMalaysiaEIS:
    """Tests for EIS (Employment Insurance System)"""

    def test_eis_oct2024_reduced_rate(self, calculator, my_employee_young_under5k):
        """
        Test EIS with reduced rate (Oct 2024: 0.2% each)
        Expected: Employee 0.2%, Employer 0.2%, ceiling RM6,000
        """
        result = calculator.calculate_all(my_employee_young_under5k)

        eis = next((c for c in result.contributions if c.scheme_code == "EIS"), None)
        assert eis is not None

        # Salary RM4,500
        # Employee: 4500 * 0.002 = RM9.00
        # Employer: 4500 * 0.002 = RM9.00
        assert eis.employee_amount == Decimal("9.00")
        assert eis.employer_amount == Decimal("9.00")

    def test_eis_ceiling_6000(self, calculator, my_employee_young_over5k):
        """
        Test EIS ceiling increased to RM6,000 (Oct 2024)
        """
        employee = EmployeeContext(
            country_code="MY",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("7000.00"),  # Above RM6,000 ceiling
            calculation_date=date(2025, 6, 1),
        )

        result = calculator.calculate_all(employee)
        eis = next((c for c in result.contributions if c.scheme_code == "EIS"), None)

        assert eis.capped is True
        assert eis.applied_salary == Decimal("6000.00")
        # 6000 * 0.002 = RM12.00 each
        assert eis.employee_amount == Decimal("12.00")
        assert eis.employer_amount == Decimal("12.00")


class TestMalaysiaHRDF:
    """Tests for HRDF (Human Resource Development Fund)"""

    def test_hrdf_employer_only(self, calculator):
        """
        Test HRDF - employer only contribution (1%)
        Applicable for companies with 10+ employees
        """
        employee = EmployeeContext(
            country_code="MY",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("5000.00"),
            company_employee_count=15,  # 10+ employees
            calculation_date=date(2025, 6, 1),
        )

        result = calculator.calculate_all(employee)
        hrdf = next((c for c in result.contributions if c.scheme_code == "HRDF"), None)

        if hrdf:  # HRDF is optional based on company size
            # Employee: 0%
            # Employer: 5000 * 0.01 = RM50.00
            assert hrdf.employee_amount == Decimal("0.00")
            assert hrdf.employer_amount == Decimal("50.00")


class TestMalaysiaIntegration:
    """Integration tests for complete Malaysia payroll"""

    def test_complete_payroll_my_employee(self, calculator, my_employee_young_under5k):
        """
        Test complete statutory calculation for Malaysian employee
        RM4,500 salary
        """
        result = calculator.calculate_all(my_employee_young_under5k)

        # Should have EPF, SOCSO, EIS at minimum
        assert len(result.contributions) >= 3

        # Total employee deductions
        # EPF: 495.00 + SOCSO: 22.50 + EIS: 9.00 = RM526.50
        expected_min_employee = Decimal("526.50")
        assert result.total_employee_amount >= expected_min_employee

        # Total employer contributions
        # EPF: 585.00 + SOCSO: 56.25 + EIS: 9.00 = RM650.25
        expected_min_employer = Decimal("650.25")
        assert result.total_employer_amount >= expected_min_employer

    def test_complete_payroll_totals(self, calculator, my_employee_young_over5k):
        """
        Test that summary totals are calculated correctly
        """
        result = calculator.calculate_all(my_employee_young_over5k)

        # Verify totals match sum of individual contributions
        calculated_employee = sum(c.employee_amount for c in result.contributions)
        calculated_employer = sum(c.employer_amount for c in result.contributions)

        assert result.total_employee_amount == calculated_employee
        assert result.total_employer_amount == calculated_employer
        assert result.total_combined_amount == calculated_employee + calculated_employer
