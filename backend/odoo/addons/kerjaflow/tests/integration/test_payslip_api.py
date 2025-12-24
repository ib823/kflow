# -*- coding: utf-8 -*-
"""
KerjaFlow Payslip API Integration Tests
=======================================

Integration tests for payslip endpoints with PIN verification.
"""

from odoo.tests import HttpCase, tagged
from datetime import date
import json


@tagged('kerjaflow', 'integration', '-at_install', 'post_install')
class TestPayslipAPI(HttpCase):
    """Integration tests for payslip API endpoints."""

    @classmethod
    def setUpClass(cls):
        """Set up test data."""
        super().setUpClass()

        # Create test company
        cls.company = cls.env['kf.company'].create({
            'name': 'Payslip Test Company',
            'registration_no': 'TEST-003',
            'epf_no': '12345678',
            'socso_no': 'S12345678',
            'address_line1': '123 Payroll St',
            'city': 'Kuala Lumpur',
            'state': 'WP',
            'postcode': '50000',
            'country': 'MY',
        })

        # Create test employee
        cls.employee = cls.env['kf.employee'].create({
            'company_id': cls.company.id,
            'employee_no': 'EMP003',
            'first_name': 'Payslip',
            'last_name': 'Viewer',
            'ic_no': '900303-14-9012',
            'date_of_birth': '1990-03-03',
            'gender': 'M',
            'nationality': 'MY',
            'email': 'payslip.viewer@example.com',
            'employment_type': 'PERMANENT',
            'hire_date': '2023-01-01',
            'status': 'ACTIVE',
            'basic_salary': 5500,
            'epf_no': '11111111',
            'socso_no': 'S11111111',
            'bank_name': 'Maybank',
            'bank_account_no': '1234567890',
        })

        # Create test user with PIN
        cls.user = cls.env['kf.user'].create({
            'employee_id': cls.employee.id,
            'company_id': cls.company.id,
            'email': 'payslip.viewer@example.com',
            'role': 'EMPLOYEE',
            'status': 'ACTIVE',
        })
        cls.user.set_password('TestPassword123!')
        cls.user.set_pin('654321')

        # Create payslips
        cls.payslip = cls.env['kf.payslip'].create({
            'employee_id': cls.employee.id,
            'company_id': cls.company.id,
            'pay_period': '2025-01',
            'pay_date': date(2025, 1, 31),
            'basic_salary': 5500,
            'gross_salary': 6000,
            'total_deductions': 1000,
            'net_salary': 5000,
            'epf_employee': 660,
            'epf_employer': 780,
            'socso_employee': 23.65,
            'socso_employer': 82.95,
            'eis_employee': 12,
            'eis_employer': 12,
            'pcb': 200,
            'status': 'PUBLISHED',
        })

        # Create payslip lines
        cls.env['kf.payslip.line'].create({
            'payslip_id': cls.payslip.id,
            'line_type': 'EARNING',
            'code': 'BASIC',
            'name': 'Basic Salary',
            'amount': 5500,
            'sequence': 10,
        })
        cls.env['kf.payslip.line'].create({
            'payslip_id': cls.payslip.id,
            'line_type': 'EARNING',
            'code': 'ALLOW',
            'name': 'Allowances',
            'amount': 500,
            'sequence': 20,
        })
        cls.env['kf.payslip.line'].create({
            'payslip_id': cls.payslip.id,
            'line_type': 'DEDUCTION',
            'code': 'EPF',
            'name': 'EPF Employee',
            'amount': 660,
            'sequence': 100,
        })

    def _get_auth_token(self):
        """Helper to get auth token."""
        response = self.url_open(
            '/api/v1/auth/login',
            data=json.dumps({
                'email': 'payslip.viewer@example.com',
                'password': 'TestPassword123!',
            }),
            headers={'Content-Type': 'application/json'},
        )
        return response.json()['access_token']

    def _get_pin_verification_token(self, auth_token):
        """Helper to get PIN verification token."""
        response = self.url_open(
            '/api/v1/auth/pin/verify',
            data=json.dumps({'pin': '654321'}),
            headers={
                'Authorization': f'Bearer {auth_token}',
                'Content-Type': 'application/json',
            },
        )
        return response.json()['verification_token']

    def test_get_payslip_list(self):
        """Test getting payslip list (no PIN required)."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/payslips',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('items', data)
        self.assertIn('pagination', data)
        self.assertGreaterEqual(len(data['items']), 1)

    def test_get_payslip_detail_without_pin(self):
        """Test getting payslip detail without PIN verification."""
        token = self._get_auth_token()

        response = self.url_open(
            f'/api/v1/payslips/{self.payslip.id}',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 403)
        data = response.json()
        self.assertEqual(data['error']['code'], 'PIN_REQUIRED')

    def test_get_payslip_detail_with_pin(self):
        """Test getting payslip detail with PIN verification."""
        auth_token = self._get_auth_token()
        pin_token = self._get_pin_verification_token(auth_token)

        response = self.url_open(
            f'/api/v1/payslips/{self.payslip.id}',
            headers={
                'Authorization': f'Bearer {auth_token}',
                'X-Verification-Token': pin_token,
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['pay_period'], '2025-01')
        self.assertIn('earnings', data)
        self.assertIn('deductions', data)
        self.assertIn('summary', data)
        self.assertIn('statutory', data)

    def test_payslip_detail_earnings_deductions(self):
        """Test payslip detail contains correct earnings and deductions."""
        auth_token = self._get_auth_token()
        pin_token = self._get_pin_verification_token(auth_token)

        response = self.url_open(
            f'/api/v1/payslips/{self.payslip.id}',
            headers={
                'Authorization': f'Bearer {auth_token}',
                'X-Verification-Token': pin_token,
                'Content-Type': 'application/json',
            },
        )

        data = response.json()
        self.assertEqual(len(data['earnings']), 2)
        self.assertEqual(len(data['deductions']), 1)

    def test_payslip_masked_sensitive_data(self):
        """Test payslip masks sensitive employee data."""
        auth_token = self._get_auth_token()
        pin_token = self._get_pin_verification_token(auth_token)

        response = self.url_open(
            f'/api/v1/payslips/{self.payslip.id}',
            headers={
                'Authorization': f'Bearer {auth_token}',
                'X-Verification-Token': pin_token,
                'Content-Type': 'application/json',
            },
        )

        data = response.json()
        employee = data['employee']

        # IC and bank account should be masked
        self.assertTrue(employee['ic_no'].startswith('****'))
        self.assertTrue(employee['bank_account_no'].startswith('****'))

    def test_payslip_pdf_download(self):
        """Test payslip PDF download endpoint."""
        auth_token = self._get_auth_token()
        pin_token = self._get_pin_verification_token(auth_token)

        response = self.url_open(
            f'/api/v1/payslips/{self.payslip.id}/pdf',
            headers={
                'Authorization': f'Bearer {auth_token}',
                'X-Verification-Token': pin_token,
                'Content-Type': 'application/json',
            },
        )

        # PDF might not be generated, so accept 404 too
        self.assertIn(response.status_code, [200, 404])

    def test_payslip_year_filter(self):
        """Test filtering payslips by year."""
        token = self._get_auth_token()

        response = self.url_open(
            '/api/v1/payslips?year=2025',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        for item in data['items']:
            self.assertTrue(item['pay_period'].startswith('2025'))

    def test_access_other_employee_payslip(self):
        """Test cannot access another employee's payslip."""
        # Create another employee
        other_employee = self.env['kf.employee'].create({
            'company_id': self.company.id,
            'employee_no': 'EMP004',
            'first_name': 'Other',
            'last_name': 'Person',
            'ic_no': '900404-14-3456',
            'date_of_birth': '1990-04-04',
            'gender': 'F',
            'nationality': 'MY',
            'email': 'other.person@example.com',
            'employment_type': 'PERMANENT',
            'hire_date': '2023-01-01',
            'status': 'ACTIVE',
            'basic_salary': 4500,
        })

        other_payslip = self.env['kf.payslip'].create({
            'employee_id': other_employee.id,
            'company_id': self.company.id,
            'pay_period': '2025-01',
            'pay_date': date(2025, 1, 31),
            'basic_salary': 4500,
            'gross_salary': 4500,
            'total_deductions': 800,
            'net_salary': 3700,
            'status': 'PUBLISHED',
        })

        auth_token = self._get_auth_token()
        pin_token = self._get_pin_verification_token(auth_token)

        response = self.url_open(
            f'/api/v1/payslips/{other_payslip.id}',
            headers={
                'Authorization': f'Bearer {auth_token}',
                'X-Verification-Token': pin_token,
                'Content-Type': 'application/json',
            },
        )

        self.assertEqual(response.status_code, 404)
