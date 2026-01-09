# -*- coding: utf-8 -*-
"""
KerjaFlow User Tests
====================

Unit tests for kf.user model including authentication and PIN management.
"""

from datetime import datetime, timedelta

from odoo.exceptions import ValidationError
from odoo.tests import tagged

from .common import KerjaFlowTestCase


@tagged("kerjaflow", "-at_install", "post_install")
class TestUser(KerjaFlowTestCase):
    """Test cases for kf.user model."""

    def test_user_creation(self):
        """Test basic user creation."""
        self.assertTrue(self.user.id)
        self.assertEqual(self.user.email, "john.doe@testcompany.my")
        self.assertEqual(self.user.role, "EMPLOYEE")
        self.assertEqual(self.user.status, "ACTIVE")

    def test_user_set_password(self):
        """Test password hashing."""
        self.user.set_password("SecurePassword123!")
        self.assertTrue(self.user.password_hash)
        self.assertNotEqual(self.user.password_hash, "SecurePassword123!")

    def test_user_verify_password(self):
        """Test password verification."""
        password = "SecurePassword123!"
        self.user.set_password(password)
        self.assertTrue(self.user.verify_password(password))
        self.assertFalse(self.user.verify_password("WrongPassword"))

    def test_user_set_pin(self):
        """Test PIN hashing."""
        self.user.set_pin("123456")
        self.assertTrue(self.user.pin_hash)
        self.assertNotEqual(self.user.pin_hash, "123456")
        self.assertTrue(self.user.pin_set_at)

    def test_user_verify_pin(self):
        """Test PIN verification."""
        pin = "654321"
        self.user.set_pin(pin)
        self.assertTrue(self.user.verify_pin(pin))
        self.assertFalse(self.user.verify_pin("000000"))

    def test_user_pin_validation(self):
        """Test PIN format validation."""
        # PIN must be 6 digits
        with self.assertRaises(ValidationError):
            self.user.set_pin("12345")  # Too short

        with self.assertRaises(ValidationError):
            self.user.set_pin("1234567")  # Too long

        with self.assertRaises(ValidationError):
            self.user.set_pin("abcdef")  # Not digits

    def test_user_lockout_on_failed_attempts(self):
        """Test account lockout after failed login attempts."""
        self.user.set_password("CorrectPassword")

        # Simulate 5 failed attempts
        for _ in range(5):
            self.user.verify_password("WrongPassword")

        self.assertEqual(self.user.failed_login_count, 5)
        self.assertTrue(self.user.is_locked)
        self.assertTrue(self.user.locked_until)

    def test_user_unlock_after_timeout(self):
        """Test account unlock after lockout period."""
        self.user.set_password("CorrectPassword")

        # Lock the account
        self.user.write(
            {
                "failed_login_count": 5,
                "locked_until": datetime.now() - timedelta(minutes=1),
            }
        )

        # After lockout period, account should be unlockable
        self.user._check_lockout()
        self.assertFalse(self.user.is_locked)

    def test_user_record_login(self):
        """Test login recording."""
        ip_address = "192.168.1.100"
        device_info = "Test Device"

        self.user.record_login(ip_address, device_info)

        self.assertEqual(self.user.last_login_ip, ip_address)
        self.assertEqual(self.user.device_info, device_info)
        self.assertTrue(self.user.last_login_at)

    def test_user_role_permissions(self):
        """Test role-based access levels."""
        # Test different roles
        roles = ["EMPLOYEE", "SUPERVISOR", "HR_EXEC", "HR_MANAGER", "ADMIN"]

        for role in roles:
            user = self.env["kf.user"].create(
                {
                    "employee_id": self.employee.id,
                    "company_id": self.company.id,
                    "email": f"{role.lower()}@testcompany.my",
                    "role": role,
                    "status": "ACTIVE",
                }
            )
            self.assertEqual(user.role, role)
            user.unlink()

    def test_user_unique_email(self):
        """Test unique email constraint."""
        with self.assertRaises(Exception):
            self.env["kf.user"].create(
                {
                    "employee_id": self.manager_employee.id,
                    "company_id": self.company.id,
                    "email": "john.doe@testcompany.my",  # Same as existing user
                    "role": "EMPLOYEE",
                    "status": "ACTIVE",
                }
            )

    def test_user_deactivate(self):
        """Test user deactivation."""
        self.user.action_deactivate()
        self.assertEqual(self.user.status, "INACTIVE")

    def test_user_reactivate(self):
        """Test user reactivation."""
        self.user.action_deactivate()
        self.user.action_reactivate()
        self.assertEqual(self.user.status, "ACTIVE")

    def test_user_fcm_token(self):
        """Test FCM token management."""
        fcm_token = "test_fcm_token_12345"
        self.user.update_fcm_token(fcm_token)
        self.assertEqual(self.user.fcm_token, fcm_token)
        self.assertTrue(self.user.fcm_token_updated_at)

    def test_user_hms_token(self):
        """Test HMS token management."""
        hms_token = "test_hms_token_67890"
        self.user.update_hms_token(hms_token)
        self.assertEqual(self.user.hms_token, hms_token)
        self.assertTrue(self.user.hms_token_updated_at)

    def test_user_password_change(self):
        """Test password change with old password verification."""
        old_password = "OldPassword123!"
        new_password = "NewPassword456!"

        self.user.set_password(old_password)

        # Should succeed with correct old password
        result = self.user.change_password(old_password, new_password)
        self.assertTrue(result)
        self.assertTrue(self.user.verify_password(new_password))

        # Should fail with wrong old password
        result = self.user.change_password("WrongPassword", "AnotherNew789!")
        self.assertFalse(result)

    def test_user_force_password_change(self):
        """Test forced password change flag."""
        self.user.write({"force_password_change": True})
        self.assertTrue(self.user.force_password_change)

        self.user.set_password("NewSecurePassword!")
        self.assertFalse(self.user.force_password_change)
