# -*- coding: utf-8 -*-
"""
Leave Type Model - Leave Policy Definition
===========================================

Table: kf_leave_type
"""

from odoo import fields, models


class KfLeaveType(models.Model):
    _name = "kf.leave.type"
    _description = "KerjaFlow Leave Type"
    _order = "sequence, name"

    # Basic Information
    code = fields.Char(
        string="Leave Code",
        required=True,
        help="Short code (e.g., AL, MC, CL)",
    )
    name = fields.Char(
        string="Leave Name",
        required=True,
        help="Full name (e.g., Annual Leave)",
    )
    name_ms = fields.Char(
        string="Name (Malay)",
        help="Name in Bahasa Malaysia",
    )
    description = fields.Text(
        string="Description",
        help="Leave type description",
    )
    color = fields.Char(
        string="Color",
        help="HEX color for calendar display",
    )
    icon = fields.Char(
        string="Icon",
        help="Icon name for mobile app",
    )

    # Entitlement Configuration
    default_entitlement = fields.Float(
        string="Default Entitlement",
        default=0,
        help="Default annual entitlement in days",
    )
    prorate_on_join = fields.Boolean(
        string="Pro-rate on Join",
        default=True,
        help="Pro-rate for new joiners",
    )
    carry_forward = fields.Boolean(
        string="Allow Carry Forward",
        default=False,
        help="Allow carry forward to next year",
    )
    max_carry_forward = fields.Float(
        string="Max Carry Forward",
        default=0,
        help="Maximum days to carry forward",
    )
    carry_forward_expiry = fields.Integer(
        string="Carry Forward Expiry (Months)",
        default=3,
        help="Months after year start to use carried days",
    )
    allow_negative = fields.Boolean(
        string="Allow Negative Balance",
        default=False,
        help="Allow leave even if balance is negative",
    )

    # Request Rules
    min_days_notice = fields.Integer(
        string="Minimum Notice Days",
        default=0,
        help="Minimum days in advance to apply",
    )
    max_days_per_request = fields.Integer(
        string="Max Days Per Request",
        help="Maximum days in single request",
    )
    requires_attachment = fields.Boolean(
        string="Requires Attachment",
        default=False,
        help="Attachment required (e.g., MC)",
    )
    allow_half_day = fields.Boolean(
        string="Allow Half Day",
        default=True,
        help="Allow half-day leave",
    )

    # Visibility
    is_visible = fields.Boolean(
        string="Visible to Employees",
        default=True,
        help="Show in employee leave type list",
    )

    # Status
    is_active = fields.Boolean(
        string="Active",
        default=True,
    )

    # Display Order
    sequence = fields.Integer(
        string="Sequence",
        default=10,
    )

    # Relationships
    company_id = fields.Many2one(
        comodel_name="kf.company",
        string="Company",
        required=True,
        ondelete="cascade",
        index=True,
    )
    leave_balance_ids = fields.One2many(
        comodel_name="kf.leave.balance",
        inverse_name="leave_type_id",
        string="Leave Balances",
    )
    leave_request_ids = fields.One2many(
        comodel_name="kf.leave.request",
        inverse_name="leave_type_id",
        string="Leave Requests",
    )

    # SQL Constraints
    _sql_constraints = [
        (
            "company_code_unique",
            "UNIQUE(company_id, code)",
            "Leave type code must be unique within company!",
        ),
    ]

    def name_get(self):
        """Display name with code."""
        result = []
        for leave_type in self:
            name = f"[{leave_type.code}] {leave_type.name}"
            result.append((leave_type.id, name))
        return result
