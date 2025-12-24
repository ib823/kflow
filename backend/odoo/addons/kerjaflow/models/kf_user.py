# -*- coding: utf-8 -*-
"""
User Model - Authentication Account
====================================

Table: kf_user
Handles JWT + PIN authentication
"""

from odoo import models, fields, api
from odoo.exceptions import ValidationError
import bcrypt
import secrets
from datetime import datetime, timedelta


class KfUser(models.Model):
    _name = 'kf.user'
    _description = 'KerjaFlow User'
    _order = 'username'

    # Authentication
    username = fields.Char(
        string='Username',
        required=True,
        index=True,
        help='Unique login username',
    )
    password_hash = fields.Char(
        string='Password Hash',
        help='Bcrypt hashed password',
    )
    pin_hash = fields.Char(
        string='PIN Hash',
        help='Bcrypt hashed 6-digit PIN',
    )
    has_pin = fields.Boolean(
        string='Has PIN Setup',
        default=False,
        help='Whether user has set up PIN',
    )

    # Token Management
    refresh_token = fields.Char(
        string='Refresh Token',
        help='JWT refresh token',
    )
    refresh_token_expiry = fields.Datetime(
        string='Refresh Token Expiry',
    )
    fcm_token = fields.Char(
        string='FCM Token',
        help='Firebase Cloud Messaging token',
    )
    hms_token = fields.Char(
        string='HMS Token',
        help='Huawei Mobile Services token',
    )

    # Security
    failed_login_count = fields.Integer(
        string='Failed Login Count',
        default=0,
    )
    locked_until = fields.Datetime(
        string='Locked Until',
        help='Account lockout time',
    )
    failed_pin_count = fields.Integer(
        string='Failed PIN Count',
        default=0,
    )
    last_login = fields.Datetime(
        string='Last Login',
    )
    last_activity = fields.Datetime(
        string='Last Activity',
    )
    password_changed_at = fields.Datetime(
        string='Password Changed At',
    )

    # Device Information
    device_id = fields.Char(
        string='Device ID',
        help='Last logged in device ID',
    )
    device_info = fields.Char(
        string='Device Info',
        help='Device model/OS info',
    )

    # Role & Access
    role = fields.Selection(
        selection=[
            ('ADMIN', 'Administrator'),
            ('HR_MANAGER', 'HR Manager'),
            ('HR_EXEC', 'HR Executive'),
            ('SUPERVISOR', 'Supervisor'),
            ('EMPLOYEE', 'Employee'),
        ],
        string='Role',
        required=True,
        default='EMPLOYEE',
    )

    # Status
    is_active = fields.Boolean(
        string='Active',
        default=True,
    )

    # Relationships
    employee_id = fields.Many2one(
        comodel_name='kf.employee',
        string='Employee',
        required=True,
        ondelete='cascade',
        index=True,
    )
    company_id = fields.Many2one(
        related='employee_id.company_id',
        string='Company',
        store=True,
        index=True,
    )

    # SQL Constraints
    _sql_constraints = [
        ('username_unique', 'UNIQUE(username)', 'Username must be unique!'),
        ('employee_unique', 'UNIQUE(employee_id)', 'Employee can only have one user account!'),
    ]

    # Password Methods
    def set_password(self, password):
        """Hash and store password."""
        self.ensure_one()
        if len(password) < 8:
            raise ValidationError('Password must be at least 8 characters.')

        # Check complexity
        has_upper = any(c.isupper() for c in password)
        has_lower = any(c.islower() for c in password)
        has_digit = any(c.isdigit() for c in password)

        if not (has_upper and has_lower and has_digit):
            raise ValidationError(
                'Password must contain uppercase, lowercase and number.'
            )

        salt = bcrypt.gensalt(rounds=12)
        self.password_hash = bcrypt.hashpw(
            password.encode('utf-8'),
            salt
        ).decode('utf-8')
        self.password_changed_at = datetime.now()

    def verify_password(self, password):
        """Verify password against stored hash."""
        self.ensure_one()
        if not self.password_hash:
            return False
        return bcrypt.checkpw(
            password.encode('utf-8'),
            self.password_hash.encode('utf-8')
        )

    # PIN Methods
    def set_pin(self, pin):
        """Hash and store PIN."""
        self.ensure_one()
        if not pin or len(pin) != 6 or not pin.isdigit():
            raise ValidationError('PIN must be exactly 6 digits.')

        # Disallow weak PINs
        if self._is_weak_pin(pin):
            raise ValidationError('PIN is too weak. Avoid sequential or repeated digits.')

        salt = bcrypt.gensalt(rounds=10)
        self.pin_hash = bcrypt.hashpw(
            pin.encode('utf-8'),
            salt
        ).decode('utf-8')
        self.has_pin = True
        self.failed_pin_count = 0

    def verify_pin(self, pin):
        """Verify PIN against stored hash."""
        self.ensure_one()
        if not self.pin_hash:
            return False
        return bcrypt.checkpw(
            pin.encode('utf-8'),
            self.pin_hash.encode('utf-8')
        )

    def _is_weak_pin(self, pin):
        """Check if PIN is too weak."""
        # Sequential
        sequential = ['012345', '123456', '234567', '345678', '456789',
                      '567890', '987654', '876543', '765432', '654321']
        if pin in sequential:
            return True

        # All same digit
        if len(set(pin)) == 1:
            return True

        return False

    # Login Methods
    def record_login_attempt(self, success):
        """Record login attempt and handle lockout."""
        self.ensure_one()
        if success:
            self.failed_login_count = 0
            self.locked_until = False
            self.last_login = datetime.now()
        else:
            self.failed_login_count += 1
            if self.failed_login_count >= 5:
                # Progressive lockout: 15, 30, 60 minutes
                lockout_minutes = 15 * (2 ** min(self.failed_login_count - 5, 2))
                self.locked_until = datetime.now() + timedelta(minutes=lockout_minutes)

    def record_pin_attempt(self, success):
        """Record PIN attempt."""
        self.ensure_one()
        if success:
            self.failed_pin_count = 0
        else:
            self.failed_pin_count += 1

    def is_locked(self):
        """Check if account is locked."""
        self.ensure_one()
        if self.locked_until and self.locked_until > datetime.now():
            return True
        return False

    def get_lockout_minutes(self):
        """Get remaining lockout minutes."""
        self.ensure_one()
        if self.locked_until and self.locked_until > datetime.now():
            delta = self.locked_until - datetime.now()
            return max(1, int(delta.total_seconds() / 60))
        return 0

    def generate_refresh_token(self, days=7):
        """Generate and store refresh token."""
        self.ensure_one()
        token = secrets.token_urlsafe(64)
        self.refresh_token = token
        self.refresh_token_expiry = datetime.now() + timedelta(days=days)
        return token

    def invalidate_refresh_token(self):
        """Invalidate current refresh token."""
        self.ensure_one()
        self.refresh_token = False
        self.refresh_token_expiry = False
