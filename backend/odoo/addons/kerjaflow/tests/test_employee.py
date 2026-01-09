# -*- coding: utf-8 -*-
"""
KerjaFlow Employee Tests
========================

Unit tests for kf.employee, kf.company, kf.department, kf.job.position models.
"""

from datetime import date, timedelta

from odoo.exceptions import ValidationError
from odoo.tests import tagged

from .common import KerjaFlowTestCase


@tagged("kerjaflow", "-at_install", "post_install")
class TestEmployee(KerjaFlowTestCase):
    """Test cases for kf.employee model."""

    def test_employee_creation(self):
        """Test basic employee creation."""
        self.assertTrue(self.employee.id)
        self.assertEqual(self.employee.first_name, "John")
        self.assertEqual(self.employee.last_name, "Doe")
        self.assertEqual(self.employee.status, "ACTIVE")

    def test_employee_full_name(self):
        """Test computed full_name field."""
        self.assertEqual(self.employee.full_name, "John Doe")

    def test_employee_age(self):
        """Test computed age field."""
        today = date.today()
        expected_age = today.year - 1990 - ((today.month, today.day) < (5, 15))
        self.assertEqual(self.employee.age, expected_age)

    def test_employee_years_of_service(self):
        """Test computed years_of_service field."""
        today = date.today()
        hire_date = date(2023, 1, 15)
        expected_years = today.year - hire_date.year - ((today.month, today.day) < (hire_date.month, hire_date.day))
        self.assertEqual(self.employee.years_of_service, expected_years)

    def test_employee_is_probation(self):
        """Test is_probation computed field."""
        # Employee without probation_end_date
        self.assertFalse(self.employee.is_probation)

        # Create employee on probation
        probation_emp = self.env["kf.employee"].create(
            {
                "company_id": self.company.id,
                "employee_no": "TC003",
                "first_name": "Probation",
                "last_name": "Employee",
                "ic_no": "950101-14-9999",
                "date_of_birth": date(1995, 1, 1),
                "gender": "F",
                "nationality": "MY",
                "email": "probation@testcompany.my",
                "department_id": self.department.id,
                "job_position_id": self.job_position.id,
                "employment_type": "PROBATION",
                "hire_date": date.today() - timedelta(days=30),
                "probation_end_date": date.today() + timedelta(days=60),
                "status": "ACTIVE",
                "basic_salary": 4000,
            }
        )
        self.assertTrue(probation_emp.is_probation)

    def test_employee_unique_employee_no(self):
        """Test unique employee number constraint."""
        with self.assertRaises(Exception):
            self.env["kf.employee"].create(
                {
                    "company_id": self.company.id,
                    "employee_no": "TC002",  # Same as existing
                    "first_name": "Duplicate",
                    "last_name": "Employee",
                    "ic_no": "960101-14-8888",
                    "date_of_birth": date(1996, 1, 1),
                    "gender": "M",
                    "nationality": "MY",
                    "email": "duplicate@testcompany.my",
                    "department_id": self.department.id,
                    "job_position_id": self.job_position.id,
                    "employment_type": "PERMANENT",
                    "hire_date": date.today(),
                    "status": "ACTIVE",
                    "basic_salary": 4000,
                }
            )

    def test_employee_unique_email(self):
        """Test unique email constraint."""
        with self.assertRaises(Exception):
            self.env["kf.employee"].create(
                {
                    "company_id": self.company.id,
                    "employee_no": "TC004",
                    "first_name": "Another",
                    "last_name": "Employee",
                    "ic_no": "970101-14-7777",
                    "date_of_birth": date(1997, 1, 1),
                    "gender": "F",
                    "nationality": "MY",
                    "email": "john.doe@testcompany.my",  # Same as existing
                    "department_id": self.department.id,
                    "job_position_id": self.job_position.id,
                    "employment_type": "PERMANENT",
                    "hire_date": date.today(),
                    "status": "ACTIVE",
                    "basic_salary": 4000,
                }
            )

    def test_employee_manager_hierarchy(self):
        """Test employee manager relationship."""
        self.assertEqual(self.employee.manager_id.id, self.manager_employee.id)
        self.assertIn(self.employee.id, self.manager_employee.subordinate_ids.ids)

    def test_employee_terminate(self):
        """Test employee termination action."""
        self.employee.action_terminate(termination_date=date.today(), termination_reason="Resignation")
        self.assertEqual(self.employee.status, "TERMINATED")
        self.assertEqual(self.employee.termination_date, date.today())
        self.assertEqual(self.employee.termination_reason, "Resignation")

    def test_employee_suspend(self):
        """Test employee suspension action."""
        self.employee.action_suspend()
        self.assertEqual(self.employee.status, "SUSPENDED")

    def test_employee_reactivate(self):
        """Test employee reactivation action."""
        self.employee.action_suspend()
        self.employee.action_reactivate()
        self.assertEqual(self.employee.status, "ACTIVE")


@tagged("kerjaflow", "-at_install", "post_install")
class TestCompany(KerjaFlowTestCase):
    """Test cases for kf.company model."""

    def test_company_creation(self):
        """Test basic company creation."""
        self.assertTrue(self.company.id)
        self.assertEqual(self.company.name, "Test Company Sdn Bhd")
        self.assertTrue(self.company.is_active)

    def test_company_employee_count(self):
        """Test computed employee_count field."""
        self.assertEqual(self.company.employee_count, 2)

    def test_company_unique_registration_no(self):
        """Test unique registration number constraint."""
        with self.assertRaises(Exception):
            self.env["kf.company"].create(
                {
                    "name": "Another Company",
                    "registration_no": "1234567-X",  # Same as existing
                    "address_line1": "456 Test Road",
                    "city": "Petaling Jaya",
                    "state": "SGR",
                    "postcode": "46000",
                    "country": "MY",
                }
            )


@tagged("kerjaflow", "-at_install", "post_install")
class TestDepartment(KerjaFlowTestCase):
    """Test cases for kf.department model."""

    def test_department_creation(self):
        """Test basic department creation."""
        self.assertTrue(self.department.id)
        self.assertEqual(self.department.name, "Engineering")
        self.assertEqual(self.department.code, "ENG")

    def test_department_employee_count(self):
        """Test computed employee_count field."""
        self.assertEqual(self.department.employee_count, 2)

    def test_department_hierarchy(self):
        """Test department parent-child relationship."""
        sub_dept = self.env["kf.department"].create(
            {
                "company_id": self.company.id,
                "name": "Frontend",
                "code": "FE",
                "parent_id": self.department.id,
                "is_active": True,
            }
        )
        self.assertEqual(sub_dept.parent_id.id, self.department.id)
        self.assertIn(sub_dept.id, self.department.child_ids.ids)

    def test_department_unique_code(self):
        """Test unique code constraint per company."""
        with self.assertRaises(Exception):
            self.env["kf.department"].create(
                {
                    "company_id": self.company.id,
                    "name": "Duplicate Engineering",
                    "code": "ENG",  # Same as existing
                    "is_active": True,
                }
            )


@tagged("kerjaflow", "-at_install", "post_install")
class TestJobPosition(KerjaFlowTestCase):
    """Test cases for kf.job.position model."""

    def test_job_position_creation(self):
        """Test basic job position creation."""
        self.assertTrue(self.job_position.id)
        self.assertEqual(self.job_position.name, "Software Engineer")
        self.assertEqual(self.job_position.code, "SE")

    def test_job_position_salary_range(self):
        """Test salary range constraint."""
        with self.assertRaises(ValidationError):
            self.env["kf.job.position"].create(
                {
                    "company_id": self.company.id,
                    "name": "Invalid Position",
                    "code": "INV",
                    "department_id": self.department.id,
                    "min_salary": 10000,
                    "max_salary": 5000,  # Less than min
                    "is_active": True,
                }
            )

    def test_job_position_employee_count(self):
        """Test computed employee_count field."""
        self.assertEqual(self.job_position.employee_count, 2)


@tagged("kerjaflow", "-at_install", "post_install")
class TestForeignWorkerDetail(KerjaFlowTestCase):
    """Test cases for kf.foreign_worker_detail model."""

    def test_foreign_worker_creation(self):
        """Test foreign worker detail creation."""
        # Create foreign employee
        foreign_emp = self.env["kf.employee"].create(
            {
                "company_id": self.company.id,
                "employee_no": "TC005",
                "first_name": "Foreign",
                "last_name": "Worker",
                "passport_no": "A12345678",
                "date_of_birth": date(1990, 6, 15),
                "gender": "M",
                "nationality": "BD",
                "email": "foreign@testcompany.my",
                "department_id": self.department.id,
                "job_position_id": self.job_position.id,
                "employment_type": "CONTRACT",
                "hire_date": date.today(),
                "status": "ACTIVE",
                "basic_salary": 2000,
                "is_foreign_worker": True,
            }
        )

        foreign_detail = self.env["kf.foreign.worker.detail"].create(
            {
                "employee_id": foreign_emp.id,
                "work_permit_no": "WP123456",
                "work_permit_issue_date": date.today() - timedelta(days=365),
                "work_permit_expiry": date.today() + timedelta(days=365),
                "visa_type": "EMPLOYMENT",
                "visa_no": "V123456",
                "visa_expiry": date.today() + timedelta(days=365),
                "passport_expiry": date.today() + timedelta(days=730),
                "fomema_status": "VALID",
                "fomema_date": date.today() - timedelta(days=30),
            }
        )

        self.assertTrue(foreign_detail.id)
        self.assertEqual(foreign_detail.work_permit_no, "WP123456")

    def test_foreign_worker_days_to_expiry(self):
        """Test days_to_expiry computed field."""
        foreign_emp = self.env["kf.employee"].create(
            {
                "company_id": self.company.id,
                "employee_no": "TC006",
                "first_name": "Another",
                "last_name": "Foreign",
                "passport_no": "B98765432",
                "date_of_birth": date(1988, 3, 20),
                "gender": "F",
                "nationality": "PH",
                "email": "another.foreign@testcompany.my",
                "department_id": self.department.id,
                "job_position_id": self.job_position.id,
                "employment_type": "CONTRACT",
                "hire_date": date.today(),
                "status": "ACTIVE",
                "basic_salary": 2500,
                "is_foreign_worker": True,
            }
        )

        expiry_date = date.today() + timedelta(days=30)
        foreign_detail = self.env["kf.foreign.worker.detail"].create(
            {
                "employee_id": foreign_emp.id,
                "work_permit_no": "WP789012",
                "work_permit_issue_date": date.today() - timedelta(days=335),
                "work_permit_expiry": expiry_date,
                "visa_type": "EMPLOYMENT",
                "visa_no": "V789012",
                "visa_expiry": expiry_date,
                "passport_expiry": date.today() + timedelta(days=730),
            }
        )

        self.assertEqual(foreign_detail.days_to_expiry, 30)
