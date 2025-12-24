# -*- coding: utf-8 -*-
"""
KerjaFlow Configuration Module

Centralized configuration management for security-sensitive settings.
All sensitive values MUST come from environment variables.
"""

import os
import logging

_logger = logging.getLogger(__name__)


class KerjaFlowConfig:
    """Centralized configuration for KerjaFlow module."""

    # JWT Configuration
    _jwt_secret = None
    _jwt_algorithm = 'HS256'
    _jwt_issuer = 'kerjaflow'
    _jwt_audience = 'kerjaflow-mobile'
    _jwt_access_token_expire_hours = 24
    _jwt_refresh_token_expire_days = 30
    _jwt_pin_verification_expire_minutes = 30

    @classmethod
    def get_jwt_secret(cls):
        """
        Get JWT secret key from environment.

        CRITICAL: This MUST be set in production via JWT_SECRET_KEY env var.
        The secret should be at least 32 characters and cryptographically random.
        """
        if cls._jwt_secret is None:
            cls._jwt_secret = os.environ.get('JWT_SECRET_KEY')

            if not cls._jwt_secret:
                _logger.error(
                    "JWT_SECRET_KEY environment variable is not set! "
                    "This is a critical security issue. "
                    "Set a strong secret key (min 32 chars) in production."
                )
                # In development only - DO NOT use in production
                if os.environ.get('ODOO_STAGE', 'production') == 'development':
                    _logger.warning(
                        "Using development-only fallback JWT secret. "
                        "NEVER use this in production!"
                    )
                    cls._jwt_secret = 'DEV-ONLY-INSECURE-KEY-REPLACE-IN-PRODUCTION-32CHARS'
                else:
                    raise ValueError(
                        "JWT_SECRET_KEY must be set in environment for production"
                    )

        return cls._jwt_secret

    @classmethod
    def get_jwt_algorithm(cls):
        """Get JWT algorithm."""
        return cls._jwt_algorithm

    @classmethod
    def get_jwt_issuer(cls):
        """Get JWT issuer."""
        return cls._jwt_issuer

    @classmethod
    def get_jwt_audience(cls):
        """Get JWT audience."""
        return cls._jwt_audience

    @classmethod
    def get_access_token_expire_hours(cls):
        """Get access token expiration in hours."""
        return int(os.environ.get('JWT_ACCESS_EXPIRE_HOURS', cls._jwt_access_token_expire_hours))

    @classmethod
    def get_refresh_token_expire_days(cls):
        """Get refresh token expiration in days."""
        return int(os.environ.get('JWT_REFRESH_EXPIRE_DAYS', cls._jwt_refresh_token_expire_days))

    @classmethod
    def get_pin_verification_expire_minutes(cls):
        """Get PIN verification token expiration in minutes."""
        return int(os.environ.get(
            'JWT_PIN_VERIFICATION_EXPIRE_MINUTES',
            cls._jwt_pin_verification_expire_minutes
        ))

    # Redis Configuration (for token storage)
    @classmethod
    def get_redis_url(cls):
        """Get Redis URL for token storage."""
        return os.environ.get('REDIS_URL', 'redis://localhost:6379/0')

    @classmethod
    def get_redis_password(cls):
        """Get Redis password."""
        return os.environ.get('REDIS_PASSWORD')

    # S3/Object Storage Configuration
    @classmethod
    def get_s3_endpoint(cls):
        """Get S3-compatible storage endpoint."""
        return os.environ.get('S3_ENDPOINT_URL')

    @classmethod
    def get_s3_access_key(cls):
        """Get S3 access key."""
        return os.environ.get('S3_ACCESS_KEY')

    @classmethod
    def get_s3_secret_key(cls):
        """Get S3 secret key."""
        return os.environ.get('S3_SECRET_KEY')

    @classmethod
    def get_s3_bucket(cls):
        """Get S3 bucket name."""
        return os.environ.get('S3_BUCKET_NAME', 'kerjaflow')

    # Push Notification Configuration
    @classmethod
    def get_firebase_server_key(cls):
        """Get Firebase server key for FCM."""
        return os.environ.get('FIREBASE_SERVER_KEY')

    @classmethod
    def get_hms_client_id(cls):
        """Get Huawei HMS client ID."""
        return os.environ.get('HMS_CLIENT_ID')

    @classmethod
    def get_hms_client_secret(cls):
        """Get Huawei HMS client secret."""
        return os.environ.get('HMS_CLIENT_SECRET')

    # Email Configuration
    @classmethod
    def get_smtp_host(cls):
        """Get SMTP host."""
        return os.environ.get('SMTP_HOST', 'localhost')

    @classmethod
    def get_smtp_port(cls):
        """Get SMTP port."""
        return int(os.environ.get('SMTP_PORT', 587))

    @classmethod
    def get_smtp_user(cls):
        """Get SMTP username."""
        return os.environ.get('SMTP_USER')

    @classmethod
    def get_smtp_password(cls):
        """Get SMTP password."""
        return os.environ.get('SMTP_PASSWORD')

    # Security Settings
    @classmethod
    def get_allowed_origins(cls):
        """Get allowed CORS origins."""
        origins = os.environ.get('ALLOWED_ORIGINS', '')
        return [o.strip() for o in origins.split(',') if o.strip()]

    @classmethod
    def is_production(cls):
        """Check if running in production mode."""
        return os.environ.get('ODOO_STAGE', 'production') == 'production'

    @classmethod
    def is_development(cls):
        """Check if running in development mode."""
        return os.environ.get('ODOO_STAGE', 'production') == 'development'


# Convenience instance
config = KerjaFlowConfig()
