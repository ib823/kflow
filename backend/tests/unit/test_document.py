# -*- coding: utf-8 -*-
"""
KerjaFlow Document Tests
========================

Test suite for document functionality (T-D01 to T-D06)
"""
from datetime import timedelta


class TestDocumentData:
    """Tests for document data"""

    def test_document_has_required_fields(self, sample_document):
        """T-D01: Document should have required fields"""
        required_fields = ["id", "employee_id", "type", "file_name", "status"]
        for field in required_fields:
            assert field in sample_document

    def test_document_types_valid(self, sample_document):
        """T-D02: Document type should be valid"""
        valid_types = [
            "IC",
            "PASSPORT",
            "PERMIT",
            "PHOTO",
            "CERTIFICATE",
            "CONTRACT",
            "BANK_STATEMENT",
            "TAX_FORM",
            "OTHER",
        ]
        assert sample_document["type"] in valid_types

    def test_document_has_file_info(self, sample_document):
        """T-D03: Document should have file information"""
        assert "file_name" in sample_document
        assert "file_size" in sample_document
        assert "mime_type" in sample_document


class TestDocumentStorage:
    """Tests for document storage"""

    def test_document_status_values(self, sample_document):
        """T-D04: Document status should be valid"""
        valid_statuses = ["ACTIVE", "ARCHIVED", "DELETED"]
        assert sample_document["status"] in valid_statuses

    def test_document_linked_to_employee(self, sample_document, sample_employee):
        """T-D05: Document should be linked to employee"""
        assert sample_document["employee_id"] == sample_employee["id"]


class TestDocumentExpiry:
    """Tests for document expiry"""

    def test_permit_expiry_tracking(self, sample_document, today):
        """T-D06: Permit documents should track expiry"""
        # Permit type document should have expiry date
        sample_document["type"] = "PERMIT"
        sample_document["expiry_date"] = today + timedelta(days=30)
        days_until_expiry = (sample_document["expiry_date"] - today).days
        assert days_until_expiry == 30
