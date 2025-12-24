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

from . import main
from . import auth_controller
from . import profile_controller
from . import payslip_controller
from . import leave_controller
from . import approval_controller
from . import notification_controller
from . import document_controller
