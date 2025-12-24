# -*- coding: utf-8 -*-
"""
Payslip Model - Monthly Salary Statement
=========================================

Table: kf_payslip
Imported from external payroll systems
"""

from odoo import models, fields, api


class KfPayslip(models.Model):
    _name = 'kf.payslip'
    _description = 'KerjaFlow Payslip'
    _order = 'pay_period desc'
    _rec_name = 'display_name'

    # Period Information
    pay_period = fields.Char(
        string='Pay Period',
        required=True,
        index=True,
        help='Period in YYYY-MM format',
    )
    pay_date = fields.Date(
        string='Pay Date',
        required=True,
        help='Payment date',
    )

    # Salary Summary
    basic_salary = fields.Float(
        string='Basic Salary',
        required=True,
    )
    gross_salary = fields.Float(
        string='Gross Salary',
        required=True,
        help='Total earnings',
    )
    total_deductions = fields.Float(
        string='Total Deductions',
        required=True,
    )
    net_salary = fields.Float(
        string='Net Salary',
        required=True,
        help='Take-home pay',
    )

    # Statutory Contributions
    epf_employee = fields.Float(
        string='EPF (Employee)',
        default=0,
    )
    epf_employer = fields.Float(
        string='EPF (Employer)',
        default=0,
    )
    socso_employee = fields.Float(
        string='SOCSO (Employee)',
        default=0,
    )
    socso_employer = fields.Float(
        string='SOCSO (Employer)',
        default=0,
    )
    eis_employee = fields.Float(
        string='EIS (Employee)',
        default=0,
    )
    eis_employer = fields.Float(
        string='EIS (Employer)',
        default=0,
    )
    pcb = fields.Float(
        string='PCB (Tax)',
        default=0,
        help='Monthly tax deduction',
    )
    zakat = fields.Float(
        string='Zakat',
        default=0,
    )

    # PDF
    pdf_url = fields.Char(
        string='PDF URL',
        help='Generated PDF file URL',
    )
    pdf_generated_at = fields.Datetime(
        string='PDF Generated At',
    )

    # Status
    status = fields.Selection(
        selection=[
            ('DRAFT', 'Draft'),
            ('PUBLISHED', 'Published'),
            ('ARCHIVED', 'Archived'),
        ],
        string='Status',
        default='DRAFT',
        required=True,
        index=True,
    )

    # Relationships
    employee_id = fields.Many2one(
        comodel_name='kf.employee',
        string='Employee',
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
    line_ids = fields.One2many(
        comodel_name='kf.payslip.line',
        inverse_name='payslip_id',
        string='Payslip Lines',
    )

    # Import Tracking
    imported_at = fields.Datetime(
        string='Imported At',
    )
    imported_by_id = fields.Many2one(
        comodel_name='kf.user',
        string='Imported By',
    )

    # Display Name
    display_name = fields.Char(
        compute='_compute_display_name',
    )

    # SQL Constraints
    _sql_constraints = [
        (
            'employee_period_unique',
            'UNIQUE(employee_id, pay_period)',
            'Payslip already exists for this period!'
        ),
    ]

    @api.depends('employee_id', 'pay_period')
    def _compute_display_name(self):
        for rec in self:
            rec.display_name = (
                f"{rec.employee_id.full_name} - {rec.pay_period}"
            )

    def action_publish(self):
        """Publish payslip to employee."""
        self.ensure_one()
        if self.status != 'DRAFT':
            return False

        self.status = 'PUBLISHED'

        # Send push notification
        self._send_publish_notification()

        return True

    def action_archive(self):
        """Archive payslip."""
        self.ensure_one()
        if self.status != 'PUBLISHED':
            return False

        self.status = 'ARCHIVED'
        return True

    def _send_publish_notification(self):
        """Send push notification when payslip is published."""
        # Will be implemented with FCM/HMS integration
        pass

    def generate_pdf(self):
        """Generate PDF for payslip."""
        # Will be implemented with reportlab
        pass
