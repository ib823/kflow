# -*- coding: utf-8 -*-
"""
KerjaFlow Audit Log Tests
=========================

Unit tests for kf.audit.log model.
"""

from odoo.tests import tagged
from datetime import datetime, timedelta
from .common import KerjaFlowTestCase


@tagged('kerjaflow', '-at_install', 'post_install')
class TestAuditLog(KerjaFlowTestCase):
    """Test cases for kf.audit.log model."""

    def test_audit_log_creation(self):
        """Test basic audit log creation."""
        log = self.env['kf.audit.log'].create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
            'ip_address': '192.168.1.100',
            'user_agent': 'KerjaFlow/1.0 (Android 14)',
        })
        self.assertTrue(log.id)
        self.assertEqual(log.action, 'LOGIN')
        self.assertTrue(log.created_at)

    def test_audit_log_actions(self):
        """Test various audit log actions."""
        actions = [
            'LOGIN', 'LOGOUT', 'LOGIN_FAILED',
            'LEAVE_APPLY', 'LEAVE_APPROVE', 'LEAVE_REJECT', 'LEAVE_CANCEL',
            'PROFILE_UPDATE', 'PASSWORD_CHANGE', 'PIN_SETUP',
            'PAYSLIP_VIEW', 'PAYSLIP_DOWNLOAD',
            'DOCUMENT_UPLOAD', 'DOCUMENT_DOWNLOAD',
            'DATA_EXPORT'
        ]

        for action in actions:
            log = self.env['kf.audit.log'].create({
                'action': action,
                'user_id': self.user.id,
                'company_id': self.company.id,
            })
            self.assertEqual(log.action, action)

    def test_audit_log_entity_reference(self):
        """Test audit log with entity reference."""
        log = self.env['kf.audit.log'].create({
            'action': 'LEAVE_APPROVE',
            'user_id': self.manager_user.id,
            'company_id': self.company.id,
            'entity_type': 'kf.leave.request',
            'entity_id': 123,
        })
        self.assertEqual(log.entity_type, 'kf.leave.request')
        self.assertEqual(log.entity_id, 123)

    def test_audit_log_value_tracking(self):
        """Test audit log with old and new values."""
        log = self.env['kf.audit.log'].create({
            'action': 'PROFILE_UPDATE',
            'user_id': self.user.id,
            'company_id': self.company.id,
            'entity_type': 'kf.employee',
            'entity_id': self.employee.id,
            'old_values': {'phone': '+60123456789'},
            'new_values': {'phone': '+60198765432'},
        })
        self.assertEqual(log.old_values, {'phone': '+60123456789'})
        self.assertEqual(log.new_values, {'phone': '+60198765432'})

    def test_audit_log_helper_method(self):
        """Test audit log helper method."""
        AuditLog = self.env['kf.audit.log']

        AuditLog.log(
            action='PASSWORD_CHANGE',
            user_id=self.user.id,
            company_id=self.company.id,
            ip_address='10.0.0.50',
        )

        log = AuditLog.search([
            ('action', '=', 'PASSWORD_CHANGE'),
            ('user_id', '=', self.user.id),
        ], limit=1)

        self.assertTrue(log.id)
        self.assertEqual(log.ip_address, '10.0.0.50')

    def test_audit_log_data_access(self):
        """Test data access audit logging."""
        AuditLog = self.env['kf.audit.log']

        AuditLog.log_data_access(
            action='PAYSLIP_VIEW',
            user_id=self.user.id,
            entity_type='kf.payslip',
            entity_id=456,
            ip_address='172.16.0.100',
        )

        log = AuditLog.search([
            ('action', '=', 'PAYSLIP_VIEW'),
            ('entity_type', '=', 'kf.payslip'),
            ('entity_id', '=', 456),
        ], limit=1)

        self.assertTrue(log.id)
        self.assertEqual(log.user_id.id, self.user.id)

    def test_audit_log_ip_address(self):
        """Test IP address logging."""
        log = self.env['kf.audit.log'].create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
            'ip_address': '203.0.113.50',
        })
        self.assertEqual(log.ip_address, '203.0.113.50')

    def test_audit_log_user_agent(self):
        """Test user agent logging."""
        user_agent = 'Mozilla/5.0 (Linux; Android 14) KerjaFlow/1.2.0'
        log = self.env['kf.audit.log'].create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
            'user_agent': user_agent,
        })
        self.assertEqual(log.user_agent, user_agent)

    def test_audit_log_chronological_order(self):
        """Test audit logs are ordered chronologically."""
        AuditLog = self.env['kf.audit.log']

        # Create logs with slight delays
        AuditLog.create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        AuditLog.create({
            'action': 'PROFILE_UPDATE',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        AuditLog.create({
            'action': 'LOGOUT',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        # Fetch in order
        logs = AuditLog.search([
            ('user_id', '=', self.user.id),
        ], order='created_at asc')

        self.assertEqual(logs[0].action, 'LOGIN')
        self.assertEqual(logs[-1].action, 'LOGOUT')

    def test_audit_log_company_isolation(self):
        """Test audit logs are isolated by company."""
        AuditLog = self.env['kf.audit.log']

        # Create another company
        company2 = self.env['kf.company'].create({
            'name': 'Another Company',
            'registration_no': '9876543-Y',
            'address_line1': '789 Other Street',
            'city': 'Penang',
            'state': 'PNG',
            'postcode': '10000',
            'country': 'MY',
        })

        # Log for first company
        AuditLog.create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        # Log for second company
        AuditLog.create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': company2.id,
        })

        # Verify isolation
        company1_logs = AuditLog.search([
            ('company_id', '=', self.company.id)
        ])
        company2_logs = AuditLog.search([
            ('company_id', '=', company2.id)
        ])

        self.assertEqual(len(company1_logs), 1)
        self.assertEqual(len(company2_logs), 1)

    def test_audit_log_retention(self):
        """Test audit log cleanup for PDPA compliance."""
        AuditLog = self.env['kf.audit.log']

        # Create old log (simulating past date)
        old_log = AuditLog.create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        # Manually set created_at to old date for testing
        old_date = datetime.now() - timedelta(days=800)  # > 2 years
        self.env.cr.execute("""
            UPDATE kf_audit_log SET created_at = %s WHERE id = %s
        """, (old_date, old_log.id))

        # Create recent log
        recent_log = AuditLog.create({
            'action': 'LOGIN',
            'user_id': self.user.id,
            'company_id': self.company.id,
        })

        # Run cleanup (keeps last 2 years per PDPA)
        deleted_count = AuditLog.cleanup_old_logs(retention_days=730)

        self.assertGreaterEqual(deleted_count, 1)
        self.assertTrue(recent_log.exists())
