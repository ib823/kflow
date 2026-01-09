import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Forgot password screen for password recovery
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    this.onSuccess,
    this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or employee number is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final empRegex = RegExp(r'^EMP\d{4,}$');
    if (!emailRegex.hasMatch(value) && !empRegex.hasMatch(value)) {
      return 'Please enter a valid email or employee number';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: KFLoadingOverlay(
          isLoading: _isLoading,
          message: 'Sending reset link...',
          child: SingleChildScrollView(
            padding: KFSpacing.screenPadding,
            child: _isSuccess ? _buildSuccessContent() : _buildFormContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KFSpacing.space8),
        // Icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: KFColors.primary100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 48,
              color: KFColors.primary600,
            ),
          ),
        ),
        const SizedBox(height: KFSpacing.space6),
        // Title
        const Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: KFTypography.fontSize2xl,
            fontWeight: KFTypography.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KFSpacing.space2),
        // Description
        const Text(
          'Enter your email address or employee number and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: KFTypography.fontSizeBase,
            color: KFColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KFSpacing.space8),
        // Error message
        if (_errorMessage != null) ...[
          KFInfoBanner(
            message: _errorMessage!,
            backgroundColor: KFColors.error100,
            textColor: KFColors.error700,
            icon: Icons.error_outline,
            onDismiss: () => setState(() => _errorMessage = null),
          ),
          const SizedBox(height: KFSpacing.space4),
        ],
        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KFTextField(
                controller: _emailController,
                label: 'Email or Employee No',
                hint: 'Enter your email or EMP1234',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: _validateEmail,
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: KFSpacing.space6),
              KFPrimaryButton(
                label: 'Send Reset Link',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: KFSpacing.space6),
        // Back to login
        Center(
          child: KFTextButton(
            label: 'Back to Login',
            onPressed: widget.onBackToLogin,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: KFSpacing.space8),
        // Success icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: KFColors.success100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 48,
              color: KFColors.success600,
            ),
          ),
        ),
        const SizedBox(height: KFSpacing.space6),
        // Title
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: KFTypography.fontSize2xl,
            fontWeight: KFTypography.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KFSpacing.space2),
        // Description
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          style: const TextStyle(
            fontSize: KFTypography.fontSizeBase,
            color: KFColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KFSpacing.space8),
        // Info banner
        KFInfoBanner(
          message:
              'Didn\'t receive the email? Check your spam folder or request a new link.',
          backgroundColor: KFColors.info100,
          textColor: KFColors.info700,
          icon: Icons.info_outline,
        ),
        const SizedBox(height: KFSpacing.space6),
        // Actions
        KFPrimaryButton(
          label: 'Back to Login',
          onPressed: widget.onBackToLogin,
        ),
        const SizedBox(height: KFSpacing.space4),
        KFSecondaryButton(
          label: 'Resend Email',
          onPressed: () {
            setState(() => _isSuccess = false);
            _handleSubmit();
          },
        ),
      ],
    );
  }
}
