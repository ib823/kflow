# -*- coding: utf-8 -*-
"""
Document Model - Employee Document Management
==============================================

Table: kf_document
"""

from odoo import api, fields, models


class KfDocument(models.Model):
    _name = "kf.document"
    _description = "KerjaFlow Document"
    _order = "created_at desc"

    # Document Information
    doc_type = fields.Selection(
        selection=[
            ("IC", "IC/MyKad"),
            ("PASSPORT", "Passport"),
            ("PERMIT", "Work Permit"),
            ("VISA", "Visa"),
            ("CERT", "Certificate"),
            ("MC", "Medical Certificate"),
            ("CONTRACT", "Employment Contract"),
            ("OTHER", "Other"),
        ],
        string="Document Type",
        required=True,
        index=True,
    )
    name = fields.Char(
        string="Document Name",
        required=True,
    )
    description = fields.Text(
        string="Description",
    )

    # File Information
    file_url = fields.Char(
        string="File URL",
        required=True,
        help="S3 or storage URL",
    )
    file_name = fields.Char(
        string="File Name",
    )
    file_size = fields.Integer(
        string="File Size (bytes)",
    )
    mime_type = fields.Char(
        string="MIME Type",
    )
    file_hash = fields.Char(
        string="File Hash",
        help="SHA-256 hash for integrity",
    )

    # Validity
    issue_date = fields.Date(
        string="Issue Date",
    )
    expiry_date = fields.Date(
        string="Expiry Date",
        index=True,
    )

    # OCR
    ocr_status = fields.Selection(
        selection=[
            ("PENDING", "Pending"),
            ("PROCESSING", "Processing"),
            ("COMPLETED", "Completed"),
            ("FAILED", "Failed"),
        ],
        string="OCR Status",
        default="PENDING",
    )
    ocr_data = fields.Text(
        string="OCR Data (JSON)",
        help="Extracted data from OCR",
    )

    # Verification
    is_verified = fields.Boolean(
        string="Verified",
        default=False,
    )
    verified_by_id = fields.Many2one(
        comodel_name="kf.user",
        string="Verified By",
    )
    verified_at = fields.Datetime(
        string="Verified At",
    )

    # Timestamps
    created_at = fields.Datetime(
        string="Created At",
        default=fields.Datetime.now,
        required=True,
    )

    # Relationships
    employee_id = fields.Many2one(
        comodel_name="kf.employee",
        string="Employee",
        required=True,
        ondelete="cascade",
        index=True,
    )
    uploaded_by_id = fields.Many2one(
        comodel_name="kf.user",
        string="Uploaded By",
    )
    company_id = fields.Many2one(
        related="employee_id.company_id",
        string="Company",
        store=True,
    )

    # Computed Fields
    is_expired = fields.Boolean(
        string="Is Expired",
        compute="_compute_is_expired",
        store=True,
    )

    @api.depends("expiry_date")
    def _compute_is_expired(self):
        today = fields.Date.today()
        for doc in self:
            if doc.expiry_date:
                doc.is_expired = doc.expiry_date < today
            else:
                doc.is_expired = False

    @api.model
    def get_allowed_mime_types(self):
        """Return allowed MIME types for upload."""
        return [
            "application/pdf",
            "image/jpeg",
            "image/png",
            "image/gif",
            "image/webp",
        ]

    @api.model
    def get_max_file_size(self):
        """Return max file size in bytes (10 MB)."""
        return 10 * 1024 * 1024
