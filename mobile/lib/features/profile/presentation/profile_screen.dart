import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.valueOrNull?.user;
    final employee = user?.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile editing coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: employee?.photoUrl != null
                      ? NetworkImage(employee!.photoUrl!)
                      : null,
                  child: employee?.photoUrl == null
                      ? Text(
                          _getInitials(employee?.fullName ?? 'U'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  employee?.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  employee?.jobTitle ?? 'Employee',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    employee?.departmentName ?? 'Department',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Employee Info
          _ProfileSection(
            title: 'Employee Information',
            items: [
              _ProfileItem(
                icon: Icons.badge_outlined,
                label: 'Employee No',
                value: employee?.employeeNo ?? '-',
              ),
              _ProfileItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user?.email ?? '-',
              ),
              _ProfileItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: employee?.phone ?? '-',
              ),
              _ProfileItem(
                icon: Icons.calendar_today_outlined,
                label: 'Joined',
                value: employee?.hireDate ?? '-',
              ),
            ],
          ),

          const Divider(),

          // Settings
          _ProfileSection(
            title: 'Settings',
            items: [
              _ProfileItem(
                icon: Icons.lock_outline,
                label: 'Change Password',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please contact HR to change your password')),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.pin_outlined,
                label: 'Change PIN',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.pinSetup);
                },
              ),
              _ProfileItem(
                icon: Icons.fingerprint,
                label: 'Biometric Login',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Biometric login coming soon')),
                    );
                  },
                ),
              ),
              _ProfileItem(
                icon: Icons.language,
                label: 'Language',
                value: 'English',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language selection coming soon')),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.notifications);
                },
              ),
            ],
          ),

          const Divider(),

          // Support
          _ProfileSection(
            title: 'Support',
            items: [
              _ProfileItem(
                icon: Icons.help_outline,
                label: 'Help & FAQ',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('For help, please contact HR at support@kerjaflow.my')),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.privacyPolicy);
                },
              ),
              _ProfileItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.termsOfService);
                },
              ),
              _ProfileItem(
                icon: Icons.info_outline,
                label: 'About',
                value: 'Version 1.0.0',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'KerjaFlow',
                    applicationVersion: '1.0.0',
                    applicationIcon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_rounded, color: Colors.white),
                    ),
                    applicationLegalese: '© 2024 KerjaFlow Sdn Bhd\nEnterprise Workforce Management',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(authStateNotifierProvider.notifier).logout();
                          context.go(AppRoutes.login);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      subtitle: value != null ? Text(value!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
