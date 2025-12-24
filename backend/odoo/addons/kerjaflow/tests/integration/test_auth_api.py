# -*- coding: utf-8 -*-
"""
KerjaFlow Authentication API Integration Tests
===============================================

Integration tests for authentication endpoints.
"""

from odoo.tests import HttpCase, tagged
import json


@tagged('kerjaflow', 'integration', '-at_install', 'post_install')
class TestAuthAPI(HttpCase):
    """Integration tests for authentication API endpoints."""

    @classmethod
    def setUpClass(cls):
        """Set up test data."""
        super().setUpClass()

        # Create test company
        cls.company = cls.env['kf.company'].create({
            'name': 'Test Company',
            'registration_no': 'TEST-001',
            'address_line1': '123 Test St',
            'city': 'Kuala Lumpur',
            'state': 'WP',
            'postcode': '50000',
            'country': 'MY',
        })

        # Create test department
        cls.department = cls.env['kf.department'].create({
            'company_id': cls.company.id,
            'name': 'IT',
            'code': 'IT',
        })

        # Create test employee
        cls.employee = cls.env['kf.employee'].create({
            'company_id': cls.company.id,
            'employee_no': 'EMP001',
            'first_name': 'Test',
            'last_name': 'User',
            'ic_no': '900101-14-1234',
            'date_of_birth': '1990-01-01',
            'gender': 'M',
            'nationality': 'MY',
            'email': 'test@example.com',
            'department_id': cls.department.id,
            'employment_type': 'PERMANENT',
            'hire_date': '2023-01-01',
            'status': 'ACTIVE',
            'basic_salary': 5000,
        })

        # Create test user with password
        cls.user = cls.env['kf.user'].create({
            'employee_id': cls.employee.id,
            'company_id': cls.company.id,
            'email': 'test@example.com',
            'role': 'EMPLOYEE',
            'status': 'ACTIVE',
        })
        cls.user.set_password('TestPassword123!')

    def test_login_success(self):
        """Test successful login."""
        response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('access_token', data)
        self.assertIn('refresh_token', data)
        self.assertIn('user', data)
        self.assertEqual(data['user']['email'], 'test@example.com')

    def test_login_invalid_password(self):
        """Test login with invalid password."""
        response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'WrongPassword',
            }),
            headers={'Content-Type': 'application/json'},
        )

        self.assertEqual(response.status_code, 401)
        data = response.json()
        self.assertEqual(data['error']['code'], 'INVALID_CREDENTIALS')

    def test_login_invalid_email(self):
        """Test login with non-existent email."""
        response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'nonexistent@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )

        self.assertEqual(response.status_code, 401)

    def test_protected_endpoint_without_token(self):
        """Test accessing protected endpoint without token."""
        response = self.url_open('/api/v1/profile')

        self.assertEqual(response.status_code, 401)
        data = response.json()
        self.assertEqual(data['error']['code'], 'TOKEN_INVALID')

    def test_protected_endpoint_with_token(self):
        """Test accessing protected endpoint with valid token."""
        # First login to get token
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        tokens = login_response.json()
        access_token = tokens['access_token']

        # Access protected endpoint
        response = self.url_open(
            '/api/v1/profile',
            headers={
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['email'], 'test@example.com')

    def test_token_refresh(self):
        """Test token refresh."""
        # Login to get tokens
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        tokens = login_response.json()
        refresh_token = tokens['refresh_token']

        # Refresh token
        response = self.url_open(
            '/api/v1/auth/refresh',
            data=json.dumps({'refresh_token': refresh_token}),
            headers={'Content-Type': 'application/json'},
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('access_token', data)
        self.assertIn('refresh_token', data)

    def test_logout(self):
        """Test logout."""
        # Login
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        tokens = login_response.json()
        access_token = tokens['access_token']

        # Logout
        response = self.url_open(
            '/api/v1/auth/logout',
            data=json.dumps({}),
            headers={
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)

    def test_pin_setup(self):
        """Test PIN setup."""
        # Login
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        access_token = login_response.json()['access_token']

        # Setup PIN
        response = self.url_open(
            '/api/v1/auth/pin/setup',
            data=json.dumps({'pin': '123456'}),
            headers={
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data.get('success'))

    def test_password_change(self):
        """Test password change."""
        # Login
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        access_token = login_response.json()['access_token']

        # Change password
        response = self.url_open(
            '/api/v1/auth/password/change',
            data=json.dumps({
                'current_password': 'TestPassword123!',
                'new_password': 'NewPassword456!',
            }),
            headers={
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)

        # Verify new password works
        login_response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'test@example.com',
                'password': 'NewPassword456!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        self.assertEqual(login_response.status_code, 200)
