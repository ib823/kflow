"""
KerjaFlow E2E Test Configuration
=================================

Configuration for end-to-end tests.
"""

import os

# API Configuration
API_BASE_URL = os.getenv('KERJAFLOW_API_URL', 'http://localhost:8069/api/v1')

# Test User Credentials
TEST_USERS = {
    'admin': {
        'email': 'ahmad.ibrahim@techcorp.my',
        'password': 'AdminPass123!',
        'role': 'ADMIN',
    },
    'hr_manager': {
        'email': 'siti.aminah@techcorp.my',
        'password': 'HRManagerPass123!',
        'role': 'HR_MANAGER',
    },
    'supervisor': {
        'email': 'raj.kumar@techcorp.my',
        'password': 'SupervisorPass123!',
        'role': 'SUPERVISOR',
    },
    'employee': {
        'email': 'nurul.huda@techcorp.my',
        'password': 'EmployeePass123!',
        'role': 'EMPLOYEE',
    },
}

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
