# -*- coding: utf-8 -*-
"""
Notification Model - In-App and Push Notifications
===================================================

Table: kf_notification
"""

from odoo import models, fields, api


class KfNotification(models.Model):
    _name = 'kf.notification'
    _description = 'KerjaFlow Notification'
    _order = 'created_at desc'

    # Notification Content
    notification_type = fields.Selection(
        selection=[
            ('LEAVE_SUBMITTED', 'Leave Submitted'),
            ('LEAVE_APPROVED', 'Leave Approved'),
            ('LEAVE_REJECTED', 'Leave Rejected'),
            ('LEAVE_CANCELLED', 'Leave Cancelled'),
            ('PAYSLIP_PUBLISHED', 'Payslip Published'),
            ('PERMIT_EXPIRY', 'Permit Expiring'),
            ('LEAVE_REMINDER', 'Leave Reminder'),
            ('SYSTEM', 'System Message'),
        ],
        string='Type',
        required=True,
        index=True,
    )
    title = fields.Char(
        string='Title',
        required=True,
    )
    title_ms = fields.Char(
        string='Title (Malay)',
    )
    body = fields.Text(
        string='Body',
        required=True,
    )
    body_ms = fields.Text(
        string='Body (Malay)',
    )
    data = fields.Text(
        string='Data (JSON)',
        help='Additional data payload as JSON',
    )
    deep_link = fields.Char(
        string='Deep Link',
        help='Deep link URI for navigation',
    )

    # Status
    is_read = fields.Boolean(
        string='Is Read',
        default=False,
        index=True,
    )
    read_at = fields.Datetime(
        string='Read At',
    )

    # Push Notification Status
    push_sent = fields.Boolean(
        string='Push Sent',
        default=False,
    )
    push_sent_at = fields.Datetime(
        string='Push Sent At',
    )
    push_error = fields.Text(
        string='Push Error',
        help='Error message if push failed',
    )

    # Timestamps
    created_at = fields.Datetime(
        string='Created At',
        default=fields.Datetime.now,
        required=True,
    )

    # Relationships
    user_id = fields.Many2one(
        comodel_name='kf.user',
        string='User',
        required=True,
        ondelete='cascade',
        index=True,
    )
    company_id = fields.Many2one(
        related='user_id.company_id',
        string='Company',
        store=True,
        index=True,
    )

    # Related Records
    leave_request_id = fields.Many2one(
        comodel_name='kf.leave.request',
        string='Leave Request',
    )
    payslip_id = fields.Many2one(
        comodel_name='kf.payslip',
        string='Payslip',
    )

    def action_mark_read(self):
        """Mark notification as read."""
        self.ensure_one()
        if not self.is_read:
            self.is_read = True
            self.read_at = fields.Datetime.now()
        return True

    @api.model
    def mark_all_read(self, user_id):
        """Mark all unread notifications as read for user."""
        notifications = self.search([
            ('user_id', '=', user_id),
            ('is_read', '=', False),
        ])
        notifications.write({
            'is_read': True,
            'read_at': fields.Datetime.now(),
        })
        return len(notifications)

    @api.model
    def get_unread_count(self, user_id):
        """Get count of unread notifications."""
        return self.search_count([
            ('user_id', '=', user_id),
            ('is_read', '=', False),
        ])

    @api.model
    def create_notification(self, user_id, notification_type, title, body,
                            title_ms=None, body_ms=None, data=None,
                            deep_link=None, send_push=True, **kwargs):
        """Create notification and optionally send push."""
        notification = self.create({
            'user_id': user_id,
            'notification_type': notification_type,
            'title': title,
            'title_ms': title_ms,
            'body': body,
            'body_ms': body_ms,
            'data': data,
            'deep_link': deep_link,
            **kwargs,
        })

        if send_push:
            notification._send_push()

        return notification

    def _send_push(self):
        """Send push notification via FCM/HMS."""
        self.ensure_one()
        user = self.user_id

        # Determine which service to use
        if user.fcm_token:
            self._send_fcm(user.fcm_token)
        elif user.hms_token:
            self._send_hms(user.hms_token)

    def _send_fcm(self, token):
        """Send via Firebase Cloud Messaging."""
        # Will be implemented with firebase-admin
        pass

    def _send_hms(self, token):
        """Send via Huawei Mobile Services."""
        # Will be implemented with HMS Push Kit
        pass
