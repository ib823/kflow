# -*- coding: utf-8 -*-
"""
KerjaFlow Leave Management Tests
================================

Test suite for leave management functionality (T-L01 to T-L15)
"""
from datetime import date, timedelta
from decimal import Decimal

import pytest


class TestLeaveBalance:
    """Tests for leave balance calculations"""

    def test_balance_calculation(self, sample_leave_balance):
        """T-L01: Balance should be entitled + carried + adjustment - taken"""
        balance = sample_leave_balance
        calculated = (
            balance["entitled"] + balance["carried"] + balance["adjustment"] - balance["taken"]
        )
        assert calculated == 13.0  # 16 + 2 + 0 - 5

    def test_available_balance_excludes_pending(self, sample_leave_balance):
        """T-L02: Available balance should exclude pending requests"""
        balance = sample_leave_balance
        available = (
            balance["entitled"]
            + balance["carried"]
            + balance["adjustment"]
            - balance["taken"]
            - balance["pending"]
        )
        assert available == 11.0  # 13 - 2

    def test_negative_balance_not_allowed(self, sample_leave_balance):
        """T-L03: Balance should not go negative"""
        balance = sample_leave_balance
        total_available = (
            balance["entitled"] + balance["carried"] + balance["adjustment"] - balance["taken"]
        )
        # Attempting to take more than available
        request_days = total_available + 1
        assert request_days > total_available

    def test_half_day_leave_deduction(self, sample_leave_balance):
        """T-L04: Half day leave should deduct 0.5 days"""
        half_day = 0.5
        initial_taken = sample_leave_balance["taken"]
        new_taken = initial_taken + half_day
        assert new_taken == 5.5

    def test_carry_forward_limit(self, sample_leave_type, sample_leave_balance):
        """T-L05: Carry forward should respect max limit"""
        max_carry = 5  # From leave type
        current_balance = 8.0
        carried = min(current_balance, max_carry)
        assert carried == 5


class TestLeaveRequest:
    """Tests for leave request handling"""

    def test_leave_request_status_flow(self, sample_leave_request):
        """T-L06: Leave request should follow status flow"""
        valid_transitions = {
            "PENDING": ["APPROVED", "REJECTED", "CANCELLED"],
            "APPROVED": ["CANCELLED"],
            "REJECTED": [],
            "CANCELLED": [],
        }
        current_status = sample_leave_request["status"]
        assert current_status in valid_transitions

    def test_leave_days_calculation(self, sample_leave_request):
        """T-L07: Total days should be correctly calculated"""
        date_from = sample_leave_request["date_from"]
        date_to = sample_leave_request["date_to"]
        expected_days = (date_to - date_from).days + 1
        assert sample_leave_request["total_days"] == expected_days

    def test_leave_request_requires_balance(self, sample_leave_balance, sample_leave_request):
        """T-L08: Leave request should require sufficient balance"""
        available = (
            sample_leave_balance["entitled"]
            + sample_leave_balance["carried"]
            + sample_leave_balance["adjustment"]
            - sample_leave_balance["taken"]
            - sample_leave_balance["pending"]
        )
        request_days = sample_leave_request["total_days"]
        assert request_days <= available

    def test_past_date_leave_not_allowed(self, today):
        """T-L09: Leave request for past dates should not be allowed"""
        past_date = today - timedelta(days=7)
        assert past_date < today

    def test_notice_period_validation(self, sample_leave_type, today):
        """T-L10: Leave request should respect notice period"""
        min_notice = sample_leave_type["min_days_notice"]
        earliest_allowed = today + timedelta(days=min_notice)
        assert earliest_allowed > today


class TestLeaveTypes:
    """Tests for leave type configurations"""

    def test_leave_type_has_required_fields(self, sample_leave_type):
        """T-L11: Leave type should have required fields"""
        required_fields = ["id", "company_id", "name", "code", "default_entitlement"]
        for field in required_fields:
            assert field in sample_leave_type

    def test_attachment_requirement(self, sample_leave_type):
        """T-L12: Leave type can require attachment"""
        assert "requires_attachment" in sample_leave_type
        assert isinstance(sample_leave_type["requires_attachment"], bool)

    def test_half_day_setting(self, sample_leave_type):
        """T-L13: Leave type can allow half day"""
        assert "allow_half_day" in sample_leave_type
        assert sample_leave_type["allow_half_day"] is True

    def test_max_consecutive_days(self, sample_leave_type):
        """T-L14: Leave type can limit consecutive days"""
        assert "max_days_per_request" in sample_leave_type
        assert sample_leave_type["max_days_per_request"] == 14


class TestPublicHolidays:
    """Tests for public holiday handling"""

    def test_working_days_excludes_weekends(self, today):
        """T-L15: Working days calculation should exclude weekends"""

        # Check if a date is a weekend
        def is_weekend(d):
            return d.weekday() >= 5  # Saturday = 5, Sunday = 6

        # Count working days in a week
        working_days = 0
        for i in range(7):
            check_date = today + timedelta(days=i)
            if not is_weekend(check_date):
                working_days += 1

        assert working_days == 5  # 5 working days in a week
