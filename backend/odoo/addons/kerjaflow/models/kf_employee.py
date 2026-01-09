# -*- coding: utf-8 -*-
"""
Employee Model - Core Employee Master Data
===========================================

Table: kf_employee (REGIONAL - stored per country VPS)
50+ fields supporting all 9 ASEAN countries

CRITICAL per CLAUDE.md:
- ALWAYS include country_code in employee-related queries
- Data routing is based on country_code field
- ID and VN have MANDATORY local data storage requirements
"""

import logging
import re
from datetime import date
from decimal import Decimal

from dateutil.relativedelta import relativedelta
from odoo.exceptions import ValidationError

from odoo import _, api, fields, models

_logger = logging.getLogger(__name__)


class KfEmployee(models.Model):
    _name = "kf.employee"
    _description = "KerjaFlow Employee"
    _order = "full_name"
    _rec_name = "full_name"

    # Identification
    employee_no = fields.Char(
        string="Employee ID",
        required=True,
        index=True,
        help="Employee ID (unique per company)",
    )
    badge_id = fields.Char(
        string="Badge ID",
        index=True,
        help="Badge/access card ID",
    )

    # Country Configuration (CRITICAL for data routing per CLAUDE.md)
    country_id = fields.Many2one(
        comodel_name="kf.country.config",
        string="Country",
        required=True,
        index=True,
        tracking=True,
        help="Employee country - determines data storage location",
    )
    country_code = fields.Char(
        string="Country Code",
        related="country_id.country_code",
        store=True,
        index=True,
        help="ISO country code for data routing (MY, SG, ID, TH, VN, PH, LA, KH, BN)",
    )

    # Currency for monetary fields
    currency_id = fields.Many2one(
        comodel_name="res.currency",
        string="Currency",
        related="country_id.currency_id",
        store=True,
        help="Currency based on employee country",
    )

    # Personal Information
    full_name = fields.Char(
        string="Full Name",
        required=True,
        index=True,
        help="Full name as per IC",
    )
    preferred_name = fields.Char(
        string="Preferred Name",
        help="Preferred/call name",
    )
    ic_no = fields.Char(
        string="IC Number",
        index=True,
        help="MyKad IC number",
    )
    passport_no = fields.Char(
        string="Passport Number",
        index=True,
    )
    date_of_birth = fields.Date(
        string="Date of Birth",
    )
    gender = fields.Selection(
        selection=[
            ("M", "Male"),
            ("F", "Female"),
            ("O", "Other"),
        ],
        string="Gender",
    )
    marital_status = fields.Selection(
        selection=[
            ("single", "Single"),
            ("married", "Married"),
            ("divorced", "Divorced"),
            ("widowed", "Widowed"),
        ],
        string="Marital Status",
    )
    nationality = fields.Char(
        string="Nationality",
        default="Malaysian",
    )
    race = fields.Selection(
        selection=[
            ("malay", "Malay"),
            ("chinese", "Chinese"),
            ("indian", "Indian"),
            ("other", "Other"),
        ],
        string="Race",
    )
    religion = fields.Char(string="Religion")

    # Contact Information
    email = fields.Char(
        string="Personal Email",
        index=True,
    )
    work_email = fields.Char(
        string="Work Email",
        index=True,
    )
    mobile_phone = fields.Char(
        string="Mobile Phone",
        index=True,
        help="Mobile number (for OTP)",
    )

    # Address
    address_line1 = fields.Char(string="Address Line 1")
    address_line2 = fields.Char(string="Address Line 2")
    city = fields.Char(string="City")
    state = fields.Char(string="State")
    postcode = fields.Char(string="Postcode")

    # Emergency Contact
    emergency_name = fields.Char(string="Emergency Contact Name")
    emergency_phone = fields.Char(string="Emergency Contact Phone")
    emergency_relation = fields.Char(
        string="Emergency Contact Relationship",
        help="Spouse/Parent/Sibling etc",
    )

    # Employment Information
    employment_type = fields.Selection(
        selection=[
            ("PERMANENT", "Permanent"),
            ("CONTRACT", "Contract"),
            ("PARTTIME", "Part-time"),
            ("INTERN", "Intern"),
        ],
        string="Employment Type",
        default="PERMANENT",
        required=True,
    )
    join_date = fields.Date(
        string="Join Date",
        required=True,
        default=fields.Date.today,
        help="First day of employment",
    )
    confirm_date = fields.Date(
        string="Confirmation Date",
        help="Confirmation date (if confirmed)",
    )
    resign_date = fields.Date(
        string="Resignation Date",
        index=True,
        help="Last working day (if resigned)",
    )
    probation_months = fields.Integer(
        string="Probation Period (Months)",
        default=3,
    )
    work_location = fields.Char(
        string="Work Location",
        help="Work location/site name",
    )

    # Statutory Information (Malaysian)
    epf_no = fields.Char(string="EPF Member No")
    socso_no = fields.Char(string="SOCSO Member No")
    eis_no = fields.Char(string="EIS Number")
    tax_no = fields.Char(string="Tax Number (LHDN)")
    tax_category = fields.Selection(
        selection=[
            ("1", "Category 1"),
            ("2", "Category 2"),
            ("3", "Category 3"),
        ],
        string="PCB Category",
    )
    tax_resident = fields.Boolean(
        string="Malaysian Tax Resident",
        default=True,
    )
    epf_rate_employee = fields.Float(
        string="Employee EPF Rate (%)",
        default=11.0,
    )
    epf_rate_employer = fields.Float(
        string="Employer EPF Rate (%)",
        help="Age-based calculation",
    )

    # Salary Information
    basic_salary = fields.Monetary(
        string="Basic Salary",
        currency_field="currency_id",
        tracking=True,
        help="Monthly basic salary in local currency",
    )

    # Banking Information
    bank_name = fields.Char(string="Bank Name")
    bank_account_no = fields.Char(string="Bank Account No")
    bank_account_name = fields.Char(string="Account Holder Name")

    # Profile
    photo_url = fields.Char(
        string="Photo URL",
        help="Profile photo URL",
    )
    preferred_lang = fields.Selection(
        selection=[
            ("en", "English"),
            ("ms", "Bahasa Malaysia"),
            ("id", "Bahasa Indonesia"),
        ],
        string="Preferred Language",
        default="en",
    )

    # Status
    status = fields.Selection(
        selection=[
            ("ACTIVE", "Active"),
            ("INACTIVE", "Inactive"),
            ("RESIGNED", "Resigned"),
            ("TERMINATED", "Terminated"),
        ],
        string="Status",
        default="ACTIVE",
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
    department_id = fields.Many2one(
        comodel_name="kf.department",
        string="Department",
        domain="[('company_id', '=', company_id)]",
    )
    job_position_id = fields.Many2one(
        comodel_name="kf.job.position",
        string="Job Position",
        domain="[('company_id', '=', company_id)]",
    )
    manager_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Reporting Manager",
        domain="[('company_id', '=', company_id), ('id', '!=', id)]",
    )
    user_id = fields.One2many(
        comodel_name="kf.user",
        inverse_name="employee_id",
        string="User Account",
    )
    foreign_worker_detail_id = fields.One2many(
        comodel_name="kf.foreign.worker.detail",
        inverse_name="employee_id",
        string="Foreign Worker Details",
    )
    document_ids = fields.One2many(
        comodel_name="kf.document",
        inverse_name="employee_id",
        string="Documents",
    )
    leave_balance_ids = fields.One2many(
        comodel_name="kf.leave.balance",
        inverse_name="employee_id",
        string="Leave Balances",
    )
    leave_request_ids = fields.One2many(
        comodel_name="kf.leave.request",
        inverse_name="employee_id",
        string="Leave Requests",
    )
    payslip_ids = fields.One2many(
        comodel_name="kf.payslip",
        inverse_name="employee_id",
        string="Payslips",
    )
    subordinate_ids = fields.One2many(
        comodel_name="kf.employee",
        inverse_name="manager_id",
        string="Direct Reports",
    )

    # Computed Fields
    age = fields.Integer(
        string="Age",
        compute="_compute_age",
    )
    years_of_service = fields.Float(
        string="Years of Service",
        compute="_compute_years_of_service",
    )
    is_confirmed = fields.Boolean(
        string="Is Confirmed",
        compute="_compute_is_confirmed",
    )
    is_foreign_worker = fields.Boolean(
        string="Is Foreign Worker",
        compute="_compute_is_foreign_worker",
    )

    # SQL Constraints
    _sql_constraints = [
        (
            "company_employee_no_unique",
            "UNIQUE(company_id, employee_no)",
            "Employee ID must be unique within company!",
        ),
        ("ic_no_unique", "UNIQUE(ic_no)", "IC number must be unique!"),
    ]

    @api.depends("date_of_birth")
    def _compute_age(self):
        today = date.today()
        for employee in self:
            if employee.date_of_birth:
                employee.age = relativedelta(today, employee.date_of_birth).years
            else:
                employee.age = 0

    @api.depends("join_date")
    def _compute_years_of_service(self):
        today = date.today()
        for employee in self:
            if employee.join_date:
                delta = relativedelta(today, employee.join_date)
                employee.years_of_service = delta.years + (delta.months / 12.0)
            else:
                employee.years_of_service = 0

    @api.depends("confirm_date", "join_date", "probation_months")
    def _compute_is_confirmed(self):
        today = date.today()
        for employee in self:
            if employee.confirm_date:
                employee.is_confirmed = employee.confirm_date <= today
            elif employee.join_date and employee.probation_months:
                probation_end = employee.join_date + relativedelta(months=employee.probation_months)
                employee.is_confirmed = probation_end <= today
            else:
                employee.is_confirmed = False

    @api.depends("nationality")
    def _compute_is_foreign_worker(self):
        for employee in self:
            employee.is_foreign_worker = employee.nationality and employee.nationality.lower() != "malaysian"

    @api.constrains("manager_id")
    def _check_manager_recursion(self):
        for employee in self:
            manager = employee.manager_id
            seen = {employee.id}
            while manager:
                if manager.id in seen:
                    raise ValidationError(_("Circular manager hierarchy is not allowed."))
                seen.add(manager.id)
                manager = manager.manager_id

    # IC Format patterns per country (per CLAUDE.md)
    IC_FORMAT_PATTERNS = {
        "MY": (r"^\d{6}-\d{2}-\d{4}$", "XXXXXX-XX-XXXX (e.g., 900101-01-1234)"),
        "SG": (r"^[STFGM]\d{7}[A-Z]$", "XNNNNNNNX (e.g., S1234567D)"),
        "ID": (r"^\d{16}$", "16 digits (NIK)"),
        "TH": (r"^\d{13}$", "13 digits"),
        "VN": (r"^\d{9}|\d{12}$", "9 or 12 digits (CCCD)"),
        "PH": (r"^\d{4}-\d{7}-\d{1}$", "NNNN-NNNNNNN-N (PhilSys)"),
        "BN": (r"^\d{2}-\d{6}$", "NN-NNNNNN"),
        # LA and KH have variable formats, validated loosely
        "LA": (r"^.{6,20}$", "6-20 characters"),
        "KH": (r"^.{6,20}$", "6-20 characters"),
    }

    @api.constrains("country_code", "ic_no")
    def _check_ic_format(self):
        """Validate IC number format based on country"""
        for record in self:
            if not record.ic_no or not record.country_code:
                continue

            pattern_info = self.IC_FORMAT_PATTERNS.get(record.country_code)
            if pattern_info:
                pattern, example = pattern_info
                if not re.match(pattern, record.ic_no):
                    raise ValidationError(
                        _(
                            "Invalid %(country)s IC format. Expected: %(example)s",
                            country=record.country_code,
                            example=example,
                        )
                    )

    # Sensitive fields that require audit logging (per CLAUDE.md)
    SENSITIVE_FIELDS = [
        "ic_no",
        "passport_no",
        "bank_account_no",
        "basic_salary",
        "epf_no",
        "socso_no",
        "tax_no",
    ]

    def write(self, vals):
        """Override write to add audit logging for sensitive fields"""
        sensitive_changed = [f for f in vals if f in self.SENSITIVE_FIELDS]
        if sensitive_changed:
            for record in self:
                _logger.info(
                    "Sensitive field(s) updated for employee %s (ID: %s) by user %s: %s",
                    record.full_name,
                    record.id,
                    self.env.uid,
                    ", ".join(sensitive_changed),
                )
        return super().write(vals)

    def get_direct_reports(self):
        """Get all direct reports for this employee."""
        return self.search(
            [
                ("manager_id", "=", self.id),
                ("status", "=", "ACTIVE"),
            ]
        )

    def get_statutory_rate(self, contribution_type, effective_date):
        """
        Get applicable statutory rate for this employee based on effective_date.

        CRITICAL per CLAUDE.md: ALWAYS use payslip_date for rate lookup, NEVER today's date.

        Args:
            contribution_type: Type of contribution (e.g., 'EPF', 'SOCSO', 'NSSF_PENSION')
            effective_date: The payslip date (determines which rate applies)

        Returns:
            recordset of kf.statutory.rate or empty recordset

        Example:
            # Cambodia pension rate auto-selects 4% for Oct 2027+
            rate = employee.get_statutory_rate('NSSF_PENSION', date(2027, 10, 15))
        """
        self.ensure_one()
        StatutoryRate = self.env["kf.statutory.rate"]
        return StatutoryRate.search(
            [
                ("country_code", "=", self.country_code),
                ("contribution_type", "=", contribution_type),
                ("effective_from", "<=", effective_date),
                "|",
                ("effective_to", "=", False),
                ("effective_to", ">=", effective_date),
            ],
            order="effective_from desc",
            limit=1,
        )

    def calculate_statutory_deductions(self, payslip_date):
        """
        Calculate all statutory deductions for given payslip date.

        Args:
            payslip_date: Date of the payslip (CRITICAL: not today's date!)

        Returns:
            Dict with employee and employer contributions
        """
        self.ensure_one()
        if not self.basic_salary:
            return {"employee": Decimal("0"), "employer": Decimal("0"), "details": []}

        # Get all applicable rates for this country
        StatutoryRate = self.env["kf.statutory.rate"]
        rates = StatutoryRate.search(
            [
                ("country_code", "=", self.country_code),
                ("effective_from", "<=", payslip_date),
                "|",
                ("effective_to", "=", False),
                ("effective_to", ">=", payslip_date),
            ]
        )

        employee_total = Decimal("0")
        employer_total = Decimal("0")
        details = []

        for rate in rates:
            applicable_salary = Decimal(str(self.basic_salary))
            if rate.salary_cap and applicable_salary > Decimal(str(rate.salary_cap)):
                applicable_salary = Decimal(str(rate.salary_cap))

            employee_amount = applicable_salary * (Decimal(str(rate.employee_rate)) / 100)
            employer_amount = applicable_salary * (Decimal(str(rate.employer_rate)) / 100)

            employee_total += employee_amount
            employer_total += employer_amount

            details.append(
                {
                    "type": rate.contribution_type,
                    "employee_rate": rate.employee_rate,
                    "employer_rate": rate.employer_rate,
                    "employee_amount": float(employee_amount),
                    "employer_amount": float(employer_amount),
                }
            )

        return {
            "employee": float(employee_total),
            "employer": float(employer_total),
            "details": details,
        }
