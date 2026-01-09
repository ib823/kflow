# -*- coding: utf-8 -*-
"""
Audit Log Model - Comprehensive Audit Trail
============================================

Table: kf_audit_log
Required for PDPA 2010 compliance
"""

import json

from odoo import api, fields, models


class KfAuditLog(models.Model):
    _name = "kf.audit.log"
    _description = "KerjaFlow Audit Log"
    _order = "timestamp desc"
    _log_access = False  # Disable default logging to avoid recursion

    # Action Information
    action = fields.Selection(
        selection=[
            # Authentication
            ("LOGIN", "Login"),
            ("LOGIN_FAILED", "Login Failed"),
            ("LOGOUT", "Logout"),
            ("PASSWORD_CHANGE", "Password Changed"),
            ("PIN_SETUP", "PIN Setup"),
            ("PIN_VERIFY", "PIN Verified"),
            ("ACCOUNT_LOCKED", "Account Locked"),
            ("ACCOUNT_UNLOCKED", "Account Unlocked"),
            # Data Access
            ("PAYSLIP_VIEW", "Payslip Viewed"),
            ("PAYSLIP_DOWNLOAD", "Payslip Downloaded"),
            ("DOCUMENT_VIEW", "Document Viewed"),
            ("DOCUMENT_DOWNLOAD", "Document Downloaded"),
            ("REPORT_GENERATE", "Report Generated"),
            # Data Modification
            ("EMPLOYEE_CREATE", "Employee Created"),
            ("EMPLOYEE_UPDATE", "Employee Updated"),
            ("LEAVE_APPLY", "Leave Applied"),
            ("LEAVE_APPROVE", "Leave Approved"),
            ("LEAVE_REJECT", "Leave Rejected"),
            ("LEAVE_CANCEL", "Leave Cancelled"),
            ("PAYSLIP_IMPORT", "Payslip Imported"),
            ("PAYSLIP_PUBLISH", "Payslip Published"),
            # Admin Actions
            ("USER_ROLE_CHANGE", "User Role Changed"),
            ("CONFIG_CHANGE", "Configuration Changed"),
        ],
        string="Action",
        required=True,
        index=True,
    )
    entity_type = fields.Char(
        string="Entity Type",
        index=True,
        help="Model name (e.g., kf.employee)",
    )
    entity_id = fields.Integer(
        string="Entity ID",
        index=True,
    )
    old_values = fields.Text(
        string="Old Values (JSON)",
        help="Previous values before change",
    )
    new_values = fields.Text(
        string="New Values (JSON)",
        help="New values after change",
    )

    # Context
    ip_address = fields.Char(
        string="IP Address",
    )
    user_agent = fields.Char(
        string="User Agent",
    )
    device_id = fields.Char(
        string="Device ID",
    )

    # Timestamp
    timestamp = fields.Datetime(
        string="Timestamp",
        required=True,
        default=fields.Datetime.now,
        index=True,
    )

    # Relationships
    user_id = fields.Many2one(
        comodel_name="kf.user",
        string="User",
        ondelete="set null",
        index=True,
    )
    company_id = fields.Many2one(
        comodel_name="kf.company",
        string="Company",
        index=True,
    )

    @api.model
    def log(
        self,
        action,
        user_id=None,
        company_id=None,
        entity_type=None,
        entity_id=None,
        old_values=None,
        new_values=None,
        ip_address=None,
        user_agent=None,
        device_id=None,
    ):
        """Create audit log entry."""
        return self.sudo().create(
            {
                "action": action,
                "user_id": user_id,
                "company_id": company_id,
                "entity_type": entity_type,
                "entity_id": entity_id,
                "old_values": json.dumps(old_values) if old_values else None,
                "new_values": json.dumps(new_values) if new_values else None,
                "ip_address": ip_address,
                "user_agent": user_agent,
                "device_id": device_id,
            }
        )

    @api.model
    def log_login(self, user_id, success, ip_address=None, user_agent=None):
        """Log login attempt."""
        action = "LOGIN" if success else "LOGIN_FAILED"
        user = self.env["kf.user"].browse(user_id)
        return self.log(
            action=action,
            user_id=user_id,
            company_id=user.company_id.id if user else None,
            ip_address=ip_address,
            user_agent=user_agent,
        )

    @api.model
    def log_data_access(self, action, user_id, entity_type, entity_id, ip_address=None):
        """Log sensitive data access."""
        user = self.env["kf.user"].browse(user_id)
        return self.log(
            action=action,
            user_id=user_id,
            company_id=user.company_id.id if user else None,
            entity_type=entity_type,
            entity_id=entity_id,
            ip_address=ip_address,
        )

    @api.model
    def log_data_change(self, action, user_id, entity_type, entity_id, old_values=None, new_values=None):
        """Log data modification."""
        user = self.env["kf.user"].browse(user_id)
        return self.log(
            action=action,
            user_id=user_id,
            company_id=user.company_id.id if user else None,
            entity_type=entity_type,
            entity_id=entity_id,
            old_values=old_values,
            new_values=new_values,
        )
