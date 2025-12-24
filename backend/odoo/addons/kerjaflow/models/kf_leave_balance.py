# -*- coding: utf-8 -*-
"""
Leave Balance Model - Employee Leave Entitlement Tracking
=========================================================

Table: kf_leave_balance
Tracks entitled, carried, taken, pending for each employee/leave type/year
"""

from odoo import models, fields, api


class KfLeaveBalance(models.Model):
    _name = 'kf.leave.balance'
    _description = 'KerjaFlow Leave Balance'
    _order = 'year desc, leave_type_id'
    _rec_name = 'display_name'

    # Relationships
    employee_id = fields.Many2one(
        comodel_name='kf.employee',
        string='Employee',
        required=True,
        ondelete='cascade',
        index=True,
    )
    leave_type_id = fields.Many2one(
        comodel_name='kf.leave.type',
        string='Leave Type',
        required=True,
        ondelete='cascade',
        index=True,
    )
    company_id = fields.Many2one(
        related='employee_id.company_id',
        string='Company',
        store=True,
        index=True,
    )

    # Year
    year = fields.Integer(
        string='Leave Year',
        required=True,
        index=True,
        help='Calendar year for balance',
    )

    # Balance Components
    entitled = fields.Float(
        string='Entitled Days',
        default=0,
        help='Annual entitlement (may be pro-rated)',
    )
    carried = fields.Float(
        string='Carried Forward',
        default=0,
        help='Days carried from previous year',
    )
    adjustment = fields.Float(
        string='Adjustment',
        default=0,
        help='Manual adjustments (+/-)',
    )
    taken = fields.Float(
        string='Taken Days',
        default=0,
        help='Days used (approved leaves that have passed)',
    )
    pending = fields.Float(
        string='Pending Days',
        default=0,
        help='Days in pending approval status',
    )

    # Computed Balance
    balance = fields.Float(
        string='Available Balance',
        compute='_compute_balance',
        store=True,
        help='Available = entitled + carried + adjustment - taken',
    )
    available = fields.Float(
        string='Available After Pending',
        compute='_compute_available',
        help='Available - pending (for validation)',
    )

    # Display Name
    display_name = fields.Char(
        compute='_compute_display_name',
    )

    # SQL Constraints
    _sql_constraints = [
        (
            'employee_leavetype_year_unique',
            'UNIQUE(employee_id, leave_type_id, year)',
            'Balance record must be unique per employee/leave type/year!'
        ),
    ]

    @api.depends('entitled', 'carried', 'adjustment', 'taken')
    def _compute_balance(self):
        for rec in self:
            rec.balance = rec.entitled + rec.carried + rec.adjustment - rec.taken

    @api.depends('balance', 'pending')
    def _compute_available(self):
        for rec in self:
            rec.available = rec.balance - rec.pending

    @api.depends('employee_id', 'leave_type_id', 'year')
    def _compute_display_name(self):
        for rec in self:
            rec.display_name = (
                f"{rec.employee_id.full_name} - "
                f"{rec.leave_type_id.code} ({rec.year})"
            )

    @api.model
    def get_or_create_balance(self, employee_id, leave_type_id, year):
        """Get existing balance or create new one."""
        balance = self.search([
            ('employee_id', '=', employee_id),
            ('leave_type_id', '=', leave_type_id),
            ('year', '=', year),
        ], limit=1)

        if not balance:
            employee = self.env['kf.employee'].browse(employee_id)
            leave_type = self.env['kf.leave.type'].browse(leave_type_id)

            # Calculate pro-rata if needed
            entitled = leave_type.default_entitlement
            if leave_type.prorate_on_join and employee.join_date:
                company = employee.company_id
                leave_year_start = (
                    employee.join_date.replace(month=company.leave_year_start, day=1)
                )
                if employee.join_date.month < company.leave_year_start:
                    leave_year_start = leave_year_start.replace(
                        year=leave_year_start.year - 1
                    )

                if employee.join_date > leave_year_start:
                    # Pro-rata calculation
                    months_remaining = 12 - (
                        (employee.join_date.month - company.leave_year_start) % 12
                    )
                    monthly = leave_type.default_entitlement / 12
                    entitled = round(monthly * months_remaining * 2) / 2

            balance = self.create({
                'employee_id': employee_id,
                'leave_type_id': leave_type_id,
                'year': year,
                'entitled': entitled,
            })

        return balance

    def update_pending(self, days, add=True):
        """Update pending days."""
        self.ensure_one()
        if add:
            self.pending += days
        else:
            self.pending = max(0, self.pending - days)

    def update_taken(self, days, add=True):
        """Update taken days."""
        self.ensure_one()
        if add:
            self.taken += days
        else:
            self.taken = max(0, self.taken - days)
