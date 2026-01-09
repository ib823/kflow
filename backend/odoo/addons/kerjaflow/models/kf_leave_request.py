# -*- coding: utf-8 -*-
"""
Leave Request Model - Leave Application with Workflow
======================================================

Table: kf_leave_request
Implements state machine: PENDING → APPROVED/REJECTED/CANCELLED
"""

from datetime import date

from odoo.exceptions import ValidationError

from odoo import api, fields, models


class KfLeaveRequest(models.Model):
    _name = "kf.leave.request"
    _description = "KerjaFlow Leave Request"
    _order = "create_date desc"
    _inherit = ["mail.thread", "mail.activity.mixin"]

    # Request Details
    leave_type_id = fields.Many2one(
        comodel_name="kf.leave.type",
        string="Leave Type",
        required=True,
        domain="[('company_id', '=', company_id), ('is_active', '=', True)]",
        tracking=True,
    )
    date_from = fields.Date(
        string="From Date",
        required=True,
        index=True,
        tracking=True,
    )
    date_to = fields.Date(
        string="To Date",
        required=True,
        index=True,
        tracking=True,
    )
    half_day_type = fields.Selection(
        selection=[
            ("AM", "Morning (AM)"),
            ("PM", "Afternoon (PM)"),
        ],
        string="Half Day Type",
        help="Only for single-day half-day leave",
    )
    total_days = fields.Float(
        string="Total Days",
        required=True,
        help="Working days requested",
    )
    reason = fields.Text(
        string="Reason",
        help="Leave reason",
        tracking=True,
    )

    # Attachment
    attachment_id = fields.Many2one(
        comodel_name="kf.document",
        string="Attachment",
        help="Supporting document (e.g., MC)",
    )

    # Status
    status = fields.Selection(
        selection=[
            ("PENDING", "Pending"),
            ("APPROVED", "Approved"),
            ("REJECTED", "Rejected"),
            ("CANCELLED", "Cancelled"),
        ],
        string="Status",
        default="PENDING",
        required=True,
        index=True,
        tracking=True,
    )

    # Approval Information
    approver_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Approver",
        help="Employee who approved/rejected",
    )
    approved_at = fields.Datetime(
        string="Processed At",
        help="When approved/rejected",
    )
    rejection_reason = fields.Text(
        string="Rejection Reason",
    )

    # Relationships
    employee_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Employee",
        required=True,
        ondelete="cascade",
        index=True,
        default=lambda self: self._get_current_employee(),
    )
    company_id = fields.Many2one(
        related="employee_id.company_id",
        string="Company",
        store=True,
        index=True,
    )

    # Audit
    created_by_id = fields.Many2one(
        comodel_name="kf.user",
        string="Created By",
    )

    # Computed Fields
    can_cancel = fields.Boolean(
        compute="_compute_can_cancel",
    )
    display_name = fields.Char(
        compute="_compute_display_name",
    )

    @api.depends("employee_id", "leave_type_id", "date_from")
    def _compute_display_name(self):
        for rec in self:
            rec.display_name = (
                f"{rec.employee_id.full_name} - " f"{rec.leave_type_id.code} " f"({rec.date_from})"
            )

    @api.depends("status", "date_from")
    def _compute_can_cancel(self):
        today = date.today()
        for rec in self:
            if rec.status == "PENDING":
                rec.can_cancel = True
            elif rec.status == "APPROVED" and rec.date_from > today:
                rec.can_cancel = True
            else:
                rec.can_cancel = False

    def _get_current_employee(self):
        """Get current user's employee record."""
        user = self.env["kf.user"].search([("id", "=", self.env.uid)], limit=1)
        return user.employee_id.id if user else False

    @api.constrains("date_from", "date_to")
    def _check_dates(self):
        for rec in self:
            if rec.date_to < rec.date_from:
                raise ValidationError("End date cannot be before start date.")

    @api.constrains("half_day_type", "date_from", "date_to")
    def _check_half_day(self):
        for rec in self:
            if rec.half_day_type and rec.date_from != rec.date_to:
                raise ValidationError("Half-day leave is only allowed for single-day requests.")

    def action_approve(self, approver_id):
        """Approve leave request."""
        self.ensure_one()
        if self.status != "PENDING":
            raise ValidationError("Can only approve pending requests.")

        self.write(
            {
                "status": "APPROVED",
                "approver_id": approver_id,
                "approved_at": fields.Datetime.now(),
            }
        )

        # Update balance: move from pending to taken
        year = self.date_from.year
        balance = self.env["kf.leave.balance"].get_or_create_balance(
            self.employee_id.id,
            self.leave_type_id.id,
            year,
        )
        balance.update_pending(self.total_days, add=False)
        # Note: 'taken' is updated when leave date passes

        # Send notification
        self._send_status_notification()

        return True

    def action_reject(self, approver_id, reason=None):
        """Reject leave request."""
        self.ensure_one()
        if self.status != "PENDING":
            raise ValidationError("Can only reject pending requests.")

        self.write(
            {
                "status": "REJECTED",
                "approver_id": approver_id,
                "approved_at": fields.Datetime.now(),
                "rejection_reason": reason,
            }
        )

        # Update balance: remove from pending
        year = self.date_from.year
        balance = self.env["kf.leave.balance"].get_or_create_balance(
            self.employee_id.id,
            self.leave_type_id.id,
            year,
        )
        balance.update_pending(self.total_days, add=False)

        # Send notification
        self._send_status_notification()

        return True

    def action_cancel(self):
        """Cancel leave request."""
        self.ensure_one()
        if not self.can_cancel:
            raise ValidationError("This leave request cannot be cancelled.")

        old_status = self.status
        self.status = "CANCELLED"

        # Update balance
        year = self.date_from.year
        balance = self.env["kf.leave.balance"].get_or_create_balance(
            self.employee_id.id,
            self.leave_type_id.id,
            year,
        )

        if old_status == "PENDING":
            balance.update_pending(self.total_days, add=False)
        elif old_status == "APPROVED":
            # If leave was already taken, restore balance
            balance.update_taken(self.total_days, add=False)

        return True

    def _send_status_notification(self):
        """Send push notification for status change."""
        # Will be implemented with FCM/HMS integration
        pass

    @api.model
    def validate_request(
        self,
        employee_id,
        leave_type_id,
        date_from,
        date_to,
        half_day_type=None,
        attachment_id=None,
        exclude_id=None,
    ):
        """
        Validate leave request before submission.
        Returns (is_valid, error_code, error_details)

        Validation sequence from 04_Business_Logic.md:
        1. Date validity
        2. Working days > 0
        3. Balance sufficiency
        4. Overlap detection
        5. Notice period
        6. Attachment required
        7. Max days per request
        """
        # Get leave type record
        leave_type = self.env["kf.leave.type"].browse(leave_type_id)

        # 1. Date validity
        if date_to < date_from:
            return (False, "INVALID_DATE_RANGE", {"message": "End date before start"})

        if date_from < date.today():
            return (False, "DATE_IN_PAST", {"message": "Cannot apply for past dates"})

        # 2. Working days calculation
        working_days = self._calculate_working_days(date_from, date_to, employee_id)

        if half_day_type and date_from == date_to:
            working_days = 0.5
        elif half_day_type:
            return (False, "HALF_DAY_MULTI_DAY", {"message": "Half day only for single day"})

        if working_days <= 0:
            return (False, "NO_WORKING_DAYS", {"message": "No working days in selected period"})

        # 3. Balance sufficiency
        year = date_from.year
        balance = self.env["kf.leave.balance"].get_or_create_balance(
            employee_id, leave_type_id, year
        )
        available = balance.available
        if exclude_id:
            # Editing existing request - add back its days
            existing = self.browse(exclude_id)
            if existing.status == "PENDING":
                available += existing.total_days

        if working_days > available and not leave_type.allow_negative:
            return (
                False,
                "INSUFFICIENT_BALANCE",
                {
                    "available": available,
                    "requested": working_days,
                    "leave_type": leave_type.name,
                },
            )

        # 4. Overlap detection
        domain = [
            ("employee_id", "=", employee_id),
            ("status", "in", ["PENDING", "APPROVED"]),
            "|",
            "&",
            ("date_from", "<=", date_from),
            ("date_to", ">=", date_from),
            "&",
            ("date_from", "<=", date_to),
            ("date_to", ">=", date_to),
        ]
        if exclude_id:
            domain.append(("id", "!=", exclude_id))

        overlapping = self.search(domain, limit=1)
        if overlapping:
            return (
                False,
                "LEAVE_OVERLAP",
                {
                    "date": str(overlapping.date_from),
                    "conflicting_id": overlapping.id,
                },
            )

        # 5. Notice period
        if leave_type.min_days_notice > 0:
            days_notice = (date_from - date.today()).days
            if days_notice < leave_type.min_days_notice:
                return (
                    False,
                    "INSUFFICIENT_NOTICE",
                    {
                        "required": leave_type.min_days_notice,
                        "provided": days_notice,
                    },
                )

        # 6. Attachment required
        if leave_type.requires_attachment and not attachment_id:
            return (
                False,
                "ATTACHMENT_REQUIRED",
                {
                    "leave_type": leave_type.name,
                },
            )

        # 7. Max days per request
        if leave_type.max_days_per_request:
            if working_days > leave_type.max_days_per_request:
                return (
                    False,
                    "MAX_DAYS_EXCEEDED",
                    {
                        "max_allowed": leave_type.max_days_per_request,
                        "requested": working_days,
                    },
                )

        return (True, None, {"total_days": working_days})

    def _calculate_working_days(self, date_from, date_to, employee_id):
        """Calculate working days excluding weekends and holidays."""
        employee = self.env["kf.employee"].browse(employee_id)
        company = employee.company_id
        work_state = employee.state or company.state

        # Get public holidays
        holidays = (
            self.env["kf.public.holiday"]
            .search(
                [
                    ("company_id", "=", company.id),
                    ("date", ">=", date_from),
                    ("date", "<=", date_to),
                    "|",
                    ("state", "=", False),
                    ("state", "=", work_state),
                ]
            )
            .mapped("date")
        )

        working_days = 0
        current = date_from
        while current <= date_to:
            # Check if weekday (0=Mon, 6=Sun)
            if current.weekday() < 5:  # Not weekend
                if current not in holidays:
                    working_days += 1
            # Move to next day
            if current.day < 28:
                current = current.replace(day=current.day + 1)
            elif current.month < 12:
                current = date(current.year, current.month + 1, 1)
            else:
                current = date(current.year + 1, 1, 1)

        return working_days
