# -*- coding: utf-8 -*-
"""
KerjaFlow Models
================

15 core entities organized into 4 domains:

Organization Domain:
- Company (kf_company)
- Department (kf_department)
- JobPosition (kf_job_position)

Employee Domain:
- Employee (kf_employee)
- User (kf_user)
- ForeignWorkerDetail (kf_foreign_worker_detail)
- Document (kf_document)

Leave Domain:
- LeaveType (kf_leave_type)
- LeaveBalance (kf_leave_balance)
- LeaveRequest (kf_leave_request)
- PublicHoliday (kf_public_holiday)

Payroll Domain:
- Payslip (kf_payslip)
- PayslipLine (kf_payslip_line)

System Domain:
- Notification (kf_notification)
- AuditLog (kf_audit_log)
"""

from . import kf_company
from . import kf_department
from . import kf_job_position
from . import kf_employee
from . import kf_user
from . import kf_foreign_worker_detail
from . import kf_document
from . import kf_leave_type
from . import kf_leave_balance
from . import kf_leave_request
from . import kf_public_holiday
from . import kf_payslip
from . import kf_payslip_line
from . import kf_notification
from . import kf_audit_log
