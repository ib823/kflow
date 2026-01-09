# KERJAFLOW RESPONSIVE LAYOUT SYSTEM
## Every Screen Size, Every Device, Every Orientation

---

## 1. BREAKPOINT SYSTEM

### 1.1 Breakpoint Definitions

```dart
/// KerjaFlow Responsive Breakpoints
/// Based on device categories, not arbitrary pixel values
class KFBreakpoints {
  // Watch devices
  static const double watchMin = 0;
  static const double watchMax = 199;
  
  // Phone devices  
  static const double phoneSmallMin = 320;
  static const double phoneSmallMax = 359;
  static const double phoneMediumMin = 360;
  static const double phoneMediumMax = 389;
  static const double phoneLargeMin = 390;
  static const double phoneLargeMax = 427;
  static const double phoneXLMin = 428;
  static const double phoneXLMax = 599;
  
  // Tablet devices
  static const double tabletSmallMin = 600;
  static const double tabletSmallMax = 743;
  static const double tabletMediumMin = 744;
  static const double tabletMediumMax = 833;
  static const double tabletLargeMin = 834;
  static const double tabletLargeMax = 1023;
  
  // Desktop
  static const double desktopMin = 1024;
  static const double desktopMax = 1279;
  static const double desktopLargeMin = 1280;
  static const double desktopLargeMax = 1439;
  static const double desktopXLMin = 1440;
  static const double desktopXLMax = 1919;
  
  // Large displays
  static const double ultrawideMin = 1920;
  static const double ultrawideMax = 2559;
  static const double display4KMin = 2560;
  static const double display4KMax = 3839;
  static const double stadiumMin = 3840;
}
```

### 1.2 Device Category Detection

```dart
enum DeviceCategory {
  watch,
  phoneSmall,
  phone,
  phoneLarge,
  phoneXL,
  tabletSmall,
  tablet,
  tabletLarge,
  desktop,
  desktopLarge,
  desktopXL,
  ultrawide,
  display4K,
  stadium,
}

DeviceCategory getDeviceCategory(double width) {
  if (width < 200) return DeviceCategory.watch;
  if (width < 360) return DeviceCategory.phoneSmall;
  if (width < 390) return DeviceCategory.phone;
  if (width < 428) return DeviceCategory.phoneLarge;
  if (width < 600) return DeviceCategory.phoneXL;
  if (width < 744) return DeviceCategory.tabletSmall;
  if (width < 834) return DeviceCategory.tablet;
  if (width < 1024) return DeviceCategory.tabletLarge;
  if (width < 1280) return DeviceCategory.desktop;
  if (width < 1440) return DeviceCategory.desktopLarge;
  if (width < 1920) return DeviceCategory.desktopXL;
  if (width < 2560) return DeviceCategory.ultrawide;
  if (width < 3840) return DeviceCategory.display4K;
  return DeviceCategory.stadium;
}

// Simplified categories for layout decisions
enum LayoutCategory { compact, medium, expanded, large }

LayoutCategory getLayoutCategory(double width) {
  if (width < 600) return LayoutCategory.compact;    // Phone
  if (width < 840) return LayoutCategory.medium;     // Small tablet
  if (width < 1200) return LayoutCategory.expanded;  // Large tablet/small desktop
  return LayoutCategory.large;                        // Desktop+
}
```

---

## 2. LAYOUT PATTERNS

### 2.1 Navigation Patterns by Device

| Device Category | Primary Navigation | Secondary Navigation |
|-----------------|-------------------|---------------------|
| Watch | Single screen, swipe | None |
| Phone (all) | Bottom navigation bar | App bar |
| Tablet Portrait | Navigation rail | App bar |
| Tablet Landscape | Navigation rail + list | Top bar |
| Desktop | Side navigation drawer | Top bar |
| TV/Stadium | Focus-based side rail | None |

### 2.2 Content Layout Patterns

#### Compact Layout (< 600dp) - Phones
```
┌─────────────────────┐
│      App Bar        │
├─────────────────────┤
│                     │
│   Single Column     │
│      Content        │
│                     │
├─────────────────────┤
│   Bottom Nav Bar    │
└─────────────────────┘
```

#### Medium Layout (600-840dp) - Small Tablets
```
┌─────────────────────────────────┐
│           App Bar               │
├───────┬─────────────────────────┤
│       │                         │
│ Nav   │    Main Content         │
│ Rail  │    (1-2 columns)        │
│       │                         │
│       │                         │
└───────┴─────────────────────────┘
```

#### Expanded Layout (840-1200dp) - Large Tablets
```
┌─────────────────────────────────────────┐
│              Top Bar                    │
├───────┬───────────────┬─────────────────┤
│       │               │                 │
│ Nav   │  List Panel   │  Detail Panel   │
│ Rail  │  (Master)     │  (Detail)       │
│       │               │                 │
│       │               │                 │
└───────┴───────────────┴─────────────────┘
```

#### Large Layout (> 1200dp) - Desktop
```
┌───────────────────────────────────────────────────┐
│                    Top Bar                        │
├─────────┬─────────────────────────────────────────┤
│         │                                         │
│  Side   │                                         │
│  Nav    │         Content Area                    │
│  Drawer │         (Multi-column)                  │
│         │                                         │
│         │                                         │
└─────────┴─────────────────────────────────────────┘
```

---

## 3. RESPONSIVE GRID SYSTEM

### 3.1 Grid Configuration by Device

| Layout | Columns | Margins | Gutters |
|--------|---------|---------|---------|
| Compact (phone) | 4 | 16dp | 16dp |
| Medium (small tablet) | 8 | 24dp | 24dp |
| Expanded (large tablet) | 12 | 24dp | 24dp |
| Large (desktop) | 12 | 32dp | 32dp |
| Extra Large | 12 | 48dp | 32dp |

### 3.2 Responsive Grid Implementation

```dart
class KFResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = _getGridConfig(constraints.maxWidth);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: config.margin),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: config.columns,
              crossAxisSpacing: config.gutter,
              mainAxisSpacing: config.gutter,
              childAspectRatio: config.aspectRatio,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
  
  _GridConfig _getGridConfig(double width) {
    if (width < 600) {
      return _GridConfig(columns: 2, margin: 16, gutter: 12, aspectRatio: 1.0);
    } else if (width < 840) {
      return _GridConfig(columns: 3, margin: 24, gutter: 16, aspectRatio: 1.0);
    } else if (width < 1200) {
      return _GridConfig(columns: 4, margin: 24, gutter: 20, aspectRatio: 1.0);
    } else {
      return _GridConfig(columns: 5, margin: 32, gutter: 24, aspectRatio: 1.0);
    }
  }
}

class _GridConfig {
  final int columns;
  final double margin;
  final double gutter;
  final double aspectRatio;
  
  _GridConfig({
    required this.columns,
    required this.margin,
    required this.gutter,
    required this.aspectRatio,
  });
}
```

---

## 4. SPECIFIC SCREEN LAYOUTS

### 4.1 Dashboard Layout

#### Phone (Compact)
```
┌─────────────────────┐
│ Logo      🔔  👤    │
├─────────────────────┤
│ Good morning, Name! │
│ Date                │
├─────────────────────┤
│ [Quick Stats - Row] │
│ Leave │ Pending     │
├─────────────────────┤
│ [Payslip Card]      │
│ Net: RM X,XXX       │
├─────────────────────┤
│ [Recent Leave List] │
├─────────────────────┤
│ [Upcoming Holiday]  │
├─────────────────────┤
│ 🏠  📄  📅  🔔  👤  │
└─────────────────────┘
```

#### Tablet (Medium/Expanded)
```
┌────────────────────────────────────────────┐
│ Logo                          🔔  👤  ⚙️   │
├──────┬─────────────────────────────────────┤
│      │ Good morning, Name!                 │
│ 🏠   │ Date                                │
│      ├──────────────────┬──────────────────┤
│ 📄   │ [Quick Stats]    │ [Payslip Card]   │
│      │ Leave   Pending  │ Net: RM X,XXX    │
│ 📅   │ Approvals        │                  │
│      ├──────────────────┼──────────────────┤
│ 🔔   │ [Recent Leave]   │ [Holiday Card]   │
│      │ - Item 1         │ Thaipusam        │
│ 👤   │ - Item 2         │ 29 Jan 2026      │
│      │ - Item 3         │                  │
└──────┴──────────────────┴──────────────────┘
```

#### Desktop (Large)
```
┌──────────────────────────────────────────────────────────────────┐
│ Logo                    Search...              🔔  👤  ⚙️        │
├─────────────┬────────────────────────────────────────────────────┤
│             │                                                    │
│ 🏠 Home     │  Good morning, Name!                               │
│             │  Date                                               │
│ 📄 Payslip  │                                                    │
│             │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐│
│ 📅 Leave    │  │  Leave   │ │ Pending  │ │Approvals │ │Payroll ││
│             │  │    12    │ │    2     │ │    5     │ │  Done  ││
│ 🔔 Inbox    │  └──────────┘ └──────────┘ └──────────┘ └────────┘│
│             │                                                    │
│ 📁 Docs     │  ┌───────────────────────┐ ┌──────────────────────┐│
│             │  │ Latest Payslip        │ │ Upcoming Holiday     ││
│ 👤 Profile  │  │ December 2025         │ │ Thaipusam            ││
│             │  │ Net: RM 4,422.00      │ │ 29 January 2026      ││
│ ⚙️ Settings │  └───────────────────────┘ └──────────────────────┘│
│             │                                                    │
│             │  Recent Leave Requests                             │
│             │  ┌────────────────────────────────────────────────┐│
│             │  │ Annual  │ 2-3 Jan │ Approved │ Enc. Ali        ││
│             │  │ Medical │ 27 Dec  │ Approved │ Enc. Ali        ││
│             │  └────────────────────────────────────────────────┘│
└─────────────┴────────────────────────────────────────────────────┘
```

### 4.2 Payslip List Layout

#### Phone - 2 Column Grid
```
┌─────────────────────┐
│ ←  Payslips   2025▼ │
├─────────────────────┤
│ ┌─────┐  ┌─────┐   │
│ │ DEC │  │ NOV │   │
│ │4,422│  │4,422│   │
│ └─────┘  └─────┘   │
│ ┌─────┐  ┌─────┐   │
│ │ OCT │  │ SEP │   │
│ │4,422│  │4,500│   │
│ └─────┘  └─────┘   │
├─────────────────────┤
│ 🏠  📄  📅  🔔  👤  │
└─────────────────────┘
```

#### Tablet - 3-4 Column Grid
```
┌────────────────────────────────────────────┐
│ ←  Payslips                         2025 ▼ │
├──────┬─────────────────────────────────────┤
│      │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│ Nav  │ │ DEC  │ │ NOV  │ │ OCT  │ │ SEP  ││
│ Rail │ │4,422 │ │4,422 │ │4,422 │ │4,500 ││
│      │ └──────┘ └──────┘ └──────┘ └──────┘│
│      │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│      │ │ AUG  │ │ JUL  │ │ JUN  │ │ MAY  ││
│      │ │4,350 │ │4,350 │ │4,350 │ │4,200 ││
│      │ └──────┘ └──────┘ └──────┘ └──────┘│
└──────┴─────────────────────────────────────┘
```

#### Desktop - Table View Option
```
┌──────────────────────────────────────────────────────────────────┐
│ ←  Payslips                                  🔍 Search   2025 ▼  │
├─────────────┬────────────────────────────────────────────────────┤
│             │ ┌────────────────────────────────────────────────┐ │
│ 🏠 Home     │ │ Period    │ Gross    │ Deduct  │ Net     │ PDF │ │
│             │ ├───────────┼──────────┼─────────┼─────────┼─────┤ │
│ 📄 Payslip  │ │ Dec 2025  │ 5,000.00 │ 578.00  │ 4,422.00│  📥 │ │
│    ▶ List   │ │ Nov 2025  │ 5,000.00 │ 578.00  │ 4,422.00│  📥 │ │
│      Detail │ │ Oct 2025  │ 5,000.00 │ 578.00  │ 4,422.00│  📥 │ │
│             │ │ Sep 2025  │ 5,200.00 │ 600.00  │ 4,600.00│  📥 │ │
│ 📅 Leave    │ │ Aug 2025  │ 5,000.00 │ 578.00  │ 4,422.00│  📥 │ │
│             │ └────────────────────────────────────────────────┘ │
│ 🔔 Inbox    │                                                    │
│             │ ⬅️ Previous  Page 1 of 3  Next ➡️                  │
│ 👤 Profile  │                                                    │
└─────────────┴────────────────────────────────────────────────────┘
```

---

## 5. COMPONENT SCALING

### 5.1 Touch Targets by Device

| Device | Minimum | Recommended | Maximum |
|--------|---------|-------------|---------|
| Watch | 38dp | 44dp | 48dp |
| Phone | 44dp | 48dp | 56dp |
| Phone (gloves) | 56dp | 64dp | 72dp |
| Tablet | 44dp | 48dp | 56dp |
| Desktop (mouse) | 32dp | 40dp | 48dp |
| TV (remote) | 56dp | 64dp | 80dp |
| Stadium | 80dp | 96dp | 120dp |

### 5.2 Font Scaling by Device

| Device | Base | Small | Large | Display |
|--------|------|-------|-------|---------|
| Watch | 12sp | 10sp | 14sp | 18sp |
| Phone | 14sp | 12sp | 16sp | 24sp |
| Tablet | 16sp | 14sp | 18sp | 28sp |
| Desktop | 16sp | 14sp | 18sp | 32sp |
| TV | 24sp | 20sp | 28sp | 48sp |
| Stadium | 48sp | 36sp | 60sp | 96sp |

### 5.3 Spacing Scaling

```dart
class KFResponsiveSpacing {
  static double getSpacing(BuildContext context, SpacingToken token) {
    final width = MediaQuery.of(context).size.width;
    final multiplier = _getMultiplier(width);
    return _baseSpacing[token]! * multiplier;
  }
  
  static double _getMultiplier(double width) {
    if (width < 200) return 0.5;   // Watch
    if (width < 600) return 1.0;   // Phone
    if (width < 840) return 1.25;  // Small tablet
    if (width < 1200) return 1.5;  // Large tablet
    if (width < 1920) return 1.75; // Desktop
    if (width < 3840) return 2.0;  // Large desktop
    return 3.0;                     // Stadium
  }
  
  static const Map<SpacingToken, double> _baseSpacing = {
    SpacingToken.xxs: 2,
    SpacingToken.xs: 4,
    SpacingToken.sm: 8,
    SpacingToken.md: 16,
    SpacingToken.lg: 24,
    SpacingToken.xl: 32,
    SpacingToken.xxl: 48,
  };
}

enum SpacingToken { xxs, xs, sm, md, lg, xl, xxl }
```

---

## 6. ORIENTATION HANDLING

### 6.1 Portrait vs Landscape

```dart
class KFOrientationLayout extends StatelessWidget {
  final Widget portraitLayout;
  final Widget landscapeLayout;
  
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return landscapeLayout;
        }
        return portraitLayout;
      },
    );
  }
}
```

### 6.2 Specific Orientation Rules

| Screen | Portrait | Landscape |
|--------|----------|-----------|
| Login | Single column, centered | Two column (image + form) |
| Dashboard | Vertical scroll | Horizontal cards |
| Payslip List | 2 column grid | 3-4 column grid |
| Payslip Detail | Full screen | Side panel option |
| Leave Calendar | Vertical month | Week view |
| Approval List | List view | Table view |

---

## 7. SAFE AREA HANDLING

### 7.1 Platform-Specific Safe Areas

```dart
class KFSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        top: top ? mediaQuery.viewPadding.top : 0,
        bottom: bottom ? mediaQuery.viewPadding.bottom : 0,
        left: left ? mediaQuery.viewPadding.left : 0,
        right: right ? mediaQuery.viewPadding.right : 0,
      ),
      child: child,
    );
  }
}
```

### 7.2 Safe Area Values by Device

| Device | Top | Bottom | Left | Right |
|--------|-----|--------|------|-------|
| iPhone SE | 20 | 0 | 0 | 0 |
| iPhone 14 | 47 | 34 | 0 | 0 |
| iPhone 14 Pro | 59 | 34 | 0 | 0 |
| Android (standard) | 24 | 0 | 0 | 0 |
| Android (cutout) | 48 | 0 | 0 | 0 |
| Android (gesture) | 24 | 20 | 0 | 0 |
| iPad | 20 | 0 | 0 | 0 |
| iPad (home indicator) | 20 | 20 | 0 | 0 |

---

## 8. MASTER-DETAIL PATTERN

### 8.1 Implementation

```dart
class KFMasterDetail extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final double masterWidth;
  
  const KFMasterDetail({
    required this.master,
    this.detail,
    this.masterWidth = 320,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Single pane for compact
        if (constraints.maxWidth < 600) {
          return master;
        }
        
        // Master-detail for expanded
        return Row(
          children: [
            SizedBox(
              width: masterWidth,
              child: master,
            ),
            VerticalDivider(width: 1),
            Expanded(
              child: detail ?? _EmptyDetailPlaceholder(),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 9. RESPONSIVE IMAGES

### 9.1 Image Asset Requirements

| Device Density | Multiplier | Folder |
|----------------|------------|--------|
| mdpi | 1.0x | assets/images/ |
| hdpi | 1.5x | assets/images/1.5x/ |
| xhdpi | 2.0x | assets/images/2.0x/ |
| xxhdpi | 3.0x | assets/images/3.0x/ |
| xxxhdpi | 4.0x | assets/images/4.0x/ |

### 9.2 Responsive Image Widget

```dart
class KFResponsiveImage extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    return Image.asset(
      _getAssetPath(pixelRatio),
      width: width,
      height: height,
      fit: fit,
    );
  }
  
  String _getAssetPath(double pixelRatio) {
    if (pixelRatio >= 4) return 'assets/images/4.0x/$assetName';
    if (pixelRatio >= 3) return 'assets/images/3.0x/$assetName';
    if (pixelRatio >= 2) return 'assets/images/2.0x/$assetName';
    if (pixelRatio >= 1.5) return 'assets/images/1.5x/$assetName';
    return 'assets/images/$assetName';
  }
}
```

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
