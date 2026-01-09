# -*- coding: utf-8 -*-
"""
KerjaFlow Document Controller
==============================

Endpoints:
- GET /documents
- POST /documents
- GET /documents/{id}
- GET /documents/{id}/download
"""

import base64

from odoo.http import request

from odoo import http

from .main import KerjaFlowController


class DocumentController(KerjaFlowController):
    """Document Management API endpoints."""

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/documents",
        type="http",
        auth="none",
        methods=["GET"],
        csrf=False,
    )
    def get_documents(self):
        """GET /documents - List user's documents."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response("TOKEN_INVALID", "Invalid token", status=401)

        doc_type = request.params.get("type")
        offset = int(request.params.get("offset", 0))
        limit = int(request.params.get("limit", 20))

        employee = user.employee_id
        Document = request.env["kf.document"].sudo()

        domain = [("employee_id", "=", employee.id)]
        if doc_type:
            domain.append(("doc_type", "=", doc_type))

        total = Document.search_count(domain)
        documents = Document.search(
            domain,
            order="created_at desc",
            offset=offset,
            limit=limit,
        )

        result = []
        for doc in documents:
            result.append(
                {
                    "id": doc.id,
                    "doc_type": doc.doc_type,
                    "name": doc.name,
                    "description": doc.description,
                    "file_name": doc.file_name,
                    "mime_type": doc.mime_type,
                    "issue_date": str(doc.issue_date) if doc.issue_date else None,
                    "expiry_date": str(doc.expiry_date) if doc.expiry_date else None,
                    "is_expired": doc.is_expired,
                    "is_verified": doc.is_verified,
                    "created_at": doc.created_at.isoformat() if doc.created_at else None,
                }
            )

        return self._json_response(
            {
                "items": result,
                "pagination": {
                    "offset": offset,
                    "limit": limit,
                    "total": total,
                    "has_more": offset + limit < total,
                },
            }
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/documents",
        type="http",
        auth="none",
        methods=["POST"],
        csrf=False,
    )
    def upload_document(self):
        """POST /documents - Upload new document."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response("TOKEN_INVALID", "Invalid token", status=401)

        # Get form data
        doc_type = request.params.get("doc_type")
        name = request.params.get("name")
        description = request.params.get("description")
        expiry_date = request.params.get("expiry_date")

        # Get uploaded file
        file = request.httprequest.files.get("file")
        if not file:
            return self._error_response("VALIDATION_ERROR", "No file uploaded")

        # Validate doc_type
        valid_types = ["IC", "PASSPORT", "PERMIT", "VISA", "CERT", "MC", "CONTRACT", "OTHER"]
        if doc_type not in valid_types:
            return self._error_response("VALIDATION_ERROR", "Invalid document type")

        # Validate file type
        Document = request.env["kf.document"].sudo()
        allowed_types = Document.get_allowed_mime_types()
        if file.content_type not in allowed_types:
            return self._error_response(
                "INVALID_FILE_TYPE",
                "Only PDF and image files are allowed",
            )

        # Validate file size
        file.seek(0, 2)
        size = file.tell()
        file.seek(0)

        max_size = Document.get_max_file_size()
        if size > max_size:
            return self._error_response(
                "FILE_TOO_LARGE",
                f"File size must be less than {max_size // 1024 // 1024}MB",
            )

        # Read file content
        content = file.read()

        # In production, upload to S3
        # For now, store as base64 URL
        file_url = f"data:{file.content_type};base64,{base64.b64encode(content).decode()}"

        employee = user.employee_id
        document = Document.create(
            {
                "employee_id": employee.id,
                "doc_type": doc_type,
                "name": name or file.filename,
                "description": description,
                "file_url": file_url,
                "file_name": file.filename,
                "file_size": size,
                "mime_type": file.content_type,
                "expiry_date": expiry_date if expiry_date else None,
                "uploaded_by_id": user.id,
            }
        )

        return self._json_response(
            {
                "id": document.id,
                "name": document.name,
                "doc_type": document.doc_type,
            },
            status=201,
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/documents/<int:document_id>",
        type="http",
        auth="none",
        methods=["GET"],
        csrf=False,
    )
    def get_document(self, document_id):
        """GET /documents/{id} - Get document details."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response("TOKEN_INVALID", "Invalid token", status=401)

        Document = request.env["kf.document"].sudo()
        document = Document.browse(document_id)

        if not document.exists():
            return self._error_response("DOCUMENT_NOT_FOUND", "Document not found", status=404)

        # Check ownership
        if document.employee_id.id != user.employee_id.id:
            if user.role not in ["HR_EXEC", "HR_MANAGER", "ADMIN"]:
                return self._error_response("FORBIDDEN", "Access denied", status=403)

        return self._json_response(
            {
                "id": document.id,
                "doc_type": document.doc_type,
                "name": document.name,
                "description": document.description,
                "file_name": document.file_name,
                "file_size": document.file_size,
                "mime_type": document.mime_type,
                "issue_date": str(document.issue_date) if document.issue_date else None,
                "expiry_date": str(document.expiry_date) if document.expiry_date else None,
                "is_expired": document.is_expired,
                "is_verified": document.is_verified,
                "verified_at": document.verified_at.isoformat() if document.verified_at else None,
                "created_at": document.created_at.isoformat() if document.created_at else None,
            }
        )

    @http.route(
        f"{KerjaFlowController.API_PREFIX}/documents/<int:document_id>/download",
        type="http",
        auth="none",
        methods=["GET"],
        csrf=False,
    )
    def download_document(self, document_id):
        """GET /documents/{id}/download - Download document file."""
        user = self._get_user_from_token()
        if not user:
            return self._error_response("TOKEN_INVALID", "Invalid token", status=401)

        Document = request.env["kf.document"].sudo()
        document = Document.browse(document_id)

        if not document.exists():
            return self._error_response("DOCUMENT_NOT_FOUND", "Document not found", status=404)

        if document.employee_id.id != user.employee_id.id:
            if user.role not in ["HR_EXEC", "HR_MANAGER", "ADMIN"]:
                return self._error_response("FORBIDDEN", "Access denied", status=403)

        # Log access
        request.env["kf.audit.log"].sudo().log_data_access(
            action="DOCUMENT_DOWNLOAD",
            user_id=user.id,
            entity_type="kf.document",
            entity_id=document_id,
            ip_address=request.httprequest.remote_addr,
        )

        # Return file URL
        return self._json_response(
            {
                "download_url": document.file_url,
                "file_name": document.file_name,
                "mime_type": document.mime_type,
            }
        )

    def _get_user_from_token(self):
        import jwt

        from ..config import config

        auth_header = request.httprequest.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return None
        token = auth_header[7:]
        try:
            payload = jwt.decode(
                token,
                config.get_jwt_secret(),
                algorithms=[config.get_jwt_algorithm()],
                audience=config.get_jwt_audience(),
                issuer=config.get_jwt_issuer(),
            )
            user_id = int(payload.get("sub"))
            return request.env["kf.user"].sudo().browse(user_id)
        except Exception:
            return None
