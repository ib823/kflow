import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.receipt_long,
      title: 'View Payslips',
      description:
          'Access your payslips anytime, anywhere. View earnings, deductions, and download PDF copies.',
      color: KFColors.primary600,
    ),
    _OnboardingPage(
      icon: Icons.calendar_today,
      title: 'Manage Leave',
      description:
          'Apply for leave, check balances, and track approval status all in one place.',
      color: KFColors.success600,
    ),
    _OnboardingPage(
      icon: Icons.notifications,
      title: 'Stay Updated',
      description:
          'Get instant notifications for payslip releases, leave approvals, and company announcements.',
      color: KFColors.secondary500,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: KFAnimation.slow,
        curve: KFAnimation.easeInOut,
      );
    } else {
      widget.onComplete?.call();
    }
  }

  void _onSkip() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(KFSpacing.space4),
                child: KFTextButton(
                  label: 'Skip',
                  onPressed: _onSkip,
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: KFSpacing.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: KFSpacing.space8),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: KFTypography.fontSize2xl,
                            fontWeight: KFTypography.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: KFSpacing.space4),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: KFTypography.fontSizeMd,
                            color: KFColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: KFAnimation.fast,
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? KFColors.primary600
                        : KFColors.gray300,
                    borderRadius: KFRadius.radiusFull,
                  ),
                );
              }),
            ),
            const SizedBox(height: KFSpacing.space8),
            // Next/Get Started button
            Padding(
              padding: KFSpacing.screenPadding,
              child: KFPrimaryButton(
                label:
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: _onNext,
                trailingIcon: Icons.arrow_forward,
              ),
            ),
            const SizedBox(height: KFSpacing.space6),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
