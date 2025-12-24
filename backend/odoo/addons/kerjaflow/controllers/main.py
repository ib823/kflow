# -*- coding: utf-8 -*-
"""
KerjaFlow API Main Controller
==============================

Base controller with health check and common utilities.
"""

from odoo import http
from odoo.http import request, Response
import json
from datetime import datetime


class KerjaFlowController(http.Controller):
    """Base controller for KerjaFlow API."""

    # API versioning
    API_VERSION = 'v1'
    API_PREFIX = f'/api/{API_VERSION}'

    @http.route('/health', type='http', auth='none', methods=['GET'], csrf=False)
    def health_check(self):
        """
        Basic health check endpoint.
        Returns: { status: "healthy", version: "1.0.0", timestamp: "..." }
        """
        return self._json_response({
            'status': 'healthy',
            'version': '1.0.0',
            'timestamp': datetime.utcnow().isoformat() + 'Z',
        })

    @http.route('/health/ready', type='http', auth='none', methods=['GET'], csrf=False)
    def readiness_check(self):
        """
        Readiness check with dependency verification.
        """
        components = {}
        overall_status = 'healthy'

        # Check database
        try:
            request.env.cr.execute('SELECT 1')
            components['database'] = {'status': 'up'}
        except Exception as e:
            components['database'] = {'status': 'down', 'error': str(e)}
            overall_status = 'unhealthy'

        return self._json_response({
            'status': overall_status,
            'version': '1.0.0',
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'components': components,
        })

    # Helper Methods

    def _json_response(self, data, status=200, headers=None):
        """Return JSON response."""
        response_headers = headers or {}
        response_headers['Content-Type'] = 'application/json'

        return Response(
            json.dumps(data),
            status=status,
            headers=response_headers.items(),
        )

    def _error_response(self, code, message, details=None, status=400):
        """Return error response."""
        error = {
            'code': code,
            'message': message,
        }
        if details:
            error['details'] = details

        return self._json_response(error, status=status)

    def _get_current_user(self):
        """Get current authenticated user."""
        # Will be implemented with JWT middleware
        return None

    def _get_current_employee(self):
        """Get current authenticated user's employee record."""
        user = self._get_current_user()
        return user.employee_id if user else None

    def _require_auth(self):
        """Require authentication. Returns user or raises error."""
        user = self._get_current_user()
        if not user:
            raise Exception('Unauthorized')
        return user

    def _require_pin(self):
        """Require PIN verification for sensitive operations."""
        # Check X-Verification-Token header
        token = request.httprequest.headers.get('X-Verification-Token')
        if not token:
            return self._error_response(
                'PIN_REQUIRED',
                'Please enter your PIN to continue',
                status=403,
            )
        # Validate token
        # Will be implemented
        return None

    def _paginate(self, records, offset=0, limit=20):
        """Paginate records."""
        total = len(records)
        items = records[offset:offset + limit]
        return {
            'items': items,
            'pagination': {
                'offset': offset,
                'limit': limit,
                'total': total,
                'has_more': offset + limit < total,
            }
        }
