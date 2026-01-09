import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onForgotPassword;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // For demo, accept any credentials
    widget.onLoginSuccess?.call();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Accept email format or employee number format (EMP####)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final empRegex = RegExp(r'^EMP\d{4,}$');
    if (!emailRegex.hasMatch(value) && !empRegex.hasMatch(value)) {
      return 'Invalid email or employee number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: KFLoadingOverlay(
          isLoading: _isLoading,
          message: 'Signing in...',
          child: isTablet || isDesktop
              ? _buildTabletLayout()
              : _buildPhoneLayout(),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KFSpacing.space8),
          _buildLogo(),
          const SizedBox(height: KFSpacing.space8),
          _buildWelcomeText(),
          const SizedBox(height: KFSpacing.space8),
          _buildForm(),
          const SizedBox(height: KFSpacing.space6),
          _buildSocialLogin(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side - branding
        Expanded(
          child: Container(
            color: KFColors.primary600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: KFColors.white.withOpacity(0.2),
                    borderRadius: KFRadius.radiusXxl,
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 64,
                    color: KFColors.white,
                  ),
                ),
                const SizedBox(height: KFSpacing.space6),
                const Text(
                  'KerjaFlow',
                  style: TextStyle(
                    fontSize: KFTypography.fontSize4xl,
                    fontWeight: KFTypography.bold,
                    color: KFColors.white,
                  ),
                ),
                const SizedBox(height: KFSpacing.space2),
                const Text(
                  'Enterprise Workforce Management',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    color: KFColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - login form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(KFSpacing.space8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWelcomeText(),
                const SizedBox(height: KFSpacing.space8),
                _buildForm(),
                const SizedBox(height: KFSpacing.space6),
                _buildSocialLogin(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: KFColors.primary600,
          borderRadius: KFRadius.radiusXl,
        ),
        child: const Icon(
          Icons.work_outline,
          size: 48,
          color: KFColors.white,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: KFTypography.fontSize2xl,
            fontWeight: KFTypography.bold,
          ),
        ),
        SizedBox(height: KFSpacing.space1),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: KFTypography.fontSizeBase,
            color: KFColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          KFTextField(
            controller: _emailController,
            label: 'Email or Employee No',
            hint: 'Enter your email or EMP1234',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: KFSpacing.space4),
          KFPasswordField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: KFSpacing.space3),
          Align(
            alignment: Alignment.centerRight,
            child: KFTextButton(
              label: 'Forgot Password?',
              onPressed: widget.onForgotPassword,
            ),
          ),
          const SizedBox(height: KFSpacing.space6),
          KFPrimaryButton(
            label: 'Login',
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KFSpacing.space4),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.gray500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: KFSpacing.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.apple, 'Apple'),
            const SizedBox(width: KFSpacing.space4),
            _buildSocialButton(Icons.g_mobiledata, 'Google'),
            const SizedBox(width: KFSpacing.space4),
            _buildSocialButton(Icons.phone_android, 'HMS'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Material(
      color: KFColors.gray100,
      borderRadius: KFRadius.radiusMd,
      child: InkWell(
        onTap: () {
          // TODO: Implement social login
        },
        borderRadius: KFRadius.radiusMd,
        child: Container(
          width: 64,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: KFColors.gray700),
        ),
      ),
    );
  }
}
