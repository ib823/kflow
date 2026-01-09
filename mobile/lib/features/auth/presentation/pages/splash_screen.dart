import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Splash screen shown on app launch
/// Displays logo, app name, and loading indicator
class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? KFColors.darkBackground : KFColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo and app name
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo placeholder
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: KFColors.primary600,
                            borderRadius: KFRadius.radiusXxl,
                          ),
                          child: const Icon(
                            Icons.work_outline,
                            size: 64,
                            color: KFColors.white,
                          ),
                        ),
                        const SizedBox(height: KFSpacing.space6),
                        Text(
                          'KerjaFlow',
                          style: TextStyle(
                            fontSize: KFTypography.fontSize4xl,
                            fontWeight: KFTypography.bold,
                            color: KFColors.primary600,
                            fontFamily: KFTypography.fontFamily,
                          ),
                        ),
                        const SizedBox(height: KFSpacing.space2),
                        Text(
                          'Workforce Management',
                          style: TextStyle(
                            fontSize: KFTypography.fontSizeBase,
                            color: KFColors.gray500,
                            fontFamily: KFTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            // Loading indicator
            const _LoadingDots(),
            const Spacer(),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: KFSpacing.space6),
              child: Text(
                'Powered by KerjaFlow',
                style: TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.gray400,
                  fontFamily: KFTypography.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final delay = index * 0.15;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (value < 0.5)
                ? value * 2
                : 2 - value * 2;

            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KFColors.primary400.withOpacity(opacity.clamp(0.3, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}
