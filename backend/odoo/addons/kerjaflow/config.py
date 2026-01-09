# -*- coding: utf-8 -*-
"""
KerjaFlow Configuration Module

Centralized configuration management for security-sensitive settings.
All sensitive values MUST come from environment variables.

SECURITY: JWT uses RS256 (asymmetric) algorithm.
- Private key: Used for signing tokens (keep secret!)
- Public key: Used for verifying tokens (can be shared)

Generate keys with: infrastructure/scripts/generate_jwt_keys.sh
"""

import logging
import os

_logger = logging.getLogger(__name__)


class KerjaFlowConfig:
    """Centralized configuration for KerjaFlow module."""

    # JWT Configuration - RS256 (asymmetric) for security
    _jwt_private_key = None
    _jwt_public_key = None
    _jwt_algorithm = "RS256"  # CRITICAL: Must be RS256, never HS256
    _jwt_issuer = "kerjaflow"
    _jwt_audience = "kerjaflow-mobile"
    _jwt_access_token_expire_hours = 24
    _jwt_refresh_token_expire_days = 30
    _jwt_pin_verification_expire_minutes = 30

    # Development-only fallback keys (2048-bit RSA)
    # NEVER use these in production - generate your own!
    _DEV_PRIVATE_KEY = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF8PbnGy0AHEYk5n3UbQhEZcKK8Cp
rBxFkZgXLlCJC5rMmFtMOl6xfvTXGlBPzRFcV0YEi8KHo1vOQbPBJe4rHN7YWJIT
TGqLmB0k9H6pLPsP0jT7NYpaxnCVdxb0BnNxJXVE0VX3+FJkk/2lGmTkpLQlXl5K
YPbpS/TSyDzMBEJGKn19lqHKzfGpRdZFhdxGvCKzMaAXorCKpfFVPLRjZ0gVqJKx
vlC+1y0MkJCnNreFyqJDxFa2FNXN9ghLEV0vPEYfJUJF3f9f7k6KXSI7xB1Hjd8G
U7hGN8aHmC8Li+R/tqfactLENPLmLfnqMdMUawIDAQABAoIBAC3D4aHvZjNMIgMv
PQz/BkK0SYiv0Ppqes0bWw1OIVO/bIJCtHBBpixO7UqE7Y7Pq/CkvpXT5jfBrxQI
XmPmjs4z7vkz6yW2nVOe1E0h0F4BX1ki+bzU/L2iYdgqXNqM7U7s+FntTUee0kLR
r6E5VYXsK1i5x+Q9YhC0aH1w8e6Aa8K4K3rmAi96VX7AfqJPYH0lNLXK7GBJpthp
X0D7YfD/CFp0TeJPEKPKAYinuW9WHAG0YPIbQLnLJ7CgRCoLckDMxzrYLjJRaNhi
TQl8NoAivqO9zPd9PwnaJH8qNxZG9h5qk0F+D3fjbfvL1V0GXeTGNf09L0M8ULUe
8KnpmIECgYEA7J1XHd3SA1gt6zxF7eKnBEsXqNSF1mt0CyywQ5afz1wB5t9P/FCv
n63fC/5q+BYxJhkLQNGsTemKvpF8dU1dMmJUVuklm2K7HLVzIeBpigUJD7eKr3jH
GmL0Z+vi/0JzIn2PGLF0pham/MwF3WGZSnYLcAsMrQsH4kgC1H5P0ssCgYEA4wYD
dILGrPprWnzqdN3lcbqVjZa+jLIkU3/M4JdoYABvt3zVflt4S/Bw9f6rh0EsGHp5
VzdKfDE/HDdcqFMj4SAjXkPl7cM8nF4zcE1OmpslL7k5XnYKi46p9E+LL2aZnXk7
G3S6rUrl0j5d8cE7V3CRZQx1P2S5vFHsVthNicECgYEA5XJAT0VPvVNfQh5xvKAO
VIHdB9LS8LLCsb8HH4pdL3q4WS0PX1Tq6aE3hjlMl7gJpFuC8Al4QKSC3xghZTM9
5njWop75wxOvT4PwAj1S9g7+0ZpYFxsNPvLdbX3fWwRl9A3fQtDH1JTVwxx1BXpE
Y9iOSF3k2cE1RfQjLH7f5B0CgYBjLF3hED+F/2icpuC8NKF0Yvnh5fh0t4/G8xI0
rk4kHX02PlnsdnXZzFB7eZnMDmk3bJQK5SqCqPs4TrHB7kH7y+HBDGOXbPJTiC7B
kL5xiwl1NnWdYb1JsYEIqoq6kJKC7/ZD0qhe3ybJrKx0C7HAQNN0lQC1x7vX7Xwx
YwPgAQKBgQCEhkqHL/xfvU8a9SFijdd9TaLe2W9L/JZdLJiUQsNmwtk/mHVzbMQE
+UF1gSNYzSM0m+yYn6F8bqTwqjhLxfnKC2FPMc75F8GIFwfJL0qJn1LH6nugyi1b
dZIlmtx1dnrLqGUpQoaNbLdtsH56E3KU6XnWdDBrcVuDLTvuL7gFJA==
-----END RSA PRIVATE KEY-----"""

    _DEV_PUBLIC_KEY = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Z3VS5JJcds3xfn/ygWy
F8PbnGy0AHEYk5n3UbQhEZcKK8CprBxFkZgXLlCJC5rMmFtMOl6xfvTXGlBPzRFc
V0YEi8KHo1vOQbPBJe4rHN7WJITTGqLmB0k9H6pLPsP0jT7NYpaxnCVdxb0BnNxJ
XVE0VX3+FJkk/2lGmTkpLQlXl5KYPbpS/TSyDzMBEJGKn19lqHKzfGpRdZFhdxGv
CKzMaAXorCKpfFVPLRjZ0gVqJKxvlC+1y0MkJCnNreFyqJDxFa2FNXN9ghLEV0vP
EYfJUJF3f9f7k6KXSI7xB1Hjd8GU7hGN8aHmC8Li+R/tqfactLENPLmLfnqMdMUa
wQIDAQAB
-----END PUBLIC KEY-----"""

    @classmethod
    def get_jwt_private_key(cls):
        """
        Get JWT RSA private key for signing tokens.

        CRITICAL: This MUST be set in production via JWT_PRIVATE_KEY env var.
        Generate with: openssl genrsa -out private.pem 2048
        """
        if cls._jwt_private_key is None:
            cls._jwt_private_key = os.environ.get("JWT_PRIVATE_KEY")

            if not cls._jwt_private_key:
                # In development only - DO NOT use in production
                if os.environ.get("ODOO_STAGE", "production") == "development":
                    _logger.warning(
                        "Using development-only JWT private key. "
                        "NEVER use this in production! "
                        "Generate your own keys with: infrastructure/scripts/generate_jwt_keys.sh"
                    )
                    cls._jwt_private_key = cls._DEV_PRIVATE_KEY
                else:
                    raise ValueError(
                        "JWT_PRIVATE_KEY must be set in environment for production. "
                        "Generate keys with: infrastructure/scripts/generate_jwt_keys.sh"
                    )

        return cls._jwt_private_key

    @classmethod
    def get_jwt_public_key(cls):
        """
        Get JWT RSA public key for verifying tokens.

        CRITICAL: This MUST be set in production via JWT_PUBLIC_KEY env var.
        Generate with: openssl rsa -in private.pem -pubout -out public.pem
        """
        if cls._jwt_public_key is None:
            cls._jwt_public_key = os.environ.get("JWT_PUBLIC_KEY")

            if not cls._jwt_public_key:
                # In development only - DO NOT use in production
                if os.environ.get("ODOO_STAGE", "production") == "development":
                    _logger.warning("Using development-only JWT public key. " "NEVER use this in production!")
                    cls._jwt_public_key = cls._DEV_PUBLIC_KEY
                else:
                    raise ValueError(
                        "JWT_PUBLIC_KEY must be set in environment for production. "
                        "Generate keys with: infrastructure/scripts/generate_jwt_keys.sh"
                    )

        return cls._jwt_public_key

    @classmethod
    def get_jwt_secret(cls):
        """
        DEPRECATED: Use get_jwt_private_key() for signing.

        This method now returns the private key for backward compatibility.
        Will be removed in a future version.
        """
        _logger.warning(
            "get_jwt_secret() is deprecated. Use get_jwt_private_key() for signing "
            "and get_jwt_public_key() for verification."
        )
        return cls.get_jwt_private_key()

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
        return int(os.environ.get("JWT_ACCESS_EXPIRE_HOURS", cls._jwt_access_token_expire_hours))

    @classmethod
    def get_refresh_token_expire_days(cls):
        """Get refresh token expiration in days."""
        return int(os.environ.get("JWT_REFRESH_EXPIRE_DAYS", cls._jwt_refresh_token_expire_days))

    @classmethod
    def get_pin_verification_expire_minutes(cls):
        """Get PIN verification token expiration in minutes."""
        return int(os.environ.get("JWT_PIN_VERIFICATION_EXPIRE_MINUTES", cls._jwt_pin_verification_expire_minutes))

    # Redis Configuration (for token storage)
    @classmethod
    def get_redis_url(cls):
        """Get Redis URL for token storage."""
        return os.environ.get("REDIS_URL", "redis://localhost:6379/0")

    @classmethod
    def get_redis_password(cls):
        """Get Redis password."""
        return os.environ.get("REDIS_PASSWORD")

    # S3/Object Storage Configuration
    @classmethod
    def get_s3_endpoint(cls):
        """Get S3-compatible storage endpoint."""
        return os.environ.get("S3_ENDPOINT_URL")

    @classmethod
    def get_s3_access_key(cls):
        """Get S3 access key."""
        return os.environ.get("S3_ACCESS_KEY")

    @classmethod
    def get_s3_secret_key(cls):
        """Get S3 secret key."""
        return os.environ.get("S3_SECRET_KEY")

    @classmethod
    def get_s3_bucket(cls):
        """Get S3 bucket name."""
        return os.environ.get("S3_BUCKET_NAME", "kerjaflow")

    # Push Notification Configuration
    @classmethod
    def get_firebase_server_key(cls):
        """Get Firebase server key for FCM."""
        return os.environ.get("FIREBASE_SERVER_KEY")

    @classmethod
    def get_hms_client_id(cls):
        """Get Huawei HMS client ID."""
        return os.environ.get("HMS_CLIENT_ID")

    @classmethod
    def get_hms_client_secret(cls):
        """Get Huawei HMS client secret."""
        return os.environ.get("HMS_CLIENT_SECRET")

    # Email Configuration
    @classmethod
    def get_smtp_host(cls):
        """Get SMTP host."""
        return os.environ.get("SMTP_HOST", "localhost")

    @classmethod
    def get_smtp_port(cls):
        """Get SMTP port."""
        return int(os.environ.get("SMTP_PORT", 587))

    @classmethod
    def get_smtp_user(cls):
        """Get SMTP username."""
        return os.environ.get("SMTP_USER")

    @classmethod
    def get_smtp_password(cls):
        """Get SMTP password."""
        return os.environ.get("SMTP_PASSWORD")

    # Security Settings
    @classmethod
    def get_allowed_origins(cls):
        """Get allowed CORS origins."""
        origins = os.environ.get("ALLOWED_ORIGINS", "")
        return [o.strip() for o in origins.split(",") if o.strip()]

    @classmethod
    def is_production(cls):
        """Check if running in production mode."""
        return os.environ.get("ODOO_STAGE", "production") == "production"

    @classmethod
    def is_development(cls):
        """Check if running in development mode."""
        return os.environ.get("ODOO_STAGE", "production") == "development"


# Convenience instance
config = KerjaFlowConfig()
