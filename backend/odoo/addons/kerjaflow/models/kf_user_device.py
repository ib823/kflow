# -*- coding: utf-8 -*-
"""
User Device Model - Device Management for Single-Device Sessions
================================================================

Table: kf_user_device
Tracks registered devices for push notifications and security enforcement.

Per CLAUDE.md:
- Single device session enforcement
- Push notification token management (FCM + HMS)
- Root/jailbreak detection tracking
- Biometric authentication status
"""

import secrets
from datetime import datetime, timedelta

from odoo.exceptions import ValidationError

from odoo import api, fields, models


class KfUserDevice(models.Model):
    _name = "kf.user.device"
    _description = "KerjaFlow User Device"
    _order = "last_active desc"
    _rec_name = "device_name"

    # Device Identification
    device_id = fields.Char(
        string="Device ID",
        required=True,
        index=True,
        help="Unique device identifier (ANDROID_ID or identifierForVendor)",
    )
    device_name = fields.Char(
        string="Device Name",
        help='User-friendly device name (e.g., "Samsung Galaxy S21")',
    )
    device_type = fields.Selection(
        selection=[
            ("phone", "Phone"),
            ("tablet", "Tablet"),
            ("unknown", "Unknown"),
        ],
        string="Device Type",
        default="phone",
    )
    os_type = fields.Selection(
        selection=[
            ("android", "Android"),
            ("ios", "iOS"),
            ("huawei", "HarmonyOS"),
        ],
        string="Operating System",
        required=True,
    )
    os_version = fields.Char(
        string="OS Version",
        help='Operating system version (e.g., "Android 14", "iOS 17.2")',
    )
    app_version = fields.Char(
        string="App Version",
        help='KerjaFlow app version (e.g., "1.0.0+1")',
    )

    # User Relationship
    user_id = fields.Many2one(
        comodel_name="kf.user",
        string="User",
        required=True,
        ondelete="cascade",
        index=True,
        help="The user who owns this device",
    )

    # Push Notification Tokens
    fcm_token = fields.Char(
        string="FCM Token",
        help="Firebase Cloud Messaging token for Android/iOS",
    )
    hms_token = fields.Char(
        string="HMS Token",
        help="Huawei Mobile Services push token",
    )
    push_token_updated_at = fields.Datetime(
        string="Push Token Updated",
        help="Last time push token was updated",
    )

    # Security Status
    is_trusted = fields.Boolean(
        string="Is Trusted",
        default=False,
        help="Device has been verified/trusted by user",
    )
    biometric_enabled = fields.Boolean(
        string="Biometric Enabled",
        default=False,
        help="Biometric authentication (fingerprint/face) is enabled",
    )
    root_detected = fields.Boolean(
        string="Root/Jailbreak Detected",
        default=False,
        help="Device appears to be rooted or jailbroken",
    )
    is_active = fields.Boolean(
        string="Is Active",
        default=True,
        help="Device is currently active (not logged out)",
    )

    # Session Management
    session_token = fields.Char(
        string="Session Token",
        help="Unique token for this device session",
    )
    last_active = fields.Datetime(
        string="Last Active",
        default=fields.Datetime.now,
        help="Last activity timestamp",
    )
    last_ip = fields.Char(
        string="Last IP Address",
        help="IP address of last request",
    )
    last_location = fields.Char(
        string="Last Location",
        help="Approximate location (country/city) from IP",
    )

    # Timestamps
    created_at = fields.Datetime(
        string="Registered At",
        default=fields.Datetime.now,
        readonly=True,
    )
    updated_at = fields.Datetime(
        string="Last Updated",
        default=fields.Datetime.now,
    )

    # SQL Constraints
    _sql_constraints = [
        (
            "device_user_unique",
            "UNIQUE(device_id, user_id)",
            "Device is already registered for this user",
        ),
    ]

    @api.model
    def create(self, vals):
        """Override create to generate session token and enforce single device."""
        vals["session_token"] = secrets.token_urlsafe(32)
        vals["created_at"] = datetime.now()
        vals["updated_at"] = datetime.now()

        # Single device enforcement: deactivate other devices for this user
        if vals.get("user_id"):
            self.search(
                [
                    ("user_id", "=", vals["user_id"]),
                    ("is_active", "=", True),
                ]
            ).write({"is_active": False})

        return super().create(vals)

    def write(self, vals):
        """Override write to update timestamp."""
        vals["updated_at"] = datetime.now()
        return super().write(vals)

    def action_trust_device(self):
        """Mark device as trusted."""
        self.ensure_one()
        self.write(
            {
                "is_trusted": True,
                "last_active": datetime.now(),
            }
        )
        return True

    def action_revoke_trust(self):
        """Revoke device trust."""
        self.ensure_one()
        self.write(
            {
                "is_trusted": False,
                "biometric_enabled": False,
            }
        )
        return True

    def action_logout(self):
        """Log out this device."""
        self.ensure_one()
        self.write(
            {
                "is_active": False,
                "session_token": False,
                "fcm_token": False,
                "hms_token": False,
            }
        )
        return True

    def update_push_token(self, fcm_token=None, hms_token=None):
        """Update push notification token."""
        self.ensure_one()
        vals = {"push_token_updated_at": datetime.now()}
        if fcm_token:
            vals["fcm_token"] = fcm_token
        if hms_token:
            vals["hms_token"] = hms_token
        self.write(vals)
        return True

    def record_activity(self, ip_address=None):
        """Record device activity."""
        self.ensure_one()
        vals = {"last_active": datetime.now()}
        if ip_address:
            vals["last_ip"] = ip_address
        self.write(vals)
        return True

    @api.model
    def register_device(self, user_id, device_data):
        """
        Register a new device or update existing one.

        Args:
            user_id: ID of kf.user
            device_data: dict with device_id, device_name, device_type,
                        os_type, os_version, app_version, fcm_token, hms_token

        Returns:
            kf.user.device record
        """
        existing = self.search(
            [
                ("user_id", "=", user_id),
                ("device_id", "=", device_data.get("device_id")),
            ],
            limit=1,
        )

        if existing:
            # Update existing device
            existing.write(
                {
                    "device_name": device_data.get("device_name"),
                    "os_version": device_data.get("os_version"),
                    "app_version": device_data.get("app_version"),
                    "fcm_token": device_data.get("fcm_token"),
                    "hms_token": device_data.get("hms_token"),
                    "is_active": True,
                    "last_active": datetime.now(),
                }
            )
            return existing
        else:
            # Create new device (will deactivate others)
            return self.create(
                {
                    "user_id": user_id,
                    "device_id": device_data.get("device_id"),
                    "device_name": device_data.get("device_name"),
                    "device_type": device_data.get("device_type", "phone"),
                    "os_type": device_data.get("os_type", "android"),
                    "os_version": device_data.get("os_version"),
                    "app_version": device_data.get("app_version"),
                    "fcm_token": device_data.get("fcm_token"),
                    "hms_token": device_data.get("hms_token"),
                }
            )

    @api.model
    def get_active_device(self, user_id):
        """Get the currently active device for a user."""
        return self.search(
            [
                ("user_id", "=", user_id),
                ("is_active", "=", True),
            ],
            limit=1,
        )

    @api.model
    def cleanup_inactive_devices(self, days=90):
        """
        Remove devices that have been inactive for specified days.
        Called by scheduled action.
        """
        cutoff = datetime.now() - timedelta(days=days)
        inactive = self.search(
            [
                ("last_active", "<", cutoff),
                ("is_active", "=", False),
            ]
        )
        count = len(inactive)
        inactive.unlink()
        return count
