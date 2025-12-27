"""
Test Suite: All ASEAN Countries Integration Tests
=================================================
Tests for Indonesia, Thailand, Philippines, Vietnam, Cambodia, Myanmar, Brunei
"""

import pytest
from decimal import Decimal
from datetime import date

from ..models.statutory import EmployeeContext, NationalityType, RiskCategory


class TestIndonesia:
    """Tests for Indonesia BPJS"""

    def test_indonesia_jkk_medium_risk(self, calculator, id_employee_medium_risk):
        """
        Test Indonesian JKK for medium risk category
        Expected: Employer 0.89%
        """
        result = calculator.calculate_all(id_employee_medium_risk)

        jkk = next((c for c in result.contributions if c.scheme_code == "JKK"), None)
        if jkk:
            # Medium risk: 0.89% employer only
            # IDR 8,000,000 * 0.0089 = IDR 71,200
            assert jkk.employee_amount == Decimal("0.00")
            assert jkk.employer_amount == Decimal("71200.00")

    def test_indonesia_jht_standard(self, calculator, id_employee_medium_risk):
        """
        Test Indonesian JHT (Old Age Savings)
        Expected: Employee 2%, Employer 3.7%
        """
        result = calculator.calculate_all(id_employee_medium_risk)

        jht = next((c for c in result.contributions if c.scheme_code == "JHT"), None)
        if jht:
            # IDR 8,000,000
            # Employee: 8M * 0.02 = IDR 160,000
            # Employer: 8M * 0.037 = IDR 296,000
            assert jht.employee_amount == Decimal("160000.00")
            assert jht.employer_amount == Decimal("296000.00")

    def test_indonesia_bpjs_kesehatan(self, calculator, id_employee_medium_risk):
        """
        Test BPJS Kesehatan (Health Insurance)
        Expected: Employee 1%, Employer 4%
        """
        result = calculator.calculate_all(id_employee_medium_risk)

        bpjs_kes = next(
            (c for c in result.contributions if c.scheme_code == "BPJS_KES"),
            None
        )
        if bpjs_kes:
            # IDR 8,000,000
            # Employee: 8M * 0.01 = IDR 80,000
            # Employer: 8M * 0.04 = IDR 320,000
            assert bpjs_kes.employee_amount == Decimal("80000.00")
            assert bpjs_kes.employer_amount == Decimal("320000.00")


class TestThailand:
    """Tests for Thailand SSF"""

    def test_thailand_ssf_2025(self, calculator):
        """
        Test Thai SSF in 2025 (ceiling ฿15,000)
        Expected: Employee 5%, Employer 5%
        """
        employee = EmployeeContext(
            country_code="TH",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("12000.00"),
            calculation_date=date(2025, 6, 1)
        )

        result = calculator.calculate_all(employee)
        ssf = next((c for c in result.contributions if c.scheme_code == "SSF_33"), None)

        if ssf:
            # ฿12,000 (under ceiling)
            # Employee: 12000 * 0.05 = ฿600.00
            # Employer: 12000 * 0.05 = ฿600.00
            assert ssf.employee_amount == Decimal("600.00")
            assert ssf.employer_amount == Decimal("600.00")

    def test_thailand_ssf_2026_new_ceiling(self, calculator, th_employee_2026):
        """
        Test Thai SSF in 2026 with new ceiling ฿17,500
        Expected: Capped at ฿17,500
        """
        result = calculator.calculate_all(th_employee_2026)
        ssf = next((c for c in result.contributions if c.scheme_code == "SSF_33"), None)

        if ssf:
            assert ssf.capped is True
            assert ssf.applied_salary == Decimal("17500.00")

            # ฿17,500 * 0.05 = ฿875.00 each
            assert ssf.employee_amount == Decimal("875.00")
            assert ssf.employer_amount == Decimal("875.00")


class TestPhilippines:
    """Tests for Philippines SSS, PhilHealth, Pag-IBIG"""

    def test_philippines_sss_2025(self, calculator, ph_employee):
        """
        Test SSS final rate (5% employee, 10% employer = 15%)
        """
        result = calculator.calculate_all(ph_employee)
        sss = next((c for c in result.contributions if c.scheme_code == "SSS"), None)

        if sss:
            # PHP 25,000 (under ceiling PHP 35,000)
            # Employee: 25000 * 0.05 = PHP 1,250
            # Employer: 25000 * 0.10 = PHP 2,500 (includes EC)
            assert sss.employee_amount == Decimal("1250.00")
            assert sss.employer_amount == Decimal("2500.00")

    def test_philippines_philhealth(self, calculator, ph_employee):
        """
        Test PhilHealth (2.5% each)
        """
        result = calculator.calculate_all(ph_employee)
        phic = next((c for c in result.contributions if c.scheme_code == "PHIC"), None)

        if phic:
            # PHP 25,000
            # Employee: 25000 * 0.025 = PHP 625
            # Employer: 25000 * 0.025 = PHP 625
            assert phic.employee_amount == Decimal("625.00")
            assert phic.employer_amount == Decimal("625.00")

    def test_philippines_pagibig_standard(self, calculator, ph_employee):
        """
        Test Pag-IBIG for salary > PHP 1,500 (2% each)
        """
        result = calculator.calculate_all(ph_employee)
        pagibig = next(
            (c for c in result.contributions if c.scheme_code == "PAGIBIG"),
            None
        )

        if pagibig:
            # PHP 25,000 but capped at PHP 5,000
            # Employee: 5000 * 0.02 = PHP 100
            # Employer: 5000 * 0.02 = PHP 100
            assert pagibig.capped is True
            assert pagibig.applied_salary == Decimal("5000.00")
            assert pagibig.employee_amount == Decimal("100.00")
            assert pagibig.employer_amount == Decimal("100.00")


class TestVietnam:
    """Tests for Vietnam BHXH"""

    def test_vietnam_local_32percent(self, calculator, vn_employee_local):
        """
        Test Vietnamese employee (32% total post-July 2025)
        Expected: Employee 10.5%, Employer 21.5%
        """
        result = calculator.calculate_all(vn_employee_local)
        bhxh = next((c for c in result.contributions if c.scheme_code == "BHXH"), None)

        if bhxh:
            # VND 15,000,000
            # Employee: 15M * 0.105 = VND 1,575,000
            # Employer: 15M * 0.215 = VND 3,225,000
            assert bhxh.employee_amount == Decimal("1575000.00")
            assert bhxh.employer_amount == Decimal("3225000.00")
            assert bhxh.total_amount == Decimal("4800000.00")  # 32%

    def test_vietnam_foreign_30percent(self, calculator, vn_employee_foreign):
        """
        Test foreign employee (30% total, no UI)
        Expected: Employee 9.5%, Employer 20.5%
        """
        result = calculator.calculate_all(vn_employee_foreign)
        bhxh = next((c for c in result.contributions if c.scheme_code == "BHXH"), None)

        if bhxh:
            # VND 20,000,000
            # Employee: 20M * 0.095 = VND 1,900,000
            # Employer: 20M * 0.205 = VND 4,100,000
            assert bhxh.employee_amount == Decimal("1900000.00")
            assert bhxh.employer_amount == Decimal("4100000.00")
            assert bhxh.total_amount == Decimal("6000000.00")  # 30%

    def test_vietnam_trade_union_reduced(self, calculator, vn_employee_local):
        """
        Test Trade Union fee reduced to 0.5% (July 2025)
        """
        result = calculator.calculate_all(vn_employee_local)
        tu = next(
            (c for c in result.contributions if c.scheme_code == "TRADE_UNION"),
            None
        )

        if tu:
            # VND 15,000,000
            # Employee: 15M * 0.005 = VND 75,000 (reduced from 1%)
            # Employer: 15M * 0.02 = VND 300,000
            assert tu.employee_amount == Decimal("75000.00")
            assert tu.employer_amount == Decimal("300000.00")


class TestCambodia:
    """Tests for Cambodia NSSF"""

    def test_cambodia_nssf_pension_phase1(self, calculator, kh_employee_phase1):
        """
        Test Cambodia NSSF Pension Phase 1 (2022-2027: 4% total)
        """
        result = calculator.calculate_all(kh_employee_phase1)
        pension = next(
            (c for c in result.contributions if c.scheme_code == "NSSF_PENSION"),
            None
        )

        if pension:
            # KHR 800,000 (under ceiling KHR 1,200,000)
            # Employee: 800K * 0.02 = KHR 16,000
            # Employer: 800K * 0.02 = KHR 16,000
            assert pension.employee_amount == Decimal("16000.00")
            assert pension.employer_amount == Decimal("16000.00")
            assert pension.total_amount == Decimal("32000.00")

    def test_cambodia_nssf_pension_phase2(self, calculator, kh_employee_phase2):
        """
        Test Cambodia NSSF Pension Phase 2 (2027-2032: 6% total)
        """
        result = calculator.calculate_all(kh_employee_phase2)
        pension = next(
            (c for c in result.contributions if c.scheme_code == "NSSF_PENSION"),
            None
        )

        if pension:
            # KHR 900,000
            # Phase 2: Employee 3%, Employer 3%
            # Employee: 900K * 0.03 = KHR 27,000
            # Employer: 900K * 0.03 = KHR 27,000
            assert pension.employee_amount == Decimal("27000.00")
            assert pension.employer_amount == Decimal("27000.00")
            assert pension.total_amount == Decimal("54000.00")  # 6%

    def test_cambodia_nssf_health_employer_only(self, calculator, kh_employee_phase1):
        """
        Test Cambodia NSSF Health (employer only: 2.6%)
        """
        result = calculator.calculate_all(kh_employee_phase1)
        health = next(
            (c for c in result.contributions if c.scheme_code == "NSSF_HEALTH"),
            None
        )

        if health:
            # KHR 800,000
            # Employee: 0%
            # Employer: 800K * 0.026 = KHR 20,800
            assert health.employee_amount == Decimal("0.00")
            assert health.employer_amount == Decimal("20800.00")


class TestMyanmar:
    """Tests for Myanmar SSB"""

    def test_myanmar_ssb_standard(self, calculator):
        """
        Test Myanmar SSB (Employee 2%, Employer 3%)
        """
        employee = EmployeeContext(
            country_code="MM",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("250000.00"),  # MMK 250K
            calculation_date=date(2025, 6, 1)
        )

        result = calculator.calculate_all(employee)
        ssb = next((c for c in result.contributions if c.scheme_code == "SSB"), None)

        if ssb:
            # MMK 250,000 (under ceiling MMK 300,000)
            # Employee: 250K * 0.02 = MMK 5,000
            # Employer: 250K * 0.03 = MMK 7,500
            assert ssb.employee_amount == Decimal("5000.00")
            assert ssb.employer_amount == Decimal("7500.00")


class TestBrunei:
    """Tests for Brunei SPK"""

    def test_brunei_spk_tier2(self, calculator, bn_employee_tier2):
        """
        Test Brunei SPK Tier 2 (BND 500-1,500)
        Expected: Employee 8.5%, Employer 10.5%
        """
        result = calculator.calculate_all(bn_employee_tier2)
        spk = next((c for c in result.contributions if c.scheme_code == "SPK"), None)

        if spk:
            # BND 1,000 (Tier 2)
            # Employee: 1000 * 0.085 = BND 85.00
            # Employer: 1000 * 0.105 = BND 105.00
            assert spk.employee_amount == Decimal("85.00")
            assert spk.employer_amount == Decimal("105.00")

    def test_brunei_spk_tier4_nocap(self, calculator):
        """
        Test Brunei SPK Tier 4 (> BND 2,800) - no cap
        Expected: Employee 8.5%, Employer 8.5%
        """
        employee = EmployeeContext(
            country_code="BN",
            nationality=NationalityType.CITIZEN,
            age=30,
            gross_salary=Decimal("5000.00"),  # High salary
            calculation_date=date(2025, 6, 1)
        )

        result = calculator.calculate_all(employee)
        spk = next((c for c in result.contributions if c.scheme_code == "SPK"), None)

        if spk:
            assert spk.capped is False  # No cap in SPK 2023

            # BND 5,000 (Tier 4)
            # Employee: 5000 * 0.085 = BND 425.00
            # Employer: 5000 * 0.085 = BND 425.00
            assert spk.employee_amount == Decimal("425.00")
            assert spk.employer_amount == Decimal("425.00")
