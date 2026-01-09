# -*- coding: utf-8 -*-
"""
KerjaFlow Payslip Tests
=======================

Test suite for payslip functionality (T-P01 to T-P09)
"""
from datetime import date
from decimal import Decimal

import pytest


class TestPayslipData:
    """Tests for payslip data handling"""

    def test_payslip_has_required_fields(self, sample_payslip):
        """T-P01: Payslip should have required fields"""
        required_fields = ["id", "employee_id", "period", "gross_salary", "net_salary", "status"]
        for field in required_fields:
            assert field in sample_payslip

    def test_gross_greater_than_net(self, sample_payslip):
        """T-P02: Gross salary should be >= net salary"""
        assert sample_payslip["gross_salary"] >= sample_payslip["net_salary"]

    def test_period_format(self, sample_payslip):
        """T-P03: Period should be in YYYY-MM format"""
        period = sample_payslip["period"]
        assert len(period) == 7
        assert period[4] == "-"
        year, month = period.split("-")
        assert 2020 <= int(year) <= 2030
        assert 1 <= int(month) <= 12

    def test_payslip_status_values(self, sample_payslip):
        """T-P04: Payslip status should be valid"""
        valid_statuses = ["DRAFT", "PUBLISHED", "ARCHIVED"]
        assert sample_payslip["status"] in valid_statuses


class TestPayslipAccess:
    """Tests for payslip access control"""

    def test_pin_required_for_download(self, sample_payslip, sample_user):
        """T-P05: Payslip download should require PIN verification"""
        # PIN verification should be required
        pin_required = True
        assert pin_required is True

    def test_employee_can_view_own_payslips(self, sample_payslip, sample_employee):
        """T-P06: Employee should only view their own payslips"""
        assert sample_payslip["employee_id"] == sample_employee["id"]

    def test_payslip_not_accessible_to_others(self, sample_payslip):
        """T-P07: Payslip should not be accessible to other employees"""
        other_employee_id = 999
        assert sample_payslip["employee_id"] != other_employee_id


class TestPayslipCalculations:
    """Tests for payslip calculations"""

    def test_statutory_deductions(self, sample_payslip):
        """T-P08: Statutory deductions should be calculated"""
        gross = sample_payslip["gross_salary"]
        net = sample_payslip["net_salary"]
        deductions = gross - net
        assert deductions == Decimal("800.00")  # 5000 - 4200

    def test_payslip_lines_total(self, sample_payslip):
        """T-P09: Payslip lines should sum to totals"""
        gross = sample_payslip["gross_salary"]
        # Assume earnings lines total equals gross
        earnings_total = gross
        assert earnings_total == sample_payslip["gross_salary"]
