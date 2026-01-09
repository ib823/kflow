# -*- coding: utf-8 -*-
"""
KerjaFlow Authentication Controller
====================================

Endpoints:
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout
- POST /auth/pin/setup
- POST /auth/pin/verify
- POST /auth/password/change
"""

import json
import secrets
from datetime import datetime, timedelta

import jwt
from odoo.http import request

from odoo import http

from .main import KerjaFlowController


class AuthController(KerjaFlowController):
    """Authentication API endpoints."""

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/login",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def login(self):
        """
        POST /auth/login
        Authenticate user with username and password.

        Request:
        {
            "username": "john.doe",
            "password": "Password123",
            "device_id": "abc123",
            "device_info": "iPhone 15 Pro, iOS 17.2",
            "fcm_token": "...",
            "hms_token": "..."
        }

        Response (200):
        {
            "access_token": "eyJ...",
            "refresh_token": "abc...",
            "expires_at": "2025-12-25T10:30:00+08:00",
            "user": {
                "id": 1,
                "employee_id": 123,
                "full_name": "John Doe",
                "role": "EMPLOYEE",
                "has_pin": true,
                "company": {...}
            }
        }
        """
        try:
            data = json.loads(request.httprequest.data or "{}")
        except json.JSONDecodeError:
            return self._error_response(
                "VALIDATION_ERROR",
                "Invalid JSON body",
            )

        username = data.get("username")
        password = data.get("password")
        device_id = data.get("device_id")
        device_info = data.get("device_info")
        fcm_token = data.get("fcm_token")
        hms_token = data.get("hms_token")

        if not username or not password:
            return self._error_response(
                "VALIDATION_ERROR",
                "Username and password are required",
            )

        # Get IP and user agent for audit
        ip_address = request.httprequest.remote_addr
        user_agent = request.httprequest.headers.get("User-Agent")

        # Find user
        User = request.env["kf.user"].sudo()
        user = User.search([("username", "=", username)], limit=1)

        if not user:
            # Log failed attempt (no user found)
            request.env["kf.audit.log"].sudo().log_login(
                user_id=None,
                success=False,
                ip_address=ip_address,
                user_agent=user_agent,
            )
            return self._error_response(
                "INVALID_CREDENTIALS",
                "Invalid username or password",
                status=401,
            )

        # Check if account is locked
        if user.is_locked():
            minutes = user.get_lockout_minutes()
            return self._error_response(
                "ACCOUNT_LOCKED",
                f"Account locked. Try again in {minutes} minutes",
                {"minutes": minutes},
                status=423,
            )

        # Check if account is active
        if not user.is_active:
            return self._error_response(
                "ACCOUNT_INACTIVE",
                "User account is deactivated",
                status=403,
            )

        # Verify password
        if not user.verify_password(password):
            user.record_login_attempt(success=False)
            request.env["kf.audit.log"].sudo().log_login(
                user_id=user.id,
                success=False,
                ip_address=ip_address,
                user_agent=user_agent,
            )

            # Check if now locked
            if user.is_locked():
                minutes = user.get_lockout_minutes()
                return self._error_response(
                    "ACCOUNT_LOCKED",
                    f"Account locked. Try again in {minutes} minutes",
                    {"minutes": minutes},
                    status=423,
                )

            return self._error_response(
                "INVALID_CREDENTIALS",
                "Invalid username or password",
                status=401,
            )

        # Successful login
        user.record_login_attempt(success=True)

        # Generate tokens
        access_token, expires_at = self._generate_access_token(user)
        refresh_token = user.generate_refresh_token()

        # Update device info
        user.write(
            {
                "device_id": device_id,
                "device_info": device_info,
                "fcm_token": fcm_token,
                "hms_token": hms_token,
                "last_activity": datetime.now(),
            }
        )

        # Log successful login
        request.env["kf.audit.log"].sudo().log_login(
            user_id=user.id,
            success=True,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        # Build response
        employee = user.employee_id
        company = employee.company_id

        return self._json_response(
            {
                "access_token": access_token,
                "refresh_token": refresh_token,
                "expires_at": expires_at.isoformat(),
                "user": {
                    "id": user.id,
                    "employee_id": employee.id,
                    "full_name": employee.full_name,
                    "role": user.role,
                    "has_pin": user.has_pin,
                    "preferred_lang": employee.preferred_lang or "en",
                    "company": {
                        "id": company.id,
                        "name": company.name,
                        "logo_url": company.logo_url,
                    },
                },
            }
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/refresh",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def refresh_token(self):
        """
        POST /auth/refresh
        Refresh access token using refresh token.
        """
        try:
            data = json.loads(request.httprequest.data or "{}")
        except json.JSONDecodeError:
            return self._error_response(
                "VALIDATION_ERROR",
                "Invalid JSON body",
            )

        refresh_token = data.get("refresh_token")
        if not refresh_token:
            return self._error_response(
                "VALIDATION_ERROR",
                "Refresh token is required",
            )

        # Find user with this refresh token
        User = request.env["kf.user"].sudo()
        user = User.search(
            [
                ("refresh_token", "=", refresh_token),
                ("is_active", "=", True),
            ],
            limit=1,
        )

        if not user:
            return self._error_response(
                "REFRESH_TOKEN_INVALID",
                "Refresh token is invalid",
                status=401,
            )

        # Check expiry
        if user.refresh_token_expiry and user.refresh_token_expiry < datetime.now():
            return self._error_response(
                "REFRESH_TOKEN_EXPIRED",
                "Refresh token has expired, please login again",
                status=401,
            )

        # Generate new access token
        access_token, expires_at = self._generate_access_token(user)

        # Update last activity
        user.last_activity = datetime.now()

        return self._json_response(
            {
                "access_token": access_token,
                "expires_at": expires_at.isoformat(),
            }
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/logout",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def logout(self):
        """
        POST /auth/logout
        Invalidate refresh token.
        """
        # Get user from token
        user = self._get_user_from_token()
        if user:
            user.invalidate_refresh_token()
            user.fcm_token = False
            user.hms_token = False

            request.env["kf.audit.log"].sudo().log(
                action="LOGOUT",
                user_id=user.id,
                company_id=user.company_id.id,
            )

        return self._json_response({"success": True})

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/pin/setup",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def pin_setup(self):
        """
        POST /auth/pin/setup
        Set up 6-digit PIN for quick login.

        Request:
        {
            "password": "CurrentPassword123",
            "pin": "123456"
        }
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response(
                "TOKEN_INVALID",
                "Invalid access token",
                status=401,
            )

        try:
            data = json.loads(request.httprequest.data or "{}")
        except json.JSONDecodeError:
            return self._error_response(
                "VALIDATION_ERROR",
                "Invalid JSON body",
            )

        password = data.get("password")
        pin = data.get("pin")

        if not password:
            return self._error_response(
                "VALIDATION_ERROR",
                "Current password is required",
            )

        if not pin:
            return self._error_response(
                "VALIDATION_ERROR",
                "PIN is required",
            )

        # Verify password first
        if not user.verify_password(password):
            return self._error_response(
                "INVALID_CREDENTIALS",
                "Current password is incorrect",
                status=401,
            )

        # Set PIN
        try:
            user.set_pin(pin)
        except Exception as e:
            return self._error_response(
                "VALIDATION_ERROR",
                str(e),
            )

        request.env["kf.audit.log"].sudo().log(
            action="PIN_SETUP",
            user_id=user.id,
            company_id=user.company_id.id,
        )

        return self._json_response({"success": True})

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/pin/verify",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def pin_verify(self):
        """
        POST /auth/pin/verify
        Verify PIN and return verification token.

        Request: { "pin": "123456" }
        Response: { "verification_token": "...", "expires_at": "..." }
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response(
                "TOKEN_INVALID",
                "Invalid access token",
                status=401,
            )

        if not user.has_pin:
            return self._error_response(
                "PIN_NOT_SET",
                "User has not set up a PIN",
            )

        try:
            data = json.loads(request.httprequest.data or "{}")
        except json.JSONDecodeError:
            return self._error_response(
                "VALIDATION_ERROR",
                "Invalid JSON body",
            )

        pin = data.get("pin")
        if not pin:
            return self._error_response(
                "VALIDATION_ERROR",
                "PIN is required",
            )

        # Check failed attempts
        if user.failed_pin_count >= 5:
            return self._error_response(
                "PIN_LOCKED",
                "Too many failed attempts. Please use password to login.",
                status=423,
            )

        # Verify PIN
        if not user.verify_pin(pin):
            user.record_pin_attempt(success=False)
            remaining = max(0, 5 - user.failed_pin_count)
            return self._error_response(
                "INVALID_PIN",
                f"Invalid PIN. {remaining} attempts remaining",
                {"remaining": remaining},
                status=401,
            )

        user.record_pin_attempt(success=True)

        # Generate verification token (valid for 5 minutes)
        verification_token = secrets.token_urlsafe(32)
        expires_at = datetime.now() + timedelta(minutes=5)

        # Store token (in production, use Redis)
        # For now, we'll use a simple approach
        # TODO: Implement proper token storage

        request.env["kf.audit.log"].sudo().log(
            action="PIN_VERIFY",
            user_id=user.id,
            company_id=user.company_id.id,
        )

        return self._json_response(
            {
                "verification_token": verification_token,
                "expires_at": expires_at.isoformat(),
            }
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/auth/password/change",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def password_change(self):
        """
        POST /auth/password/change
        Change password.

        Request:
        {
            "current_password": "OldPassword123",
            "new_password": "NewPassword456"
        }
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response(
                "TOKEN_INVALID",
                "Invalid access token",
                status=401,
            )

        try:
            data = json.loads(request.httprequest.data or "{}")
        except json.JSONDecodeError:
            return self._error_response(
                "VALIDATION_ERROR",
                "Invalid JSON body",
            )

        current_password = data.get("current_password")
        new_password = data.get("new_password")

        if not current_password or not new_password:
            return self._error_response(
                "VALIDATION_ERROR",
                "Current and new password are required",
            )

        # Verify current password
        if not user.verify_password(current_password):
            return self._error_response(
                "INVALID_CREDENTIALS",
                "Current password is incorrect",
                status=401,
            )

        # Check if same password
        if current_password == new_password:
            return self._error_response(
                "PASSWORD_SAME",
                "New password must be different from current password",
            )

        # Set new password
        try:
            user.set_password(new_password)
        except Exception as e:
            return self._error_response(
                "PASSWORD_TOO_WEAK",
                str(e),
            )

        request.env["kf.audit.log"].sudo().log(
            action="PASSWORD_CHANGE",
            user_id=user.id,
            company_id=user.company_id.id,
        )

        return self._json_response({"success": True})

    # Helper methods

    def _generate_access_token(self, user):
        """Generate JWT access token using RS256."""
        from ..config import config

        # Use private key for signing (RS256)
        private_key = config.get_jwt_private_key()
        algorithm = config.get_jwt_algorithm()  # RS256
        expires_at = datetime.now() + timedelta(hours=config.get_access_token_expire_hours())

        payload = {
            "sub": str(user.id),
            "emp": str(user.employee_id.id),
            "cid": str(user.company_id.id),
            "role": user.role,
            "iss": config.get_jwt_issuer(),
            "aud": config.get_jwt_audience(),
            "iat": datetime.now().timestamp(),
            "exp": expires_at.timestamp(),
        }

        token = jwt.encode(payload, private_key, algorithm=algorithm)
        return token, expires_at

    def _get_user_from_token(self):
        """Extract user from Authorization header using RS256 verification."""
        auth_header = request.httprequest.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return None

        token = auth_header[7:]  # Remove 'Bearer ' prefix

        try:
            from ..config import config

            # Use public key for verification (RS256)
            payload = jwt.decode(
                token,
                config.get_jwt_public_key(),
                algorithms=[config.get_jwt_algorithm()],  # RS256
                audience=config.get_jwt_audience(),
                issuer=config.get_jwt_issuer(),
            )
            user_id = int(payload.get("sub"))
            return request.env["kf.user"].sudo().browse(user_id)
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
