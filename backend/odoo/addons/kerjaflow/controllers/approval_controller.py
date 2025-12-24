# -*- coding: utf-8 -*-
"""
KerjaFlow Approval Controller
==============================

Endpoints:
- GET /approvals/pending
- POST /approvals/{id}/approve
- POST /approvals/{id}/reject
"""

from odoo import http
from odoo.http import request
from .main import KerjaFlowController
import json


class ApprovalController(KerjaFlowController):
    """Approval API endpoints for supervisors and HR."""

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/approvals/pending',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_pending(self):
        """GET /approvals/pending - Get pending leave requests for approval."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        # Check role
        if user.role not in ['SUPERVISOR', 'HR_EXEC', 'HR_MANAGER', 'ADMIN']:
            return self._error_response('FORBIDDEN', 'Not authorized', status=403)

        offset = int(request.params.get('offset', 0))
        limit = int(request.params.get('limit', 20))

        employee = user.employee_id
        company = user.company_id
        LeaveRequest = request.env['kf.leave.request'].sudo()

        # Build domain based on role
        if user.role == 'SUPERVISOR':
            domain = [
                ('employee_id.manager_id', '=', employee.id),
                ('status', '=', 'PENDING'),
            ]
        else:
            domain = [
                ('company_id', '=', company.id),
                ('status', '=', 'PENDING'),
            ]

        total = LeaveRequest.search_count(domain)
        requests = LeaveRequest.search(
            domain,
            order='create_date asc',
            offset=offset,
            limit=limit,
        )

        result = []
        for req in requests:
            emp = req.employee_id
            lt = req.leave_type_id
            result.append({
                'id': req.id,
                'employee': {
                    'id': emp.id,
                    'full_name': emp.full_name,
                    'photo_url': emp.photo_url,
                    'department': emp.department_id.name if emp.department_id else None,
                },
                'leave_type': {
                    'id': lt.id,
                    'code': lt.code,
                    'name': lt.name,
                    'color': lt.color,
                },
                'date_from': str(req.date_from),
                'date_to': str(req.date_to),
                'total_days': req.total_days,
                'reason': req.reason,
                'created_at': req.create_date.isoformat() if req.create_date else None,
            })

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
        f'{KerjaFlowController.API_PREFIX}/approvals/<int:request_id>/approve',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def approve(self, request_id):
        """POST /approvals/{id}/approve - Approve a leave request."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        LeaveRequest = request.env['kf.leave.request'].sudo()
        leave_request = LeaveRequest.browse(request_id)

        if not leave_request.exists():
            return self._error_response('NOT_FOUND', 'Leave request not found', status=404)

        # Check authorization
        if not self._can_approve(user, leave_request):
            return self._error_response('CANNOT_APPROVE', 'Not authorized to approve', status=403)

        if leave_request.status != 'PENDING':
            return self._error_response('ALREADY_PROCESSED', 'Already processed')

        try:
            leave_request.action_approve(user.employee_id.id)
        except Exception as e:
            return self._error_response('ERROR', str(e))

        request.env['kf.audit.log'].sudo().log(
            action='LEAVE_APPROVE',
            user_id=user.id,
            company_id=user.company_id.id,
            entity_type='kf.leave.request',
            entity_id=request_id,
        )

        return self._json_response({'success': True})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/approvals/<int:request_id>/reject',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def reject(self, request_id):
        """POST /approvals/{id}/reject - Reject a leave request."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        try:
            data = json.loads(request.httprequest.data or '{}')
        except json.JSONDecodeError:
            return self._error_response('VALIDATION_ERROR', 'Invalid JSON body')

        reason = data.get('reason')

        LeaveRequest = request.env['kf.leave.request'].sudo()
        leave_request = LeaveRequest.browse(request_id)

        if not leave_request.exists():
            return self._error_response('NOT_FOUND', 'Leave request not found', status=404)

        if not self._can_approve(user, leave_request):
            return self._error_response('CANNOT_APPROVE', 'Not authorized', status=403)

        if leave_request.status != 'PENDING':
            return self._error_response('ALREADY_PROCESSED', 'Already processed')

        try:
            leave_request.action_reject(user.employee_id.id, reason)
        except Exception as e:
            return self._error_response('ERROR', str(e))

        request.env['kf.audit.log'].sudo().log(
            action='LEAVE_REJECT',
            user_id=user.id,
            company_id=user.company_id.id,
            entity_type='kf.leave.request',
            entity_id=request_id,
            new_values={'rejection_reason': reason},
        )

        return self._json_response({'success': True})

    def _can_approve(self, user, leave_request):
        """Check if user can approve this request."""
        if user.role in ['HR_MANAGER', 'HR_EXEC', 'ADMIN']:
            return leave_request.company_id.id == user.company_id.id
        if user.role == 'SUPERVISOR':
            return leave_request.employee_id.manager_id.id == user.employee_id.id
        return False

    def _get_user_from_token(self):
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
                issuer=config.get_jwt_issuer())
            user_id = int(payload.get('sub'))
            return request.env['kf.user'].sudo().browse(user_id)
        except Exception:
            return None
