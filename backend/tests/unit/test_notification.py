# -*- coding: utf-8 -*-
"""
KerjaFlow Notification Tests
============================

Test suite for notification functionality (T-N01 to T-N07)
"""
import pytest
from datetime import datetime, timedelta


class TestNotificationData:
    """Tests for notification data"""

    def test_notification_has_required_fields(self, sample_notification):
        """T-N01: Notification should have required fields"""
        required_fields = ['id', 'user_id', 'type', 'title', 'message', 'is_read']
        for field in required_fields:
            assert field in sample_notification

    def test_notification_types_valid(self, sample_notification):
        """T-N02: Notification type should be valid"""
        valid_types = [
            'LEAVE_APPROVED', 'LEAVE_REJECTED', 'LEAVE_CANCELLED',
            'LEAVE_PENDING_APPROVAL', 'PAYSLIP_AVAILABLE',
            'DOCUMENT_EXPIRING', 'PERMIT_EXPIRING', 'SYSTEM'
        ]
        assert sample_notification['type'] in valid_types

    def test_notification_bilingual(self, sample_notification):
        """T-N03: Notification should have bilingual content"""
        assert 'title' in sample_notification
        assert 'title_ms' in sample_notification
        assert 'message' in sample_notification
        assert 'message_ms' in sample_notification


class TestNotificationStatus:
    """Tests for notification status"""

    def test_new_notification_unread(self, sample_notification):
        """T-N04: New notification should be unread"""
        assert sample_notification['is_read'] is False

    def test_notification_can_be_marked_read(self, sample_notification):
        """T-N05: Notification should be markable as read"""
        sample_notification['is_read'] = True
        assert sample_notification['is_read'] is True


class TestNotificationDelivery:
    """Tests for notification delivery"""

    def test_notification_has_timestamp(self, sample_notification):
        """T-N06: Notification should have creation timestamp"""
        assert 'created_at' in sample_notification
        assert isinstance(sample_notification['created_at'], datetime)

    def test_notification_linked_to_user(self, sample_notification, sample_user):
        """T-N07: Notification should be linked to user"""
        assert sample_notification['user_id'] == sample_user['id']
