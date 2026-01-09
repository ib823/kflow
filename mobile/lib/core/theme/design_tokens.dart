/// KerjaFlow Design Tokens v5.0
/// Single source of truth for ALL design values
///
/// RULE: NEVER use raw values in widgets - always reference these tokens
/// RULE: Every color, spacing, font, shadow, animation comes from here
library design_tokens;

import 'package:flutter/material.dart';

// ============================================================================
// BRAND COLORS
// ============================================================================

abstract class KFColors {
  KFColors._();

  // Primary Blue Palette - "KerjaFlow Blue"
  static const Color primary50 = Color(0xFFEBF5FB);
  static const Color primary100 = Color(0xFFD4E6F1);
  static const Color primary200 = Color(0xFF85C1E9);
  static const Color primary300 = Color(0xFF5DADE2);
  static const Color primary400 = Color(0xFF2E86AB);
  static const Color primary500 = Color(0xFF2471A3);
  static const Color primary600 = Color(0xFF1A5276); // DEFAULT
  static const Color primary700 = Color(0xFF145470);
  static const Color primary800 = Color(0xFF0F4460);
  static const Color primary900 = Color(0xFF0D3B50);

  // Secondary Gold Palette - "KerjaFlow Gold"
  static const Color secondary50 = Color(0xFFFEF9E7);
  static const Color secondary100 = Color(0xFFFCF3CF);
  static const Color secondary200 = Color(0xFFFAE5A0);
  static const Color secondary300 = Color(0xFFF9E79F);
  static const Color secondary400 = Color(0xFFF7B731);
  static const Color secondary500 = Color(0xFFF39C12); // DEFAULT
  static const Color secondary600 = Color(0xFFD68910);
  static const Color secondary700 = Color(0xFFB9770E);

  // Semantic: Success
  static const Color success50 = Color(0xFFEAFAF1);
  static const Color success100 = Color(0xFFD5F5E3);
  static const Color success200 = Color(0xFFABEBC6);
  static const Color success500 = Color(0xFF2ECC71);
  static const Color success600 = Color(0xFF27AE60); // DEFAULT
  static const Color success700 = Color(0xFF1E8449);

  // Semantic: Warning
  static const Color warning50 = Color(0xFFFEF9E7);
  static const Color warning100 = Color(0xFFFCF3CF);
  static const Color warning200 = Color(0xFFFAE5A0);
  static const Color warning500 = Color(0xFFF5B041);
  static const Color warning600 = Color(0xFFF39C12); // DEFAULT
  static const Color warning700 = Color(0xFFB9770E);

  // Semantic: Error
  static const Color error50 = Color(0xFFFDEDEC);
  static const Color error100 = Color(0xFFF5B7B1);
  static const Color error200 = Color(0xFFF1948A);
  static const Color error500 = Color(0xFFE74C3C);
  static const Color error600 = Color(0xFFC0392B); // DEFAULT
  static const Color error700 = Color(0xFF922B21);

  // Semantic: Info
  static const Color info50 = Color(0xFFEBF5FB);
  static const Color info100 = Color(0xFFD4E6F1);
  static const Color info200 = Color(0xFFA9CCE3);
  static const Color info500 = Color(0xFF3498DB);
  static const Color info600 = Color(0xFF2980B9); // DEFAULT
  static const Color info700 = Color(0xFF1F618D);

  // Neutral Grays
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF0F0F3);
  static const Color gray200 = Color(0xFFE0E0E5);
  static const Color gray300 = Color(0xFFC4C4CC);
  static const Color gray400 = Color(0xFFA8A8B3);
  static const Color gray500 = Color(0xFF8E8E9A);
  static const Color gray600 = Color(0xFF6B6B7B);
  static const Color gray700 = Color(0xFF4A4A5A);
  static const Color gray800 = Color(0xFF2D2D44);
  static const Color gray900 = Color(0xFF1A1A2E);
  static const Color black = Color(0xFF000000);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceElevated = Color(0xFF2D2D44);
  static const Color darkBorder = Color(0xFF3D3D54);

  // Leave Type Colors (for visual distinction)
  static const Color leaveAnnual = Color(0xFF27AE60);
  static const Color leaveMedical = Color(0xFFE74C3C);
  static const Color leaveEmergency = Color(0xFFF39C12);
  static const Color leaveUnpaid = Color(0xFF8E8E9A);
  static const Color leaveMaternity = Color(0xFFE91E63);
  static const Color leavePaternity = Color(0xFF2196F3);
  static const Color leaveCompassionate = Color(0xFF9C27B0);
  static const Color leaveReplacement = Color(0xFF00BCD4);
  static const Color leaveHajj = Color(0xFF795548);
  static const Color leaveMarriage = Color(0xFFFF5722);

  // Overlay colors
  static const Color overlay50 = Color(0x80000000);
  static const Color overlay25 = Color(0x40000000);
  static const Color overlayLight = Color(0x1A000000);

  /// Get leave type color by leave type string
  static Color getLeaveTypeColor(String leaveType) {
    switch (leaveType.toLowerCase()) {
      case 'annual':
        return leaveAnnual;
      case 'medical':
      case 'sick':
        return leaveMedical;
      case 'emergency':
        return leaveEmergency;
      case 'unpaid':
        return leaveUnpaid;
      case 'maternity':
        return leaveMaternity;
      case 'paternity':
        return leavePaternity;
      case 'compassionate':
        return leaveCompassionate;
      case 'replacement':
        return leaveReplacement;
      case 'hajj':
        return leaveHajj;
      case 'marriage':
        return leaveMarriage;
      default:
        return gray500;
    }
  }
}

// ============================================================================
// TYPOGRAPHY
// ============================================================================

abstract class KFTypography {
  KFTypography._();

  // Font Families
  static const String fontFamily = 'PlusJakartaSans';
  static const String fontFamilyFallback = 'Inter';
  static const String fontFamilyMono = 'JetBrainsMono';

  // Language-specific fonts
  static const String fontFamilyArabic = 'IBMPlexSansArabic'; // Jawi
  static const String fontFamilyThai = 'NotoSansThai';
  static const String fontFamilyChinese = 'NotoSansSC';
  static const String fontFamilyTamil = 'NotoSansTamil';
  static const String fontFamilyKhmer = 'NotoSansKhmer';
  static const String fontFamilyMyanmar = 'NotoSansMyanmar';
  static const String fontFamilyBengali = 'NotoSansBengali';
  static const String fontFamilyVietnamese = 'NotoSans'; // Latin extended
  static const String fontFamilyDevanagari = 'NotoSansDevanagari'; // Nepali

  // Font Sizes (in logical pixels)
  static const double fontSizeXxs = 8;
  static const double fontSizeXs = 10;
  static const double fontSizeSm = 12;
  static const double fontSizeBase = 14;
  static const double fontSizeMd = 16;
  static const double fontSizeLg = 18;
  static const double fontSizeXl = 20;
  static const double fontSize2xl = 24;
  static const double fontSize3xl = 30;
  static const double fontSize4xl = 36;
  static const double fontSize5xl = 48;
  static const double fontSize6xl = 60;

  // Font Weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Line Heights (multipliers)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  static const double lineHeightLoose = 2.0;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;
}

// ============================================================================
// SPACING (8-point grid system)
// ============================================================================

abstract class KFSpacing {
  KFSpacing._();

  static const double space0 = 0;
  static const double space0_5 = 2;
  static const double space1 = 4;
  static const double space1_5 = 6;
  static const double space2 = 8;
  static const double space2_5 = 10;
  static const double space3 = 12;
  static const double space3_5 = 14;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 28;
  static const double space8 = 32;
  static const double space9 = 36;
  static const double space10 = 40;
  static const double space11 = 44;
  static const double space12 = 48;
  static const double space14 = 56;
  static const double space16 = 64;
  static const double space20 = 80;
  static const double space24 = 96;
  static const double space28 = 112;
  static const double space32 = 128;

  // Common padding presets
  static const EdgeInsets screenPadding = EdgeInsets.all(space4);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: space4);
  static const EdgeInsets cardPadding = EdgeInsets.all(space4);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(space3);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: space4, vertical: space3);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: space6, vertical: space3);
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: space4, vertical: space3);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: space3, vertical: space1);
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

abstract class KFRadius {
  KFRadius._();

  // Raw values
  static const double none = 0;
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 9999;

  // BorderRadius presets
  static final BorderRadius radiusNone = BorderRadius.circular(none);
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusXxxl = BorderRadius.circular(xxxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // Special shapes
  static final BorderRadius radiusTop = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
  static final BorderRadius radiusBottom = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );
}

// ============================================================================
// SHADOWS / ELEVATION
// ============================================================================

abstract class KFShadows {
  KFShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 10),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      offset: Offset(0, 20),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 10,
      offset: Offset(0, 8),
      spreadRadius: -5,
    ),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 50,
      offset: Offset(0, 25),
      spreadRadius: -12,
    ),
  ];

  // Colored shadows for emphasis
  static List<BoxShadow> get primary => [
        BoxShadow(
          color: KFColors.primary600.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get success => [
        BoxShadow(
          color: KFColors.success600.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get error => [
        BoxShadow(
          color: KFColors.error600.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// ============================================================================
// TOUCH TARGETS (WCAG 2.2 AA Compliance)
// ============================================================================

abstract class KFTouchTargets {
  KFTouchTargets._();

  /// WCAG 2.2 minimum (44x44)
  static const double minimum = 44;

  /// Recommended for comfort (48x48)
  static const double comfortable = 48;

  /// Large for accessibility or gloves (56x56)
  static const double large = 56;

  /// Extra large for TV/Stadium (64x64)
  static const double extraLarge = 64;

  /// Maximum for kiosk/outdoor (72x72)
  static const double maximum = 72;

  /// Minimum spacing between touch targets
  static const double minSpacing = 8;
}

// ============================================================================
// ANIMATION
// ============================================================================

abstract class KFAnimation {
  KFAnimation._();

  // Durations
  static const Duration instant = Duration.zero;
  static const Duration fastest = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);

  // Curves - Standard
  static const Curve linear = Curves.linear;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  // Curves - Emphasized
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  // Curves - Playful
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve overshoot = Cubic(0.34, 1.56, 0.64, 1.0);
}

// ============================================================================
// BREAKPOINTS
// ============================================================================

abstract class KFBreakpoints {
  KFBreakpoints._();

  // Watch
  static const double watchSmall = 162; // Apple Watch 38mm
  static const double watchMedium = 184; // Apple Watch 42mm
  static const double watchLarge = 198; // Apple Watch 45mm

  // Phone
  static const double phoneSmall = 320; // iPhone SE, small Android
  static const double phone = 360; // Standard Android
  static const double phoneMedium = 375; // iPhone 12 mini
  static const double phoneLarge = 390; // iPhone 12/13/14
  static const double phoneXL = 428; // iPhone 12/13/14 Pro Max

  // Tablet
  static const double tabletSmall = 600; // Small tablet, large phone landscape
  static const double tablet = 768; // iPad Mini
  static const double tabletLarge = 834; // iPad Air
  static const double tabletXL = 1024; // iPad Pro 11"

  // Desktop
  static const double desktop = 1280; // Standard desktop
  static const double desktopLarge = 1440; // Large desktop
  static const double desktopXL = 1920; // Full HD

  // Large displays
  static const double ultrawide = 2560; // 2K/QHD
  static const double display4K = 3840; // 4K UHD
  static const double stadium = 7680; // 8K
}

// ============================================================================
// ICON SIZES
// ============================================================================

abstract class KFIconSizes {
  KFIconSizes._();

  static const double xxs = 10;
  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;
}

// ============================================================================
// AVATAR SIZES
// ============================================================================

abstract class KFAvatarSizes {
  KFAvatarSizes._();

  static const double xxs = 20;
  static const double xs = 24;
  static const double sm = 32;
  static const double md = 40;
  static const double lg = 48;
  static const double xl = 64;
  static const double xxl = 80;
  static const double xxxl = 96;
  static const double huge = 128;
}

// ============================================================================
// Z-INDEX LAYERS
// ============================================================================

abstract class KFZIndex {
  KFZIndex._();

  static const int base = 0;
  static const int dropdown = 1000;
  static const int sticky = 1020;
  static const int fixed = 1030;
  static const int modalBackdrop = 1040;
  static const int modal = 1050;
  static const int popover = 1060;
  static const int tooltip = 1070;
  static const int toast = 1080;
}

// ============================================================================
// DEVICE CATEGORY HELPER
// ============================================================================

enum DeviceCategory {
  watch,
  phoneSmall,
  phone,
  phoneLarge,
  tablet,
  tabletLarge,
  desktop,
  desktopLarge,
  tv,
  stadium,
}

DeviceCategory getDeviceCategory(double width) {
  if (width < 200) return DeviceCategory.watch;
  if (width < 360) return DeviceCategory.phoneSmall;
  if (width < 428) return DeviceCategory.phone;
  if (width < 600) return DeviceCategory.phoneLarge;
  if (width < 840) return DeviceCategory.tablet;
  if (width < 1024) return DeviceCategory.tabletLarge;
  if (width < 1440) return DeviceCategory.desktop;
  if (width < 1920) return DeviceCategory.desktopLarge;
  if (width < 3840) return DeviceCategory.tv;
  return DeviceCategory.stadium;
}

bool isPhone(double width) => width < KFBreakpoints.tabletSmall;
bool isTablet(double width) =>
    width >= KFBreakpoints.tabletSmall && width < KFBreakpoints.desktop;
bool isDesktop(double width) => width >= KFBreakpoints.desktop;
bool isLargeScreen(double width) => width >= KFBreakpoints.desktopXL;

// ============================================================================
// SAFE AREAS
// ============================================================================

abstract class KFSafeAreas {
  KFSafeAreas._();

  // iOS Safe Areas
  static const double iosTop = 44;
  static const double iosTopDynamic = 59; // With Dynamic Island
  static const double iosBottom = 34; // Home indicator

  // Android Safe Areas
  static const double androidTop = 24;
  static const double androidTopLarge = 48; // With camera cutout
  static const double androidBottom = 0;

  // Bottom Navigation Heights
  static const double bottomNavIos = 83; // 49 + 34 home indicator
  static const double bottomNavAndroid = 56;
  static const double bottomNavAndroidGesture = 80; // With gesture bar
}

// ============================================================================
// STATUS BAR HEIGHTS
// ============================================================================

abstract class KFStatusBar {
  KFStatusBar._();

  static const double ios = 44;
  static const double iosDynamic = 59;
  static const double android = 24;
  static const double androidLarge = 48;
}
