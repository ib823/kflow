# -*- coding: utf-8 -*-
"""
KerjaFlow Notification Tests
============================

Unit tests for kf.notification model.
"""

from odoo.tests import tagged
from datetime import datetime
from .common import KerjaFlowTestCase


@tagged('kerjaflow', '-at_install', 'post_install')
class TestNotification(KerjaFlowTestCase):
    """Test cases for kf.notification model."""

    def test_notification_creation(self):
        """Test basic notification creation."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'LEAVE_APPROVED',
            'title': 'Leave Approved',
            'title_ms': 'Cuti Diluluskan',
            'body': 'Your leave request has been approved',
            'body_ms': 'Permohonan cuti anda telah diluluskan',
        })
        self.assertTrue(notification.id)
        self.assertEqual(notification.notification_type, 'LEAVE_APPROVED')
        self.assertFalse(notification.is_read)

    def test_notification_types(self):
        """Test all notification types."""
        types = [
            'LEAVE_APPROVED', 'LEAVE_REJECTED', 'LEAVE_CANCELLED',
            'LEAVE_PENDING', 'PAYSLIP_READY', 'DOCUMENT_EXPIRING',
            'PERMIT_EXPIRING', 'ANNOUNCEMENT', 'SYSTEM'
        ]

        for ntype in types:
            notification = self.env['kf.notification'].create({
                'user_id': self.user.id,
                'notification_type': ntype,
                'title': f'Test {ntype}',
                'body': f'Test notification for {ntype}',
            })
            self.assertEqual(notification.notification_type, ntype)

    def test_notification_mark_read(self):
        """Test marking notification as read."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'PAYSLIP_READY',
            'title': 'Payslip Ready',
            'body': 'Your payslip for January 2025 is ready',
        })
        self.assertFalse(notification.is_read)

        notification.action_mark_read()
        self.assertTrue(notification.is_read)
        self.assertTrue(notification.read_at)

    def test_notification_mark_unread(self):
        """Test marking notification as unread."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'ANNOUNCEMENT',
            'title': 'Company Announcement',
            'body': 'Important announcement for all staff',
            'is_read': True,
            'read_at': datetime.now(),
        })

        notification.action_mark_unread()
        self.assertFalse(notification.is_read)
        self.assertFalse(notification.read_at)

    def test_notification_unread_count(self):
        """Test unread notification count."""
        Notification = self.env['kf.notification']

        # Create multiple notifications
        for i in range(5):
            Notification.create({
                'user_id': self.user.id,
                'notification_type': 'SYSTEM',
                'title': f'Notification {i+1}',
                'body': f'Test notification body {i+1}',
            })

        count = Notification.get_unread_count(self.user.id)
        self.assertEqual(count, 5)

        # Mark some as read
        notifications = Notification.search([('user_id', '=', self.user.id)])
        notifications[:2].action_mark_read()

        count = Notification.get_unread_count(self.user.id)
        self.assertEqual(count, 3)

    def test_notification_mark_all_read(self):
        """Test marking all notifications as read."""
        Notification = self.env['kf.notification']

        # Create multiple unread notifications
        for i in range(3):
            Notification.create({
                'user_id': self.user.id,
                'notification_type': 'SYSTEM',
                'title': f'Notification {i+1}',
                'body': f'Body {i+1}',
            })

        count = Notification.mark_all_read(self.user.id)
        self.assertEqual(count, 3)

        # Verify all are read
        unread_count = Notification.get_unread_count(self.user.id)
        self.assertEqual(unread_count, 0)

    def test_notification_deep_link(self):
        """Test notification with deep link."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'LEAVE_APPROVED',
            'title': 'Leave Approved',
            'body': 'Your leave has been approved',
            'deep_link': 'kerjaflow://leave/requests/123',
        })
        self.assertEqual(notification.deep_link, 'kerjaflow://leave/requests/123')

    def test_notification_bilingual_content(self):
        """Test bilingual notification content."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'DOCUMENT_EXPIRING',
            'title': 'Document Expiring',
            'title_ms': 'Dokumen Akan Tamat',
            'body': 'Your passport will expire in 30 days',
            'body_ms': 'Pasport anda akan tamat dalam 30 hari',
        })
        self.assertEqual(notification.title, 'Document Expiring')
        self.assertEqual(notification.title_ms, 'Dokumen Akan Tamat')
        self.assertEqual(notification.body, 'Your passport will expire in 30 days')
        self.assertEqual(notification.body_ms, 'Pasport anda akan tamat dalam 30 hari')

    def test_notification_user_isolation(self):
        """Test notifications are isolated per user."""
        Notification = self.env['kf.notification']

        # Create notification for user
        Notification.create({
            'user_id': self.user.id,
            'notification_type': 'SYSTEM',
            'title': 'User Notification',
            'body': 'For user only',
        })

        # Create notification for manager
        Notification.create({
            'user_id': self.manager_user.id,
            'notification_type': 'SYSTEM',
            'title': 'Manager Notification',
            'body': 'For manager only',
        })

        # Verify counts are isolated
        user_count = Notification.get_unread_count(self.user.id)
        manager_count = Notification.get_unread_count(self.manager_user.id)

        self.assertEqual(user_count, 1)
        self.assertEqual(manager_count, 1)

    def test_notification_created_at(self):
        """Test notification creation timestamp."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'SYSTEM',
            'title': 'Test',
            'body': 'Test body',
        })
        self.assertTrue(notification.created_at)

    def test_notification_push_sent(self):
        """Test push notification sent tracking."""
        notification = self.env['kf.notification'].create({
            'user_id': self.user.id,
            'notification_type': 'LEAVE_PENDING',
            'title': 'Leave Pending Approval',
            'body': 'New leave request pending your approval',
        })
        self.assertFalse(notification.is_push_sent)

        # Mark push as sent
        notification.mark_push_sent()
        self.assertTrue(notification.is_push_sent)
        self.assertTrue(notification.push_sent_at)
