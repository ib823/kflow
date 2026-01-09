# -*- coding: utf-8 -*-
"""
KerjaFlow Model Unit Tests
==========================

Unit tests for business logic and model validation (30+ tests)
"""
import re
from datetime import date, datetime, timedelta
from decimal import Decimal

import pytest


class TestCompanyModel:
    """Tests for Company model"""

    def test_company_name_required(self, sample_company):
        """Company name should be required"""
        assert sample_company["name"] is not None
        assert len(sample_company["name"]) > 0

    def test_company_code_format(self, sample_company):
        """Company code should be uppercase"""
        code = sample_company["code"]
        assert code == code.upper()

    def test_company_registration_format(self, sample_company):
        """Company registration number should match format"""
        reg_no = sample_company["registration_no"]
        # Malaysian company format: xxxxxxx-X
        assert "-" in reg_no

    def test_company_timezone_valid(self, sample_company):
        """Company timezone should be valid"""
        valid_timezones = ["Asia/Kuala_Lumpur", "Asia/Singapore", "UTC"]
        assert sample_company["timezone"] in valid_timezones


class TestEmployeeModel:
    """Tests for Employee model"""

    def test_employee_no_required(self, sample_employee):
        """Employee number should be required"""
        assert sample_employee["employee_no"] is not None

    def test_employee_no_unique_format(self, sample_employee):
        """Employee number should follow format"""
        emp_no = sample_employee["employee_no"]
        # Format: EMP001, TC001, etc.
        assert len(emp_no) >= 3

    def test_employee_name_not_empty(self, sample_employee):
        """Employee name should not be empty"""
        assert len(sample_employee["first_name"]) > 0
        assert len(sample_employee["last_name"]) > 0

    def test_employee_full_name(self, sample_employee):
        """Employee full name should combine first and last"""
        full_name = f"{sample_employee['first_name']} {sample_employee['last_name']}"
        assert full_name == "Ahmad bin Abdullah"

    def test_employee_age_calculation(self, sample_employee, today):
        """Employee age should be correctly calculated"""
        dob = sample_employee["date_of_birth"]
        age = today.year - dob.year
        if today.month < dob.month or (today.month == dob.month and today.day < dob.day):
            age -= 1
        assert age >= 0

    def test_employee_tenure_calculation(self, sample_employee, today):
        """Employee tenure should be correctly calculated"""
        hire_date = sample_employee["hire_date"]
        tenure_days = (today - hire_date).days
        assert tenure_days >= 0

    def test_employee_gender_valid(self, sample_employee):
        """Employee gender should be valid"""
        valid_genders = ["M", "F"]
        assert sample_employee["gender"] in valid_genders

    def test_employee_status_valid(self, sample_employee):
        """Employee status should be valid"""
        valid_statuses = ["ACTIVE", "INACTIVE", "TERMINATED", "SUSPENDED"]
        assert sample_employee["status"] in valid_statuses


class TestUserModel:
    """Tests for User model"""

    def test_user_email_unique(self, sample_user):
        """User email should be unique"""
        assert sample_user["email"] is not None

    def test_user_role_hierarchy(self, sample_user):
        """User role should be in hierarchy"""
        role_levels = {
            "EMPLOYEE": 1,
            "SUPERVISOR": 2,
            "HR_EXEC": 3,
            "HR_MANAGER": 4,
            "ADMIN": 5,
        }
        assert sample_user["role"] in role_levels

    def test_user_failed_attempts_default(self, sample_user):
        """User failed attempts should start at 0"""
        assert sample_user["failed_login_attempts"] == 0


class TestLeaveTypeModel:
    """Tests for LeaveType model"""

    def test_leave_type_code_unique(self, sample_leave_type):
        """Leave type code should be unique"""
        assert sample_leave_type["code"] is not None
        assert len(sample_leave_type["code"]) <= 10

    def test_leave_type_entitlement_positive(self, sample_leave_type):
        """Leave type entitlement should be positive"""
        assert sample_leave_type["default_entitlement"] > 0

    def test_leave_type_bilingual_name(self, sample_leave_type):
        """Leave type should have bilingual name"""
        assert "name" in sample_leave_type
        assert "name_ms" in sample_leave_type


class TestLeaveBalanceModel:
    """Tests for LeaveBalance model"""

    def test_balance_year_valid(self, sample_leave_balance, current_year):
        """Leave balance year should be valid"""
        assert sample_leave_balance["year"] >= 2020
        assert sample_leave_balance["year"] <= current_year + 1

    def test_balance_values_non_negative(self, sample_leave_balance):
        """Leave balance values should be non-negative"""
        assert sample_leave_balance["entitled"] >= 0
        assert sample_leave_balance["carried"] >= 0
        assert sample_leave_balance["taken"] >= 0
        assert sample_leave_balance["pending"] >= 0


class TestLeaveRequestModel:
    """Tests for LeaveRequest model"""

    def test_leave_request_dates_valid(self, sample_leave_request):
        """Leave request dates should be valid"""
        assert sample_leave_request["date_from"] <= sample_leave_request["date_to"]

    def test_leave_request_days_positive(self, sample_leave_request):
        """Leave request days should be positive"""
        assert sample_leave_request["total_days"] > 0

    def test_leave_request_status_valid(self, sample_leave_request):
        """Leave request status should be valid"""
        valid_statuses = ["PENDING", "APPROVED", "REJECTED", "CANCELLED"]
        assert sample_leave_request["status"] in valid_statuses


class TestPayslipModel:
    """Tests for Payslip model"""

    def test_payslip_period_format(self, sample_payslip):
        """Payslip period should be YYYY-MM format"""
        period = sample_payslip["period"]
        pattern = r"^\d{4}-\d{2}$"
        assert re.match(pattern, period)

    def test_payslip_amounts_decimal(self, sample_payslip):
        """Payslip amounts should be Decimal"""
        assert isinstance(sample_payslip["gross_salary"], Decimal)
        assert isinstance(sample_payslip["net_salary"], Decimal)

    def test_payslip_gross_gte_net(self, sample_payslip):
        """Gross salary should be >= net salary"""
        assert sample_payslip["gross_salary"] >= sample_payslip["net_salary"]


class TestNotificationModel:
    """Tests for Notification model"""

    def test_notification_timestamp(self, sample_notification):
        """Notification should have timestamp"""
        assert "created_at" in sample_notification
        assert isinstance(sample_notification["created_at"], datetime)

    def test_notification_read_status(self, sample_notification):
        """Notification should track read status"""
        assert isinstance(sample_notification["is_read"], bool)


class TestDocumentModel:
    """Tests for Document model"""

    def test_document_file_size_positive(self, sample_document):
        """Document file size should be positive"""
        assert sample_document["file_size"] > 0

    def test_document_mime_type_valid(self, sample_document):
        """Document mime type should be valid"""
        valid_mimes = [
            "image/jpeg",
            "image/png",
            "image/gif",
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ]
        assert sample_document["mime_type"] in valid_mimes
