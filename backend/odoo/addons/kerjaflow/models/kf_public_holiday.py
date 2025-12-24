# -*- coding: utf-8 -*-
"""
Public Holiday Model - Malaysian Holiday Calendar
==================================================

Table: kf_public_holiday
Federal and state-specific holidays
"""

from odoo import models, fields


class KfPublicHoliday(models.Model):
    _name = 'kf.public.holiday'
    _description = 'KerjaFlow Public Holiday'
    _order = 'date'

    # Holiday Details
    name = fields.Char(
        string='Holiday Name',
        required=True,
        help='Holiday name in English',
    )
    name_ms = fields.Char(
        string='Name (Malay)',
        help='Holiday name in Bahasa Malaysia',
    )
    date = fields.Date(
        string='Date',
        required=True,
        index=True,
    )
    state = fields.Char(
        string='State',
        help='State code (null = federal/all states)',
        index=True,
    )
    is_recurring = fields.Boolean(
        string='Recurring',
        default=False,
        help='Whether holiday recurs annually (fixed date)',
    )
    holiday_type = fields.Selection(
        selection=[
            ('federal', 'Federal Holiday'),
            ('state', 'State Holiday'),
            ('company', 'Company Holiday'),
        ],
        string='Holiday Type',
        default='federal',
    )

    # Relationships
    company_id = fields.Many2one(
        comodel_name='kf.company',
        string='Company',
        required=True,
        ondelete='cascade',
        index=True,
    )

    # SQL Constraints
    _sql_constraints = [
        (
            'company_date_state_unique',
            'UNIQUE(company_id, date, state)',
            'Holiday must be unique per date/state!'
        ),
    ]

    def name_get(self):
        """Display name with date."""
        result = []
        for holiday in self:
            name = f"{holiday.name} ({holiday.date})"
            if holiday.state:
                name += f" [{holiday.state}]"
            result.append((holiday.id, name))
        return result
