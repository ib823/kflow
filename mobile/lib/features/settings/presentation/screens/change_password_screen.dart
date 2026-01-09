import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/secure_screen_mixin.dart';
import '../../../../shared/theme/app_theme.dart';

/// Password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

/// S-081: Change Password Screen
///
/// Secure password change with:
/// - FLAG_SECURE enabled
/// - Current password verification
/// - New password with strength indicator
/// - Password requirements display
/// - Real-time validation
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen>
    with SecureScreenMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  PasswordStrength _strength = PasswordStrength.weak;

  // Password requirements state
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    enableSecureScreen(); // FLAG_SECURE - prevent screenshots
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    disableSecureScreen();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      int score = 0;
      if (_hasMinLength) score++;
      if (_hasUppercase) score++;
      if (_hasLowercase) score++;
      if (_hasNumber) score++;
      if (_hasSpecialChar) score++;

      if (score <= 2) {
        _strength = PasswordStrength.weak;
      } else if (score == 3) {
        _strength = PasswordStrength.medium;
      } else if (score == 4) {
        _strength = PasswordStrength.strong;
      } else {
        _strength = PasswordStrength.veryStrong;
      }
    });
  }

  Color _getStrengthColor() {
    switch (_strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.info;
      case PasswordStrength.veryStrong:
        return AppColors.success;
    }
  }

  String _getStrengthLabel() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  double _getStrengthProgress() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call: POST /api/v1/auth/change-password
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security notice
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: AppColors.info, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Screen capture is disabled for your security',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Current password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // New password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (!_hasMinLength || !_hasUppercase || !_hasLowercase ||
                      !_hasNumber || !_hasSpecialChar) {
                    return 'Password does not meet all requirements';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Password strength indicator
              if (_newPasswordController.text.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _getStrengthProgress(),
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(_getStrengthColor()),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      _getStrengthLabel(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStrengthColor(),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Password requirements
              _buildRequirementsList(),

              const SizedBox(height: AppSpacing.lg),

              // Confirm password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsList() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildRequirement('At least 8 characters', _hasMinLength),
          _buildRequirement('At least 1 uppercase letter (A-Z)', _hasUppercase),
          _buildRequirement('At least 1 lowercase letter (a-z)', _hasLowercase),
          _buildRequirement('At least 1 number (0-9)', _hasNumber),
          _buildRequirement('At least 1 special character (!@#\$%^&*)', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isMet ? AppColors.success : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
