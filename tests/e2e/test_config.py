"""
KerjaFlow E2E Test Configuration
=================================

Configuration for end-to-end tests.

IMPORTANT: Test credentials MUST be set via environment variables.
Never commit actual passwords to version control.
"""

import os


def _get_required_env(key: str, description: str) -> str:
    """Get required environment variable or raise error."""
    value = os.getenv(key)
    if not value:
        raise ValueError(
            f"Environment variable {key} is required for E2E tests. "
            f"Description: {description}"
        )
    return value


# API Configuration
API_BASE_URL = os.getenv('KERJAFLOW_API_URL', 'http://localhost:8069/api/v1')


def get_test_users():
    """
    Get test user credentials from environment variables.

    Required environment variables:
    - TEST_ADMIN_EMAIL, TEST_ADMIN_PASSWORD
    - TEST_HR_MANAGER_EMAIL, TEST_HR_MANAGER_PASSWORD
    - TEST_SUPERVISOR_EMAIL, TEST_SUPERVISOR_PASSWORD
    - TEST_EMPLOYEE_EMAIL, TEST_EMPLOYEE_PASSWORD
    """
    return {
        'admin': {
            'email': os.getenv('TEST_ADMIN_EMAIL', 'test-admin@example.com'),
            'password': _get_required_env('TEST_ADMIN_PASSWORD', 'Admin test user password'),
            'role': 'ADMIN',
        },
        'hr_manager': {
            'email': os.getenv('TEST_HR_MANAGER_EMAIL', 'test-hr@example.com'),
            'password': _get_required_env('TEST_HR_MANAGER_PASSWORD', 'HR Manager test user password'),
            'role': 'HR_MANAGER',
        },
        'supervisor': {
            'email': os.getenv('TEST_SUPERVISOR_EMAIL', 'test-supervisor@example.com'),
            'password': _get_required_env('TEST_SUPERVISOR_PASSWORD', 'Supervisor test user password'),
            'role': 'SUPERVISOR',
        },
        'employee': {
            'email': os.getenv('TEST_EMPLOYEE_EMAIL', 'test-employee@example.com'),
            'password': _get_required_env('TEST_EMPLOYEE_PASSWORD', 'Employee test user password'),
            'role': 'EMPLOYEE',
        },
    }


# Lazy-loaded test users (to avoid requiring env vars at import time)
TEST_USERS = None


def get_test_user(role: str) -> dict:
    """Get test user credentials by role."""
    global TEST_USERS
    if TEST_USERS is None:
        TEST_USERS = get_test_users()
    return TEST_USERS.get(role)

# Test Timeouts
DEFAULT_TIMEOUT = 30  # seconds
LONG_TIMEOUT = 60  # seconds

# Retry Configuration
MAX_RETRIES = 3
RETRY_DELAY = 2  # seconds

# Test Data
TEST_COMPANY = {
    'name': 'TechCorp Malaysia Sdn Bhd',
    'registration_no': '1234567-X',
}

LEAVE_TYPES = ['AL', 'MC', 'EL', 'CL', 'UL']
