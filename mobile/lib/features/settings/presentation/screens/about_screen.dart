import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_theme.dart';

/// S-083: About Screen
///
/// App information including:
/// - App name and logo
/// - Version and build number
/// - Copyright
/// - Links to Terms, Privacy, Licenses, Support
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@kerjaflow.com',
      queryParameters: {
        'subject': 'KerjaFlow App Support',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '---';
          final buildNumber = snapshot.data?.buildNumber ?? '---';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'KF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App name
              Center(
                child: Text(
                  'KerjaFlow',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Tagline
              Center(
                child: Text(
                  'Enterprise Workforce Management',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Version
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Version $version (Build $buildNumber)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // Links
              _buildLinkTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _launchUrl('https://kerjaflow.com/terms'),
              ),
              _buildLinkTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _launchUrl('https://kerjaflow.com/privacy'),
              ),
              _buildLinkTile(
                context,
                icon: Icons.code,
                title: 'Open Source Licenses',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'KerjaFlow',
                  applicationVersion: '$version ($buildNumber)',
                  applicationIcon: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'KF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildLinkTile(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'support@kerjaflow.com',
                onTap: _launchEmail,
              ),

              const SizedBox(height: AppSpacing.xxl),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),

              // Features
              Center(
                child: Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFeatureGrid(context),

              const SizedBox(height: AppSpacing.xxl),

              // Copyright
              Center(
                child: Text(
                  '\u00A9 2026 KerjaFlow',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'All rights reserved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Made with love
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made with ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    const Icon(Icons.favorite, size: 14, color: Colors.red),
                    Text(
                      ' in ASEAN',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {'icon': Icons.flag, 'label': '9 ASEAN Countries'},
      {'icon': Icons.translate, 'label': '12 Languages'},
      {'icon': Icons.phone_android, 'label': 'Offline-First'},
      {'icon': Icons.security, 'label': 'Enterprise Security'},
      {'icon': Icons.calculate, 'label': 'Statutory Compliance'},
      {'icon': Icons.sync, 'label': 'ERP Integration'},
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      children: features.map((feature) {
        return Container(
          width: 100,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Icon(
                feature['icon'] as IconData,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                feature['label'] as String,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
