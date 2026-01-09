import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Responsive layout builder that adapts to screen size
class KFResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget? phoneSmall;
  final Widget? phoneLarge;
  final Widget? tablet;
  final Widget? tabletLarge;
  final Widget? desktop;
  final Widget? desktopLarge;
  final Widget? watch;
  final Widget? tv;

  const KFResponsiveLayout({
    super.key,
    required this.phone,
    this.phoneSmall,
    this.phoneLarge,
    this.tablet,
    this.tabletLarge,
    this.desktop,
    this.desktopLarge,
    this.watch,
    this.tv,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final category = getDeviceCategory(width);

        switch (category) {
          case DeviceCategory.watch:
            return watch ?? phone;
          case DeviceCategory.phoneSmall:
            return phoneSmall ?? phone;
          case DeviceCategory.phone:
            return phone;
          case DeviceCategory.phoneLarge:
            return phoneLarge ?? phone;
          case DeviceCategory.tablet:
            return tablet ?? phone;
          case DeviceCategory.tabletLarge:
            return tabletLarge ?? tablet ?? phone;
          case DeviceCategory.desktop:
            return desktop ?? tablet ?? phone;
          case DeviceCategory.desktopLarge:
            return desktopLarge ?? desktop ?? tablet ?? phone;
          case DeviceCategory.tv:
          case DeviceCategory.stadium:
            return tv ?? desktop ?? tablet ?? phone;
        }
      },
    );
  }
}

/// Responsive value helper - returns different values based on screen size
class KFResponsiveValue<T> {
  final T phone;
  final T? tablet;
  final T? desktop;

  const KFResponsiveValue({
    required this.phone,
    this.tablet,
    this.desktop,
  });

  T resolve(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= KFBreakpoints.desktop) {
      return desktop ?? tablet ?? phone;
    }
    if (width >= KFBreakpoints.tabletSmall) {
      return tablet ?? phone;
    }
    return phone;
  }
}

/// Extension for easy responsive value access
extension ResponsiveContext on BuildContext {
  /// Get device category
  DeviceCategory get deviceCategory {
    final width = MediaQuery.of(this).size.width;
    return getDeviceCategory(width);
  }

  /// Check if phone
  bool get isPhone =>
      MediaQuery.of(this).size.width < KFBreakpoints.tabletSmall;

  /// Check if tablet
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= KFBreakpoints.tabletSmall && width < KFBreakpoints.desktop;
  }

  /// Check if desktop
  bool get isDesktop => MediaQuery.of(this).size.width >= KFBreakpoints.desktop;

  /// Check if large screen (desktop+)
  bool get isLargeScreen =>
      MediaQuery.of(this).size.width >= KFBreakpoints.desktopXL;

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    if (isDesktop) return const EdgeInsets.all(KFSpacing.space8);
    if (isTablet) return const EdgeInsets.all(KFSpacing.space6);
    return const EdgeInsets.all(KFSpacing.space4);
  }

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: KFSpacing.space8);
    }
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: KFSpacing.space6);
    }
    return const EdgeInsets.symmetric(horizontal: KFSpacing.space4);
  }
}

/// Responsive grid that adapts column count
class KFResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? phoneColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double childAspectRatio;

  const KFResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = KFSpacing.space3,
    this.runSpacing = KFSpacing.space3,
    this.phoneColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width >= KFBreakpoints.desktop) {
      return desktopColumns ?? 4;
    }
    if (width >= KFBreakpoints.tabletSmall) {
      return tabletColumns ?? 3;
    }
    return phoneColumns ?? 2;
  }
}

/// Master-detail layout for tablets and desktops
class KFMasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final bool showDetail;

  const KFMasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.masterWidth = 320,
    this.showDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= KFBreakpoints.tabletSmall;

    if (!isWide) {
      // Phone: show master or detail based on state
      return showDetail && detail != null ? detail! : master;
    }

    // Tablet/Desktop: side-by-side
    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: master,
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: detail ??
              const Center(
                child: Text('Select an item'),
              ),
        ),
      ],
    );
  }
}

/// Orientation-aware layout
class KFOrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const KFOrientationLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// Safe area wrapper with platform awareness
class KFSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  const KFSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: child,
    );
  }
}

/// Sliver-based responsive grid for use in CustomScrollView
class KFSliverResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int? phoneColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double childAspectRatio;

  const KFSliverResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = KFSpacing.space3,
    this.phoneColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.crossAxisExtent);

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width >= KFBreakpoints.desktop) return desktopColumns ?? 4;
    if (width >= KFBreakpoints.tabletSmall) return tabletColumns ?? 3;
    return phoneColumns ?? 2;
  }
}

/// Adaptive scaffold that uses navigation rail on tablets/desktop
class KFAdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const KFAdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= KFBreakpoints.tabletSmall;

    if (isWide) {
      // Tablet/Desktop: Navigation rail
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Phone: Bottom navigation
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
