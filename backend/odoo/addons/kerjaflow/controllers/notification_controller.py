# -*- coding: utf-8 -*-
"""
KerjaFlow Notification Controller
==================================

Endpoints:
- GET /notifications
- GET /notifications/unread-count
- POST /notifications/{id}/read
- POST /notifications/read-all
"""

from odoo import http
from odoo.http import request
from .main import KerjaFlowController


class NotificationController(KerjaFlowController):
    """Notification API endpoints."""

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/notifications',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_notifications(self):
        """GET /notifications - Get notifications with cursor pagination."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        cursor = request.params.get('cursor')
        limit = int(request.params.get('limit', 20))

        Notification = request.env['kf.notification'].sudo()

        domain = [('user_id', '=', user.id)]
        if cursor:
            domain.append(('id', '<', int(cursor)))

        notifications = Notification.search(
            domain,
            order='created_at desc',
            limit=limit + 1,  # Get one extra to check for more
        )

        has_more = len(notifications) > limit
        if has_more:
            notifications = notifications[:-1]

        result = []
        for n in notifications:
            result.append({
                'id': n.id,
                'type': n.notification_type,
                'title': n.title,
                'title_ms': n.title_ms,
                'body': n.body,
                'body_ms': n.body_ms,
                'is_read': n.is_read,
                'deep_link': n.deep_link,
                'created_at': n.created_at.isoformat() if n.created_at else None,
            })

        next_cursor = str(notifications[-1].id) if notifications else None

        return self._json_response({
            'items': result,
            'next_cursor': next_cursor if has_more else None,
            'has_more': has_more,
        })

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/notifications/unread-count',
        type='http',
        auth='none',
        methods=['GET'],
        csrf=False,
    )
    def get_unread_count(self):
        """GET /notifications/unread-count - Get badge count."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        Notification = request.env['kf.notification'].sudo()
        count = Notification.get_unread_count(user.id)

        return self._json_response({'count': count})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/notifications/<int:notification_id>/read',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def mark_read(self, notification_id):
        """POST /notifications/{id}/read - Mark as read."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        Notification = request.env['kf.notification'].sudo()
        notification = Notification.browse(notification_id)

        if not notification.exists():
            return self._error_response('NOT_FOUND', 'Notification not found', status=404)

        if notification.user_id.id != user.id:
            return self._error_response('FORBIDDEN', 'Access denied', status=403)

        notification.action_mark_read()

        return self._json_response({'success': True})

    @http.route(
        f'{KerjaFlowController.API_PREFIX}/notifications/read-all',
        type='http',
        auth='none',
        methods=['POST'],
        csrf=False,
    )
    def mark_all_read(self):
        """POST /notifications/read-all - Mark all as read."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response('TOKEN_INVALID', 'Invalid token', status=401)

        Notification = request.env['kf.notification'].sudo()
        count = Notification.mark_all_read(user.id)

        return self._json_response({'success': True, 'count': count})

    def _get_user_from_token(self):
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
