import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Full screen loading overlay
class KFLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const KFLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: KFColors.overlay25,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(KFColors.primary600),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: KFSpacing.space4),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: KFColors.white,
                        fontSize: KFTypography.fontSizeBase,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loading placeholder
class KFSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const KFSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = KFRadius.md,
    this.isCircle = false,
  });

  @override
  State<KFSkeleton> createState() => _KFSkeletonState();
}

class _KFSkeletonState extends State<KFSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                KFColors.gray200,
                KFColors.gray100,
                KFColors.gray200,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for list items
class KFSkeletonListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int lines;

  const KFSkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KFSpacing.space4,
        vertical: KFSpacing.space3,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const KFSkeleton(width: 40, height: 40, isCircle: true),
            const SizedBox(width: KFSpacing.space3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < lines - 1 ? KFSpacing.space2 : 0,
                  ),
                  child: KFSkeleton(
                    width: index == 0 ? double.infinity : 120,
                    height: index == 0 ? 16 : 12,
                  ),
                );
              }),
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: KFSpacing.space3),
            const KFSkeleton(width: 60, height: 24),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for cards
class KFSkeletonCard extends StatelessWidget {
  final double? height;

  const KFSkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: KFSpacing.cardPadding,
      decoration: BoxDecoration(
        color: KFColors.white,
        borderRadius: KFRadius.radiusXl,
        border: Border.all(color: KFColors.gray200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KFSkeleton(width: 40, height: 40, borderRadius: KFRadius.md),
              SizedBox(width: KFSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KFSkeleton(width: 120, height: 16),
                    SizedBox(height: KFSpacing.space1),
                    KFSkeleton(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          KFSkeleton(height: 24),
          SizedBox(height: KFSpacing.space2),
          KFSkeleton(height: 8),
        ],
      ),
    );
  }
}

/// Pull to refresh wrapper
class KFRefreshable extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const KFRefreshable({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? KFColors.primary600,
      backgroundColor: KFColors.white,
      displacement: 40,
      strokeWidth: 2.5,
      child: child,
    );
  }
}

/// Inline loading indicator
class KFLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const KFLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color ?? KFColors.primary600),
      ),
    );
  }
}

/// Loading state for entire screen
class KFLoadingScreen extends StatelessWidget {
  final String? message;

  const KFLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(KFColors.primary600),
            ),
            if (message != null) ...[
              const SizedBox(height: KFSpacing.space4),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeBase,
                  color: KFColors.gray600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
