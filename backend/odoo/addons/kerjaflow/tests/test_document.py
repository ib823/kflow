# -*- coding: utf-8 -*-
"""
KerjaFlow Document Tests
========================

Unit tests for kf.document model.
"""

from odoo.tests import tagged
from datetime import date, timedelta
from .common import KerjaFlowTestCase


@tagged('kerjaflow', '-at_install', 'post_install')
class TestDocument(KerjaFlowTestCase):
    """Test cases for kf.document model."""

    def test_document_creation(self):
        """Test basic document creation."""
        document = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'IC',
            'name': 'MyKad',
            'file_url': 'https://example.com/docs/ic.pdf',
            'file_name': 'ic_scan.pdf',
            'file_size': 1024000,
            'mime_type': 'application/pdf',
            'uploaded_by_id': self.user.id,
        })
        self.assertTrue(document.id)
        self.assertEqual(document.doc_type, 'IC')
        self.assertEqual(document.name, 'MyKad')

    def test_document_types(self):
        """Test all valid document types."""
        doc_types = ['IC', 'PASSPORT', 'PERMIT', 'VISA', 'CERT', 'MC', 'CONTRACT', 'OTHER']

        for doc_type in doc_types:
            doc = self.env['kf.document'].create({
                'employee_id': self.employee.id,
                'doc_type': doc_type,
                'name': f'Test {doc_type}',
                'file_url': f'https://example.com/docs/{doc_type.lower()}.pdf',
                'file_name': f'{doc_type.lower()}.pdf',
                'file_size': 512000,
                'mime_type': 'application/pdf',
                'uploaded_by_id': self.user.id,
            })
            self.assertEqual(doc.doc_type, doc_type)

    def test_document_expiry(self):
        """Test document expiry computed field."""
        # Non-expired document
        future_date = date.today() + timedelta(days=365)
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'PASSPORT',
            'name': 'Passport',
            'file_url': 'https://example.com/docs/passport.pdf',
            'file_name': 'passport.pdf',
            'file_size': 2048000,
            'mime_type': 'application/pdf',
            'expiry_date': future_date,
            'uploaded_by_id': self.user.id,
        })
        self.assertFalse(doc.is_expired)

        # Expired document
        past_date = date.today() - timedelta(days=30)
        expired_doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'PERMIT',
            'name': 'Work Permit',
            'file_url': 'https://example.com/docs/permit.pdf',
            'file_name': 'permit.pdf',
            'file_size': 1536000,
            'mime_type': 'application/pdf',
            'expiry_date': past_date,
            'uploaded_by_id': self.user.id,
        })
        self.assertTrue(expired_doc.is_expired)

    def test_document_verification(self):
        """Test document verification."""
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'CERT',
            'name': 'Degree Certificate',
            'file_url': 'https://example.com/docs/cert.pdf',
            'file_name': 'degree.pdf',
            'file_size': 3072000,
            'mime_type': 'application/pdf',
            'uploaded_by_id': self.user.id,
        })
        self.assertFalse(doc.is_verified)

        # Verify document
        doc.action_verify(self.manager_user.id)
        self.assertTrue(doc.is_verified)
        self.assertEqual(doc.verified_by_id.id, self.manager_user.id)
        self.assertTrue(doc.verified_at)

    def test_document_unverify(self):
        """Test document unverification."""
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'OTHER',
            'name': 'Other Document',
            'file_url': 'https://example.com/docs/other.pdf',
            'file_name': 'other.pdf',
            'file_size': 768000,
            'mime_type': 'application/pdf',
            'is_verified': True,
            'verified_by_id': self.manager_user.id,
            'verified_at': date.today(),
            'uploaded_by_id': self.user.id,
        })

        doc.action_unverify()
        self.assertFalse(doc.is_verified)
        self.assertFalse(doc.verified_by_id)
        self.assertFalse(doc.verified_at)

    def test_document_allowed_mime_types(self):
        """Test allowed MIME types method."""
        Document = self.env['kf.document']
        allowed = Document.get_allowed_mime_types()

        self.assertIn('application/pdf', allowed)
        self.assertIn('image/jpeg', allowed)
        self.assertIn('image/png', allowed)

    def test_document_max_file_size(self):
        """Test max file size method."""
        Document = self.env['kf.document']
        max_size = Document.get_max_file_size()

        # Default should be 10MB
        self.assertEqual(max_size, 10 * 1024 * 1024)

    def test_document_with_issue_date(self):
        """Test document with issue date."""
        issue_date = date(2020, 1, 15)
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'IC',
            'name': 'MyKad Renewal',
            'file_url': 'https://example.com/docs/ic_new.pdf',
            'file_name': 'ic_new.pdf',
            'file_size': 1024000,
            'mime_type': 'application/pdf',
            'issue_date': issue_date,
            'expiry_date': date(2030, 1, 15),
            'uploaded_by_id': self.user.id,
        })
        self.assertEqual(doc.issue_date, issue_date)

    def test_document_description(self):
        """Test document with description."""
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'MC',
            'name': 'Medical Certificate',
            'description': 'MC for flu - 2 days rest',
            'file_url': 'https://example.com/docs/mc.pdf',
            'file_name': 'mc_20250115.pdf',
            'file_size': 512000,
            'mime_type': 'application/pdf',
            'uploaded_by_id': self.user.id,
        })
        self.assertEqual(doc.description, 'MC for flu - 2 days rest')

    def test_document_employee_ownership(self):
        """Test document belongs to correct employee."""
        doc = self.env['kf.document'].create({
            'employee_id': self.employee.id,
            'doc_type': 'CONTRACT',
            'name': 'Employment Contract',
            'file_url': 'https://example.com/docs/contract.pdf',
            'file_name': 'contract.pdf',
            'file_size': 4096000,
            'mime_type': 'application/pdf',
            'uploaded_by_id': self.user.id,
        })
        self.assertEqual(doc.employee_id.id, self.employee.id)
        self.assertIn(doc.id, self.employee.document_ids.ids)
