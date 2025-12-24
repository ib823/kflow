# -*- coding: utf-8 -*-
"""
KerjaFlow Profile Controller
=============================

Endpoints:
- GET /profile
- PATCH /profile
- POST /profile/photo
- GET /dashboard
"""

from odoo import http
from odoo.http import request
from .main import KerjaFlowController
import json
import base64


class ProfileController(KerjaFlowController):
    """Profile and Dashboard API endpoints."""

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/profile',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_profile(self):
        """
        GET /profile
        Get current user's profile.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        employee = user.employee_id
        company = employee.company_id
        department = employee.department_id
        job = employee.job_position_id

        return self._json_response({
            'id': employee.id,
            'employee_no': employee.employee_no,
            'full_name': employee.full_name,
            'preferred_name': employee.preferred_name,
            'email': employee.email,
            'work_email': employee.work_email,
            'mobile_phone': employee.mobile_phone,
            'photo_url': employee.photo_url,
            'date_of_birth': str(employee.date_of_birth) if employee.date_of_birth else None,
            'gender': employee.gender,
            'marital_status': employee.marital_status,
            'nationality': employee.nationality,
            'address': {
                'line1': employee.address_line1,
                'line2': employee.address_line2,
                'city': employee.city,
                'state': employee.state,
                'postcode': employee.postcode,
            },
            'emergency_contact': {
                'name': employee.emergency_name,
                'phone': employee.emergency_phone,
                'relation': employee.emergency_relation,
            },
            'employment': {
                'type': employee.employment_type,
                'join_date': str(employee.join_date) if employee.join_date else None,
                'confirm_date': str(employee.confirm_date) if employee.confirm_date else None,
                'years_of_service': round(employee.years_of_service, 2),
                'is_confirmed': employee.is_confirmed,
            },
            'department': {
                'id': department.id if department else None,
                'name': department.name if department else None,
            },
            'job_position': {
                'id': job.id if job else None,
                'name': job.name if job else None,
            },
            'manager': {
                'id': employee.manager_id.id if employee.manager_id else None,
                'name': employee.manager_id.full_name if employee.manager_id else None,
            },
            'company': {
                'id': company.id,
                'name': company.name,
                'logo_url': company.logo_url,
            },
            'role': user.role,
            'preferred_lang': employee.preferred_lang or 'en',
        })

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/profile',
        type='http',
        auth='none',
        methods=['PATCH'],
        csrf=False,
    )
    def update_profile(self):
        """
        PATCH /profile
        Update limited profile fields.

        Allowed fields: mobile_phone, email, address_*, emergency_*, preferred_lang
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        try:
            data = json.loads(request.httprequest.data or '{}')
        except json.JSONDecodeError:
            return self._error_response('VALIDATION_ERROR', 'Invalid JSON body')

        employee = user.employee_id

        # Only allow updating specific fields
        allowed_fields = {
            'mobile_phone', 'email',
            'address_line1', 'address_line2', 'city', 'state', 'postcode',
            'emergency_name', 'emergency_phone', 'emergency_relation',
            'preferred_lang',
        }

        update_data = {}
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]

        if update_data:
            employee.sudo().write(update_data)

        return self._json_response({'success': True})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/profile/photo',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def upload_photo(self):
        """
        POST /profile/photo
        Upload profile photo.

        Content-Type: multipart/form-data
        Body: file (image file, max 5MB)
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        # Get uploaded file
        file = request.httprequest.files.get('file')
        if not file:
            return self._error_response('VALIDATION_ERROR', 'No file uploaded')

        # Validate file type
        allowed_types = ['image/jpeg', 'image/png', 'image/webp']
        if file.content_type not in allowed_types:
            return self._error_response(
                'INVALID_FILE_TYPE',
                'Only JPEG, PNG, and WebP images are allowed',
            )

        # Validate file size (5MB)
        file.seek(0, 2)  # Seek to end
        size = file.tell()
        file.seek(0)  # Reset to start

        if size > 5 * 1024 * 1024:
            return self._error_response(
                'FILE_TOO_LARGE',
                'File size must be less than 5MB',
            )

        # Read file content
        content = file.read()

        # In production, upload to S3 and get URL
        # For now, store as base64 (not recommended for production)
        photo_url = f"data:{file.content_type};base64,{base64.b64encode(content).decode()}"

        employee = user.employee_id
        employee.sudo().photo_url = photo_url

        return self._json_response({
            'success': True,
            'photo_url': photo_url[:100] + '...',  # Truncate for response
        })

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/dashboard',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_dashboard(self):
        """
        GET /dashboard
        Get aggregated dashboard data for home screen.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        employee = user.employee_id
        company = employee.company_id
        from datetime import date

        # Get greeting based on time
        from datetime import datetime
        hour = datetime.now().hour
        if hour < 12:
            greeting = 'Good morning'
        elif hour < 17:
            greeting = 'Good afternoon'
        else:
            greeting = 'Good evening'

        # Get latest payslip
        Payslip = request.env['kf.payslip'].sudo()
        latest_payslip = Payslip.search([
            ('employee_id', '=', employee.id),
            ('status', '=', 'PUBLISHED'),
        ], order='pay_period desc', limit=1)

        payslip_summary = None
        if latest_payslip:
            payslip_summary = {
                'id': latest_payslip.id,
                'pay_period': latest_payslip.pay_period,
                'net_salary': latest_payslip.net_salary,
            }

        # Get leave balances
        LeaveBalance = request.env['kf.leave.balance'].sudo()
        current_year = date.today().year
        balances = LeaveBalance.search([
            ('employee_id', '=', employee.id),
            ('year', '=', current_year),
        ])

        leave_summary = []
        for balance in balances:
            leave_summary.append({
                'leave_type': {
                    'id': balance.leave_type_id.id,
                    'code': balance.leave_type_id.code,
                    'name': balance.leave_type_id.name,
                    'color': balance.leave_type_id.color,
                },
                'balance': balance.balance,
                'pending': balance.pending,
            })

        # Get pending leave requests
        LeaveRequest = request.env['kf.leave.request'].sudo()
        pending_leaves = LeaveRequest.search([
            ('employee_id', '=', employee.id),
            ('status', '=', 'PENDING'),
        ])

        pending_leave_count = len(pending_leaves)

        # Get upcoming leave
        upcoming_leave = LeaveRequest.search([
            ('employee_id', '=', employee.id),
            ('status', '=', 'APPROVED'),
            ('date_from', '>=', date.today()),
        ], order='date_from asc', limit=1)

        upcoming_leave_data = None
        if upcoming_leave:
            upcoming_leave_data = {
                'id': upcoming_leave.id,
                'leave_type': upcoming_leave.leave_type_id.name,
                'date_from': str(upcoming_leave.date_from),
                'date_to': str(upcoming_leave.date_to),
                'total_days': upcoming_leave.total_days,
            }

        # Get pending approvals (for supervisor/HR)
        pending_approvals_count = 0
        if user.role in ['SUPERVISOR', 'HR_EXEC', 'HR_MANAGER', 'ADMIN']:
            if user.role == 'SUPERVISOR':
                pending_approvals_count = LeaveRequest.search_count([
                    ('employee_id.manager_id', '=', employee.id),
                    ('status', '=', 'PENDING'),
                ])
            else:
                pending_approvals_count = LeaveRequest.search_count([
                    ('company_id', '=', company.id),
                    ('status', '=', 'PENDING'),
                ])

        # Get unread notification count
        Notification = request.env['kf.notification'].sudo()
        unread_count = Notification.get_unread_count(user.id)

        return self._json_response({
            'greeting': greeting,
            'user': {
                'full_name': employee.full_name,
                'photo_url': employee.photo_url,
            },
            'payslip': payslip_summary,
            'leave': {
                'balances': leave_summary,
                'pending_count': pending_leave_count,
                'upcoming': upcoming_leave_data,
            },
            'approvals': {
                'pending_count': pending_approvals_count,
            },
            'notifications': {
                'unread_count': unread_count,
            },
        })

    def _get_user_from_token(self):
        """Extract user from Authorization header."""
        import jwt
        from ..config import config
        auth_header = request.httprequest.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        token = auth_header[7:]

        try:
            payload = jwt.decode(
                token, config.get_jwt_secret(),
                algorithms=[config.get_jwt_algorithm()],
                audience=config.get_jwt_audience(),
                issuer=config.get_jwt_issuer(),
            )
            user_id = int(payload.get('sub'))
            return request.env['kf.user'].sudo().browse(user_id)
        except Exception:
            return None
