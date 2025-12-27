"""
Test Suite: Singapore Statutory Contributions
=============================================
Tests for CPF and SDL
"""

import pytest
from decimal import Decimal
from datetime import date

from ..models.statutory import EmployeeContext, NationalityType


class TestSingaporeCPF:
    """Tests for Singapore CPF (Central Provident Fund)"""

    def test_cpf_young_37percent_2025(self, calculator, sg_employee_young_2025):
        """
        Test CPF for employee under 55 in 2025
        Expected: Employee 20%, Employer 17%, Total 37%
        """
        result = calculator.calculate_all(sg_employee_young_2025)

        cpf = next((c for c in result.contributions if c.scheme_code == "CPF"), None)
        assert cpf is not None

        # Salary SGD5,000
        # Employee: 5000 * 0.20 = SGD1,000.00
        # Employer: 5000 * 0.17 = SGD850.00
        assert cpf.employee_amount == Decimal("1000.00")
        assert cpf.employer_amount == Decimal("850.00")
        assert cpf.total_amount == Decimal("1850.00")

    def test_cpf_senior_60_65_2026_increase(self, calculator, sg_employee_senior_2026):
        """
        Test CPF for age 60-65 in 2026 (with rate increase)
        Expected: Total 25.5% (increased from 23% in 2025)
        """
        result = calculator.calculate_all(sg_employee_senior_2026)

        cpf = next((c for c in result.contributions if c.scheme_code == "CPF"), None)
        assert cpf is not None

        # In 2026, age 60-65: Employee 13%, Employer 12.5%
        # Salary SGD6,000
        # Employee: 6000 * 0.13 = SGD780.00
        # Employer: 6000 * 0.125 = SGD750.00
        assert cpf.employee_amount == Decimal("780.00")
        assert cpf.employer_amount == Decimal("750.00")
        assert cpf.total_amount == Decimal("1530.00")

    def test_cpf_ow_ceiling_2025(self, calculator):
        """
        Test CPF OW ceiling SGD7,400 in 2025
        """
        employee = EmployeeContext(
            country_code="SG",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("10000.00"),  # Above ceiling
            ordinary_wages=Decimal("10000.00"),
            calculation_date=date(2025, 6, 1)
        )

        result = calculator.calculate_all(employee)
        cpf = next((c for c in result.contributions if c.scheme_code == "CPF"), None)

        assert cpf.capped is True
        assert cpf.applied_salary == Decimal("7400.00")

        # Capped at SGD7,400
        # Employee: 7400 * 0.20 = SGD1,480.00
        # Employer: 7400 * 0.17 = SGD1,258.00
        assert cpf.employee_amount == Decimal("1480.00")
        assert cpf.employer_amount == Decimal("1258.00")

    def test_cpf_ow_ceiling_2026_increase(self, calculator):
        """
        Test CPF OW ceiling increased to SGD8,000 in 2026
        """
        employee = EmployeeContext(
            country_code="SG",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("10000.00"),
            ordinary_wages=Decimal("10000.00"),
            calculation_date=date(2026, 6, 1)
        )

        result = calculator.calculate_all(employee)
        cpf = next((c for c in result.contributions if c.scheme_code == "CPF"), None)

        assert cpf.capped is True
        assert cpf.applied_salary == Decimal("8000.00")

        # Capped at SGD8,000 (2026 ceiling)
        # Employee: 8000 * 0.20 = SGD1,600.00
        # Employer: 8000 * 0.17 = SGD1,360.00
        assert cpf.employee_amount == Decimal("1600.00")
        assert cpf.employer_amount == Decimal("1360.00")


class TestSingaporeSDL:
    """Tests for SDL (Skills Development Levy)"""

    def test_sdl_under_4500(self, calculator):
        """
        Test SDL for salary <= SGD4,500
        Expected: Employer 0.25%
        """
        employee = EmployeeContext(
            country_code="SG",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("4000.00"),
            calculation_date=date(2025, 6, 1)
        )

        result = calculator.calculate_all(employee)
        sdl = next((c for c in result.contributions if c.scheme_code == "SDL"), None)

        if sdl:
            # Employee: 0%
            # Employer: 4000 * 0.0025 = SGD10.00
            assert sdl.employee_amount == Decimal("0.00")
            assert sdl.employer_amount == Decimal("10.00")

    def test_sdl_over_4500(self, calculator, sg_employee_young_2025):
        """
        Test SDL for salary > SGD4,500
        Expected: Employer 0.5%
        """
        result = calculator.calculate_all(sg_employee_young_2025)
        sdl = next((c for c in result.contributions if c.scheme_code == "SDL"), None)

        if sdl:
            # Salary SGD5,000
            # Employee: 0%
            # Employer: 5000 * 0.005 = SGD25.00
            assert sdl.employee_amount == Decimal("0.00")
            assert sdl.employer_amount == Decimal("25.00")


class TestSingaporeIntegration:
    """Integration tests for Singapore"""

    def test_complete_payroll_sg_2025(self, calculator, sg_employee_young_2025):
        """Complete payroll test for Singapore 2025"""
        result = calculator.calculate_all(sg_employee_young_2025)

        # Should have CPF at minimum
        assert len(result.contributions) >= 1

        cpf = next((c for c in result.contributions if c.scheme_code == "CPF"), None)
        assert cpf is not None

        # Verify country code
        assert result.country_code == "SG"
