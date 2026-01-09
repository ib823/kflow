"""
Pytest Configuration and Fixtures
==================================
Shared fixtures for all test modules
"""

from datetime import date
from decimal import Decimal
from typing import Generator

import psycopg2
import pytest

from ..models.statutory import EmployeeContext, NationalityType, RiskCategory
from ..services.statutory_calculator import StatutoryCalculator


@pytest.fixture(scope="session")
def db_connection():
    """
    Database connection fixture (session-scoped)

    Set environment variables:
    - KFLOW_DB_HOST
    - KFLOW_DB_NAME
    - KFLOW_DB_USER
    - KFLOW_DB_PASSWORD
    """
    import os

    conn = psycopg2.connect(
        host=os.getenv("KFLOW_DB_HOST", "localhost"),
        database=os.getenv("KFLOW_DB_NAME", "kerjaflow_test"),
        user=os.getenv("KFLOW_DB_USER", "postgres"),
        password=os.getenv("KFLOW_DB_PASSWORD", "postgres"),
    )

    yield conn

    conn.close()


@pytest.fixture
def calculator(db_connection) -> StatutoryCalculator:
    """Statutory calculator instance"""
    return StatutoryCalculator(db_connection)


# ============================================================================
# MALAYSIA FIXTURES
# ============================================================================


@pytest.fixture
def my_employee_young_under5k() -> EmployeeContext:
    """Malaysian employee, age 30, salary RM4,500 (EPF 13%)"""
    return EmployeeContext(
        country_code="MY",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("4500.00"),
        basic_salary=Decimal("4500.00"),
        calculation_date=date(2025, 6, 1),
    )


@pytest.fixture
def my_employee_young_over5k() -> EmployeeContext:
    """Malaysian employee, age 35, salary RM8,000 (EPF 12%)"""
    return EmployeeContext(
        country_code="MY",
        nationality=NationalityType.CITIZEN,
        age=35,
        gross_salary=Decimal("8000.00"),
        basic_salary=Decimal("8000.00"),
        calculation_date=date(2025, 6, 1),
    )


@pytest.fixture
def my_employee_senior() -> EmployeeContext:
    """Malaysian employee, age 62, salary RM5,000 (EPF 4%)"""
    return EmployeeContext(
        country_code="MY",
        nationality=NationalityType.CITIZEN,
        age=62,
        gross_salary=Decimal("5000.00"),
        basic_salary=Decimal("5000.00"),
        calculation_date=date(2025, 6, 1),
    )


@pytest.fixture
def my_foreign_worker_post_oct2025() -> EmployeeContext:
    """Foreign worker in Malaysia after Oct 1, 2025 (EPF 2%)"""
    return EmployeeContext(
        country_code="MY",
        nationality=NationalityType.FOREIGN,
        age=28,
        gross_salary=Decimal("3000.00"),
        basic_salary=Decimal("3000.00"),
        calculation_date=date(2025, 11, 1),
    )


# ============================================================================
# SINGAPORE FIXTURES
# ============================================================================


@pytest.fixture
def sg_employee_young_2025() -> EmployeeContext:
    """Singaporean employee, age 30, salary SGD5,000 (CPF 37%)"""
    return EmployeeContext(
        country_code="SG",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("5000.00"),
        ordinary_wages=Decimal("5000.00"),
        calculation_date=date(2025, 6, 1),
    )


@pytest.fixture
def sg_employee_senior_2026() -> EmployeeContext:
    """Singaporean employee, age 63, salary SGD6,000 (CPF 25.5% in 2026)"""
    return EmployeeContext(
        country_code="SG",
        nationality=NationalityType.CITIZEN,
        age=63,
        gross_salary=Decimal("6000.00"),
        ordinary_wages=Decimal("6000.00"),
        calculation_date=date(2026, 6, 1),
    )


# ============================================================================
# INDONESIA FIXTURES
# ============================================================================


@pytest.fixture
def id_employee_medium_risk() -> EmployeeContext:
    """Indonesian employee, medium risk manufacturing"""
    return EmployeeContext(
        country_code="ID",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("8000000.00"),  # IDR 8M
        risk_category=RiskCategory.MEDIUM,
        calculation_date=date(2025, 6, 1),
    )


# ============================================================================
# THAILAND FIXTURES
# ============================================================================


@pytest.fixture
def th_employee_2026() -> EmployeeContext:
    """Thai employee in 2026 (new ceiling ฿17,500)"""
    return EmployeeContext(
        country_code="TH",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("18000.00"),  # Above new ceiling
        calculation_date=date(2026, 6, 1),
    )


# ============================================================================
# PHILIPPINES FIXTURES
# ============================================================================


@pytest.fixture
def ph_employee() -> EmployeeContext:
    """Filipino employee, PHP25,000"""
    return EmployeeContext(
        country_code="PH",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("25000.00"),
        calculation_date=date(2025, 6, 1),
    )


# ============================================================================
# VIETNAM FIXTURES
# ============================================================================


@pytest.fixture
def vn_employee_local() -> EmployeeContext:
    """Vietnamese employee (32% total post-July 2025)"""
    return EmployeeContext(
        country_code="VN",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("15000000.00"),  # VND 15M
        calculation_date=date(2025, 8, 1),
    )


@pytest.fixture
def vn_employee_foreign() -> EmployeeContext:
    """Foreign employee in Vietnam (30% total, no UI)"""
    return EmployeeContext(
        country_code="VN",
        nationality=NationalityType.FOREIGN,
        age=30,
        gross_salary=Decimal("20000000.00"),  # VND 20M
        calculation_date=date(2025, 8, 1),
    )


# ============================================================================
# CAMBODIA FIXTURES
# ============================================================================


@pytest.fixture
def kh_employee_phase1() -> EmployeeContext:
    """Cambodian employee in Phase 1 (pension 4%)"""
    return EmployeeContext(
        country_code="KH",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("800000.00"),  # KHR 800K
        calculation_date=date(2025, 6, 1),
    )


@pytest.fixture
def kh_employee_phase2() -> EmployeeContext:
    """Cambodian employee in Phase 2 (pension 6%)"""
    return EmployeeContext(
        country_code="KH",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("900000.00"),
        calculation_date=date(2028, 6, 1),
    )


# ============================================================================
# BRUNEI FIXTURES
# ============================================================================


@pytest.fixture
def bn_employee_tier2() -> EmployeeContext:
    """Brunei employee in Tier 2 (BND 500-1,500)"""
    return EmployeeContext(
        country_code="BN",
        nationality=NationalityType.CITIZEN,
        age=30,
        gross_salary=Decimal("1000.00"),
        calculation_date=date(2025, 6, 1),
    )
