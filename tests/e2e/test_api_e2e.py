"""
KerjaFlow API End-to-End Tests
==============================

Comprehensive E2E tests for the KerjaFlow API.
"""

import pytest
import requests
from datetime import date, timedelta
from test_config import API_BASE_URL, TEST_USERS, DEFAULT_TIMEOUT


class TestAuthenticationE2E:
    """E2E tests for authentication flows."""

    def test_full_login_flow(self):
        """Test complete login flow."""
        user = TEST_USERS['employee']

        # Login
        response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )

        assert response.status_code == 200
        data = response.json()
        assert 'access_token' in data
        assert 'refresh_token' in data
        assert data['user']['role'] == user['role']

        access_token = data['access_token']
        refresh_token = data['refresh_token']

        # Access protected resource
        profile_response = requests.get(
            f'{API_BASE_URL}/profile',
            headers={'Authorization': f'Bearer {access_token}'},
            timeout=DEFAULT_TIMEOUT,
        )
        assert profile_response.status_code == 200

        # Refresh token
        refresh_response = requests.post(
            f'{API_BASE_URL}/auth/refresh',
            json={'refresh_token': refresh_token},
            timeout=DEFAULT_TIMEOUT,
        )
        assert refresh_response.status_code == 200
        new_token = refresh_response.json()['access_token']

        # Logout
        logout_response = requests.post(
            f'{API_BASE_URL}/auth/logout',
            headers={'Authorization': f'Bearer {new_token}'},
            json={},
            timeout=DEFAULT_TIMEOUT,
        )
        assert logout_response.status_code == 200

    def test_pin_setup_and_verify(self):
        """Test PIN setup and verification flow."""
        user = TEST_USERS['employee']

        # Login
        login_response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )
        token = login_response.json()['access_token']

        # Setup PIN
        pin = '123456'
        setup_response = requests.post(
            f'{API_BASE_URL}/auth/pin/setup',
            headers={'Authorization': f'Bearer {token}'},
            json={'pin': pin},
            timeout=DEFAULT_TIMEOUT,
        )
        assert setup_response.status_code == 200

        # Verify PIN
        verify_response = requests.post(
            f'{API_BASE_URL}/auth/pin/verify',
            headers={'Authorization': f'Bearer {token}'},
            json={'pin': pin},
            timeout=DEFAULT_TIMEOUT,
        )
        assert verify_response.status_code == 200
        assert 'verification_token' in verify_response.json()


class TestLeaveManagementE2E:
    """E2E tests for leave management."""

    @pytest.fixture
    def employee_token(self):
        """Get employee auth token."""
        user = TEST_USERS['employee']
        response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )
        return response.json()['access_token']

    @pytest.fixture
    def supervisor_token(self):
        """Get supervisor auth token."""
        user = TEST_USERS['supervisor']
        response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )
        return response.json()['access_token']

    def test_leave_balance_check(self, employee_token):
        """Test checking leave balances."""
        response = requests.get(
            f'{API_BASE_URL}/leave/balances',
            headers={'Authorization': f'Bearer {employee_token}'},
            timeout=DEFAULT_TIMEOUT,
        )

        assert response.status_code == 200
        data = response.json()
        assert 'balances' in data
        assert len(data['balances']) > 0

    def test_complete_leave_request_cycle(self, employee_token, supervisor_token):
        """Test complete leave request cycle: apply, approve, verify."""
        # Step 1: Apply for leave
        date_from = (date.today() + timedelta(days=30)).isoformat()
        date_to = (date.today() + timedelta(days=31)).isoformat()

        apply_response = requests.post(
            f'{API_BASE_URL}/leave/requests',
            headers={'Authorization': f'Bearer {employee_token}'},
            json={
                'leave_type_id': 1,  # Annual Leave
                'date_from': date_from,
                'date_to': date_to,
                'reason': 'E2E Test Leave',
            },
            timeout=DEFAULT_TIMEOUT,
        )

        assert apply_response.status_code == 201
        request_id = apply_response.json()['id']
        assert apply_response.json()['status'] == 'PENDING'

        # Step 2: Supervisor approves
        approve_response = requests.post(
            f'{API_BASE_URL}/approvals/{request_id}/approve',
            headers={'Authorization': f'Bearer {supervisor_token}'},
            json={},
            timeout=DEFAULT_TIMEOUT,
        )

        assert approve_response.status_code == 200

        # Step 3: Employee verifies approval
        verify_response = requests.get(
            f'{API_BASE_URL}/leave/requests/{request_id}',
            headers={'Authorization': f'Bearer {employee_token}'},
            timeout=DEFAULT_TIMEOUT,
        )

        assert verify_response.status_code == 200
        assert verify_response.json()['status'] == 'APPROVED'


class TestPayslipE2E:
    """E2E tests for payslip access."""

    @pytest.fixture
    def authenticated_employee(self):
        """Get authenticated employee with PIN."""
        user = TEST_USERS['employee']

        # Login
        login_response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )
        token = login_response.json()['access_token']

        # Setup and verify PIN
        pin = '654321'
        requests.post(
            f'{API_BASE_URL}/auth/pin/setup',
            headers={'Authorization': f'Bearer {token}'},
            json={'pin': pin},
            timeout=DEFAULT_TIMEOUT,
        )

        verify_response = requests.post(
            f'{API_BASE_URL}/auth/pin/verify',
            headers={'Authorization': f'Bearer {token}'},
            json={'pin': pin},
            timeout=DEFAULT_TIMEOUT,
        )
        pin_token = verify_response.json()['verification_token']

        return {'auth_token': token, 'pin_token': pin_token}

    def test_payslip_list_access(self, authenticated_employee):
        """Test payslip list is accessible without PIN."""
        response = requests.get(
            f'{API_BASE_URL}/payslips',
            headers={
                'Authorization': f'Bearer {authenticated_employee["auth_token"]}',
            },
            timeout=DEFAULT_TIMEOUT,
        )

        assert response.status_code == 200
        data = response.json()
        assert 'items' in data
        assert 'pagination' in data

    def test_payslip_detail_requires_pin(self, authenticated_employee):
        """Test payslip detail requires PIN verification."""
        # Get payslip list first
        list_response = requests.get(
            f'{API_BASE_URL}/payslips',
            headers={
                'Authorization': f'Bearer {authenticated_employee["auth_token"]}',
            },
            timeout=DEFAULT_TIMEOUT,
        )

        if list_response.json()['items']:
            payslip_id = list_response.json()['items'][0]['id']

            # Try without PIN
            no_pin_response = requests.get(
                f'{API_BASE_URL}/payslips/{payslip_id}',
                headers={
                    'Authorization': f'Bearer {authenticated_employee["auth_token"]}',
                },
                timeout=DEFAULT_TIMEOUT,
            )
            assert no_pin_response.status_code == 403

            # Try with PIN
            with_pin_response = requests.get(
                f'{API_BASE_URL}/payslips/{payslip_id}',
                headers={
                    'Authorization': f'Bearer {authenticated_employee["auth_token"]}',
                    'X-Verification-Token': authenticated_employee['pin_token'],
                },
                timeout=DEFAULT_TIMEOUT,
            )
            assert with_pin_response.status_code == 200


class TestNotificationsE2E:
    """E2E tests for notifications."""

    @pytest.fixture
    def employee_token(self):
        """Get employee auth token."""
        user = TEST_USERS['employee']
        response = requests.post(
            f'{API_BASE_URL}/auth/login',
            json={
                'email': user['email'],
                'password': user['password'],
            },
            timeout=DEFAULT_TIMEOUT,
        )
        return response.json()['access_token']

    def test_notification_lifecycle(self, employee_token):
        """Test notification read/unread cycle."""
        # Get notifications
        list_response = requests.get(
            f'{API_BASE_URL}/notifications',
            headers={'Authorization': f'Bearer {employee_token}'},
            timeout=DEFAULT_TIMEOUT,
        )

        assert list_response.status_code == 200
        data = list_response.json()
        assert 'items' in data

        # Get unread count
        count_response = requests.get(
            f'{API_BASE_URL}/notifications/unread-count',
            headers={'Authorization': f'Bearer {employee_token}'},
            timeout=DEFAULT_TIMEOUT,
        )

        assert count_response.status_code == 200
        assert 'count' in count_response.json()


class TestRBACE2E:
    """E2E tests for role-based access control."""

    def test_role_access_levels(self):
        """Test different roles have appropriate access."""
        roles_and_endpoints = [
            ('employee', '/approvals/pending', 403),
            ('supervisor', '/approvals/pending', 200),
            ('hr_manager', '/approvals/pending', 200),
            ('admin', '/approvals/pending', 200),
        ]

        for role, endpoint, expected_status in roles_and_endpoints:
            user = TEST_USERS[role]

            login_response = requests.post(
                f'{API_BASE_URL}/auth/login',
                json={
                    'email': user['email'],
                    'password': user['password'],
                },
                timeout=DEFAULT_TIMEOUT,
            )
            token = login_response.json()['access_token']

            response = requests.get(
                f'{API_BASE_URL}{endpoint}',
                headers={'Authorization': f'Bearer {token}'},
                timeout=DEFAULT_TIMEOUT,
            )

            assert response.status_code == expected_status, \
                f"Role {role} got {response.status_code} for {endpoint}, expected {expected_status}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
