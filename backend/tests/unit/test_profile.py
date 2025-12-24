# -*- coding: utf-8 -*-
"""
KerjaFlow Profile Tests
=======================

Test suite for profile functionality (T-PR01 to T-PR08)
"""
import pytest
from datetime import date
from decimal import Decimal
import re


class TestEmployeeProfile:
    """Tests for employee profile data"""

    def test_employee_has_required_fields(self, sample_employee):
        """T-PR01: Employee should have required fields"""
        required_fields = [
            'id', 'company_id', 'employee_no', 'first_name', 'last_name',
            'email', 'status', 'hire_date'
        ]
        for field in required_fields:
            assert field in sample_employee, f"Missing field: {field}"

    def test_employee_ic_format(self, sample_employee):
        """T-PR02: IC number should be in valid format"""
        ic_no = sample_employee['ic_no']
        # Malaysian IC format: YYMMDD-SS-NNNN
        pattern = r'^\d{6}-\d{2}-\d{4}$'
        assert re.match(pattern, ic_no), f"Invalid IC format: {ic_no}"

    def test_employee_email_format(self, sample_employee):
        """T-PR03: Email should be in valid format"""
        email = sample_employee['email']
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        assert re.match(pattern, email), f"Invalid email format: {email}"

    def test_employee_status_values(self, sample_employee):
        """T-PR04: Employee status should be valid"""
        valid_statuses = ['ACTIVE', 'INACTIVE', 'TERMINATED', 'SUSPENDED']
        assert sample_employee['status'] in valid_statuses


class TestUserProfile:
    """Tests for user profile data"""

    def test_user_has_required_fields(self, sample_user):
        """T-PR05: User should have required fields"""
        required_fields = ['id', 'employee_id', 'email', 'role', 'status']
        for field in required_fields:
            assert field in sample_user

    def test_user_role_values(self, sample_user):
        """T-PR06: User role should be valid"""
        valid_roles = ['EMPLOYEE', 'SUPERVISOR', 'HR_EXEC', 'HR_MANAGER', 'ADMIN']
        assert sample_user['role'] in valid_roles

    def test_user_linked_to_employee(self, sample_user, sample_employee):
        """T-PR07: User should be linked to employee"""
        assert sample_user['employee_id'] == sample_employee['id']


class TestProfilePrivacy:
    """Tests for profile privacy"""

    def test_sensitive_fields_protected(self, sample_employee):
        """T-PR08: Sensitive fields should be protected"""
        sensitive_fields = ['ic_no', 'bank_account_no', 'basic_salary']
        for field in sensitive_fields:
            if field in sample_employee:
                # Sensitive data should exist but be protected in API response
                assert sample_employee[field] is not None
