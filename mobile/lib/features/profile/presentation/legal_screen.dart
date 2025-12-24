import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

enum LegalDocType { privacyPolicy, termsOfService }

class LegalScreen extends StatelessWidget {
  final LegalDocType docType;

  const LegalScreen({super.key, required this.docType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(docType == LegalDocType.privacyPolicy
            ? 'Privacy Policy'
            : 'Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SelectableText.rich(
          TextSpan(
            children: docType == LegalDocType.privacyPolicy
                ? _buildPrivacyPolicy(context)
                : _buildTermsOfService(context),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildPrivacyPolicy(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    );
    final subheadingStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
      height: 1.6,
    );

    return [
      TextSpan(text: 'KerjaFlow Privacy Policy\n\n', style: headingStyle),
      TextSpan(text: 'Last Updated: December 2024\n\n', style: bodyStyle),

      TextSpan(text: '1. Introduction\n\n', style: subheadingStyle),
      TextSpan(
        text: 'KerjaFlow ("we", "our", or "us") is committed to protecting your privacy. '
            'This Privacy Policy explains how we collect, use, disclose, and safeguard your '
            'information when you use our mobile application and related services.\n\n'
            'This policy complies with:\n'
            '• Personal Data Protection Act 2010 (PDPA) - Malaysia\n'
            '• General Data Protection Regulation (GDPR) - where applicable\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '2. Information We Collect\n\n', style: subheadingStyle),
      TextSpan(text: '2.1 Personal Data\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: 'We collect the following personal data:\n'
            '• Identity Data: Full name, employee number, IC number (NRIC)\n'
            '• Contact Data: Email address, phone number\n'
            '• Employment Data: Job title, department, hire date, reporting manager\n'
            '• Financial Data: Bank account details (for payroll), EPF number, SOCSO number, tax number\n'
            '• Leave Data: Leave balances, leave requests, attendance records\n\n',
        style: bodyStyle,
      ),
      TextSpan(text: '2.2 Technical Data\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: '• Device information (model, OS version)\n'
            '• App version\n'
            '• IP address\n'
            '• Push notification tokens\n'
            '• Usage analytics (anonymized)\n\n',
        style: bodyStyle,
      ),
      TextSpan(text: '2.3 Biometric Data\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: 'If you enable biometric authentication:\n'
            '• Fingerprint data (stored locally on device only)\n'
            '• Face ID data (stored locally on device only)\n\n'
            'Note: Biometric templates are never transmitted to our servers.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '3. How We Use Your Information\n\n', style: subheadingStyle),
      TextSpan(
        text: 'We use your personal data to:\n'
            '• Process leave requests and approvals\n'
            '• Generate and distribute payslips\n'
            '• Manage employee documents\n'
            '• Send notifications about your employment matters\n'
            '• Provide HR self-service features\n'
            '• Comply with legal obligations\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '4. Data Sharing\n\n', style: subheadingStyle),
      TextSpan(
        text: 'We may share your data with:\n'
            '• Your Employer: HR department, managers (as necessary for HR processes)\n'
            '• Government Agencies: EPF, SOCSO, LHDN (as required by law)\n'
            '• Service Providers: Secure cloud hosting, payment processors\n\n'
            'We do NOT:\n'
            '• Sell your personal data\n'
            '• Share data with third-party advertisers\n'
            '• Use data for profiling or automated decision-making\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '5. Data Security\n\n', style: subheadingStyle),
      TextSpan(
        text: 'We implement:\n'
            '• End-to-end encryption for data transmission (TLS 1.3)\n'
            '• AES-256 encryption for data at rest\n'
            '• PIN and biometric authentication\n'
            '• Secure token-based sessions\n'
            '• Regular security audits\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '6. Data Retention\n\n', style: subheadingStyle),
      TextSpan(
        text: '• Employment records: Duration of employment + 7 years\n'
            '• Payslip data: 7 years\n'
            '• Leave records: 7 years\n'
            '• Access logs: 1 year\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '7. Your Rights\n\n', style: subheadingStyle),
      TextSpan(text: 'Under PDPA (Malaysia):\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: '• Right to access your personal data\n'
            '• Right to correct inaccurate data\n'
            '• Right to withdraw consent\n'
            '• Right to make complaints to JPDP\n\n',
        style: bodyStyle,
      ),
      TextSpan(text: 'Under GDPR (if applicable):\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: '• Right to be informed\n'
            '• Right of access\n'
            '• Right to rectification\n'
            '• Right to erasure\n'
            '• Right to restrict processing\n'
            '• Right to data portability\n'
            '• Right to object\n\n'
            'To exercise these rights, contact your HR department or email: privacy@kerjaflow.my\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '8. Children\'s Privacy\n\n', style: subheadingStyle),
      TextSpan(
        text: 'KerjaFlow is not intended for individuals under 18 years of age. '
            'We do not knowingly collect data from minors.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '9. Changes to This Policy\n\n', style: subheadingStyle),
      TextSpan(
        text: 'We may update this Privacy Policy periodically. Changes will be notified via:\n'
            '• In-app notification\n'
            '• Email (for significant changes)\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '10. Contact Us\n\n', style: subheadingStyle),
      TextSpan(
        text: 'Data Protection Officer\n'
            'KerjaFlow Sdn Bhd\n'
            'Email: dpo@kerjaflow.my\n\n'
            'Regulatory Authority (Malaysia)\n'
            'Jabatan Perlindungan Data Peribadi (JPDP)\n'
            'Website: www.pdp.gov.my\n\n'
            '---\n\n'
            'By using KerjaFlow, you acknowledge that you have read and understood this Privacy Policy.',
        style: bodyStyle,
      ),
    ];
  }

  List<TextSpan> _buildTermsOfService(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    );
    final subheadingStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
      height: 1.6,
    );

    return [
      TextSpan(text: 'KerjaFlow Terms of Service\n\n', style: headingStyle),
      TextSpan(text: 'Last Updated: December 2024\n\n', style: bodyStyle),

      TextSpan(text: '1. Acceptance of Terms\n\n', style: subheadingStyle),
      TextSpan(
        text: 'By downloading, installing, or using the KerjaFlow mobile application ("App"), '
            'you agree to be bound by these Terms of Service ("Terms"). If you do not agree to '
            'these Terms, do not use the App.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '2. Description of Service\n\n', style: subheadingStyle),
      TextSpan(
        text: 'KerjaFlow is an enterprise workforce management application that provides:\n'
            '• Leave management and requests\n'
            '• Payslip viewing and downloads\n'
            '• Employee document management\n'
            '• Notification services\n'
            '• HR self-service features\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '3. User Accounts\n\n', style: subheadingStyle),
      TextSpan(text: '3.1 Account Creation\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: '• Accounts are created by your employer\'s HR department\n'
            '• You are responsible for maintaining the confidentiality of your login credentials\n'
            '• You must immediately notify HR of any unauthorized use of your account\n\n',
        style: bodyStyle,
      ),
      TextSpan(text: '3.2 Account Security\n', style: subheadingStyle?.copyWith(fontSize: 14)),
      TextSpan(
        text: '• You must set up a 6-digit PIN for accessing sensitive information\n'
            '• Biometric authentication is optional but recommended\n'
            '• Never share your PIN or allow others to use your biometric data\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '4. Acceptable Use\n\n', style: subheadingStyle),
      TextSpan(
        text: 'You agree NOT to:\n'
            '• Share your login credentials with others\n'
            '• Attempt to access other employees\' data\n'
            '• Use the App for any unlawful purpose\n'
            '• Attempt to circumvent security measures\n'
            '• Reverse engineer or decompile the App\n'
            '• Submit false information or fraudulent requests\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '5. Leave Requests\n\n', style: subheadingStyle),
      TextSpan(
        text: '• Leave requests are subject to company policy and manager approval\n'
            '• Submitting a request does not guarantee approval\n'
            '• You must have sufficient leave balance\n'
            '• Pending requests may be cancelled before approval\n'
            '• Approved leave may only be cancelled with manager permission\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '6. Payslip Information\n\n', style: subheadingStyle),
      TextSpan(
        text: '• Payslips are confidential documents\n'
            '• PIN verification is required to view payslip details\n'
            '• Downloaded PDFs should be stored securely\n'
            '• Report any discrepancies to your HR department immediately\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '7. Intellectual Property\n\n', style: subheadingStyle),
      TextSpan(
        text: '• The App and its content are owned by KerjaFlow Sdn Bhd\n'
            '• You are granted a limited, non-exclusive license to use the App\n'
            '• You may not copy, modify, or distribute the App\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '8. Privacy\n\n', style: subheadingStyle),
      TextSpan(
        text: 'Your use of the App is also governed by our Privacy Policy. By using the App, '
            'you consent to the collection and use of data as described in the Privacy Policy.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '9. Disclaimers\n\n', style: subheadingStyle),
      TextSpan(
        text: 'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DO NOT WARRANT THAT:\n'
            '• The App will be uninterrupted or error-free\n'
            '• Defects will be corrected\n'
            '• The App is free of viruses\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '10. Limitation of Liability\n\n', style: subheadingStyle),
      TextSpan(
        text: 'TO THE MAXIMUM EXTENT PERMITTED BY LAW, KERJAFLOW SHALL NOT BE LIABLE FOR:\n'
            '• Indirect, incidental, or consequential damages\n'
            '• Loss of data or business interruption\n'
            '• Damages exceeding the amount paid for the App (if any)\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '11. Indemnification\n\n', style: subheadingStyle),
      TextSpan(
        text: 'You agree to indemnify and hold harmless KerjaFlow from any claims arising from:\n'
            '• Your use of the App\n'
            '• Your violation of these Terms\n'
            '• Your violation of any third-party rights\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '12. Modifications\n\n', style: subheadingStyle),
      TextSpan(
        text: 'We reserve the right to modify these Terms at any time. Continued use of the App '
            'after changes constitutes acceptance of the modified Terms.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '13. Termination\n\n', style: subheadingStyle),
      TextSpan(
        text: '• Your access may be terminated by your employer\n'
            '• We may suspend access for violation of these Terms\n'
            '• Upon termination, you must delete the App and any downloaded content\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '14. Governing Law\n\n', style: subheadingStyle),
      TextSpan(
        text: 'These Terms are governed by the laws of Malaysia. Any disputes shall be subject '
            'to the exclusive jurisdiction of the courts of Malaysia.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '15. Severability\n\n', style: subheadingStyle),
      TextSpan(
        text: 'If any provision of these Terms is found invalid, the remaining provisions shall '
            'remain in effect.\n\n',
        style: bodyStyle,
      ),

      TextSpan(text: '16. Contact\n\n', style: subheadingStyle),
      TextSpan(
        text: 'For questions about these Terms:\n\n'
            'KerjaFlow Sdn Bhd\n'
            'Email: legal@kerjaflow.my\n\n'
            '---\n\n'
            'By using KerjaFlow, you acknowledge that you have read, understood, and agree to be '
            'bound by these Terms of Service.',
        style: bodyStyle,
      ),
    ];
  }
}
