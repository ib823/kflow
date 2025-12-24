# -*- coding: utf-8 -*-
"""
Payslip Line Model - Individual Earnings/Deductions
====================================================

Table: kf_payslip_line
"""

from odoo import models, fields


class KfPayslipLine(models.Model):
    _name = 'kf.payslip.line'
    _description = 'KerjaFlow Payslip Line'
    _order = 'sequence, id'

    # Line Details
    line_type = fields.Selection(
        selection=[
            ('EARNING', 'Earning'),
            ('DEDUCTION', 'Deduction'),
        ],
        string='Type',
        required=True,
    )
    code = fields.Char(
        string='Code',
        required=True,
        help='Line item code (e.g., BASIC, OT_1_5X, EPF_EE)',
    )
    name = fields.Char(
        string='Description',
        required=True,
        help='Display name',
    )
    amount = fields.Float(
        string='Amount',
        required=True,
    )
    sequence = fields.Integer(
        string='Sequence',
        default=10,
    )

    # Relationships
    payslip_id = fields.Many2one(
        comodel_name='kf.payslip',
        string='Payslip',
        required=True,
        ondelete='cascade',
        index=True,
    )

    # Standard Codes
    @staticmethod
    def get_earning_codes():
        """Return standard earning codes."""
        return {
            'BASIC': 'Basic Salary',
            'OT_1_5X': 'Overtime 1.5x',
            'OT_2_0X': 'Overtime 2.0x',
            'OT_3_0X': 'Overtime 3.0x',
            'ALW_TRANSPORT': 'Transport Allowance',
            'ALW_MEAL': 'Meal Allowance',
            'ALW_PHONE': 'Phone Allowance',
            'ALW_HOUSING': 'Housing Allowance',
            'COMMISSION': 'Sales Commission',
            'BONUS': 'Bonus',
        }

    @staticmethod
    def get_deduction_codes():
        """Return standard deduction codes."""
        return {
            'EPF_EE': 'EPF Employee',
            'SOCSO_EE': 'SOCSO Employee',
            'EIS_EE': 'EIS Employee',
            'PCB': 'Monthly Tax (PCB)',
            'ZAKAT': 'Zakat',
            'LOAN': 'Company Loan',
            'ADVANCE': 'Salary Advance',
        }
