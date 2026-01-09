# -*- coding: utf-8 -*-
"""
KerjaFlow Leave Tests
=====================

Unit tests for leave management models:
- kf.leave.type
- kf.leave.balance
- kf.leave.request
- kf.public.holiday
"""

from datetime import date, timedelta

from odoo.exceptions import ValidationError
from odoo.tests import tagged

from .common import KerjaFlowTestCase


@tagged("kerjaflow", "-at_install", "post_install")
class TestLeaveType(KerjaFlowTestCase):
    """Test cases for kf.leave.type model."""

    def test_leave_type_creation(self):
        """Test basic leave type creation."""
        self.assertTrue(self.leave_type_annual.id)
        self.assertEqual(self.leave_type_annual.code, "AL")
        self.assertEqual(self.leave_type_annual.name, "Annual Leave")
        self.assertEqual(self.leave_type_annual.default_entitlement, 14)

    def test_leave_type_unique_code(self):
        """Test unique code constraint per company."""
        with self.assertRaises(Exception):
            self.env["kf.leave.type"].create(
                {
                    "company_id": self.company.id,
                    "code": "AL",  # Same as existing
                    "name": "Another Annual Leave",
                    "default_entitlement": 10,
                    "is_visible": True,
                    "is_active": True,
                }
            )

    def test_leave_type_half_day_setting(self):
        """Test half day configuration."""
        self.assertTrue(self.leave_type_annual.allow_half_day)
        self.assertTrue(self.leave_type_medical.allow_half_day)

    def test_leave_type_attachment_requirement(self):
        """Test attachment requirement setting."""
        self.assertFalse(self.leave_type_annual.requires_attachment)
        self.assertTrue(self.leave_type_medical.requires_attachment)


@tagged("kerjaflow", "-at_install", "post_install")
class TestLeaveBalance(KerjaFlowTestCase):
    """Test cases for kf.leave.balance model."""

    def test_leave_balance_creation(self):
        """Test leave balance creation."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)
        self.assertTrue(balance.id)
        self.assertEqual(balance.entitled, 14)
        self.assertEqual(balance.year, date.today().year)

    def test_leave_balance_calculation(self):
        """Test balance computed field."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)
        # Balance = entitled + carried + adjustment - taken
        self.assertEqual(balance.balance, 14)

        # Update taken
        balance.write({"taken": 5})
        self.assertEqual(balance.balance, 9)

    def test_leave_balance_available(self):
        """Test available balance computation."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)
        # Available = balance - pending
        self.assertEqual(balance.available, 14)

        # Update pending
        balance.write({"pending": 3})
        self.assertEqual(balance.available, 11)

    def test_leave_balance_unique_constraint(self):
        """Test unique employee/leave_type/year constraint."""
        self._create_leave_balance(self.employee, self.leave_type_annual, year=2025)

        with self.assertRaises(Exception):
            self._create_leave_balance(self.employee, self.leave_type_annual, year=2025)  # Same combination

    def test_leave_balance_get_or_create(self):
        """Test get_or_create_balance helper method."""
        LeaveBalance = self.env["kf.leave.balance"]

        # First call should create
        balance1 = LeaveBalance.get_or_create_balance(self.employee.id, self.leave_type_annual.id, 2026)
        self.assertTrue(balance1.id)

        # Second call should return existing
        balance2 = LeaveBalance.get_or_create_balance(self.employee.id, self.leave_type_annual.id, 2026)
        self.assertEqual(balance1.id, balance2.id)

    def test_leave_balance_update_pending(self):
        """Test pending balance update helper."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)
        self.assertEqual(balance.pending, 0)

        # Add pending
        balance.update_pending(3, add=True)
        self.assertEqual(balance.pending, 3)

        # Remove pending
        balance.update_pending(1, add=False)
        self.assertEqual(balance.pending, 2)

    def test_leave_balance_update_taken(self):
        """Test taken balance update helper."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)
        self.assertEqual(balance.taken, 0)

        # Add taken
        balance.update_taken(5, add=True)
        self.assertEqual(balance.taken, 5)

        # Remove taken (e.g., cancelled leave)
        balance.update_taken(2, add=False)
        self.assertEqual(balance.taken, 3)


@tagged("kerjaflow", "-at_install", "post_install")
class TestLeaveRequest(KerjaFlowTestCase):
    """Test cases for kf.leave.request model."""

    def test_leave_request_creation(self):
        """Test basic leave request creation."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=7),
            date_to=date.today() + timedelta(days=8),
        )
        self.assertTrue(request.id)
        self.assertEqual(request.status, "PENDING")

    def test_leave_request_total_days(self):
        """Test total days calculation."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=10),
            date_to=date.today() + timedelta(days=12),
        )
        self.assertEqual(request.total_days, 3)

    def test_leave_request_half_day(self):
        """Test half day leave request."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=14),
            date_to=date.today() + timedelta(days=14),
            half_day_type="AM",
            total_days=0.5,
        )
        self.assertEqual(request.total_days, 0.5)
        self.assertEqual(request.half_day_type, "AM")

    def test_leave_request_approve(self):
        """Test leave request approval."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=20),
            date_to=date.today() + timedelta(days=21),
        )
        balance.write({"pending": 2})

        request.action_approve(self.manager_employee.id)

        self.assertEqual(request.status, "APPROVED")
        self.assertEqual(request.approver_id.id, self.manager_employee.id)
        self.assertTrue(request.approved_at)

    def test_leave_request_reject(self):
        """Test leave request rejection."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=25),
            date_to=date.today() + timedelta(days=26),
        )
        balance.write({"pending": 2})

        request.action_reject(self.manager_employee.id, "Not approved - busy period")

        self.assertEqual(request.status, "REJECTED")
        self.assertEqual(request.rejection_reason, "Not approved - busy period")

    def test_leave_request_cancel(self):
        """Test leave request cancellation."""
        balance = self._create_leave_balance(self.employee, self.leave_type_annual)

        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=30),
            date_to=date.today() + timedelta(days=31),
        )
        balance.write({"pending": 2})

        request.action_cancel()

        self.assertEqual(request.status, "CANCELLED")

    def test_leave_request_can_cancel(self):
        """Test can_cancel computed field."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        # Pending request can be cancelled
        request = self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=35),
            date_to=date.today() + timedelta(days=36),
        )
        self.assertTrue(request.can_cancel)

        # Rejected request cannot be cancelled
        request.write({"status": "REJECTED"})
        self.assertFalse(request.can_cancel)

    def test_leave_request_date_validation(self):
        """Test date from must be before date to."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        with self.assertRaises(ValidationError):
            self._create_leave_request(
                self.employee,
                self.leave_type_annual,
                date_from=date.today() + timedelta(days=45),
                date_to=date.today() + timedelta(days=40),  # Before date_from
            )

    def test_leave_request_overlap_validation(self):
        """Test overlapping leave request validation."""
        self._create_leave_balance(self.employee, self.leave_type_annual)

        # Create first request
        self._create_leave_request(
            self.employee,
            self.leave_type_annual,
            date_from=date.today() + timedelta(days=50),
            date_to=date.today() + timedelta(days=52),
            status="APPROVED",
        )

        # Overlapping request should fail
        with self.assertRaises(ValidationError):
            self._create_leave_request(
                self.employee,
                self.leave_type_annual,
                date_from=date.today() + timedelta(days=51),
                date_to=date.today() + timedelta(days=53),
            )


@tagged("kerjaflow", "-at_install", "post_install")
class TestPublicHoliday(KerjaFlowTestCase):
    """Test cases for kf.public.holiday model."""

    def test_public_holiday_creation(self):
        """Test public holiday creation."""
        holiday = self.env["kf.public.holiday"].create(
            {
                "company_id": self.company.id,
                "name": "National Day",
                "name_ms": "Hari Kebangsaan",
                "date": date(2025, 8, 31),
                "holiday_type": "FEDERAL",
                "is_active": True,
            }
        )
        self.assertTrue(holiday.id)
        self.assertEqual(holiday.name, "National Day")

    def test_public_holiday_state_specific(self):
        """Test state-specific holiday."""
        holiday = self.env["kf.public.holiday"].create(
            {
                "company_id": self.company.id,
                "name": "Sultan of Selangor Birthday",
                "name_ms": "Hari Keputeraan Sultan Selangor",
                "date": date(2025, 12, 11),
                "holiday_type": "STATE",
                "state": "SGR",
                "is_active": True,
            }
        )
        self.assertEqual(holiday.state, "SGR")
        self.assertEqual(holiday.holiday_type, "STATE")

    def test_public_holiday_unique_date(self):
        """Test unique date constraint per company."""
        self.env["kf.public.holiday"].create(
            {
                "company_id": self.company.id,
                "name": "Holiday 1",
                "date": date(2025, 1, 1),
                "holiday_type": "FEDERAL",
                "is_active": True,
            }
        )

        with self.assertRaises(Exception):
            self.env["kf.public.holiday"].create(
                {
                    "company_id": self.company.id,
                    "name": "Holiday 2",
                    "date": date(2025, 1, 1),  # Same date
                    "holiday_type": "FEDERAL",
                    "is_active": True,
                }
            )

    def test_public_holiday_is_holiday_check(self):
        """Test is_holiday method."""
        PublicHoliday = self.env["kf.public.holiday"]

        PublicHoliday.create(
            {
                "company_id": self.company.id,
                "name": "Test Holiday",
                "date": date(2025, 7, 4),
                "holiday_type": "FEDERAL",
                "is_active": True,
            }
        )

        # Federal holiday should match any state
        self.assertTrue(PublicHoliday.is_holiday(self.company.id, date(2025, 7, 4)))
        self.assertFalse(PublicHoliday.is_holiday(self.company.id, date(2025, 7, 5)))
