# -*- coding: utf-8 -*-
"""
KerjaFlow Models
================

20 core entities organized into 5 domains:

Organization Domain:
- Company (kf_company)
- Department (kf_department)
- JobPosition (kf_job_position)
- CountryConfig (kf_country_config)
- StatutoryRate (kf_statutory_rate)

Employee Domain:
- Employee (kf_employee)
- User (kf_user)
- UserDevice (kf_user_device)
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
- Compliance (compliance)
"""

# Odoo model discovery requires these imports
from . import compliance  # noqa: F401
from . import kf_audit_log  # noqa: F401
from . import kf_company  # noqa: F401
from . import kf_department  # noqa: F401
from . import kf_document  # noqa: F401
from . import kf_employee  # noqa: F401
from . import kf_foreign_worker_detail  # noqa: F401
from . import kf_job_position  # noqa: F401
from . import kf_leave_balance  # noqa: F401
from . import kf_leave_request  # noqa: F401
from . import kf_leave_type  # noqa: F401
from . import kf_notification  # noqa: F401
from . import kf_payslip  # noqa: F401
from . import kf_payslip_line  # noqa: F401
from . import kf_public_holiday  # noqa: F401
from . import kf_statutory_rate  # noqa: F401
from . import kf_user  # noqa: F401
from . import kf_user_device  # noqa: F401
from . import (  # noqa: F401 - Must be first (other models depend on it)
    kf_country_config,
)
