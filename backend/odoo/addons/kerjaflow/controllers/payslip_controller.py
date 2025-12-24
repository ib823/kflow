# -*- coding: utf-8 -*-
"""
KerjaFlow Payslip Controller
=============================

Endpoints:
- GET /payslips
- GET /payslips/{id}
- GET /payslips/{id}/pdf
"""

from odoo import http
from odoo.http import request
from .main import KerjaFlowController
import json


class PayslipController(KerjaFlowController):
    """Payslip API endpoints."""

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/payslips',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_payslips(self):
        """
        GET /payslips
        Get payslip list (published only).
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        year = request.params.get('year')
        offset = int(request.params.get('offset', 0))
        limit = int(request.params.get('limit', 12))

        employee = user.employee_id
        Payslip = request.env['kf.payslip'].sudo()

        domain = [
            ('employee_id', '=', employee.id),
            ('status', '=', 'PUBLISHED'),
        ]

        if year:
            domain.append(('pay_period', 'like', f'{year}-%'))

        total = Payslip.search_count(domain)
        payslips = Payslip.search(
            domain,
            order='pay_period desc',
            offset=offset,
            limit=limit,
        )

        result = []
        for payslip in payslips:
            result.append({
                'id': payslip.id,
                'pay_period': payslip.pay_period,
                'pay_date': str(payslip.pay_date),
                'net_salary': payslip.net_salary,
                'status': payslip.status,
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
        f'{KerjaFlowController.API_PREFIX}/payslips/<int:payslip_id>',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_payslip(self, payslip_id):
        """
        GET /payslips/{id}
        Get payslip detail (requires PIN verification).
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        # Check PIN verification
        pin_error = self._require_pin_verification()
        if pin_error:
            return pin_error

        Payslip = request.env['kf.payslip'].sudo()
        payslip = Payslip.browse(payslip_id)

        if not payslip.exists():
            return self._error_response('PAYSLIP_NOT_FOUND', 'Payslip not found', status=404)

        # Check ownership
        if payslip.employee_id.id != user.employee_id.id:
            return self._error_response('PAYSLIP_NOT_FOUND', 'Payslip not found', status=404)

        # Check if published
        if payslip.status != 'PUBLISHED':
            return self._error_response('PAYSLIP_NOT_PUBLISHED', 'Payslip not yet published', status=403)

        # Log access
        request.env['kf.audit.log'].sudo().log_data_access(
            action='PAYSLIP_VIEW',
            user_id=user.id,
            entity_type='kf.payslip',
            entity_id=payslip_id,
            ip_address=request.httprequest.remote_addr,
        )

        # Format earnings and deductions
        earnings = []
        deductions = []
        for line in payslip.line_ids:
            item = {
                'code': line.code,
                'name': line.name,
                'amount': line.amount,
            }
            if line.line_type == 'EARNING':
                earnings.append(item)
            else:
                deductions.append(item)

        employee = payslip.employee_id
        return self._json_response({
            'id': payslip.id,
            'pay_period': payslip.pay_period,
            'pay_date': str(payslip.pay_date),
            'employee': {
                'id': employee.id,
                'employee_no': employee.employee_no,
                'full_name': employee.full_name,
                'ic_no': self._mask_ic(employee.ic_no),
                'epf_no': employee.epf_no,
                'socso_no': employee.socso_no,
                'bank_name': employee.bank_name,
                'bank_account_no': self._mask_account(employee.bank_account_no),
            },
            'earnings': earnings,
            'deductions': deductions,
            'summary': {
                'basic_salary': payslip.basic_salary,
                'gross_salary': payslip.gross_salary,
                'total_deductions': payslip.total_deductions,
                'net_salary': payslip.net_salary,
            },
            'statutory': {
                'epf_employee': payslip.epf_employee,
                'epf_employer': payslip.epf_employer,
                'socso_employee': payslip.socso_employee,
                'socso_employer': payslip.socso_employer,
                'eis_employee': payslip.eis_employee,
                'eis_employer': payslip.eis_employer,
                'pcb': payslip.pcb,
                'zakat': payslip.zakat,
            },
            'has_pdf': bool(payslip.pdf_url),
        })

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/payslips/<int:payslip_id>/pdf',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def download_pdf(self, payslip_id):
        """
        GET /payslips/{id}/pdf
        Download payslip PDF (requires PIN verification).
        """
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        # Check PIN verification
        pin_error = self._require_pin_verification()
        if pin_error:
            return pin_error

        Payslip = request.env['kf.payslip'].sudo()
        payslip = Payslip.browse(payslip_id)

        if not payslip.exists():
            return self._error_response('PAYSLIP_NOT_FOUND', 'Payslip not found', status=404)

        if payslip.employee_id.id != user.employee_id.id:
            return self._error_response('PAYSLIP_NOT_FOUND', 'Payslip not found', status=404)

        if payslip.status != 'PUBLISHED':
            return self._error_response('PAYSLIP_NOT_PUBLISHED', 'Payslip not yet published', status=403)

        if not payslip.pdf_url:
            return self._error_response('PDF_NOT_AVAILABLE', 'PDF has not been generated', status=404)

        # Log download
        request.env['kf.audit.log'].sudo().log_data_access(
            action='PAYSLIP_DOWNLOAD',
            user_id=user.id,
            entity_type='kf.payslip',
            entity_id=payslip_id,
            ip_address=request.httprequest.remote_addr,
        )

        # Return PDF URL or redirect
        # In production, generate signed URL for S3
        return self._json_response({
            'pdf_url': payslip.pdf_url,
        })

    def _require_pin_verification(self):
        """Check X-Verification-Token header."""
        token = request.httprequest.headers.get('X-Verification-Token')
        if not token:
            return self._error_response(
                'PIN_REQUIRED',
                'Please enter your PIN to continue',
                status=403,
            )
        # TODO: Validate token against Redis/cache
        return None

    def _mask_ic(self, ic_no):
        """Mask IC number: ****1234"""
        if not ic_no or len(ic_no) < 4:
            return ic_no
        return '****' + ic_no[-4:]

    def _mask_account(self, account_no):
        """Mask bank account: ****5678"""
        if not account_no or len(account_no) < 4:
            return account_no
        return '****' + account_no[-4:]

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
