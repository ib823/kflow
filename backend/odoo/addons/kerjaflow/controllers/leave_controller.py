# -*- coding: utf-8 -*-
"""
KerjaFlow Leave Controller
===========================

Endpoints:
- GET /leave/balances
- GET /leave/types
- GET /leave/requests
- POST /leave/requests
- GET /leave/requests/{id}
- POST /leave/requests/{id}/cancel
- GET /leave/calendar
- GET /public-holidays
"""

from odoo import http
from odoo.http import request
from .main import KerjaFlowController
import json
from datetime import date


class LeaveController(KerjaFlowController):
    """Leave Management API endpoints."""

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/balances',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_balances(self):
        """
        GET /leave/balances
        Get all leave type balances for current year.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        year = int(request.params.get('year', date.today().year))
        employee = user.employee_id

        LeaveBalance = request.env['kf.leave.balance'].sudo()
        balances = LeaveBalance.search([
            ('employee_id', '=', employee.id),
            ('year', '=', year),
        ])

        result = []
        for balance in balances:
            lt = balance.leave_type_id
            result.append({
                'leave_type': {
                    'id': lt.id,
                    'code': lt.code,
                    'name': lt.name,
                    'name_ms': lt.name_ms,
                    'color': lt.color,
                    'icon': lt.icon,
                },
                'year': balance.year,
                'entitled': balance.entitled,
                'carried': balance.carried,
                'adjustment': balance.adjustment,
                'taken': balance.taken,
                'pending': balance.pending,
                'balance': balance.balance,
                'available': balance.available,
            })

        return self._json_response({'balances': result})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/types',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_leave_types(self):
        """
        GET /leave/types
        Get available leave types.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        company = user.company_id
        LeaveType = request.env['kf.leave.type'].sudo()

        leave_types = LeaveType.search([
            ('company_id', '=', company.id),
            ('is_active', '=', True),
            ('is_visible', '=', True),
        ], order='sequence, name')

        result = []
        for lt in leave_types:
            result.append({
                'id': lt.id,
                'code': lt.code,
                'name': lt.name,
                'name_ms': lt.name_ms,
                'description': lt.description,
                'color': lt.color,
                'icon': lt.icon,
                'default_entitlement': lt.default_entitlement,
                'allow_half_day': lt.allow_half_day,
                'requires_attachment': lt.requires_attachment,
                'min_days_notice': lt.min_days_notice,
                'max_days_per_request': lt.max_days_per_request,
            })

        return self._json_response({'leave_types': result})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/requests',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_requests(self):
        """
        GET /leave/requests
        Get leave request history with optional status filter.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        status = request.params.get('status')
        offset = int(request.params.get('offset', 0))
        limit = int(request.params.get('limit', 20))

        employee = user.employee_id
        LeaveRequest = request.env['kf.leave.request'].sudo()

        domain = [('employee_id', '=', employee.id)]
        if status:
            domain.append(('status', '=', status))

        total = LeaveRequest.search_count(domain)
        requests = LeaveRequest.search(
            domain,
            order='date_from desc',
            offset=offset,
            limit=limit,
        )

        result = []
        for req in requests:
            result.append(self._format_leave_request(req))

        return self._json_response({
            'items': result,
            'pagination': {
                'offset': offset,
                'limit': limit,
                'total': total,
                'has_more': offset + limit < total,
            }
        })

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/requests',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def create_request(self):
        """
        POST /leave/requests
        Submit new leave request.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        try:
            data = json.loads(request.httprequest.data or '{}')
        except json.JSONDecodeError:
            return self._error_response('VALIDATION_ERROR', 'Invalid JSON body')

        leave_type_id = data.get('leave_type_id')
        date_from = data.get('date_from')
        date_to = data.get('date_to')
        half_day_type = data.get('half_day_type')
        reason = data.get('reason')
        attachment_id = data.get('attachment_id')

        # Validate required fields
        if not leave_type_id or not date_from or not date_to:
            return self._error_response(
                'VALIDATION_ERROR',
                'leave_type_id, date_from, and date_to are required',
            )

        # Parse dates
        try:
            date_from = date.fromisoformat(date_from)
            date_to = date.fromisoformat(date_to)
        except ValueError:
            return self._error_response(
                'VALIDATION_ERROR',
                'Invalid date format. Use YYYY-MM-DD',
            )

        employee = user.employee_id
        LeaveRequest = request.env['kf.leave.request'].sudo()

        # Validate request
        is_valid, error_code, details = LeaveRequest.validate_request(
            employee_id=employee.id,
            leave_type_id=leave_type_id,
            date_from=date_from,
            date_to=date_to,
            half_day_type=half_day_type,
            attachment_id=attachment_id,
        )

        if not is_valid:
            return self._error_response(error_code, details.get('message', ''), details)

        # Create request
        leave_request = LeaveRequest.create({
            'employee_id': employee.id,
            'leave_type_id': leave_type_id,
            'date_from': date_from,
            'date_to': date_to,
            'half_day_type': half_day_type,
            'total_days': details.get('total_days', 1),
            'reason': reason,
            'attachment_id': attachment_id,
            'created_by_id': user.id,
        })

        # Update pending balance
        year = date_from.year
        balance = request.env['kf.leave.balance'].sudo().get_or_create_balance(
            employee.id, leave_type_id, year
        )
        balance.update_pending(leave_request.total_days, add=True)

        # Log
        request.env['kf.audit.log'].sudo().log(
            action='LEAVE_APPLY',
            user_id=user.id,
            company_id=user.company_id.id,
            entity_type='kf.leave.request',
            entity_id=leave_request.id,
            new_values={
                'leave_type_id': leave_type_id,
                'date_from': str(date_from),
                'date_to': str(date_to),
                'total_days': leave_request.total_days,
            },
        )

        # Notify approvers
        # TODO: Implement notification

        return self._json_response(
            self._format_leave_request(leave_request),
            status=201,
        )

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/requests/<int:request_id>',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_request(self, request_id):
        """
        GET /leave/requests/{id}
        Get single leave request details.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        LeaveRequest = request.env['kf.leave.request'].sudo()
        leave_request = LeaveRequest.browse(request_id)

        if not leave_request.exists():
            return self._error_response('NOT_FOUND', 'Leave request not found', status=404)

        # Check access
        if leave_request.employee_id.id != user.employee_id.id:
            if user.role not in ['HR_EXEC', 'HR_MANAGER', 'ADMIN']:
                if user.role == 'SUPERVISOR':
                    if leave_request.employee_id.manager_id.id != user.employee_id.id:
                        return self._error_response('FORBIDDEN', 'Access denied', status=403)
                else:
                    return self._error_response('FORBIDDEN', 'Access denied', status=403)

        return self._json_response(self._format_leave_request(leave_request))

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/leave/requests/<int:request_id>/cancel',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def cancel_request(self, request_id):
        """
        POST /leave/requests/{id}/cancel
        Cancel a leave request.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        LeaveRequest = request.env['kf.leave.request'].sudo()
        leave_request = LeaveRequest.browse(request_id)

        if not leave_request.exists():
            return self._error_response('NOT_FOUND', 'Leave request not found', status=404)

        # Check ownership
        if leave_request.employee_id.id != user.employee_id.id:
            return self._error_response('FORBIDDEN', 'Can only cancel own requests', status=403)

        # Check if can cancel
        if not leave_request.can_cancel:
            return self._error_response('CANNOT_CANCEL', 'This leave cannot be cancelled')

        try:
            leave_request.action_cancel()
        except Exception as e:
            return self._error_response('CANNOT_CANCEL', str(e))

        request.env['kf.audit.log'].sudo().log(
            action='LEAVE_CANCEL',
            user_id=user.id,
            company_id=user.company_id.id,
            entity_type='kf.leave.request',
            entity_id=leave_request.id,
        )

        return self._json_response({'success': True})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/public-holidays',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_public_holidays(self):
        """
        GET /public-holidays
        Get public holidays for a year.
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        year = int(request.params.get('year', date.today().year))
        company = user.company_id
        employee = user.employee_id
        work_state = employee.state or company.state

        Holiday = request.env['kf.public.holiday'].sudo()
        holidays = Holiday.search([
            ('company_id', '=', company.id),
            ('date', '>=', f'{year}-01-01'),
            ('date', '<=', f'{year}-12-31'),
            '|',
            ('state', '=', False),
            ('state', '=', work_state),
        ], order='date')

        result = []
        for h in holidays:
            result.append({
                'id': h.id,
                'name': h.name,
                'name_ms': h.name_ms,
                'date': str(h.date),
                'state': h.state,
                'holiday_type': h.holiday_type,
            })

        return self._json_response({'holidays': result})

    def _format_leave_request(self, req):
        """Format leave request for API response."""
        lt = req.leave_type_id
        return {
            'id': req.id,
            'leave_type': {
                'id': lt.id,
                'code': lt.code,
                'name': lt.name,
                'color': lt.color,
            },
            'date_from': str(req.date_from),
            'date_to': str(req.date_to),
            'half_day_type': req.half_day_type,
            'total_days': req.total_days,
            'reason': req.reason,
            'status': req.status,
            'can_cancel': req.can_cancel,
            'approver': {
                'id': req.approver_id.id if req.approver_id else None,
                'name': req.approver_id.full_name if req.approver_id else None,
            } if req.approver_id else None,
            'approved_at': req.approved_at.isoformat() if req.approved_at else None,
            'rejection_reason': req.rejection_reason,
            'created_at': req.create_date.isoformat() if req.create_date else None,
        }

    def _get_user_from_token(self):
        """Extract user from Authorization header."""
        import jwt
        auth_header = request.httprequest.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None
        token = auth_header[7:]
        try:
            secret = 'your-secret-key'
            payload = jwt.decode(token, secret, algorithms=['HS256'],
                               audience='kerjaflow-mobile', issuer='kerjaflow')
            user_id = int(payload.get('sub'))
            return request.env['kf.user'].sudo().browse(user_id)
        except Exception:
            return None
