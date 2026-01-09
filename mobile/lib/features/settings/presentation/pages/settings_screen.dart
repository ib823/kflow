import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Main settings screen with navigation to sub-settings
class SettingsScreen extends StatelessWidget {
  final VoidCallback? onLanguageTap;
  final VoidCallback? onThemeTap;
  final VoidCallback? onSecurityTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onLogout;

  const SettingsScreen({
    super.key,
    this.onLanguageTap,
    this.onThemeTap,
    this.onSecurityTap,
    this.onHelpTap,
    this.onAboutTap,
    this.onLogout,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLogout?.call();
            },
            style: TextButton.styleFrom(foregroundColor: KFColors.error600),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Preferences'),
            KFCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.language,
                    iconColor: KFColors.primary600,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: onLanguageTap,
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    iconColor: KFColors.secondary500,
                    title: 'Theme',
                    subtitle: 'System default',
                    onTap: onThemeTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
            _buildSectionHeader('Security'),
            KFCard(
              child: _SettingsTile(
                icon: Icons.security,
                iconColor: KFColors.success600,
                title: 'Security Settings',
                subtitle: 'PIN, biometric, auto-lock',
                onTap: onSecurityTap,
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
            _buildSectionHeader('Support'),
            KFCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    iconColor: KFColors.info500,
                    title: 'Help & FAQ',
                    onTap: onHelpTap,
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    iconColor: KFColors.gray600,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: onAboutTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space8),
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: KFColors.error600),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: KFColors.error600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: KFColors.error600),
                  padding: const EdgeInsets.all(KFSpacing.space4),
                  shape: RoundedRectangleBorder(
                    borderRadius: KFRadius.radiusMd,
                  ),
                ),
              ),
            ),
            const SizedBox(height: KFSpacing.space8),
            // Version info
            Center(
              child: Text(
                'KerjaFlow v1.0.0 (Build 100)',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.gray500,
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
          fontWeight: KFTypography.semiBold,
          color: KFColors.gray600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
                      subtitle!,
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        color: KFColors.gray500,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: KFColors.gray400,
                ),
          ],
        ),
      ),
    );
  }
}
