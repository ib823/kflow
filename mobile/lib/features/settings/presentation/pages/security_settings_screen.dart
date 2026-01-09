import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Security settings screen for PIN, biometric, and auto-lock settings
class SecuritySettingsScreen extends StatefulWidget {
  final VoidCallback? onChangePIN;
  final VoidCallback? onChangePassword;

  const SecuritySettingsScreen({
    super.key,
    this.onChangePIN,
    this.onChangePassword,
  });

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = true;
  bool _autoLockEnabled = true;
  String _autoLockDuration = '5';

  final List<_AutoLockOption> _autoLockOptions = const [
    _AutoLockOption('1', '1 minute'),
    _AutoLockOption('5', '5 minutes'),
    _AutoLockOption('10', '10 minutes'),
    _AutoLockOption('15', '15 minutes'),
    _AutoLockOption('30', '30 minutes'),
  ];

  void _toggleBiometric(bool value) {
    setState(() => _biometricEnabled = value);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Biometric login enabled'
              : 'Biometric login disabled',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAutoLock(bool value) {
    setState(() => _autoLockEnabled = value);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Auto-lock enabled'
              : 'Auto-lock disabled',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAutoLockPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KFRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(KFSpacing.space4),
              child: Text(
                'Auto-lock After',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeLg,
                  fontWeight: KFTypography.semibold,
                ),
              ),
            ),
            const Divider(height: 1),
            ..._autoLockOptions.map((option) => ListTile(
                  title: Text(option.label),
                  trailing: _autoLockDuration == option.value
                      ? const Icon(Icons.check, color: KFColors.primary600)
                      : null,
                  onTap: () {
                    setState(() => _autoLockDuration = option.value);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Auto-lock set to ${option.label}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )),
            const SizedBox(height: KFSpacing.space4),
          ],
        ),
      ),
    );
  }

  void _showChangePINConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: const Text(
          'You will need to verify your current PIN before setting a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onChangePIN?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'You will be redirected to change your password. Make sure you remember your current password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onChangePassword?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Security'),
      body: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            KFInfoBanner(
              message: 'Keep your account secure by using a strong PIN and enabling biometric authentication.',
              backgroundColor: KFColors.info50,
              textColor: KFColors.info700,
              icon: Icons.security,
            ),
            const SizedBox(height: KFSpacing.space6),

            // Biometric section
            _buildSectionHeader('Quick Access'),
            KFCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    iconColor: KFColors.primary600,
                    title: 'Biometric Login',
                    subtitle: 'Use fingerprint or face ID to login',
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space6),

            // Auto-lock section
            _buildSectionHeader('Auto-lock'),
            KFCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.lock_clock,
                    iconColor: KFColors.warning500,
                    title: 'Auto-lock',
                    subtitle: 'Lock app after inactivity',
                    value: _autoLockEnabled,
                    onChanged: _toggleAutoLock,
                  ),
                  if (_autoLockEnabled) ...[
                    const Divider(height: 1),
                    _buildNavigationTile(
                      icon: Icons.timer_outlined,
                      iconColor: KFColors.warning500,
                      title: 'Lock After',
                      value: _autoLockOptions
                          .firstWhere((o) => o.value == _autoLockDuration)
                          .label,
                      onTap: _showAutoLockPicker,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space6),

            // Credentials section
            _buildSectionHeader('Credentials'),
            KFCard(
              child: Column(
                children: [
                  _buildNavigationTile(
                    icon: Icons.pin,
                    iconColor: KFColors.success600,
                    title: 'Change PIN',
                    subtitle: 'Update your 6-digit PIN',
                    onTap: _showChangePINConfirmation,
                  ),
                  const Divider(height: 1),
                  _buildNavigationTile(
                    icon: Icons.password,
                    iconColor: KFColors.error500,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: _showChangePasswordConfirmation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space8),

            // Security tips
            _buildSectionHeader('Security Tips'),
            KFCard(
              child: Padding(
                padding: const EdgeInsets.all(KFSpacing.space4),
                child: Column(
                  children: [
                    _buildTipRow(
                      Icons.check_circle,
                      KFColors.success600,
                      'Use a PIN that is not easily guessable',
                    ),
                    const SizedBox(height: KFSpacing.space3),
                    _buildTipRow(
                      Icons.check_circle,
                      KFColors.success600,
                      'Enable biometric login for quick and secure access',
                    ),
                    const SizedBox(height: KFSpacing.space3),
                    _buildTipRow(
                      Icons.check_circle,
                      KFColors.success600,
                      'Keep auto-lock enabled to protect your data',
                    ),
                    const SizedBox(height: KFSpacing.space3),
                    _buildTipRow(
                      Icons.warning_amber,
                      KFColors.warning500,
                      'Never share your PIN with anyone',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: KFSpacing.space1,
        bottom: KFSpacing.space3,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(KFSpacing.space4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: KFRadius.radiusMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: KFSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.medium,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.gray500,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: KFColors.primary600,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: KFRadius.radiusMd,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: KFSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeMd,
                      fontWeight: KFTypography.medium,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        color: KFColors.gray500,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null)
              Text(
                value,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.gray500,
                ),
              ),
            const SizedBox(width: KFSpacing.space2),
            const Icon(
              Icons.chevron_right,
              color: KFColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: KFSpacing.space2),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              color: KFColors.gray700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AutoLockOption {
  final String value;
  final String label;

  const _AutoLockOption(this.value, this.label);
}
