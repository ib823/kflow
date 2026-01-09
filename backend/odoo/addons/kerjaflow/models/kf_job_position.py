# -*- coding: utf-8 -*-
"""
Job Position Model - Job Title/Role Definition
===============================================

Table: kf_job_position
"""

from odoo import fields, models


class KfJobPosition(models.Model):
    _name = "kf.job.position"
    _description = "KerjaFlow Job Position"
    _order = "name"

    # Basic Information
    code = fields.Char(
        string="Position Code",
        required=True,
        index=True,
        help="Unique within company",
    )
    name = fields.Char(
        string="Job Title",
        required=True,
        help="Job title (e.g., Senior Engineer)",
    )
    description = fields.Text(
        string="Job Description",
        help="Job description",
    )
    grade = fields.Char(
        string="Salary Grade",
        help="Salary grade code",
    )

    # Relationships
    company_id = fields.Many2one(
        comodel_name="kf.company",
        string="Company",
        required=True,
        ondelete="cascade",
        index=True,
    )
    employee_ids = fields.One2many(
        comodel_name="kf.employee",
        inverse_name="job_position_id",
        string="Employees",
    )

    # Status
    is_active = fields.Boolean(
        string="Active",
        default=True,
    )

    # Computed Fields
    employee_count = fields.Integer(
        string="Employee Count",
        compute="_compute_employee_count",
    )

    # SQL Constraints
    _sql_constraints = [
        (
            "company_code_unique",
            "UNIQUE(company_id, code)",
            "Position code must be unique within company!",
        ),
    ]

    def _compute_employee_count(self):
        for position in self:
            position.employee_count = len(
                position.employee_ids.filtered(lambda e: e.status == "ACTIVE")
            )
