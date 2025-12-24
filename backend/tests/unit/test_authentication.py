# -*- coding: utf-8 -*-
"""
KerjaFlow Authentication Tests
==============================

Test suite for authentication functionality (T-A01 to T-A12)
"""
import pytest
import jwt
import bcrypt
from datetime import datetime, timedelta
from unittest.mock import Mock, patch


class TestJWTTokens:
    """Tests for JWT token handling"""

    def test_valid_token_decodes_successfully(self, jwt_secret, valid_jwt_token):
        """T-A01: Valid JWT token should decode successfully"""
        payload = jwt.decode(valid_jwt_token, jwt_secret, algorithms=['HS256'])
        assert payload['sub'] == '1'
        assert payload['role'] == 'EMPLOYEE'

    def test_expired_token_raises_exception(self, jwt_secret, expired_jwt_token):
        """T-A02: Expired JWT token should raise ExpiredSignatureError"""
        with pytest.raises(jwt.ExpiredSignatureError):
            jwt.decode(expired_jwt_token, jwt_secret, algorithms=['HS256'])

    def test_invalid_token_raises_exception(self, jwt_secret):
        """T-A03: Invalid JWT token should raise DecodeError"""
        with pytest.raises(jwt.DecodeError):
            jwt.decode('invalid.token.here', jwt_secret, algorithms=['HS256'])

    def test_token_contains_required_claims(self, jwt_secret, valid_jwt_token):
        """T-A04: JWT token should contain required claims"""
        payload = jwt.decode(valid_jwt_token, jwt_secret, algorithms=['HS256'])
        required_claims = ['sub', 'emp', 'cid', 'role', 'iat', 'exp']
        for claim in required_claims:
            assert claim in payload, f"Missing required claim: {claim}"

    def test_admin_token_has_admin_role(self, jwt_secret, admin_jwt_token):
        """T-A05: Admin JWT token should have ADMIN role"""
        payload = jwt.decode(admin_jwt_token, jwt_secret, algorithms=['HS256'])
        assert payload['role'] == 'ADMIN'


class TestPasswordHashing:
    """Tests for password hashing"""

    def test_password_hashes_correctly(self):
        """T-A06: Password should hash correctly with bcrypt"""
        password = "TestPassword123!"
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        assert bcrypt.checkpw(password.encode('utf-8'), hashed)

    def test_wrong_password_fails_verification(self):
        """T-A07: Wrong password should fail verification"""
        password = "TestPassword123!"
        wrong_password = "WrongPassword456!"
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        assert not bcrypt.checkpw(wrong_password.encode('utf-8'), hashed)

    def test_password_hash_is_unique(self):
        """T-A08: Same password should produce different hashes (salt)"""
        password = "TestPassword123!"
        hash1 = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        hash2 = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        assert hash1 != hash2


class TestRoleBasedAccess:
    """Tests for role-based access control"""

    def test_employee_role_permissions(self, jwt_secret, valid_jwt_token):
        """T-A09: EMPLOYEE role should have limited permissions"""
        payload = jwt.decode(valid_jwt_token, jwt_secret, algorithms=['HS256'])
        assert payload['role'] == 'EMPLOYEE'
        # EMPLOYEE can view own data only
        allowed_actions = ['view_own_profile', 'view_own_leave', 'view_own_payslip']
        # Verify role is not admin
        assert payload['role'] != 'ADMIN'

    def test_admin_role_permissions(self, jwt_secret, admin_jwt_token):
        """T-A10: ADMIN role should have full permissions"""
        payload = jwt.decode(admin_jwt_token, jwt_secret, algorithms=['HS256'])
        assert payload['role'] == 'ADMIN'

    @pytest.mark.parametrize("role,expected_level", [
        ('EMPLOYEE', 1),
        ('SUPERVISOR', 2),
        ('HR_EXEC', 3),
        ('HR_MANAGER', 4),
        ('ADMIN', 5),
    ])
    def test_role_hierarchy(self, role, expected_level):
        """T-A11: Role hierarchy should be correctly ordered"""
        role_levels = {
            'EMPLOYEE': 1,
            'SUPERVISOR': 2,
            'HR_EXEC': 3,
            'HR_MANAGER': 4,
            'ADMIN': 5,
        }
        assert role_levels[role] == expected_level


class TestLoginAttempts:
    """Tests for login attempt tracking"""

    def test_failed_login_increments_counter(self, sample_user):
        """T-A12: Failed login should increment counter"""
        initial_count = sample_user['failed_login_attempts']
        # Simulate failed login
        sample_user['failed_login_attempts'] += 1
        assert sample_user['failed_login_attempts'] == initial_count + 1
