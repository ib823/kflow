# -*- coding: utf-8 -*-
"""
KerjaFlow Module Hooks
======================

Post-init and uninstall hooks for module lifecycle management.
"""

import logging

_logger = logging.getLogger(__name__)


def post_init_hook(cr, registry):
    """
    Post-initialization hook.
    Creates database indexes for optimal query performance.
    """
    _logger.info("KerjaFlow: Running post-init hook - Creating indexes...")

    # Performance-critical indexes
    indexes = [
        # Employee indexes
        ("kf_employee_company_idx", "kf_employee", "company_id"),
        ("kf_employee_department_idx", "kf_employee", "department_id"),
        ("kf_employee_manager_idx", "kf_employee", "manager_id"),
        ("kf_employee_status_idx", "kf_employee", "status"),
        ("kf_employee_email_idx", "kf_employee", "email"),
        ("kf_employee_ic_no_idx", "kf_employee", "ic_no"),
        # User indexes
        ("kf_user_email_idx", "kf_user", "email"),
        ("kf_user_employee_idx", "kf_user", "employee_id"),
        ("kf_user_status_idx", "kf_user", "status"),
        ("kf_user_role_idx", "kf_user", "role"),
        # Leave request indexes
        ("kf_leave_request_employee_idx", "kf_leave_request", "employee_id"),
        ("kf_leave_request_status_idx", "kf_leave_request", "status"),
        ("kf_leave_request_date_from_idx", "kf_leave_request", "date_from"),
        ("kf_leave_request_date_to_idx", "kf_leave_request", "date_to"),
        ("kf_leave_request_leave_type_idx", "kf_leave_request", "leave_type_id"),
        # Leave balance indexes
        ("kf_leave_balance_employee_idx", "kf_leave_balance", "employee_id"),
        ("kf_leave_balance_year_idx", "kf_leave_balance", "year"),
        # Payslip indexes
        ("kf_payslip_employee_idx", "kf_payslip", "employee_id"),
        ("kf_payslip_pay_period_idx", "kf_payslip", "pay_period"),
        ("kf_payslip_status_idx", "kf_payslip", "status"),
        # Notification indexes
        ("kf_notification_user_idx", "kf_notification", "user_id"),
        ("kf_notification_is_read_idx", "kf_notification", "is_read"),
        ("kf_notification_created_idx", "kf_notification", "created_at"),
        # Document indexes
        ("kf_document_employee_idx", "kf_document", "employee_id"),
        ("kf_document_doc_type_idx", "kf_document", "doc_type"),
        ("kf_document_expiry_idx", "kf_document", "expiry_date"),
        # Foreign worker detail indexes
        ("kf_foreign_worker_employee_idx", "kf_foreign_worker_detail", "employee_id"),
        ("kf_foreign_worker_permit_expiry_idx", "kf_foreign_worker_detail", "work_permit_expiry"),
        # Audit log indexes
        ("kf_audit_log_user_idx", "kf_audit_log", "user_id"),
        ("kf_audit_log_action_idx", "kf_audit_log", "action"),
        ("kf_audit_log_entity_idx", "kf_audit_log", "entity_type, entity_id"),
        ("kf_audit_log_created_idx", "kf_audit_log", "created_at"),
        # Public holiday indexes
        ("kf_public_holiday_date_idx", "kf_public_holiday", "date"),
        ("kf_public_holiday_company_idx", "kf_public_holiday", "company_id"),
        ("kf_public_holiday_state_idx", "kf_public_holiday", "state"),
    ]

    for idx_name, table_name, columns in indexes:
        try:
            # Check if index already exists
            cr.execute(
                """
                SELECT 1 FROM pg_indexes
                WHERE indexname = %s
            """,
                (idx_name,),
            )

            if not cr.fetchone():
                sql = f"CREATE INDEX {idx_name} ON {table_name} ({columns})"
                cr.execute(sql)
                _logger.info(f"KerjaFlow: Created index {idx_name}")
            else:
                _logger.debug(f"KerjaFlow: Index {idx_name} already exists")
        except Exception as e:
            _logger.warning(f"KerjaFlow: Failed to create index {idx_name}: {e}")

    # Composite indexes for common queries
    composite_indexes = [
        # Leave requests by employee and status (for dashboard)
        ("kf_leave_request_emp_status_idx", "kf_leave_request", "employee_id, status"),
        # Leave requests by company and status (for approvals)
        ("kf_leave_request_company_status_idx", "kf_leave_request", "company_id, status"),
        # Leave balance by employee and year
        ("kf_leave_balance_emp_year_idx", "kf_leave_balance", "employee_id, year"),
        # Payslips by employee and status (for listing)
        ("kf_payslip_emp_status_idx", "kf_payslip", "employee_id, status"),
        # Notifications by user and read status
        ("kf_notification_user_read_idx", "kf_notification", "user_id, is_read"),
        # Documents by employee and type
        ("kf_document_emp_type_idx", "kf_document", "employee_id, doc_type"),
        # Employees by company and status (for listings)
        ("kf_employee_company_status_idx", "kf_employee", "company_id, status"),
    ]

    for idx_name, table_name, columns in composite_indexes:
        try:
            cr.execute(
                """
                SELECT 1 FROM pg_indexes
                WHERE indexname = %s
            """,
                (idx_name,),
            )

            if not cr.fetchone():
                sql = f"CREATE INDEX {idx_name} ON {table_name} ({columns})"
                cr.execute(sql)
                _logger.info(f"KerjaFlow: Created composite index {idx_name}")
        except Exception as e:
            _logger.warning(f"KerjaFlow: Failed to create composite index {idx_name}: {e}")

    _logger.info("KerjaFlow: Post-init hook completed")


def uninstall_hook(cr, registry):
    """
    Uninstall hook.
    Cleans up custom database objects.
    """
    _logger.info("KerjaFlow: Running uninstall hook...")

    # Drop custom indexes (Odoo handles table drops)
    try:
        cr.execute(
            """
            SELECT indexname FROM pg_indexes
            WHERE indexname LIKE 'kf_%'
        """
        )
        indexes = cr.fetchall()

        for (idx_name,) in indexes:
            try:
                cr.execute(f"DROP INDEX IF EXISTS {idx_name}")
                _logger.info(f"KerjaFlow: Dropped index {idx_name}")
            except Exception as e:
                _logger.warning(f"KerjaFlow: Failed to drop index {idx_name}: {e}")
    except Exception as e:
        _logger.warning(f"KerjaFlow: Error during index cleanup: {e}")

    _logger.info("KerjaFlow: Uninstall hook completed")
