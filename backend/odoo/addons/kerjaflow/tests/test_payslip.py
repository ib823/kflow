# -*- coding: utf-8 -*-
"""
KerjaFlow Payslip Tests
=======================

Unit tests for payslip models:
- kf.payslip
- kf.payslip.line
"""

from odoo.tests import tagged
from odoo.exceptions import ValidationError
from datetime import date
from .common import KerjaFlowTestCase


@tagged('kerjaflow', '-at_install', 'post_install')
class TestPayslip(KerjaFlowTestCase):
    """Test cases for kf.payslip model."""

    def setUp(self):
        """Set up test payslip data."""
        super().setUp()

        self.payslip = self.env['kf.payslip'].create({
            'employee_id': self.employee.id,
            'company_id': self.company.id,
            'pay_period': '2025-01',
            'pay_date': date(2025, 1, 31),
            'basic_salary': 5500,
            'gross_salary': 6000,
            'total_deductions': 1200,
            'net_salary': 4800,
            'epf_employee': 660,
            'epf_employer': 780,
            'socso_employee': 23.65,
            'socso_employer': 82.95,
            'eis_employee': 12,
            'eis_employer': 12,
            'pcb': 250,
            'status': 'DRAFT',
        })

    def test_payslip_creation(self):
        """Test basic payslip creation."""
        self.assertTrue(self.payslip.id)
        self.assertEqual(self.payslip.pay_period, '2025-01')
        self.assertEqual(self.payslip.basic_salary, 5500)
        self.assertEqual(self.payslip.status, 'DRAFT')

    def test_payslip_net_calculation(self):
        """Test net salary calculation."""
        # Net = Gross - Deductions
        expected_net = 6000 - 1200
        self.assertEqual(self.payslip.net_salary, expected_net)

    def test_payslip_statutory_contributions(self):
        """Test statutory contribution amounts."""
        # EPF employee contribution
        self.assertEqual(self.payslip.epf_employee, 660)
        # EPF employer contribution
        self.assertEqual(self.payslip.epf_employer, 780)
        # SOCSO employee contribution
        self.assertEqual(self.payslip.socso_employee, 23.65)
        # SOCSO employer contribution
        self.assertEqual(self.payslip.socso_employer, 82.95)

    def test_payslip_publish(self):
        """Test payslip publishing."""
        self.payslip.action_publish()
        self.assertEqual(self.payslip.status, 'PUBLISHED')
        self.assertTrue(self.payslip.published_at)

    def test_payslip_draft_to_publish_flow(self):
        """Test payslip workflow from draft to published."""
        self.assertEqual(self.payslip.status, 'DRAFT')

        # Finalize
        self.payslip.action_finalize()
        self.assertEqual(self.payslip.status, 'FINALIZED')

        # Publish
        self.payslip.action_publish()
        self.assertEqual(self.payslip.status, 'PUBLISHED')

    def test_payslip_unique_constraint(self):
        """Test unique employee/pay_period constraint."""
        with self.assertRaises(Exception):
            self.env['kf.payslip'].create({
                'employee_id': self.employee.id,
                'company_id': self.company.id,
                'pay_period': '2025-01',  # Same as existing
                'pay_date': date(2025, 1, 31),
                'basic_salary': 5500,
                'gross_salary': 6000,
                'total_deductions': 1200,
                'net_salary': 4800,
                'status': 'DRAFT',
            })

    def test_payslip_different_months(self):
        """Test creating payslips for different months."""
        payslip_feb = self.env['kf.payslip'].create({
            'employee_id': self.employee.id,
            'company_id': self.company.id,
            'pay_period': '2025-02',
            'pay_date': date(2025, 2, 28),
            'basic_salary': 5500,
            'gross_salary': 6000,
            'total_deductions': 1200,
            'net_salary': 4800,
            'status': 'DRAFT',
        })
        self.assertTrue(payslip_feb.id)
        self.assertEqual(payslip_feb.pay_period, '2025-02')


@tagged('kerjaflow', '-at_install', 'post_install')
class TestPayslipLine(KerjaFlowTestCase):
    """Test cases for kf.payslip.line model."""

    def setUp(self):
        """Set up test payslip with lines."""
        super().setUp()

        self.payslip = self.env['kf.payslip'].create({
            'employee_id': self.employee.id,
            'company_id': self.company.id,
            'pay_period': '2025-03',
            'pay_date': date(2025, 3, 31),
            'basic_salary': 5500,
            'gross_salary': 6000,
            'total_deductions': 1200,
            'net_salary': 4800,
            'status': 'DRAFT',
        })

    def test_payslip_line_earning(self):
        """Test earning line creation."""
        line = self.env['kf.payslip.line'].create({
            'payslip_id': self.payslip.id,
            'line_type': 'EARNING',
            'code': 'BASIC',
            'name': 'Basic Salary',
            'amount': 5500,
            'sequence': 10,
        })
        self.assertTrue(line.id)
        self.assertEqual(line.line_type, 'EARNING')
        self.assertEqual(line.amount, 5500)

    def test_payslip_line_deduction(self):
        """Test deduction line creation."""
        line = self.env['kf.payslip.line'].create({
            'payslip_id': self.payslip.id,
            'line_type': 'DEDUCTION',
            'code': 'EPF',
            'name': 'EPF Employee',
            'amount': 660,
            'sequence': 100,
        })
        self.assertTrue(line.id)
        self.assertEqual(line.line_type, 'DEDUCTION')
        self.assertEqual(line.amount, 660)

    def test_payslip_multiple_lines(self):
        """Test multiple payslip lines."""
        earnings = [
            ('BASIC', 'Basic Salary', 5500),
            ('ALLOW_TRANS', 'Transport Allowance', 300),
            ('ALLOW_MEAL', 'Meal Allowance', 200),
        ]

        deductions = [
            ('EPF_EE', 'EPF Employee', 660),
            ('SOCSO_EE', 'SOCSO Employee', 23.65),
            ('EIS_EE', 'EIS Employee', 12),
            ('PCB', 'Monthly Tax Deduction', 250),
        ]

        for i, (code, name, amount) in enumerate(earnings):
            self.env['kf.payslip.line'].create({
                'payslip_id': self.payslip.id,
                'line_type': 'EARNING',
                'code': code,
                'name': name,
                'amount': amount,
                'sequence': (i + 1) * 10,
            })

        for i, (code, name, amount) in enumerate(deductions):
            self.env['kf.payslip.line'].create({
                'payslip_id': self.payslip.id,
                'line_type': 'DEDUCTION',
                'code': code,
                'name': name,
                'amount': amount,
                'sequence': 100 + (i + 1) * 10,
            })

        # Verify line counts
        self.assertEqual(len(self.payslip.line_ids), 7)
        earnings_count = len(self.payslip.line_ids.filtered(
            lambda l: l.line_type == 'EARNING'
        ))
        deductions_count = len(self.payslip.line_ids.filtered(
            lambda l: l.line_type == 'DEDUCTION'
        ))
        self.assertEqual(earnings_count, 3)
        self.assertEqual(deductions_count, 4)

    def test_payslip_line_sequence(self):
        """Test line ordering by sequence."""
        self.env['kf.payslip.line'].create({
            'payslip_id': self.payslip.id,
            'line_type': 'EARNING',
            'code': 'BONUS',
            'name': 'Bonus',
            'amount': 1000,
            'sequence': 50,
        })

        self.env['kf.payslip.line'].create({
            'payslip_id': self.payslip.id,
            'line_type': 'EARNING',
            'code': 'BASIC',
            'name': 'Basic Salary',
            'amount': 5500,
            'sequence': 10,
        })

        lines = self.payslip.line_ids.sorted('sequence')
        self.assertEqual(lines[0].code, 'BASIC')
        self.assertEqual(lines[1].code, 'BONUS')
