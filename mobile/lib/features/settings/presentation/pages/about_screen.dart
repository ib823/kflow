import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// About screen showing app info, version, and links
class AboutScreen extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onLicensesTap;

  const AboutScreen({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onLicensesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'About'),
      body: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: KFSpacing.space8),
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: KFColors.primary600,
                borderRadius: KFRadius.radiusXxl,
                boxShadow: KFShadows.lg,
              ),
              child: const Center(
                child: Text(
                  'KF',
                  style: TextStyle(
                    fontSize: KFTypography.fontSize4xl,
                    fontWeight: KFTypography.bold,
                    color: KFColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: KFSpacing.space4),
            // App name
            const Text(
              'KerjaFlow',
              style: TextStyle(
                fontSize: KFTypography.fontSize2xl,
                fontWeight: KFTypography.bold,
              ),
            ),
            const SizedBox(height: KFSpacing.space1),
            // Tagline
            const Text(
              'Enterprise Workforce Management',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                color: KFColors.gray600,
              ),
            ),
            const SizedBox(height: KFSpacing.space2),
            // Version
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KFSpacing.space4,
                vertical: KFSpacing.space1,
              ),
              decoration: BoxDecoration(
                color: KFColors.primary50,
                borderRadius: KFRadius.radiusFull,
              ),
              child: const Text(
                'Version 1.0.0 (Build 100)',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.primary600,
                  fontWeight: KFTypography.medium,
                ),
              ),
            ),
            const SizedBox(height: KFSpacing.space8),
            // Description card
            KFCard(
              child: Padding(
                padding: const EdgeInsets.all(KFSpacing.space4),
                child: Column(
                  children: [
                    const Text(
                      'KerjaFlow is a comprehensive workforce management platform designed for enterprises in the ASEAN region. We help organizations manage their workforce efficiently with features for payroll, leave management, attendance tracking, and more.',
                      style: TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        color: KFColors.gray700,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: KFSpacing.space4),
                    // Features list
                    Wrap(
                      spacing: KFSpacing.space2,
                      runSpacing: KFSpacing.space2,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureChip('9 ASEAN Countries'),
                        _buildFeatureChip('12 Languages'),
                        _buildFeatureChip('Offline Support'),
                        _buildFeatureChip('Enterprise Security'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
            // Legal links
            KFCard(
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: onTermsTap,
                  ),
                  const Divider(height: 1),
                  _buildLinkTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: onPrivacyTap,
                  ),
                  const Divider(height: 1),
                  _buildLinkTile(
                    icon: Icons.gavel_outlined,
                    title: 'Open Source Licenses',
                    onTap: onLicensesTap ?? () => _showLicenses(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KFSpacing.space8),
            // Social links / Contact
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.language, 'Website'),
                const SizedBox(width: KFSpacing.space4),
                _buildSocialButton(Icons.email_outlined, 'Email'),
                const SizedBox(width: KFSpacing.space4),
                _buildSocialButton(Icons.support_agent, 'Support'),
              ],
            ),
            const SizedBox(height: KFSpacing.space8),
            // Copyright
            const Text(
              'Made with care for ASEAN enterprises',
              style: TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray500,
              ),
            ),
            const SizedBox(height: KFSpacing.space2),
            Text(
              '\u00a9 ${DateTime.now().year} KerjaFlow Sdn Bhd',
              style: const TextStyle(
                fontSize: KFTypography.fontSizeXs,
                color: KFColors.gray400,
              ),
            ),
            const Text(
              'All rights reserved.',
              style: TextStyle(
                fontSize: KFTypography.fontSizeXs,
                color: KFColors.gray400,
              ),
            ),
            const SizedBox(height: KFSpacing.space8),
          ],
        ),
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'KerjaFlow',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: KFColors.primary600,
          borderRadius: KFRadius.radiusLg,
        ),
        child: const Center(
          child: Text(
            'KF',
            style: TextStyle(
              fontSize: KFTypography.fontSize2xl,
              fontWeight: KFTypography.bold,
              color: KFColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KFSpacing.space3,
        vertical: KFSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: KFColors.gray100,
        borderRadius: KFRadius.radiusFull,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: KFTypography.fontSizeXs,
          color: KFColors.gray700,
          fontWeight: KFTypography.medium,
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: KFColors.gray600),
            const SizedBox(width: KFSpacing.space3),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeMd,
                  fontWeight: KFTypography.medium,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: KFColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: KFColors.gray100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: KFColors.gray600),
        ),
        const SizedBox(height: KFSpacing.space1),
        Text(
          label,
          style: const TextStyle(
            fontSize: KFTypography.fontSizeXs,
            color: KFColors.gray600,
          ),
        ),
      ],
    );
  }
}
