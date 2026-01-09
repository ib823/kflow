# -*- coding: utf-8 -*-
"""
KerjaFlow Approval Workflow Integration Tests
==============================================

Integration tests for leave approval workflow.
"""

import json
from datetime import date, timedelta

from odoo.tests import HttpCase, tagged


@tagged("kerjaflow", "integration", "-at_install", "post_install")
class TestApprovalWorkflow(HttpCase):
    """Integration tests for approval workflow."""

    @classmethod
    def setUpClass(cls):
        """Set up test data with manager and employee hierarchy."""
        super().setUpClass()

        # Create test company
        cls.company = cls.env["kf.company"].create(
            {
                "name": "Workflow Test Company",
                "registration_no": "TEST-004",
                "address_line1": "123 Workflow St",
                "city": "Kuala Lumpur",
                "state": "WP",
                "postcode": "50000",
                "country": "MY",
            }
        )

        # Create department
        cls.department = cls.env["kf.department"].create(
            {
                "company_id": cls.company.id,
                "name": "Engineering",
                "code": "ENG",
            }
        )

        # Create manager employee
        cls.manager = cls.env["kf.employee"].create(
            {
                "company_id": cls.company.id,
                "employee_no": "MGR001",
                "first_name": "Manager",
                "last_name": "Person",
                "ic_no": "850101-14-1111",
                "date_of_birth": "1985-01-01",
                "gender": "M",
                "nationality": "MY",
                "email": "manager@workflow.com",
                "department_id": cls.department.id,
                "employment_type": "PERMANENT",
                "hire_date": "2020-01-01",
                "status": "ACTIVE",
                "basic_salary": 15000,
            }
        )

        # Create manager user
        cls.manager_user = cls.env["kf.user"].create(
            {
                "employee_id": cls.manager.id,
                "company_id": cls.company.id,
                "email": "manager@workflow.com",
                "role": "SUPERVISOR",
                "status": "ACTIVE",
            }
        )
        cls.manager_user.set_password("ManagerPass123!")

        # Create subordinate employee
        cls.employee = cls.env["kf.employee"].create(
            {
                "company_id": cls.company.id,
                "employee_no": "EMP005",
                "first_name": "Subordinate",
                "last_name": "Employee",
                "ic_no": "900505-14-2222",
                "date_of_birth": "1990-05-05",
                "gender": "F",
                "nationality": "MY",
                "email": "subordinate@workflow.com",
                "department_id": cls.department.id,
                "manager_id": cls.manager.id,  # Reports to manager
                "employment_type": "PERMANENT",
                "hire_date": "2023-01-01",
                "status": "ACTIVE",
                "basic_salary": 5000,
            }
        )

        # Create employee user
        cls.employee_user = cls.env["kf.user"].create(
            {
                "employee_id": cls.employee.id,
                "company_id": cls.company.id,
                "email": "subordinate@workflow.com",
                "role": "EMPLOYEE",
                "status": "ACTIVE",
            }
        )
        cls.employee_user.set_password("EmployeePass123!")

        # Create leave type
        cls.leave_type = cls.env["kf.leave.type"].create(
            {
                "company_id": cls.company.id,
                "code": "AL",
                "name": "Annual Leave",
                "default_entitlement": 14,
                "is_visible": True,
                "is_active": True,
            }
        )

        # Create leave balance
        cls.env["kf.leave.balance"].create(
            {
                "employee_id": cls.employee.id,
                "leave_type_id": cls.leave_type.id,
                "company_id": cls.company.id,
                "year": date.today().year,
                "entitled": 14,
                "taken": 0,
                "pending": 0,
            }
        )

    def _get_employee_token(self):
        """Get auth token for employee."""
        response = self.url_open(
            "/api/v1/auth/login",
            data=json.dumps(
                {
                    "email": "subordinate@workflow.com",
                    "password": "EmployeePass123!",
                }
            ),
            headers={"Content-Type": "application/json"},
        )
        return response.json()["access_token"]

    def _get_manager_token(self):
        """Get auth token for manager."""
        response = self.url_open(
            "/api/v1/auth/login",
            data=json.dumps(
                {
                    "email": "manager@workflow.com",
                    "password": "ManagerPass123!",
                }
            ),
            headers={"Content-Type": "application/json"},
        )
        return response.json()["access_token"]

    def test_complete_approval_workflow(self):
        """Test complete leave request approval workflow."""
        # Step 1: Employee submits leave request
        emp_token = self._get_employee_token()
        date_from = date.today() + timedelta(days=14)
        date_to = date.today() + timedelta(days=15)

        create_response = self.url_open(
            "/api/v1/leave/requests",
            data=json.dumps(
                {
                    "leave_type_id": self.leave_type.id,
                    "date_from": str(date_from),
                    "date_to": str(date_to),
                    "reason": "Workflow test leave",
                }
            ),
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(create_response.status_code, 201)
        request_data = create_response.json()
        request_id = request_data["id"]
        self.assertEqual(request_data["status"], "PENDING")

        # Step 2: Manager sees pending approval
        mgr_token = self._get_manager_token()

        pending_response = self.url_open(
            "/api/v1/approvals/pending",
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(pending_response.status_code, 200)
        pending_data = pending_response.json()
        self.assertIn("items", pending_data)

        # Find our request in pending list
        pending_ids = [item["id"] for item in pending_data["items"]]
        self.assertIn(request_id, pending_ids)

        # Step 3: Manager approves the request
        approve_response = self.url_open(
            f"/api/v1/approvals/{request_id}/approve",
            data=json.dumps({}),
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(approve_response.status_code, 200)

        # Step 4: Verify request is now approved
        detail_response = self.url_open(
            f"/api/v1/leave/requests/{request_id}",
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(detail_response.status_code, 200)
        detail_data = detail_response.json()
        self.assertEqual(detail_data["status"], "APPROVED")
        self.assertIsNotNone(detail_data["approved_at"])

    def test_rejection_workflow(self):
        """Test leave request rejection workflow."""
        emp_token = self._get_employee_token()
        date_from = date.today() + timedelta(days=21)

        # Employee submits request
        create_response = self.url_open(
            "/api/v1/leave/requests",
            data=json.dumps(
                {
                    "leave_type_id": self.leave_type.id,
                    "date_from": str(date_from),
                    "date_to": str(date_from),
                    "reason": "To be rejected",
                }
            ),
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )
        request_id = create_response.json()["id"]

        # Manager rejects
        mgr_token = self._get_manager_token()
        reject_response = self.url_open(
            f"/api/v1/approvals/{request_id}/reject",
            data=json.dumps(
                {
                    "reason": "Busy period - please reschedule",
                }
            ),
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(reject_response.status_code, 200)

        # Verify rejection
        detail_response = self.url_open(
            f"/api/v1/leave/requests/{request_id}",
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )

        detail_data = detail_response.json()
        self.assertEqual(detail_data["status"], "REJECTED")
        self.assertEqual(detail_data["rejection_reason"], "Busy period - please reschedule")

    def test_employee_cannot_approve(self):
        """Test that regular employees cannot access approval endpoints."""
        emp_token = self._get_employee_token()

        response = self.url_open(
            "/api/v1/approvals/pending",
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(response.status_code, 403)

    def test_cannot_approve_already_processed(self):
        """Test cannot approve an already processed request."""
        # Create and approve a request
        emp_token = self._get_employee_token()
        mgr_token = self._get_manager_token()

        date_from = date.today() + timedelta(days=28)
        create_response = self.url_open(
            "/api/v1/leave/requests",
            data=json.dumps(
                {
                    "leave_type_id": self.leave_type.id,
                    "date_from": str(date_from),
                    "date_to": str(date_from),
                }
            ),
            headers={
                "Authorization": f"Bearer {emp_token}",
                "Content-Type": "application/json",
            },
        )
        request_id = create_response.json()["id"]

        # First approval
        self.url_open(
            f"/api/v1/approvals/{request_id}/approve",
            data=json.dumps({}),
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        # Try to approve again
        response = self.url_open(
            f"/api/v1/approvals/{request_id}/approve",
            data=json.dumps({}),
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.json()["error"]["code"], "ALREADY_PROCESSED")

    def test_manager_cannot_approve_other_team(self):
        """Test manager cannot approve requests from other teams."""
        # Create another department and employee
        other_dept = self.env["kf.department"].create(
            {
                "company_id": self.company.id,
                "name": "Sales",
                "code": "SALES",
            }
        )

        other_manager = self.env["kf.employee"].create(
            {
                "company_id": self.company.id,
                "employee_no": "MGR002",
                "first_name": "Other",
                "last_name": "Manager",
                "ic_no": "850202-14-3333",
                "date_of_birth": "1985-02-02",
                "gender": "F",
                "nationality": "MY",
                "email": "other.manager@workflow.com",
                "department_id": other_dept.id,
                "employment_type": "PERMANENT",
                "hire_date": "2020-01-01",
                "status": "ACTIVE",
                "basic_salary": 15000,
            }
        )

        other_employee = self.env["kf.employee"].create(
            {
                "company_id": self.company.id,
                "employee_no": "EMP006",
                "first_name": "Sales",
                "last_name": "Person",
                "ic_no": "900606-14-4444",
                "date_of_birth": "1990-06-06",
                "gender": "M",
                "nationality": "MY",
                "email": "sales.person@workflow.com",
                "department_id": other_dept.id,
                "manager_id": other_manager.id,
                "employment_type": "PERMANENT",
                "hire_date": "2023-01-01",
                "status": "ACTIVE",
                "basic_salary": 5000,
            }
        )

        # Create leave request for sales person
        self.env["kf.leave.balance"].create(
            {
                "employee_id": other_employee.id,
                "leave_type_id": self.leave_type.id,
                "company_id": self.company.id,
                "year": date.today().year,
                "entitled": 14,
            }
        )

        leave_request = self.env["kf.leave.request"].create(
            {
                "employee_id": other_employee.id,
                "leave_type_id": self.leave_type.id,
                "company_id": self.company.id,
                "date_from": date.today() + timedelta(days=35),
                "date_to": date.today() + timedelta(days=35),
                "total_days": 1,
                "status": "PENDING",
            }
        )

        # Engineering manager tries to approve sales request
        mgr_token = self._get_manager_token()
        response = self.url_open(
            f"/api/v1/approvals/{leave_request.id}/approve",
            data=json.dumps({}),
            headers={
                "Authorization": f"Bearer {mgr_token}",
                "Content-Type": "application/json",
            },
        )

        self.assertEqual(response.status_code, 403)
