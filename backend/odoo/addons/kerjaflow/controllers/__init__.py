# -*- coding: utf-8 -*-
"""
KerjaFlow API Controllers
=========================

RESTful API endpoints for mobile app integration.

Endpoint Groups:
- Authentication (6 endpoints): /auth/*
- Profile (4 endpoints): /profile, /dashboard
- Payslips (3 endpoints): /payslips/*
- Leave (8 endpoints): /leave/*
- Approvals (3 endpoints): /approvals/*
- Notifications (4 endpoints): /notifications/*
- Documents (4 endpoints): /documents/*

Total: 32 endpoints
"""

# Odoo controller discovery requires these imports
from . import main  # noqa: F401
from . import auth_controller  # noqa: F401
from . import profile_controller  # noqa: F401
from . import payslip_controller  # noqa: F401
from . import leave_controller  # noqa: F401
from . import approval_controller  # noqa: F401
from . import notification_controller  # noqa: F401
from . import document_controller  # noqa: F401
