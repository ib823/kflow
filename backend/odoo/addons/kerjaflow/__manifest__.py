# -*- coding: utf-8 -*-
{
    'name': 'KerjaFlow',
    'version': '1.0.0',
    'category': 'Human Resources',
    'summary': 'Enterprise Workforce Management Platform for Malaysian Industries',
    'description': """
KerjaFlow - Enterprise Workforce Management Platform
=====================================================

A comprehensive mobile-first workforce management solution designed
for Malaysian regulated industries.

Key Features
------------
* **Employee Management**
  - Complete employee profiles with Malaysian statutory fields
  - Foreign worker permit tracking with expiry alerts
  - Document management with OCR support

* **Leave Management**
  - Malaysian public holiday calendar (federal + state)
  - Working days calculation
  - Pro-rata entitlement for new joiners
  - Multi-level approval workflow

* **Payslip Access**
  - PIN-protected sensitive data access
  - PDF generation and download
  - Import from external payroll systems

* **Mobile App Integration**
  - RESTful API for Flutter mobile app
  - Push notifications (FCM + HMS)
  - Offline-first architecture support

* **Security & Compliance**
  - JWT authentication with RS256
  - RBAC with 5 role levels
  - Full audit trail
  - PDPA 2010 compliance

Technical Specifications
------------------------
- 15 database entities
- 32 API endpoints
- 5 RBAC roles (ADMIN, HR_MANAGER, HR_EXEC, SUPERVISOR, EMPLOYEE)
- Dual-layer authentication (JWT + PIN)
    """,
    'author': 'KerjaFlow',
    'website': 'https://kerjaflow.my',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'mail',
    ],
    'data': [
        # Security - Groups must load FIRST, then CSV, then rules
        'security/kerjaflow_groups.xml',
        'security/ir.model.access.csv',
        'security/kerjaflow_security.xml',

        # Data
        'data/kf_leave_type_data.xml',
        'data/kf_public_holiday_data.xml',
    ],
    'demo': [
        # Demo data requires field validation - disabled for initial install
        # 'data/demo/kf_company_demo.xml',
        # 'data/demo/kf_employee_demo.xml',
    ],
    'assets': {},
    'installable': True,
    'application': True,
    'auto_install': False,
    'sequence': 1,
}
