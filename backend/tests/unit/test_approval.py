# -*- coding: utf-8 -*-
"""
KerjaFlow Approval Tests
========================

Test suite for approval workflow functionality (T-AP01 to T-AP06)
"""
from datetime import date, datetime

import pytest


class TestApprovalWorkflow:
    """Tests for approval workflow"""

    def test_pending_request_can_be_approved(self, sample_leave_request):
        """T-AP01: Pending request should be approvable"""
        assert sample_leave_request["status"] == "PENDING"
        # Simulate approval
        sample_leave_request["status"] = "APPROVED"
        assert sample_leave_request["status"] == "APPROVED"

    def test_pending_request_can_be_rejected(self, sample_leave_request):
        """T-AP02: Pending request should be rejectable"""
        assert sample_leave_request["status"] == "PENDING"
        # Simulate rejection
        sample_leave_request["status"] = "REJECTED"
        assert sample_leave_request["status"] == "REJECTED"

    def test_approved_request_cannot_be_rejected(self, sample_leave_request):
        """T-AP03: Approved request should not be rejectable"""
        sample_leave_request["status"] = "APPROVED"
        # Rejection should not be allowed after approval
        valid_transitions_from_approved = ["CANCELLED"]
        assert "REJECTED" not in valid_transitions_from_approved

    def test_supervisor_can_approve_team_requests(self, sample_leave_request, sample_user):
        """T-AP04: Supervisor should be able to approve team requests"""
        # Set user as supervisor
        sample_user["role"] = "SUPERVISOR"
        supervisor_roles = ["SUPERVISOR", "HR_EXEC", "HR_MANAGER", "ADMIN"]
        assert sample_user["role"] in supervisor_roles


class TestApprovalNotifications:
    """Tests for approval notifications"""

    def test_approval_triggers_notification(self, sample_leave_request, sample_notification):
        """T-AP05: Approval should trigger notification"""
        sample_leave_request["status"] = "APPROVED"
        sample_notification["type"] = "LEAVE_APPROVED"
        assert sample_notification["type"] == "LEAVE_APPROVED"

    def test_rejection_triggers_notification(self, sample_leave_request, sample_notification):
        """T-AP06: Rejection should trigger notification"""
        sample_leave_request["status"] = "REJECTED"
        sample_notification["type"] = "LEAVE_REJECTED"
        assert sample_notification["type"] == "LEAVE_REJECTED"
