# -*- coding: utf-8 -*-
"""
Statutory Rate Model
====================

Table: kf_statutory_rate
CENTRAL table (Malaysia Hub Only) - stores statutory contribution rates
for all 9 ASEAN countries with date-based activation.

Per CLAUDE.md:
- ALWAYS use payslip_date for rate lookup, NEVER use today's date
- Supports scheduled future rates (e.g., Cambodia NSSF Oct 2027 increase)
"""

from odoo import models, fields, api
from datetime import date
from decimal import Decimal
import logging

_logger = logging.getLogger(__name__)


class KfStatutoryRate(models.Model):
    """Statutory contribution rates with date-based activation"""
    _name = 'kf.statutory.rate'
    _description = 'KerjaFlow Statutory Rate'
    _order = 'country_code, contribution_type, effective_from desc'

    # Country reference
    country_id = fields.Many2one(
        comodel_name='kf.country.config',
        string='Country',
        required=True,
        ondelete='cascade',
        index=True,
    )
    country_code = fields.Char(
        string='Country Code',
        related='country_id.country_code',
        store=True,
        index=True,
    )

    # Rate identification
    contribution_type = fields.Selection(
        selection=[
            # Malaysia
            ('EPF', 'EPF (Malaysia)'),
            ('SOCSO', 'SOCSO (Malaysia)'),
            ('EIS', 'EIS (Malaysia)'),
            # Singapore
            ('CPF', 'CPF (Singapore)'),
            # Indonesia
            ('BPJS_TK', 'BPJS Ketenagakerjaan (Indonesia)'),
            ('BPJS_KES', 'BPJS Kesehatan (Indonesia)'),
            # Thailand
            ('SSF', 'Social Security Fund (Thailand)'),
            # Vietnam
            ('SI', 'Social Insurance (Vietnam)'),
            ('HI', 'Health Insurance (Vietnam)'),
            ('UI', 'Unemployment Insurance (Vietnam)'),
            # Philippines
            ('SSS', 'SSS (Philippines)'),
            ('PHILHEALTH', 'PhilHealth (Philippines)'),
            ('HDMF', 'HDMF/Pag-IBIG (Philippines)'),
            # Laos
            ('LSSO', 'LSSO (Laos)'),
            # Cambodia
            ('NSSF_RISK', 'NSSF Occupational Risk (Cambodia)'),
            ('NSSF_HEALTH', 'NSSF Health (Cambodia)'),
            ('NSSF_PENSION', 'NSSF Pension (Cambodia)'),
            # Brunei
            ('SPK', 'TAP/SCP (Brunei)'),
        ],
        string='Contribution Type',
        required=True,
        index=True,
    )
    system_name = fields.Char(
        string='System Name',
        help='Full name of the statutory system',
    )

    # Rates
    employee_rate = fields.Float(
        string='Employee Rate (%)',
        required=True,
        default=0.0,
        digits=(5, 2),
        help='Employee contribution rate as percentage',
    )
    employer_rate = fields.Float(
        string='Employer Rate (%)',
        required=True,
        default=0.0,
        digits=(5, 2),
        help='Employer contribution rate as percentage',
    )
    salary_cap = fields.Float(
        string='Salary Cap',
        digits=(15, 2),
        help='Maximum salary for contribution calculation',
    )
    currency_code = fields.Char(
        string='Currency Code',
        related='country_id.currency_code',
        store=True,
    )

    # Date-based activation (CRITICAL per CLAUDE.md)
    effective_from = fields.Date(
        string='Effective From',
        required=True,
        index=True,
        help='Date when this rate becomes effective',
    )
    effective_to = fields.Date(
        string='Effective To',
        index=True,
        help='Date when this rate expires (NULL = currently active)',
    )
    is_scheduled = fields.Boolean(
        string='Scheduled Future Rate',
        default=False,
        help='If True, this is a pre-configured future rate',
    )
    superseded_by = fields.Many2one(
        comodel_name='kf.statutory.rate',
        string='Superseded By',
        help='If set, points to the rate that replaced this one',
    )

    # Reference
    regulatory_reference = fields.Char(
        string='Regulatory Reference',
        help='Law or regulation reference',
    )
    notes = fields.Text(
        string='Notes',
        help='Additional information about this rate',
    )

    # SQL Constraints
    _sql_constraints = [
        (
            'unique_rate_period',
            'UNIQUE(country_code, contribution_type, effective_from)',
            'Rate for this country, type, and effective date already exists!'
        ),
    ]

    @api.model
    def get_rate(self, country_code, contribution_type, effective_date=None):
        """
        Get the applicable rate for a given date.

        CRITICAL per CLAUDE.md: Use payslip_date, NEVER today's date for payroll!

        Args:
            country_code: ISO 2-letter country code
            contribution_type: Type of contribution
            effective_date: Date for rate lookup (defaults to today)

        Returns:
            recordset with applicable rate or empty recordset

        Example:
            # Cambodia pension for Oct 2027 - auto-selects 4% rate
            rate = self.env['kf.statutory.rate'].get_rate(
                'KH', 'NSSF_PENSION', date(2027, 10, 15)
            )
        """
        if effective_date is None:
            effective_date = date.today()

        return self.search([
            ('country_code', '=', country_code),
            ('contribution_type', '=', contribution_type),
            ('effective_from', '<=', effective_date),
            '|', ('effective_to', '=', False),
                 ('effective_to', '>=', effective_date),
        ], order='effective_from desc', limit=1)

    @api.model
    def get_all_rates_for_country(self, country_code, effective_date=None):
        """
        Get all applicable rates for a country on a given date.

        Args:
            country_code: ISO 2-letter country code
            effective_date: Date for rate lookup

        Returns:
            recordset with all applicable rates
        """
        if effective_date is None:
            effective_date = date.today()

        return self.search([
            ('country_code', '=', country_code),
            ('effective_from', '<=', effective_date),
            '|', ('effective_to', '=', False),
                 ('effective_to', '>=', effective_date),
        ])

    @api.model
    def get_upcoming_changes(self, days_ahead=90):
        """
        Get scheduled rate changes in the next N days.
        Used for compliance alerts.

        Args:
            days_ahead: Number of days to look ahead

        Returns:
            recordset of scheduled future rates
        """
        from datetime import timedelta
        future_date = date.today() + timedelta(days=days_ahead)

        return self.search([
            ('is_scheduled', '=', True),
            ('effective_from', '>', date.today()),
            ('effective_from', '<=', future_date),
        ], order='effective_from')

    def calculate_contribution(self, gross_salary):
        """
        Calculate employee and employer contributions for a salary.

        Args:
            gross_salary: Gross monthly salary

        Returns:
            dict with 'employee' and 'employer' amounts
        """
        self.ensure_one()
        salary = Decimal(str(gross_salary))

        # Apply salary cap if exists
        if self.salary_cap:
            cap = Decimal(str(self.salary_cap))
            if salary > cap:
                salary = cap

        employee_amount = salary * (Decimal(str(self.employee_rate)) / 100)
        employer_amount = salary * (Decimal(str(self.employer_rate)) / 100)

        return {
            'employee': float(employee_amount),
            'employer': float(employer_amount),
            'applied_salary': float(salary),
            'capped': self.salary_cap and gross_salary > self.salary_cap,
        }
