# -*- coding: utf-8 -*-
"""
Employee Model - Core Employee Master Data
===========================================

Table: kf_employee
50+ fields including Malaysian statutory requirements
"""

from odoo import models, fields, api
from odoo.exceptions import ValidationError
from datetime import date
from dateutil.relativedelta import relativedelta


class KfEmployee(models.Model):
    _name = 'kf.employee'
    _description = 'KerjaFlow Employee'
    _order = 'full_name'
    _rec_name = 'full_name'

    # Identification
    employee_no = fields.Char(
        string='Employee ID',
        required=True,
        index=True,
        help='Employee ID (unique per company)',
    )
    badge_id = fields.Char(
        string='Badge ID',
        index=True,
        help='Badge/access card ID',
    )

    # Personal Information
    full_name = fields.Char(
        string='Full Name',
        required=True,
        index=True,
        help='Full name as per IC',
    )
    preferred_name = fields.Char(
        string='Preferred Name',
        help='Preferred/call name',
    )
    ic_no = fields.Char(
        string='IC Number',
        index=True,
        help='MyKad IC number',
    )
    passport_no = fields.Char(
        string='Passport Number',
        index=True,
    )
    date_of_birth = fields.Date(
        string='Date of Birth',
    )
    gender = fields.Selection(
        selection=[
            ('M', 'Male'),
            ('F', 'Female'),
            ('O', 'Other'),
        ],
        string='Gender',
    )
    marital_status = fields.Selection(
        selection=[
            ('single', 'Single'),
            ('married', 'Married'),
            ('divorced', 'Divorced'),
            ('widowed', 'Widowed'),
        ],
        string='Marital Status',
    )
    nationality = fields.Char(
        string='Nationality',
        default='Malaysian',
    )
    race = fields.Selection(
        selection=[
            ('malay', 'Malay'),
            ('chinese', 'Chinese'),
            ('indian', 'Indian'),
            ('other', 'Other'),
        ],
        string='Race',
    )
    religion = fields.Char(string='Religion')

    # Contact Information
    email = fields.Char(
        string='Personal Email',
        index=True,
    )
    work_email = fields.Char(
        string='Work Email',
        index=True,
    )
    mobile_phone = fields.Char(
        string='Mobile Phone',
        index=True,
        help='Mobile number (for OTP)',
    )

    # Address
    address_line1 = fields.Char(string='Address Line 1')
    address_line2 = fields.Char(string='Address Line 2')
    city = fields.Char(string='City')
    state = fields.Char(string='State')
    postcode = fields.Char(string='Postcode')

    # Emergency Contact
    emergency_name = fields.Char(string='Emergency Contact Name')
    emergency_phone = fields.Char(string='Emergency Contact Phone')
    emergency_relation = fields.Char(
        string='Emergency Contact Relationship',
        help='Spouse/Parent/Sibling etc',
    )

    # Employment Information
    employment_type = fields.Selection(
        selection=[
            ('PERMANENT', 'Permanent'),
            ('CONTRACT', 'Contract'),
            ('PARTTIME', 'Part-time'),
            ('INTERN', 'Intern'),
        ],
        string='Employment Type',
        default='PERMANENT',
        required=True,
    )
    join_date = fields.Date(
        string='Join Date',
        required=True,
        default=fields.Date.today,
        help='First day of employment',
    )
    confirm_date = fields.Date(
        string='Confirmation Date',
        help='Confirmation date (if confirmed)',
    )
    resign_date = fields.Date(
        string='Resignation Date',
        index=True,
        help='Last working day (if resigned)',
    )
    probation_months = fields.Integer(
        string='Probation Period (Months)',
        default=3,
    )
    work_location = fields.Char(
        string='Work Location',
        help='Work location/site name',
    )

    # Statutory Information (Malaysian)
    epf_no = fields.Char(string='EPF Member No')
    socso_no = fields.Char(string='SOCSO Member No')
    eis_no = fields.Char(string='EIS Number')
    tax_no = fields.Char(string='Tax Number (LHDN)')
    tax_category = fields.Selection(
        selection=[
            ('1', 'Category 1'),
            ('2', 'Category 2'),
            ('3', 'Category 3'),
        ],
        string='PCB Category',
    )
    tax_resident = fields.Boolean(
        string='Malaysian Tax Resident',
        default=True,
    )
    epf_rate_employee = fields.Float(
        string='Employee EPF Rate (%)',
        default=11.0,
    )
    epf_rate_employer = fields.Float(
        string='Employer EPF Rate (%)',
        help='Age-based calculation',
    )

    # Banking Information
    bank_name = fields.Char(string='Bank Name')
    bank_account_no = fields.Char(string='Bank Account No')
    bank_account_name = fields.Char(string='Account Holder Name')

    # Profile
    photo_url = fields.Char(
        string='Photo URL',
        help='Profile photo URL',
    )
    preferred_lang = fields.Selection(
        selection=[
            ('en', 'English'),
            ('ms', 'Bahasa Malaysia'),
            ('id', 'Bahasa Indonesia'),
        ],
        string='Preferred Language',
        default='en',
    )

    # Status
    status = fields.Selection(
        selection=[
            ('ACTIVE', 'Active'),
            ('INACTIVE', 'Inactive'),
            ('RESIGNED', 'Resigned'),
            ('TERMINATED', 'Terminated'),
        ],
        string='Status',
        default='ACTIVE',
        required=True,
    )

    # Relationships
    company_id = fields.Many2one(
        comodel_name='kf.company',
        string='Company',
        required=True,
        ondelete='cascade',
        index=True,
    )
    department_id = fields.Many2one(
        comodel_name='kf.department',
        string='Department',
        domain="[('company_id', '=', company_id)]",
    )
    job_position_id = fields.Many2one(
        comodel_name='kf.job.position',
        string='Job Position',
        domain="[('company_id', '=', company_id)]",
    )
    manager_id = fields.Many2one(
        comodel_name='kf.employee',
        string='Reporting Manager',
        domain="[('company_id', '=', company_id), ('id', '!=', id)]",
    )
    user_id = fields.One2many(
        comodel_name='kf.user',
        inverse_name='employee_id',
        string='User Account',
    )
    foreign_worker_detail_id = fields.One2many(
        comodel_name='kf.foreign.worker.detail',
        inverse_name='employee_id',
        string='Foreign Worker Details',
    )
    document_ids = fields.One2many(
        comodel_name='kf.document',
        inverse_name='employee_id',
        string='Documents',
    )
    leave_balance_ids = fields.One2many(
        comodel_name='kf.leave.balance',
        inverse_name='employee_id',
        string='Leave Balances',
    )
    leave_request_ids = fields.One2many(
        comodel_name='kf.leave.request',
        inverse_name='employee_id',
        string='Leave Requests',
    )
    payslip_ids = fields.One2many(
        comodel_name='kf.payslip',
        inverse_name='employee_id',
        string='Payslips',
    )
    subordinate_ids = fields.One2many(
        comodel_name='kf.employee',
        inverse_name='manager_id',
        string='Direct Reports',
    )

    # Computed Fields
    age = fields.Integer(
        string='Age',
        compute='_compute_age',
    )
    years_of_service = fields.Float(
        string='Years of Service',
        compute='_compute_years_of_service',
    )
    is_confirmed = fields.Boolean(
        string='Is Confirmed',
        compute='_compute_is_confirmed',
    )
    is_foreign_worker = fields.Boolean(
        string='Is Foreign Worker',
        compute='_compute_is_foreign_worker',
    )

    # SQL Constraints
    _sql_constraints = [
        (
            'company_employee_no_unique',
            'UNIQUE(company_id, employee_no)',
            'Employee ID must be unique within company!'
        ),
        (
            'ic_no_unique',
            'UNIQUE(ic_no)',
            'IC number must be unique!'
        ),
    ]

    @api.depends('date_of_birth')
    def _compute_age(self):
        today = date.today()
        for employee in self:
            if employee.date_of_birth:
                employee.age = relativedelta(today, employee.date_of_birth).years
            else:
                employee.age = 0

    @api.depends('join_date')
    def _compute_years_of_service(self):
        today = date.today()
        for employee in self:
            if employee.join_date:
                delta = relativedelta(today, employee.join_date)
                employee.years_of_service = delta.years + (delta.months / 12.0)
            else:
                employee.years_of_service = 0

    @api.depends('confirm_date', 'join_date', 'probation_months')
    def _compute_is_confirmed(self):
        today = date.today()
        for employee in self:
            if employee.confirm_date:
                employee.is_confirmed = employee.confirm_date <= today
            elif employee.join_date and employee.probation_months:
                probation_end = employee.join_date + relativedelta(
                    months=employee.probation_months
                )
                employee.is_confirmed = probation_end <= today
            else:
                employee.is_confirmed = False

    @api.depends('nationality')
    def _compute_is_foreign_worker(self):
        for employee in self:
            employee.is_foreign_worker = (
                employee.nationality and
                employee.nationality.lower() != 'malaysian'
            )

    @api.constrains('manager_id')
    def _check_manager_recursion(self):
        for employee in self:
            manager = employee.manager_id
            seen = {employee.id}
            while manager:
                if manager.id in seen:
                    raise ValidationError('Circular manager hierarchy is not allowed.')
                seen.add(manager.id)
                manager = manager.manager_id

    def get_direct_reports(self):
        """Get all direct reports for this employee."""
        return self.search([
            ('manager_id', '=', self.id),
            ('status', '=', 'ACTIVE'),
        ])
