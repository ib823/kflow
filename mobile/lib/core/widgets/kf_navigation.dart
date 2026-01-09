import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'kf_status.dart';

/// Bottom navigation bar item data
class KFNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const KFNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// Bottom navigation bar
class KFBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<KFNavItem> items;

  const KFBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: KFColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.badgeCount > 0)
                        KFBadge(
                          count: item.badgeCount,
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? KFColors.primary600
                                : KFColors.gray500,
                            size: KFIconSizes.lg,
                          ),
                        )
                      else
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? KFColors.primary600
                              : KFColors.gray500,
                          size: KFIconSizes.lg,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: KFTypography.fontSizeXs,
                          fontWeight: isSelected
                              ? KFTypography.medium
                              : KFTypography.regular,
                          color: isSelected
                              ? KFColors.primary600
                              : KFColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// App bar with standard styling
class KFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final VoidCallback? onBack;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const KFAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBack = false,
    this.onBack,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// Section header
class KFSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const KFSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(
      horizontal: KFSpacing.space4,
      vertical: KFSpacing.space3,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeMd,
              fontWeight: KFTypography.semibold,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: KFTypography.fontSizeSm,
                  color: KFColors.primary600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// List tile with KerjaFlow styling
class KFListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets? padding;

  const KFListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: padding ?? KFSpacing.listItemPadding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: KFSpacing.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KFTypography.fontSizeBase,
                        fontWeight: KFTypography.medium,
                        color: enabled ? KFColors.gray900 : KFColors.gray400,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          color: enabled ? KFColors.gray600 : KFColors.gray400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: KFSpacing.space3),
                trailing!,
              ] else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: enabled ? KFColors.gray400 : KFColors.gray300,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab bar with KerjaFlow styling
class KFTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final bool isScrollable;

  const KFTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}

/// Breadcrumb navigation
class KFBreadcrumb extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int>? onItemTap;

  const KFBreadcrumb({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isLast ? null : () => onItemTap?.call(index),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: isLast ? KFColors.gray900 : KFColors.primary600,
                    fontWeight:
                        isLast ? KFTypography.medium : KFTypography.regular,
                  ),
                ),
              ),
              if (!isLast) ...[
                const SizedBox(width: KFSpacing.space2),
                const Icon(
                  Icons.chevron_right,
                  size: KFIconSizes.sm,
                  color: KFColors.gray400,
                ),
                const SizedBox(width: KFSpacing.space2),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}
