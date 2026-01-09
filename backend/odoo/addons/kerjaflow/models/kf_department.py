# -*- coding: utf-8 -*-
"""
Department Model - Organizational Unit
======================================

Table: kf_department
"""

from odoo.exceptions import ValidationError

from odoo import api, fields, models


class KfDepartment(models.Model):
    _name = "kf.department"
    _description = "KerjaFlow Department"
    _order = "name"
    _rec_name = "display_name"
    _parent_name = "parent_id"
    _parent_store = True

    # Basic Information
    code = fields.Char(
        string="Department Code",
        required=True,
        index=True,
        help="Unique within company",
    )
    name = fields.Char(
        string="Department Name",
        required=True,
    )

    # Relationships
    company_id = fields.Many2one(
        comodel_name="kf.company",
        string="Company",
        required=True,
        ondelete="cascade",
        index=True,
    )
    parent_id = fields.Many2one(
        comodel_name="kf.department",
        string="Parent Department",
        index=True,
        ondelete="set null",
        domain="[('company_id', '=', company_id)]",
    )
    parent_path = fields.Char(index=True)
    child_ids = fields.One2many(
        comodel_name="kf.department",
        inverse_name="parent_id",
        string="Sub Departments",
    )
    manager_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Department Head",
        domain="[('company_id', '=', company_id)]",
        help="Department head/manager",
    )
    employee_ids = fields.One2many(
        comodel_name="kf.employee",
        inverse_name="department_id",
        string="Employees",
    )

    # Financial
    cost_center = fields.Char(
        string="Cost Center",
        help="Cost center code",
    )

    # Status
    is_active = fields.Boolean(
        string="Active",
        default=True,
    )

    # Computed Fields
    display_name = fields.Char(
        compute="_compute_display_name",
        store=True,
    )
    employee_count = fields.Integer(
        string="Employee Count",
        compute="_compute_employee_count",
    )

    # SQL Constraints
    _sql_constraints = [
        (
            "company_code_unique",
            "UNIQUE(company_id, code)",
            "Department code must be unique within company!",
        ),
    ]

    @api.depends("name", "parent_id.display_name")
    def _compute_display_name(self):
        for dept in self:
            if dept.parent_id:
                dept.display_name = f"{dept.parent_id.display_name} / {dept.name}"
            else:
                dept.display_name = dept.name

    @api.depends("employee_ids")
    def _compute_employee_count(self):
        for dept in self:
            dept.employee_count = len(dept.employee_ids.filtered(lambda e: e.status == "ACTIVE"))

    @api.constrains("parent_id")
    def _check_parent_id(self):
        if not self._check_recursion():
            raise ValidationError("You cannot create recursive department hierarchy.")
