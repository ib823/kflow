# -*- coding: utf-8 -*-
"""
Foreign Worker Detail Model - Permit and Visa Tracking
========================================================

Table: kf_foreign_worker_detail
For non-Malaysian employees
"""

from datetime import date, timedelta

from odoo import api, fields, models


class KfForeignWorkerDetail(models.Model):
    _name = "kf.foreign.worker.detail"
    _description = "KerjaFlow Foreign Worker Detail"
    _order = "permit_expiry"

    # Passport Information
    passport_no = fields.Char(
        string="Passport Number",
        required=True,
        index=True,
    )
    passport_expiry = fields.Date(
        string="Passport Expiry",
    )
    passport_country = fields.Char(
        string="Passport Country",
    )

    # Work Permit
    permit_type = fields.Selection(
        selection=[
            ("PLKS", "PLKS (Temporary Employment Pass)"),
            ("VP_TE", "Visit Pass (Temporary Employment)"),
            ("EP", "Employment Pass"),
            ("DP", "Dependant Pass"),
            ("PR", "Permanent Resident"),
            ("OTHER", "Other"),
        ],
        string="Permit Type",
        required=True,
    )
    permit_no = fields.Char(
        string="Permit Number",
        required=True,
        index=True,
    )
    permit_issue_date = fields.Date(
        string="Permit Issue Date",
    )
    permit_expiry = fields.Date(
        string="Permit Expiry",
        required=True,
        index=True,
    )

    # Visa Information
    visa_type = fields.Char(
        string="Visa Type",
    )
    visa_no = fields.Char(
        string="Visa Number",
    )
    visa_expiry = fields.Date(
        string="Visa Expiry",
    )

    # FOMEMA (Medical Examination)
    fomema_status = fields.Selection(
        selection=[
            ("PENDING", "Pending"),
            ("PASSED", "Passed"),
            ("FAILED", "Failed"),
            ("EXPIRED", "Expired"),
        ],
        string="FOMEMA Status",
    )
    fomema_date = fields.Date(
        string="FOMEMA Date",
    )
    fomema_expiry = fields.Date(
        string="FOMEMA Expiry",
    )

    # Security Bond
    security_bond_amount = fields.Float(
        string="Security Bond Amount",
    )
    security_bond_ref = fields.Char(
        string="Security Bond Reference",
    )

    # Immigration Office
    immigration_office = fields.Char(
        string="Immigration Office",
        help="Handling immigration office",
    )

    # Relationships
    employee_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Employee",
        required=True,
        ondelete="cascade",
        index=True,
    )
    company_id = fields.Many2one(
        related="employee_id.company_id",
        string="Company",
        store=True,
    )

    # Computed Fields
    days_until_expiry = fields.Integer(
        string="Days Until Expiry",
        compute="_compute_days_until_expiry",
    )
    is_expiring_soon = fields.Boolean(
        string="Expiring Soon",
        compute="_compute_is_expiring_soon",
        store=True,
    )
    is_expired = fields.Boolean(
        string="Is Expired",
        compute="_compute_is_expired",
        store=True,
    )

    # SQL Constraints
    _sql_constraints = [
        ("employee_unique", "UNIQUE(employee_id)", "Only one foreign worker detail per employee!"),
    ]

    @api.depends("permit_expiry")
    def _compute_days_until_expiry(self):
        today = date.today()
        for rec in self:
            if rec.permit_expiry:
                delta = rec.permit_expiry - today
                rec.days_until_expiry = delta.days
            else:
                rec.days_until_expiry = 0

    @api.depends("permit_expiry")
    def _compute_is_expiring_soon(self):
        today = date.today()
        warning_date = today + timedelta(days=90)
        for rec in self:
            if rec.permit_expiry:
                rec.is_expiring_soon = rec.permit_expiry <= warning_date and rec.permit_expiry > today
            else:
                rec.is_expiring_soon = False

    @api.depends("permit_expiry")
    def _compute_is_expired(self):
        today = date.today()
        for rec in self:
            if rec.permit_expiry:
                rec.is_expired = rec.permit_expiry < today
            else:
                rec.is_expired = False

    @api.model
    def get_expiring_permits(self, days=30, company_id=None):
        """Get permits expiring within specified days."""
        today = date.today()
        expiry_date = today + timedelta(days=days)

        domain = [
            ("permit_expiry", ">=", today),
            ("permit_expiry", "<=", expiry_date),
        ]
        if company_id:
            domain.append(("company_id", "=", company_id))

        return self.search(domain)
