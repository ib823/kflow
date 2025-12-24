# -*- coding: utf-8 -*-
"""
Company Model - Organization/Legal Entity
==========================================

Table: kf_company
"""

from odoo import models, fields, api
from odoo.exceptions import ValidationError


class KfCompany(models.Model):
    _name = 'kf.company'
    _description = 'KerjaFlow Company'
    _order = 'name'
    _rec_name = 'name'

    # Basic Information
    code = fields.Char(
        string='Company Code',
        required=True,
        index=True,
        help='Unique company code (e.g., ACME)',
    )
    name = fields.Char(
        string='Company Name',
        required=True,
        index=True,
        help='Legal company name',
    )
    registration_no = fields.Char(
        string='SSM Registration No',
        help='SSM registration number',
    )
    tax_no = fields.Char(
        string='Tax Reference No',
        help='LHDN tax reference number',
    )

    # Statutory Numbers
    epf_no = fields.Char(
        string='EPF Employer No',
        help='EPF employer number',
    )
    socso_no = fields.Char(
        string='SOCSO Employer No',
        help='SOCSO employer number',
    )
    eis_no = fields.Char(
        string='EIS Employer No',
        help='EIS employer number',
    )

    # Address
    address_line1 = fields.Char(
        string='Address Line 1',
        help='Street address line 1',
    )
    address_line2 = fields.Char(
        string='Address Line 2',
        help='Street address line 2',
    )
    city = fields.Char(string='City')
    state = fields.Char(
        string='State',
        help='State (for public holidays)',
    )
    postcode = fields.Char(string='Postcode')
    country = fields.Char(
        string='Country',
        default='Malaysia',
    )

    # Contact
    phone = fields.Char(string='Phone')
    email = fields.Char(string='Email')

    # Branding
    logo_url = fields.Char(
        string='Logo URL',
        help='Company logo URL',
    )

    # Leave Configuration
    leave_year_start = fields.Integer(
        string='Leave Year Start Month',
        default=1,
        help='Month (1-12) when leave year starts',
    )

    # Timezone
    timezone = fields.Char(
        string='Timezone',
        default='Asia/Kuala_Lumpur',
        help='Timezone for scheduling',
    )

    # Status
    is_active = fields.Boolean(
        string='Active',
        default=True,
        help='Soft delete flag',
    )

    # Relationships
    department_ids = fields.One2many(
        comodel_name='kf.department',
        inverse_name='company_id',
        string='Departments',
    )
    job_position_ids = fields.One2many(
        comodel_name='kf.job.position',
        inverse_name='company_id',
        string='Job Positions',
    )
    employee_ids = fields.One2many(
        comodel_name='kf.employee',
        inverse_name='company_id',
        string='Employees',
    )
    leave_type_ids = fields.One2many(
        comodel_name='kf.leave.type',
        inverse_name='company_id',
        string='Leave Types',
    )
    public_holiday_ids = fields.One2many(
        comodel_name='kf.public.holiday',
        inverse_name='company_id',
        string='Public Holidays',
    )

    # Computed Fields
    employee_count = fields.Integer(
        string='Employee Count',
        compute='_compute_employee_count',
    )

    # SQL Constraints
    _sql_constraints = [
        ('code_unique', 'UNIQUE(code)', 'Company code must be unique!'),
    ]

    @api.depends('employee_ids')
    def _compute_employee_count(self):
        for company in self:
            company.employee_count = len(
                company.employee_ids.filtered(lambda e: e.status == 'ACTIVE')
            )

    @api.constrains('leave_year_start')
    def _check_leave_year_start(self):
        for company in self:
            if company.leave_year_start < 1 or company.leave_year_start > 12:
                raise ValidationError('Leave year start must be between 1 and 12.')

    @api.model
    def get_states(self):
        """Return Malaysian states for public holiday filtering."""
        return [
            ('johor', 'Johor'),
            ('kedah', 'Kedah'),
            ('kelantan', 'Kelantan'),
            ('melaka', 'Melaka'),
            ('negeri_sembilan', 'Negeri Sembilan'),
            ('pahang', 'Pahang'),
            ('perak', 'Perak'),
            ('perlis', 'Perlis'),
            ('pulau_pinang', 'Pulau Pinang'),
            ('sabah', 'Sabah'),
            ('sarawak', 'Sarawak'),
            ('selangor', 'Selangor'),
            ('terengganu', 'Terengganu'),
            ('wp_kuala_lumpur', 'WP Kuala Lumpur'),
            ('wp_labuan', 'WP Labuan'),
            ('wp_putrajaya', 'WP Putrajaya'),
        ]
