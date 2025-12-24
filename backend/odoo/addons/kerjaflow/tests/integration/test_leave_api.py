# -*- coding: utf-8 -*-
"""
KerjaFlow Leave API Integration Tests
=====================================

Integration tests for leave management endpoints.
"""

from odoo.tests import HttpCase, tagged
from datetime import date, timedelta
import json


@tagged('kerjaflow', 'integration', '-at_install', 'post_install')
class TestLeaveAPI(HttpCase):
    """Integration tests for leave API endpoints."""

    @classmethod
    def setUpClass(cls):
        """Set up test data."""
        super().setUpClass()

        # Create test company
        cls.company = cls.env['kf.company'].create({
            'name': 'Test Company',
            'registration_no': 'TEST-002',
            'address_line1': '123 Test St',
            'city': 'Kuala Lumpur',
            'state': 'WP',
            'postcode': '50000',
            'country': 'MY',
        })

        # Create test department
        cls.department = cls.env['kf.department'].create({
            'company_id': cls.company.id,
            'name': 'Engineering',
            'code': 'ENG',
        })

        # Create test employee
        cls.employee = cls.env['kf.employee'].create({
            'company_id': cls.company.id,
            'employee_no': 'EMP002',
            'first_name': 'Leave',
            'last_name': 'Tester',
            'ic_no': '900202-14-5678',
            'date_of_birth': '1990-02-02',
            'gender': 'F',
            'nationality': 'MY',
            'email': 'leave.tester@example.com',
            'department_id': cls.department.id,
            'employment_type': 'PERMANENT',
            'hire_date': '2023-01-01',
            'status': 'ACTIVE',
            'basic_salary': 6000,
        })

        # Create test user
        cls.user = cls.env['kf.user'].create({
            'employee_id': cls.employee.id,
            'company_id': cls.company.id,
            'email': 'leave.tester@example.com',
            'role': 'EMPLOYEE',
            'status': 'ACTIVE',
        })
        cls.user.set_password('TestPassword123!')

        # Create leave types
        cls.annual_leave = cls.env['kf.leave.type'].create({
            'company_id': cls.company.id,
            'code': 'AL',
            'name': 'Annual Leave',
            'default_entitlement': 14,
            'allow_half_day': True,
            'requires_attachment': False,
            'min_days_notice': 3,
            'is_visible': True,
            'is_active': True,
        })

        cls.medical_leave = cls.env['kf.leave.type'].create({
            'company_id': cls.company.id,
            'code': 'MC',
            'name': 'Medical Leave',
            'default_entitlement': 14,
            'allow_half_day': True,
            'requires_attachment': True,
            'min_days_notice': 0,
            'is_visible': True,
            'is_active': True,
        })

        # Create leave balance
        cls.balance = cls.env['kf.leave.balance'].create({
            'employee_id': cls.employee.id,
            'leave_type_id': cls.annual_leave.id,
            'company_id': cls.company.id,
            'year': date.today().year,
            'entitled': 14,
            'carried': 0,
            'taken': 0,
            'pending': 0,
        })

    def _get_auth_token(self):
        """Helper to get auth token."""
        response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'leave.tester@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        return response.json()['access_token']

    def test_get_leave_types(self):
        """Test getting leave types."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/leave/types',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('leave_types', data)
        self.assertGreaterEqual(len(data['leave_types']), 2)

    def test_get_leave_balances(self):
        """Test getting leave balances."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/leave/balances',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('balances', data)

    def test_create_leave_request(self):
        """Test creating a leave request."""
        token = self._get_auth_token()

        date_from = date.today() + timedelta(days=10)
        date_to = date.today() + timedelta(days=12)

        response = self.url_open(
            '/api/v1/leave/requests',
            data=json.dumps({
                'leave_type_id': self.annual_leave.id,
                'date_from': str(date_from),
                'date_to': str(date_to),
                'reason': 'Family vacation',
            }),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 201)
        data = response.json()
        self.assertEqual(data['status'], 'PENDING')
        self.assertEqual(data['total_days'], 3)

    def test_create_half_day_request(self):
        """Test creating a half-day leave request."""
        token = self._get_auth_token()

        leave_date = date.today() + timedelta(days=20)

        response = self.url_open(
            '/api/v1/leave/requests',
            data=json.dumps({
                'leave_type_id': self.annual_leave.id,
                'date_from': str(leave_date),
                'date_to': str(leave_date),
                'half_day_type': 'AM',
                'reason': 'Doctor appointment',
            }),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 201)
        data = response.json()
        self.assertEqual(data['half_day_type'], 'AM')

    def test_get_leave_requests(self):
        """Test getting leave requests."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/leave/requests',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('items', data)
        self.assertIn('pagination', data)

    def test_get_leave_request_detail(self):
        """Test getting leave request details."""
        token = self._get_auth_token()

        # Create a request first
        date_from = date.today() + timedelta(days=30)
        create_response = self.url_open(
            '/api/v1/leave/requests',
            data=json.dumps({
                'leave_type_id': self.annual_leave.id,
                'date_from': str(date_from),
                'date_to': str(date_from),
                'reason': 'Personal day',
            }),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )
        request_id = create_response.json()['id']

        # Get details
        response = self.url_open(
            f'/api/v1/leave/requests/{request_id}',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['id'], request_id)

    def test_cancel_leave_request(self):
        """Test cancelling a leave request."""
        token = self._get_auth_token()

        # Create a request
        date_from = date.today() + timedelta(days=40)
        create_response = self.url_open(
            '/api/v1/leave/requests',
            data=json.dumps({
                'leave_type_id': self.annual_leave.id,
                'date_from': str(date_from),
                'date_to': str(date_from),
                'reason': 'To be cancelled',
            }),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )
        request_id = create_response.json()['id']

        # Cancel it
        response = self.url_open(
            f'/api/v1/leave/requests/{request_id}/cancel',
            data=json.dumps({}),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data.get('success'))

    def test_get_public_holidays(self):
        """Test getting public holidays."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/public-holidays',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('holidays', data)

    def test_insufficient_balance_error(self):
        """Test error when requesting more days than available."""
        token = self._get_auth_token()

        # Try to request 20 days when only 14 available
        date_from = date.today() + timedelta(days=50)
        date_to = date.today() + timedelta(days=70)

        response = self.url_open(
            '/api/v1/leave/requests',
            data=json.dumps({
                'leave_type_id': self.annual_leave.id,
                'date_from': str(date_from),
                'date_to': str(date_to),
                'reason': 'Too long vacation',
            }),
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertIn(response.status_code, [400, 422])
        data = response.json()
        self.assertIn('error', data)
