# -*- coding: utf-8 -*-
"""
KerjaFlow Test Configuration
Provides fixtures and utilities for standalone pytest tests
"""
import os
import sys
from datetime import date, datetime, timedelta
from decimal import Decimal
from unittest.mock import MagicMock, Mock, patch

import jwt
import pytest

# Add project to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))


# ============== JWT FIXTURES ==============


@pytest.fixture
def jwt_secret():
    """JWT secret for testing"""
    return "test-secret-key-for-testing-only"


@pytest.fixture
def valid_jwt_token(jwt_secret):
    """Generate a valid JWT token for testing"""
    payload = {
        "sub": "1",
        "emp": "1",
        "cid": "1",
        "role": "EMPLOYEE",
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=24),
    }
    return jwt.encode(payload, jwt_secret, algorithm="HS256")


@pytest.fixture
def expired_jwt_token(jwt_secret):
    """Generate an expired JWT token for testing"""
    payload = {
        "sub": "1",
        "emp": "1",
        "cid": "1",
        "role": "EMPLOYEE",
        "iat": datetime.utcnow() - timedelta(hours=48),
        "exp": datetime.utcnow() - timedelta(hours=24),
    }
    return jwt.encode(payload, jwt_secret, algorithm="HS256")


@pytest.fixture
def admin_jwt_token(jwt_secret):
    """Generate an admin JWT token for testing"""
    payload = {
        "sub": "1",
        "emp": "1",
        "cid": "1",
        "role": "ADMIN",
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=24),
    }
    return jwt.encode(payload, jwt_secret, algorithm="HS256")


# ============== SAMPLE DATA FIXTURES ==============


@pytest.fixture
def sample_company():
    """Sample company data"""
    return {
        "id": 1,
        "name": "ACME Corporation Sdn Bhd",
        "code": "ACME",
        "registration_no": "1234567-X",
        "state": "Selangor",
        "timezone": "Asia/Kuala_Lumpur",
        "leave_year_start": 1,
        "is_active": True,
    }


@pytest.fixture
def sample_employee():
    """Sample employee data"""
    return {
        "id": 1,
        "company_id": 1,
        "department_id": 1,
        "employee_no": "EMP001",
        "first_name": "Ahmad",
        "last_name": "bin Abdullah",
        "email": "ahmad@acme.my",
        "ic_no": "850101-14-5555",
        "gender": "M",
        "date_of_birth": date(1985, 1, 1),
        "hire_date": date(2020, 1, 1),
        "status": "ACTIVE",
        "epf_no": "EPF123456",
        "socso_no": "SOCSO123456",
        "basic_salary": Decimal("5000.00"),
    }


@pytest.fixture
def sample_user():
    """Sample user data"""
    return {
        "id": 1,
        "employee_id": 1,
        "company_id": 1,
        "email": "ahmad@acme.my",
        "role": "EMPLOYEE",
        "status": "ACTIVE",
        "failed_login_attempts": 0,
    }


@pytest.fixture
def sample_leave_type():
    """Sample leave type data"""
    return {
        "id": 1,
        "company_id": 1,
        "name": "Annual Leave",
        "name_ms": "Cuti Tahunan",
        "code": "AL",
        "default_entitlement": 16,
        "allow_half_day": True,
        "requires_attachment": False,
        "max_days_per_request": 14,
        "min_days_notice": 3,
        "is_active": True,
    }


@pytest.fixture
def sample_leave_balance():
    """Sample leave balance data"""
    return {
        "id": 1,
        "employee_id": 1,
        "leave_type_id": 1,
        "company_id": 1,
        "year": 2025,
        "entitled": 16.0,
        "carried": 2.0,
        "adjustment": 0.0,
        "taken": 5.0,
        "pending": 2.0,
    }


@pytest.fixture
def sample_leave_request():
    """Sample leave request data"""
    return {
        "id": 1,
        "employee_id": 1,
        "leave_type_id": 1,
        "company_id": 1,
        "date_from": date(2025, 2, 1),
        "date_to": date(2025, 2, 3),
        "total_days": 3.0,
        "reason": "Family vacation",
        "status": "PENDING",
    }


@pytest.fixture
def sample_payslip():
    """Sample payslip data"""
    return {
        "id": 1,
        "employee_id": 1,
        "company_id": 1,
        "period": "2025-01",
        "period_month": 1,
        "period_year": 2025,
        "gross_salary": Decimal("5000.00"),
        "net_salary": Decimal("4200.00"),
        "status": "PUBLISHED",
    }


@pytest.fixture
def sample_notification():
    """Sample notification data"""
    return {
        "id": 1,
        "user_id": 1,
        "company_id": 1,
        "type": "LEAVE_APPROVED",
        "title": "Leave Approved",
        "title_ms": "Cuti Diluluskan",
        "message": "Your leave request has been approved",
        "message_ms": "Permohonan cuti anda telah diluluskan",
        "is_read": False,
        "created_at": datetime.now(),
    }


@pytest.fixture
def sample_document():
    """Sample document data"""
    return {
        "id": 1,
        "employee_id": 1,
        "company_id": 1,
        "type": "IC",
        "document_no": "850101-14-5555",
        "file_name": "ic_front.jpg",
        "file_size": 1024000,
        "mime_type": "image/jpeg",
        "status": "ACTIVE",
    }


# ============== HELPER FIXTURES ==============


@pytest.fixture
def current_year():
    """Current year"""
    return date.today().year


@pytest.fixture
def today():
    """Today's date"""
    return date.today()


@pytest.fixture
def now():
    """Current datetime"""
    return datetime.now()
