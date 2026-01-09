import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Help & FAQ screen with searchable FAQ and contact options
class HelpScreen extends StatefulWidget {
  final VoidCallback? onContactHR;
  final VoidCallback? onReportIssue;

  const HelpScreen({
    super.key,
    this.onContactHR,
    this.onReportIssue,
  });

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _expandedItems = {};

  final List<_FAQCategory> _faqCategories = const [
    _FAQCategory(
      title: 'Getting Started',
      icon: Icons.rocket_launch,
      items: [
        _FAQItem(
          question: 'How do I login to the app?',
          answer: 'You can login using your employee credentials provided by HR. Enter your employee ID and password on the login screen. If you\'ve set up a PIN, you can use that for subsequent logins.',
        ),
        _FAQItem(
          question: 'How do I set up my PIN?',
          answer: 'After your first login, you\'ll be prompted to create a 6-digit PIN. This PIN will be used for quick access to the app. Make sure to choose a PIN that\'s easy to remember but hard to guess.',
        ),
        _FAQItem(
          question: 'Can I use biometric login?',
          answer: 'Yes! If your device supports fingerprint or face recognition, you can enable biometric login in Settings > Security. This provides a quick and secure way to access the app.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Payslip',
      icon: Icons.receipt_long,
      items: [
        _FAQItem(
          question: 'When will my payslip be available?',
          answer: 'Payslips are typically available on or before your company\'s designated pay day. You\'ll receive a notification when your payslip is ready to view.',
        ),
        _FAQItem(
          question: 'Can I download my payslip?',
          answer: 'Yes, you can download your payslip as a PDF from the payslip detail screen. Tap on the download icon to save it to your device.',
        ),
        _FAQItem(
          question: 'Why are my deductions different this month?',
          answer: 'Deductions can vary based on statutory rates, bonuses, overtime, or other factors. For specific questions about your deductions, please contact your HR department.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Leave',
      icon: Icons.event_note,
      items: [
        _FAQItem(
          question: 'How do I apply for leave?',
          answer: 'Go to Leave > Apply Leave, select the leave type, choose your dates, and provide a reason. Your request will be sent to your manager for approval.',
        ),
        _FAQItem(
          question: 'How long does leave approval take?',
          answer: 'Approval time depends on your company\'s policies and your manager\'s availability. Typically, leave requests are processed within 1-3 business days.',
        ),
        _FAQItem(
          question: 'Can I cancel an approved leave?',
          answer: 'Yes, you can cancel approved leave before the leave start date. Go to Leave > History, find your leave, and tap Cancel. Note that some leave types may have restrictions on cancellation.',
        ),
        _FAQItem(
          question: 'What happens to unused leave at year end?',
          answer: 'This depends on your company\'s leave policy. Some companies allow leave to be carried forward, while others may have a use-it-or-lose-it policy. Check with your HR department for your specific policy.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Profile & Settings',
      icon: Icons.person,
      items: [
        _FAQItem(
          question: 'How do I update my profile information?',
          answer: 'Go to Profile > Edit Profile. You can update your contact information and emergency contacts. Some information like your name and employee ID can only be changed by HR.',
        ),
        _FAQItem(
          question: 'How do I change my language?',
          answer: 'Go to Settings > Language and select your preferred language. The app supports 12 languages including English, Bahasa Malaysia, Bahasa Indonesia, Thai, Vietnamese, Filipino, Chinese, Tamil, Bengali, Nepali, Khmer, and Myanmar.',
        ),
        _FAQItem(
          question: 'How do I change my PIN?',
          answer: 'Go to Settings > Security > Change PIN. You\'ll need to verify your current PIN before setting a new one.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Troubleshooting',
      icon: Icons.build,
      items: [
        _FAQItem(
          question: 'I forgot my PIN. What should I do?',
          answer: 'On the PIN entry screen, tap "Forgot PIN". You\'ll be redirected to login with your password. After successful login, you can set up a new PIN.',
        ),
        _FAQItem(
          question: 'The app is running slowly. How can I fix this?',
          answer: 'Try closing and reopening the app, or check your internet connection. If the issue persists, try clearing the app cache in your device settings.',
        ),
        _FAQItem(
          question: 'I\'m not receiving notifications. What should I check?',
          answer: 'Make sure notifications are enabled in your device settings for KerjaFlow. Also check the in-app notification settings to ensure they haven\'t been disabled.',
        ),
      ],
    ),
  ];

  List<_FAQCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;

    return _faqCategories
        .map((category) {
          final filteredItems = category.items
              .where((item) =>
                  item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  item.answer.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          return _FAQCategory(
            title: category.title,
            icon: category.icon,
            items: filteredItems,
          );
        })
        .where((category) => category.items.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Help & FAQ'),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(KFSpacing.space4),
            child: KFSearchField(
              controller: _searchController,
              hint: 'Search FAQ...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _expandedItems.clear();
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                  _expandedItems.clear();
                });
              },
            ),
          ),

          // FAQ list
          Expanded(
            child: _filteredCategories.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KFSpacing.space4,
                    ),
                    itemCount: _filteredCategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _filteredCategories.length) {
                        return _buildContactSection();
                      }
                      return _buildCategorySection(_filteredCategories[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return KFEmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      description: 'Try a different search term or contact support for help.',
    );
  }

  Widget _buildCategorySection(_FAQCategory category, int categoryIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: KFSpacing.space3),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KFColors.primary100,
                  borderRadius: KFRadius.radiusMd,
                ),
                child: Icon(
                  category.icon,
                  size: 18,
                  color: KFColors.primary600,
                ),
              ),
              const SizedBox(width: KFSpacing.space3),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeMd,
                  fontWeight: KFTypography.semibold,
                ),
              ),
            ],
          ),
        ),
        // FAQ items
        KFCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: category.items.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              final globalIndex = categoryIndex * 100 + itemIndex;
              final isExpanded = _expandedItems.contains(globalIndex);
              final isLast = itemIndex == category.items.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedItems.remove(globalIndex);
                        } else {
                          _expandedItems.add(globalIndex);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(KFSpacing.space4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.question,
                                  style: TextStyle(
                                    fontSize: KFTypography.fontSizeSm,
                                    fontWeight: isExpanded
                                        ? KFTypography.semibold
                                        : KFTypography.medium,
                                    color: isExpanded
                                        ? KFColors.primary700
                                        : KFColors.gray900,
                                  ),
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: KFSpacing.space3),
                                  Text(
                                    item.answer,
                                    style: const TextStyle(
                                      fontSize: KFTypography.fontSizeSm,
                                      color: KFColors.gray600,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: KFSpacing.space2),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: KFAnimation.fast,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: isExpanded
                                  ? KFColors.primary600
                                  : KFColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: KFSpacing.space4),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: KFSpacing.space4),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: KFSpacing.space3),
          child: Text(
            'Still need help?',
            style: TextStyle(
              fontSize: KFTypography.fontSizeMd,
              fontWeight: KFTypography.semibold,
            ),
          ),
        ),
        KFCard(
          child: Padding(
            padding: const EdgeInsets.all(KFSpacing.space4),
            child: Column(
              children: [
                const Text(
                  'Can\'t find what you\'re looking for? Our support team is here to help.',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: KFColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KFSpacing.space4),
                Row(
                  children: [
                    Expanded(
                      child: KFSecondaryButton(
                        label: 'Contact HR',
                        leadingIcon: Icons.support_agent,
                        onPressed: widget.onContactHR ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening HR contact...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: KFSpacing.space3),
                    Expanded(
                      child: KFPrimaryButton(
                        label: 'Report Issue',
                        leadingIcon: Icons.bug_report,
                        onPressed: widget.onReportIssue ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening issue reporter...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KFSpacing.space8),
      ],
    );
  }
}

class _FAQCategory {
  final String title;
  final IconData icon;
  final List<_FAQItem> items;

  const _FAQCategory({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class _FAQItem {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });
}
