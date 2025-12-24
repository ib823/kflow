# -*- coding: utf-8 -*-
"""
KerjaFlow Test Common
=====================

Common test utilities and base test class for KerjaFlow tests.
"""

from odoo.tests import TransactionCase, tagged
from datetime import date, datetime, timedelta


@tagged('kerjaflow', '-at_install', 'post_install')
class KerjaFlowTestCase(TransactionCase):
    """Base test case for KerjaFlow tests."""

    @classmethod
    def setUpClass(cls):
        """Set up test data."""
        super().setUpClass()

        # Create test company
        cls.company = cls.env['kf.company'].create({
            'name': 'Test Company Sdn Bhd',
            'registration_no': '1234567-X',
            'epf_no': '12345678',
            'socso_no': 'S12345678',
            'eis_no': 'E12345678',
            'address_line1': '123 Test Street',
            'city': 'Kuala Lumpur',
            'state': 'WP',
            'postcode': '50000',
            'country': 'MY',
            'email': 'test@testcompany.my',
            'is_active': True,
        })

        # Create test department
        cls.department = cls.env['kf.department'].create({
            'company_id': cls.company.id,
            'name': 'Engineering',
            'code': 'ENG',
            'is_active': True,
        })

        # Create test job position
        cls.job_position = cls.env['kf.job.position'].create({
            'company_id': cls.company.id,
            'name': 'Software Engineer',
            'code': 'SE',
            'department_id': cls.department.id,
            'grade': 'E3',
            'min_salary': 4000,
            'max_salary': 8000,
            'is_active': True,
        })

        # Create manager employee
        cls.manager_employee = cls.env['kf.employee'].create({
            'company_id': cls.company.id,
            'employee_no': 'TC001',
            'first_name': 'Manager',
            'last_name': 'Test',
            'ic_no': '800101-14-1234',
            'date_of_birth': date(1980, 1, 1),
            'gender': 'M',
            'nationality': 'MY',
            'email': 'manager@testcompany.my',
            'department_id': cls.department.id,
            'job_position_id': cls.job_position.id,
            'employment_type': 'PERMANENT',
            'hire_date': date(2020, 1, 1),
            'status': 'ACTIVE',
            'basic_salary': 15000,
        })

        # Create test employee
        cls.employee = cls.env['kf.employee'].create({
            'company_id': cls.company.id,
            'employee_no': 'TC002',
            'first_name': 'John',
            'last_name': 'Doe',
            'ic_no': '900515-14-5678',
            'date_of_birth': date(1990, 5, 15),
            'gender': 'M',
            'nationality': 'MY',
            'email': 'john.doe@testcompany.my',
            'phone': '+60123456789',
            'department_id': cls.department.id,
            'job_position_id': cls.job_position.id,
            'manager_id': cls.manager_employee.id,
            'employment_type': 'PERMANENT',
            'hire_date': date(2023, 1, 15),
            'status': 'ACTIVE',
            'basic_salary': 5500,
            'epf_no': '23456789',
            'socso_no': 'S23456789',
            'bank_name': 'Maybank',
            'bank_account_no': '1234567890',
        })

        # Create test user
        cls.user = cls.env['kf.user'].create({
            'employee_id': cls.employee.id,
            'company_id': cls.company.id,
            'email': 'john.doe@testcompany.my',
            'role': 'EMPLOYEE',
            'status': 'ACTIVE',
        })

        # Create manager user
        cls.manager_user = cls.env['kf.user'].create({
            'employee_id': cls.manager_employee.id,
            'company_id': cls.company.id,
            'email': 'manager@testcompany.my',
            'role': 'SUPERVISOR',
            'status': 'ACTIVE',
        })

        # Create leave type
        cls.leave_type_annual = cls.env['kf.leave.type'].create({
            'company_id': cls.company.id,
            'code': 'AL',
            'name': 'Annual Leave',
            'name_ms': 'Cuti Tahunan',
            'color': '#4CAF50',
            'default_entitlement': 14,
            'max_carry_forward': 5,
            'carry_forward_months': 3,
            'allow_half_day': True,
            'requires_attachment': False,
            'requires_approval': True,
            'min_days_notice': 3,
            'max_days_per_request': 14,
            'is_visible': True,
            'is_active': True,
        })

        cls.leave_type_medical = cls.env['kf.leave.type'].create({
            'company_id': cls.company.id,
            'code': 'MC',
            'name': 'Medical Leave',
            'name_ms': 'Cuti Sakit',
            'color': '#F44336',
            'default_entitlement': 14,
            'max_carry_forward': 0,
            'allow_half_day': True,
            'requires_attachment': True,
            'requires_approval': True,
            'min_days_notice': 0,
            'is_visible': True,
            'is_active': True,
        })

    def _create_leave_balance(self, employee, leave_type, year=None):
        """Helper to create leave balance."""
        if year is None:
            year = date.today().year

        return self.env['kf.leave.balance'].create({
            'employee_id': employee.id,
            'leave_type_id': leave_type.id,
            'company_id': employee.company_id.id,
            'year': year,
            'entitled': leave_type.default_entitlement,
            'carried': 0,
            'adjustment': 0,
            'taken': 0,
            'pending': 0,
        })

    def _create_leave_request(self, employee, leave_type, date_from, date_to,
                               status='PENDING', **kwargs):
        """Helper to create leave request."""
        vals = {
            'employee_id': employee.id,
            'leave_type_id': leave_type.id,
            'company_id': employee.company_id.id,
            'date_from': date_from,
            'date_to': date_to,
            'total_days': (date_to - date_from).days + 1,
            'status': status,
            'created_by_id': kwargs.get('created_by_id', self.user.id),
        }
        vals.update(kwargs)
        return self.env['kf.leave.request'].create(vals)
