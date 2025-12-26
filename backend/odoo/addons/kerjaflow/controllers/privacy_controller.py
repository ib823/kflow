# -*- coding: utf-8 -*-
"""
KerjaFlow Privacy Controller
============================

Handles data subject rights under PDPA/PDPO/PDP Law:
- Data access requests
- Data deletion requests
- Data portability requests

Endpoints:
- POST /api/v1/privacy/data-request - Submit data access request
- POST /api/v1/privacy/delete-request - Submit data deletion request
- GET /api/v1/privacy/delete-request/<token> - Check deletion status
- POST /api/v1/privacy/delete-confirm/<token> - Confirm deletion
"""

from odoo import http, fields, _
from odoo.http import request, Response
from odoo.exceptions import AccessDenied, ValidationError
import json
import logging
import secrets
from datetime import datetime, timedelta

_logger = logging.getLogger(__name__)


class PrivacyController(http.Controller):
    """Controller for privacy and data subject rights."""

    # =========================================================================
    # Data Access Request
    # =========================================================================

    @http.route('/api/v1/privacy/data-request', type='json', auth='user', methods=['POST'], csrf=False)
    def request_data_access(self, **kwargs):
        """
        Submit a data access request (DSAR).

        The user can request a copy of their personal data.
        Response time varies by country (see Privacy Policy).

        Returns:
            dict: Request confirmation with reference number
        """
        user = request.env.user
        employee = user.employee_id

        if not employee:
            return {'success': False, 'error': {'code': 'NO_EMPLOYEE', 'message': 'No employee record found'}}

        # Create data access request
        data_request = request.env['kf.privacy.request'].sudo().create({
            'user_id': user.id,
            'employee_id': employee.id,
            'request_type': 'access',
            'country_code': employee.country_code,
            'status': 'pending',
            'requested_at': fields.Datetime.now(),
        })

        # Calculate response deadline based on country
        deadline = self._get_response_deadline(employee.country_code)

        # Notify HR and DPO
        self._notify_privacy_request(data_request, 'access')

        # Log the request
        request.env['kf.audit.log'].sudo().create({
            'user_id': user.id,
            'action': 'privacy_data_request',
            'reference_model': 'kf.privacy.request',
            'reference_id': data_request.id,
            'description': f'Data access request submitted',
            'ip_address': request.httprequest.remote_addr,
        })

        return {
            'success': True,
            'data': {
                'reference': data_request.reference,
                'status': 'pending',
                'response_deadline': deadline.isoformat(),
                'message': _('Your data access request has been received. '
                           'We will respond by %s.') % deadline.strftime('%Y-%m-%d'),
            }
        }

    # =========================================================================
    # Data Deletion Request
    # =========================================================================

    @http.route('/api/v1/privacy/delete-request', type='json', auth='user', methods=['POST'], csrf=False)
    def request_data_deletion(self, reason=None, **kwargs):
        """
        Submit a data deletion request.

        Initiates the "right to be forgotten" process.
        Some data may be retained for legal compliance.

        Args:
            reason: Optional reason for deletion request

        Returns:
            dict: Confirmation with verification token
        """
        user = request.env.user
        employee = user.employee_id

        if not employee:
            return {'success': False, 'error': {'code': 'NO_EMPLOYEE', 'message': 'No employee record found'}}

        # Generate confirmation token
        confirmation_token = secrets.token_urlsafe(32)
        token_expiry = datetime.now() + timedelta(hours=24)

        # Create deletion request
        delete_request = request.env['kf.privacy.request'].sudo().create({
            'user_id': user.id,
            'employee_id': employee.id,
            'request_type': 'deletion',
            'country_code': employee.country_code,
            'status': 'pending_confirmation',
            'reason': reason,
            'confirmation_token': confirmation_token,
            'token_expiry': token_expiry,
            'requested_at': fields.Datetime.now(),
        })

        # Send confirmation email
        self._send_deletion_confirmation_email(user, delete_request, confirmation_token)

        # Notify HR
        self._notify_privacy_request(delete_request, 'deletion')

        # Log the request
        request.env['kf.audit.log'].sudo().create({
            'user_id': user.id,
            'action': 'privacy_deletion_request',
            'reference_model': 'kf.privacy.request',
            'reference_id': delete_request.id,
            'description': f'Data deletion request submitted',
            'ip_address': request.httprequest.remote_addr,
        })

        return {
            'success': True,
            'data': {
                'reference': delete_request.reference,
                'status': 'pending_confirmation',
                'message': _('A confirmation email has been sent to your registered email address. '
                           'Please confirm within 24 hours to proceed with deletion.'),
                'confirmation_url': f'/privacy/delete-confirm/{confirmation_token}',
            }
        }

    @http.route('/api/v1/privacy/delete-request/<string:token>', type='json', auth='public', methods=['GET'], csrf=False)
    def check_deletion_status(self, token, **kwargs):
        """
        Check the status of a deletion request.

        Args:
            token: Confirmation token from the deletion request

        Returns:
            dict: Current status of the deletion request
        """
        delete_request = request.env['kf.privacy.request'].sudo().search([
            ('confirmation_token', '=', token),
            ('request_type', '=', 'deletion'),
        ], limit=1)

        if not delete_request:
            return {'success': False, 'error': {'code': 'NOT_FOUND', 'message': 'Deletion request not found'}}

        # Check if token is expired
        if delete_request.token_expiry and fields.Datetime.now() > delete_request.token_expiry:
            return {
                'success': False,
                'error': {
                    'code': 'TOKEN_EXPIRED',
                    'message': 'Confirmation token has expired. Please submit a new deletion request.'
                }
            }

        return {
            'success': True,
            'data': {
                'reference': delete_request.reference,
                'status': delete_request.status,
                'requested_at': delete_request.requested_at.isoformat() if delete_request.requested_at else None,
                'completed_at': delete_request.completed_at.isoformat() if delete_request.completed_at else None,
                'data_retained': self._get_retained_data_summary(delete_request),
            }
        }

    @http.route('/api/v1/privacy/delete-confirm/<string:token>', type='json', auth='public', methods=['POST'], csrf=False)
    def confirm_data_deletion(self, token, **kwargs):
        """
        Confirm and execute data deletion.

        This action is irreversible. Data required for legal
        compliance will be retained as described in Privacy Policy.

        Args:
            token: Confirmation token

        Returns:
            dict: Deletion confirmation and summary
        """
        delete_request = request.env['kf.privacy.request'].sudo().search([
            ('confirmation_token', '=', token),
            ('request_type', '=', 'deletion'),
            ('status', '=', 'pending_confirmation'),
        ], limit=1)

        if not delete_request:
            return {'success': False, 'error': {'code': 'NOT_FOUND', 'message': 'Deletion request not found or already processed'}}

        # Check if token is expired
        if delete_request.token_expiry and fields.Datetime.now() > delete_request.token_expiry:
            return {
                'success': False,
                'error': {
                    'code': 'TOKEN_EXPIRED',
                    'message': 'Confirmation token has expired. Please submit a new deletion request.'
                }
            }

        # Execute deletion
        try:
            deletion_summary = self._execute_data_deletion(delete_request)

            # Update request status
            delete_request.write({
                'status': 'completed',
                'completed_at': fields.Datetime.now(),
                'deletion_summary': json.dumps(deletion_summary),
            })

            # Log completion
            request.env['kf.audit.log'].sudo().create({
                'user_id': delete_request.user_id.id,
                'action': 'privacy_deletion_completed',
                'reference_model': 'kf.privacy.request',
                'reference_id': delete_request.id,
                'description': f'Data deletion completed: {deletion_summary}',
                'ip_address': request.httprequest.remote_addr,
            })

            return {
                'success': True,
                'data': {
                    'reference': delete_request.reference,
                    'status': 'completed',
                    'completed_at': delete_request.completed_at.isoformat(),
                    'deletion_summary': deletion_summary,
                    'message': _('Your data has been deleted. Some data may be retained for legal compliance as described in our Privacy Policy.'),
                }
            }

        except Exception as e:
            _logger.exception(f'Data deletion failed for request {delete_request.reference}')
            delete_request.write({
                'status': 'failed',
                'error_message': str(e),
            })
            return {
                'success': False,
                'error': {
                    'code': 'DELETION_FAILED',
                    'message': 'Data deletion failed. Our team has been notified and will contact you.',
                }
            }

    # =========================================================================
    # Data Portability
    # =========================================================================

    @http.route('/api/v1/privacy/export-data', type='json', auth='user', methods=['POST'], csrf=False)
    def export_personal_data(self, format='json', **kwargs):
        """
        Export personal data in machine-readable format.

        Implements data portability right under PDPA/PDPO.

        Args:
            format: Export format ('json' or 'csv')

        Returns:
            dict: Download URL for the exported data
        """
        user = request.env.user
        employee = user.employee_id

        if not employee:
            return {'success': False, 'error': {'code': 'NO_EMPLOYEE', 'message': 'No employee record found'}}

        # Collect all personal data
        personal_data = self._collect_personal_data(employee)

        # Create export file
        export_record = request.env['kf.privacy.export'].sudo().create({
            'user_id': user.id,
            'employee_id': employee.id,
            'format': format,
            'data_json': json.dumps(personal_data, default=str, ensure_ascii=False),
            'status': 'ready',
            'expires_at': fields.Datetime.now() + timedelta(hours=24),
        })

        # Generate secure download token
        download_token = secrets.token_urlsafe(32)
        export_record.write({'download_token': download_token})

        # Log the export
        request.env['kf.audit.log'].sudo().create({
            'user_id': user.id,
            'action': 'privacy_data_export',
            'reference_model': 'kf.privacy.export',
            'reference_id': export_record.id,
            'description': f'Personal data exported in {format} format',
            'ip_address': request.httprequest.remote_addr,
        })

        return {
            'success': True,
            'data': {
                'download_url': f'/api/v1/privacy/download/{download_token}',
                'expires_at': export_record.expires_at.isoformat(),
                'format': format,
                'message': _('Your data export is ready. The download link expires in 24 hours.'),
            }
        }

    @http.route('/api/v1/privacy/download/<string:token>', type='http', auth='public', methods=['GET'], csrf=False)
    def download_exported_data(self, token, **kwargs):
        """
        Download previously exported personal data.

        Args:
            token: Download token

        Returns:
            File download response
        """
        export_record = request.env['kf.privacy.export'].sudo().search([
            ('download_token', '=', token),
            ('status', '=', 'ready'),
        ], limit=1)

        if not export_record:
            return Response(
                json.dumps({'error': 'Export not found or expired'}),
                status=404,
                content_type='application/json'
            )

        # Check expiry
        if fields.Datetime.now() > export_record.expires_at:
            return Response(
                json.dumps({'error': 'Download link has expired'}),
                status=410,
                content_type='application/json'
            )

        # Prepare file content
        if export_record.format == 'json':
            content = export_record.data_json
            content_type = 'application/json'
            filename = f'kerjaflow_data_{export_record.employee_id.employee_code}.json'
        else:
            # Convert to CSV
            content = self._json_to_csv(json.loads(export_record.data_json))
            content_type = 'text/csv'
            filename = f'kerjaflow_data_{export_record.employee_id.employee_code}.csv'

        # Mark as downloaded
        export_record.write({'status': 'downloaded'})

        return Response(
            content,
            headers=[
                ('Content-Type', content_type),
                ('Content-Disposition', f'attachment; filename="{filename}"'),
            ]
        )

    # =========================================================================
    # Helper Methods
    # =========================================================================

    def _get_response_deadline(self, country_code):
        """Get statutory response deadline based on country."""
        deadlines = {
            'MY': 21,   # Malaysia: 21 days
            'SG': 30,   # Singapore: reasonable time (we use 30 days)
            'ID': 14,   # Indonesia: 3x24h confirmation + 14 days
            'TH': 30,   # Thailand: 30 days
            'VN': 30,   # Vietnam: 30 days
            'PH': 15,   # Philippines: 15 days
            'BN': 30,   # Brunei: 30 days
            'LA': 30,   # Laos: 30 days (no specific law)
            'KH': 30,   # Cambodia: 30 days (pending LPDP)
        }
        days = deadlines.get(country_code, 30)
        return datetime.now() + timedelta(days=days)

    def _notify_privacy_request(self, privacy_request, request_type):
        """Notify HR and DPO about a privacy request."""
        # Find HR admins for the employee's company
        hr_users = request.env['kf.user'].sudo().search([
            ('role', 'in', ['HR_ADMIN', 'HR_MANAGER']),
            ('employee_id.company_id', '=', privacy_request.employee_id.company_id.id),
        ])

        # Create notifications
        for hr_user in hr_users:
            request.env['kf.notification'].sudo().create({
                'user_id': hr_user.id,
                'type': 'privacy_request',
                'title': f'Privacy {request_type.title()} Request',
                'message': f'Employee {privacy_request.employee_id.full_name} has submitted a data {request_type} request. Reference: {privacy_request.reference}',
                'reference_model': 'kf.privacy.request',
                'reference_id': privacy_request.id,
                'priority': 'high',
            })

    def _send_deletion_confirmation_email(self, user, delete_request, token):
        """Send confirmation email for deletion request."""
        template = request.env.ref('kerjaflow.email_template_deletion_confirmation', raise_if_not_found=False)
        if template:
            template.sudo().send_mail(delete_request.id, force_send=True)
        else:
            _logger.warning('Deletion confirmation email template not found')

    def _get_retained_data_summary(self, delete_request):
        """Get summary of data that will be retained for legal compliance."""
        return {
            'payroll_records': {
                'retained': True,
                'retention_period': '7 years',
                'reason': 'Tax and employment law compliance',
            },
            'statutory_contributions': {
                'retained': True,
                'retention_period': '7 years',
                'reason': 'Government reporting requirements',
            },
            'audit_logs': {
                'retained': True,
                'retention_period': '2 years',
                'reason': 'Security and compliance auditing',
            },
        }

    def _execute_data_deletion(self, delete_request):
        """Execute the actual data deletion."""
        employee = delete_request.employee_id
        deletion_summary = {
            'personal_profile': False,
            'contact_info': False,
            'leave_requests': False,
            'notifications': False,
            'device_tokens': False,
            'login_sessions': False,
        }

        # Delete personal profile data (except legal retention fields)
        if employee:
            employee.sudo().write({
                'personal_email': False,
                'personal_phone': False,
                'home_address': False,
                'emergency_contact': False,
                'emergency_phone': False,
                'profile_photo': False,
            })
            deletion_summary['personal_profile'] = True
            deletion_summary['contact_info'] = True

        # Delete leave requests older than 3 years (non-approved only)
        old_leaves = request.env['kf.leave.request'].sudo().search([
            ('employee_id', '=', employee.id),
            ('status', 'in', ['draft', 'cancelled', 'rejected']),
            ('create_date', '<', fields.Datetime.now() - timedelta(days=365*3)),
        ])
        old_leaves.sudo().unlink()
        deletion_summary['leave_requests'] = True

        # Delete notifications
        request.env['kf.notification'].sudo().search([
            ('user_id', '=', delete_request.user_id.id),
        ]).unlink()
        deletion_summary['notifications'] = True

        # Delete device tokens
        request.env['kf.user.device'].sudo().search([
            ('user_id', '=', delete_request.user_id.id),
        ]).unlink()
        deletion_summary['device_tokens'] = True

        # Invalidate login sessions
        delete_request.user_id.sudo().write({
            'access_token': False,
            'refresh_token': False,
        })
        deletion_summary['login_sessions'] = True

        return deletion_summary

    def _collect_personal_data(self, employee):
        """Collect all personal data for export."""
        data = {
            'export_date': datetime.now().isoformat(),
            'employee': {
                'employee_code': employee.employee_code,
                'full_name': employee.full_name,
                'email': employee.email,
                'phone': employee.phone,
                'date_of_birth': str(employee.date_of_birth) if employee.date_of_birth else None,
                'gender': employee.gender,
                'nationality': employee.nationality_id.name if employee.nationality_id else None,
                'country': employee.country_id.name if employee.country_id else None,
            },
            'employment': {
                'company': employee.company_id.name if employee.company_id else None,
                'department': employee.department_id.name if employee.department_id else None,
                'job_position': employee.job_position_id.name if employee.job_position_id else None,
                'hire_date': str(employee.hire_date) if employee.hire_date else None,
                'employment_status': employee.employment_status,
            },
            'leave_balances': [],
            'leave_requests': [],
            'payslips': [],
        }

        # Add leave balances
        for balance in employee.leave_balance_ids:
            data['leave_balances'].append({
                'leave_type': balance.leave_type_id.name,
                'year': balance.year,
                'entitled_days': float(balance.entitled_days),
                'used_days': float(balance.used_days),
                'available_days': float(balance.available_days),
            })

        # Add leave requests (last 3 years)
        leave_requests = request.env['kf.leave.request'].sudo().search([
            ('employee_id', '=', employee.id),
            ('create_date', '>=', fields.Datetime.now() - timedelta(days=365*3)),
        ], order='create_date desc')

        for leave in leave_requests:
            data['leave_requests'].append({
                'leave_type': leave.leave_type_id.name,
                'start_date': str(leave.start_date),
                'end_date': str(leave.end_date),
                'days': float(leave.days_requested),
                'status': leave.status,
                'reason': leave.reason,
            })

        # Add payslip summary (last 3 years - no detailed salary for security)
        payslips = request.env['kf.payslip'].sudo().search([
            ('employee_id', '=', employee.id),
            ('create_date', '>=', fields.Datetime.now() - timedelta(days=365*3)),
        ], order='period_year desc, period_month desc')

        for payslip in payslips:
            data['payslips'].append({
                'period': f'{payslip.period_year}-{payslip.period_month:02d}',
                'status': payslip.status,
                # Note: Actual salary figures excluded for security
                # Full payslip can be downloaded via the Payslip feature
            })

        return data

    def _json_to_csv(self, data):
        """Convert JSON data to CSV format."""
        import csv
        import io

        output = io.StringIO()
        writer = csv.writer(output)

        # Write employee info
        writer.writerow(['=== Employee Information ==='])
        for key, value in data.get('employee', {}).items():
            writer.writerow([key, value])

        writer.writerow([])
        writer.writerow(['=== Employment Information ==='])
        for key, value in data.get('employment', {}).items():
            writer.writerow([key, value])

        writer.writerow([])
        writer.writerow(['=== Leave Balances ==='])
        writer.writerow(['Leave Type', 'Year', 'Entitled', 'Used', 'Available'])
        for balance in data.get('leave_balances', []):
            writer.writerow([
                balance.get('leave_type'),
                balance.get('year'),
                balance.get('entitled_days'),
                balance.get('used_days'),
                balance.get('available_days'),
            ])

        writer.writerow([])
        writer.writerow(['=== Leave Requests ==='])
        writer.writerow(['Leave Type', 'Start Date', 'End Date', 'Days', 'Status', 'Reason'])
        for leave in data.get('leave_requests', []):
            writer.writerow([
                leave.get('leave_type'),
                leave.get('start_date'),
                leave.get('end_date'),
                leave.get('days'),
                leave.get('status'),
                leave.get('reason'),
            ])

        return output.getvalue()
