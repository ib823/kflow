import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/models/user.dart';

void main() {
  group('User Model', () {
    test('creates User from JSON', () {
      final json = {
        'id': 1,
        'email': 'john@example.com',
        'role': 'EMPLOYEE',
        'status': 'ACTIVE',
        'is_email_verified': true,
        'is_phone_verified': false,
        'has_pin': true,
        'force_password_change': false,
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.email, 'john@example.com');
      expect(user.role, 'EMPLOYEE');
      expect(user.status, 'ACTIVE');
      expect(user.isEmailVerified, isTrue);
      expect(user.hasPin, isTrue);
    });

    test('converts User to JSON', () {
      const user = User(
        id: 1,
        email: 'john@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
        isEmailVerified: true,
        hasPin: true,
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['email'], 'john@example.com');
      expect(json['role'], 'EMPLOYEE');
      expect(json['is_email_verified'], isTrue);
    });

    test('User equality works correctly', () {
      const user1 = User(
        id: 1,
        email: 'john@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
      );

      const user2 = User(
        id: 1,
        email: 'john@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
      );

      expect(user1, equals(user2));
    });

    test('User with nested Employee', () {
      final json = {
        'id': 1,
        'email': 'john@example.com',
        'role': 'EMPLOYEE',
        'status': 'ACTIVE',
        'employee': {
          'id': 1,
          'employee_no': 'EMP001',
          'full_name': 'John Doe',
        },
      };

      final user = User.fromJson(json);

      expect(user.employee, isNotNull);
      expect(user.employee!.employeeNo, 'EMP001');
      expect(user.employee!.fullName, 'John Doe');
    });

    test('User default values', () {
      const user = User(
        id: 1,
        email: 'john@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
      );

      expect(user.isEmailVerified, isFalse);
      expect(user.isPhoneVerified, isFalse);
      expect(user.hasPin, isFalse);
      expect(user.forcePasswordChange, isFalse);
      expect(user.employee, isNull);
    });
  });

  group('Employee Model', () {
    test('creates Employee from JSON', () {
      final json = {
        'id': 1,
        'employee_no': 'EMP001',
        'first_name': 'John',
        'last_name': 'Doe',
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'department_name': 'Engineering',
        'job_title': 'Software Engineer',
        'status': 'ACTIVE',
      };

      final employee = Employee.fromJson(json);

      expect(employee.id, 1);
      expect(employee.employeeNo, 'EMP001');
      expect(employee.firstName, 'John');
      expect(employee.lastName, 'Doe');
      expect(employee.fullName, 'John Doe');
      expect(employee.departmentName, 'Engineering');
      expect(employee.jobTitle, 'Software Engineer');
    });

    test('Employee handles null optional fields', () {
      final json = {
        'id': 1,
        'employee_no': 'EMP001',
        'full_name': 'John Doe',
      };

      final employee = Employee.fromJson(json);

      expect(employee.firstName, isNull);
      expect(employee.lastName, isNull);
      expect(employee.phone, isNull);
      expect(employee.photoUrl, isNull);
      expect(employee.departmentName, isNull);
      expect(employee.jobTitle, isNull);
      expect(employee.hireDate, isNull);
      expect(employee.yearsOfService, isNull);
    });

    test('Employee converts to JSON correctly', () {
      const employee = Employee(
        id: 1,
        employeeNo: 'EMP001',
        fullName: 'John Doe',
        firstName: 'John',
        lastName: 'Doe',
        departmentName: 'Engineering',
      );

      final json = employee.toJson();

      expect(json['id'], 1);
      expect(json['employee_no'], 'EMP001');
      expect(json['full_name'], 'John Doe');
      expect(json['department_name'], 'Engineering');
    });
  });

  group('AuthTokens Model', () {
    test('creates AuthTokens from JSON', () {
      final json = {
        'access_token': 'access123',
        'refresh_token': 'refresh456',
        'expires_in': 86400,
        'token_type': 'Bearer',
      };

      final tokens = AuthTokens.fromJson(json);

      expect(tokens.accessToken, 'access123');
      expect(tokens.refreshToken, 'refresh456');
      expect(tokens.expiresIn, 86400);
      expect(tokens.tokenType, 'Bearer');
    });

    test('AuthTokens default token type', () {
      const tokens = AuthTokens(
        accessToken: 'access123',
        refreshToken: 'refresh456',
        expiresIn: 86400,
      );

      expect(tokens.tokenType, 'Bearer');
    });

    test('AuthTokens converts to JSON', () {
      const tokens = AuthTokens(
        accessToken: 'access123',
        refreshToken: 'refresh456',
        expiresIn: 86400,
      );

      final json = tokens.toJson();

      expect(json['access_token'], 'access123');
      expect(json['refresh_token'], 'refresh456');
      expect(json['expires_in'], 86400);
      expect(json['token_type'], 'Bearer');
    });
  });

  group('LoginResponse Model', () {
    test('creates LoginResponse from JSON', () {
      final json = {
        'user': {
          'id': 1,
          'email': 'john@example.com',
          'role': 'EMPLOYEE',
          'status': 'ACTIVE',
        },
        'tokens': {
          'access_token': 'access123',
          'refresh_token': 'refresh456',
          'expires_in': 86400,
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.user.id, 1);
      expect(response.user.email, 'john@example.com');
      expect(response.tokens.accessToken, 'access123');
    });

    test('LoginResponse converts to JSON', () {
      const response = LoginResponse(
        user: User(
          id: 1,
          email: 'john@example.com',
          role: 'EMPLOYEE',
          status: 'ACTIVE',
        ),
        tokens: AuthTokens(
          accessToken: 'access123',
          refreshToken: 'refresh456',
          expiresIn: 86400,
        ),
      );

      final json = response.toJson();

      expect(json['user']['id'], 1);
      expect(json['tokens']['access_token'], 'access123');
    });
  });
}
