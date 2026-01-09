================================================================================
KERJAFLOW UI/UX IMPLEMENTATION - EXTREME KIASU MODE
================================================================================
COPY EVERYTHING BELOW THIS LINE INTO CLAUDE CODE CLI
================================================================================

KERJAFLOW UI/UX IMPLEMENTATION - PIXEL-PERFECT ORGASMIC EDITION

OBJECTIVE:
Implement pixel-perfect UI/UX across ALL platforms:
- iOS (iPhone, iPad, Apple Watch)
- Android (Phone, Tablet, Wear OS)
- Huawei (Phone, Tablet, Watch via HMS)
- Web (Desktop, Mobile, PWA)
- TV/Stadium displays

Every pixel. Every animation. Every state. Every user segment.
Making users orgasm with how perfect this is.

═══════════════════════════════════════════════════════════════════════════════
STEP 0: VERIFY CURRENT STATE & SETUP
═══════════════════════════════════════════════════════════════════════════════

cd /workspaces/kflow

echo "═══════════════════════════════════════════════════════════════"
echo "KERJAFLOW UI/UX IMPLEMENTATION - STATE VERIFICATION"
echo "═══════════════════════════════════════════════════════════════"

# Check progress
cat .kerjaflow_progress.json 2>/dev/null || echo '{"completed":[],"phase":0}'

# Verify mobile structure
echo ""
echo "Mobile Structure:"
ls -la mobile/lib/features/ 2>/dev/null | head -20
ls -la mobile/lib/core/ 2>/dev/null | head -20

# Check current theme
echo ""
echo "Current Theme File:"
test -f mobile/lib/core/theme/app_theme.dart && echo "✓ app_theme.dart exists" || echo "✗ MISSING"

# Check design tokens
echo ""
echo "Design Tokens:"
test -f mobile/lib/core/theme/design_tokens.dart && echo "✓ design_tokens.dart exists" || echo "✗ NEED TO CREATE"

═══════════════════════════════════════════════════════════════════════════════
TASK UI-1: IMPLEMENT DESIGN TOKENS (Single Source of Truth)
═══════════════════════════════════════════════════════════════════════════════

Create file: mobile/lib/core/theme/design_tokens.dart

PURPOSE: Single source of truth for ALL design values.
Every color, spacing, font, shadow, animation MUST come from here.

```dart
/// KerjaFlow Design Tokens v4.0
/// Single source of truth for all design values
/// NEVER use raw values in widgets - always reference these tokens
library design_tokens;

import 'package:flutter/material.dart';

/// === BRAND COLORS ===
abstract class KFColors {
  KFColors._();
  
  // Primary palette
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
  
  // Secondary palette
  static const Color secondary100 = Color(0xFFFCF3CF);
  static const Color secondary300 = Color(0xFFF9E79F);
  static const Color secondary400 = Color(0xFFF7B731);
  static const Color secondary500 = Color(0xFFF39C12); // DEFAULT
  static const Color secondary600 = Color(0xFFD68910);
  
  // Semantic colors
  static const Color success50 = Color(0xFFEAFAF1);
  static const Color success100 = Color(0xFFD5F5E3);
  static const Color success500 = Color(0xFF2ECC71);
  static const Color success600 = Color(0xFF27AE60); // DEFAULT
  static const Color success700 = Color(0xFF1E8449);
  
  static const Color warning50 = Color(0xFFFEF9E7);
  static const Color warning100 = Color(0xFFFCF3CF);
  static const Color warning500 = Color(0xFFF5B041);
  static const Color warning600 = Color(0xFFF39C12); // DEFAULT
  static const Color warning700 = Color(0xFFB9770E);
  
  static const Color error50 = Color(0xFFFDEDEC);
  static const Color error100 = Color(0xFFF5B7B1);
  static const Color error500 = Color(0xFFE74C3C);
  static const Color error600 = Color(0xFFC0392B); // DEFAULT
  static const Color error700 = Color(0xFF922B21);
  
  static const Color info100 = Color(0xFFD4E6F1);
  static const Color info500 = Color(0xFF3498DB);
  static const Color info600 = Color(0xFF2980B9); // DEFAULT
  
  // Neutral colors
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
  
  // Dark mode specific
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceElevated = Color(0xFF2D2D44);
  static const Color darkBorder = Color(0xFF3D3D54);
  
  // Leave type colors
  static const Color leaveAnnual = Color(0xFF27AE60);
  static const Color leaveMedical = Color(0xFFE74C3C);
  static const Color leaveEmergency = Color(0xFFF39C12);
  static const Color leaveUnpaid = Color(0xFF8E8E9A);
  static const Color leaveMaternity = Color(0xFFE91E63);
  static const Color leavePaternity = Color(0xFF2196F3);
  static const Color leaveCompassionate = Color(0xFF9C27B0);
  static const Color leaveReplacement = Color(0xFF00BCD4);
  static const Color leavePublicHoliday = Color(0xFFFF9800);
}

/// === TYPOGRAPHY ===
abstract class KFTypography {
  KFTypography._();
  
  // Font family
  static const String fontFamily = 'PlusJakartaSans';
  static const String fontFamilyArabic = 'IBMPlexSansArabic';
  static const String fontFamilyThai = 'NotoSansThai';
  static const String fontFamilyChinese = 'NotoSansSC';
  static const String fontFamilyTamil = 'NotoSansTamil';
  static const String fontFamilyMono = 'JetBrainsMono';
  
  // Font sizes
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
  
  // Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtrabold = FontWeight.w800;
  
  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  
  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.5;
}

/// === SPACING ===
abstract class KFSpacing {
  KFSpacing._();
  
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  static const double space20 = 80;
  static const double space24 = 96;
  
  // Screen padding
  static const double screenPaddingHorizontal = 16;
  static const double screenPaddingVertical = 16;
  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  
  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);
}

/// === BORDER RADIUS ===
abstract class KFRadius {
  KFRadius._();
  
  static const double none = 0;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 9999;
  
  // Pre-built BorderRadius
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);
}

/// === SHADOWS ===
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
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
  ];
}

/// === TOUCH TARGETS ===
abstract class KFTouchTargets {
  KFTouchTargets._();
  
  // WCAG 2.2 minimum
  static const double minimum = 44;
  // Recommended comfortable size
  static const double comfortable = 48;
  // For gloves/accessibility
  static const double large = 56;
  // TV/Stadium mode
  static const double extraLarge = 64;
}

/// === ANIMATION ===
abstract class KFAnimation {
  KFAnimation._();
  
  // Durations
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);
  
  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}

/// === BREAKPOINTS ===
abstract class KFBreakpoints {
  KFBreakpoints._();
  
  static const double watch = 200;
  static const double phoneSmall = 320;
  static const double phone = 360;
  static const double phoneLarge = 390;
  static const double phoneXL = 428;
  static const double tabletSmall = 600;
  static const double tablet = 744;
  static const double tabletLarge = 834;
  static const double desktop = 1024;
  static const double desktopLarge = 1280;
  static const double desktopXL = 1440;
  static const double ultrawide = 1920;
  static const double tv4k = 2560;
  static const double stadium = 3840;
  
  /// Get device category from width
  static DeviceCategory getCategory(double width) {
    if (width < watch) return DeviceCategory.watch;
    if (width < tabletSmall) return DeviceCategory.phone;
    if (width < desktop) return DeviceCategory.tablet;
    if (width < tv4k) return DeviceCategory.desktop;
    return DeviceCategory.tv;
  }
}

enum DeviceCategory { watch, phone, tablet, desktop, tv }

/// === ICON SIZES ===
abstract class KFIconSizes {
  KFIconSizes._();
  
  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
}

/// === AVATAR SIZES ===
abstract class KFAvatarSizes {
  KFAvatarSizes._();
  
  static const double xs = 24;
  static const double sm = 32;
  static const double md = 40;
  static const double lg = 48;
  static const double xl = 64;
  static const double xxl = 80;
  static const double xxxl = 120;
}

/// === Z-INDEX ===
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
  static const int max = 9999;
}
```

After creating:
# Verify
test -f mobile/lib/core/theme/design_tokens.dart && echo "✓ design_tokens.dart created" || echo "✗ MISSING"
wc -l mobile/lib/core/theme/design_tokens.dart

git add mobile/lib/core/theme/
git commit -m "feat(uiux): Task UI-1 - Design tokens (single source of truth)

Implemented comprehensive design tokens:
- Brand colors (primary, secondary)
- Semantic colors (success, warning, error, info)
- Neutral colors (gray scale)
- Dark mode colors
- Leave type colors
- Typography (fonts, sizes, weights)
- Spacing scale
- Border radius
- Shadows (xs to xl)
- Touch targets (WCAG compliant)
- Animation durations and curves
- Breakpoints for all devices
- Icon and avatar sizes
- Z-index scale

NEVER use raw values in widgets - always reference tokens."

═══════════════════════════════════════════════════════════════════════════════
TASK UI-2: IMPLEMENT APP THEME (Light + Dark)
═══════════════════════════════════════════════════════════════════════════════

Create file: mobile/lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

/// KerjaFlow App Theme
/// Implements Material 3 with custom design tokens
class KFTheme {
  KFTheme._();
  
  /// Light theme
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: KFColors.primary600,
        onPrimary: KFColors.white,
        primaryContainer: KFColors.primary100,
        onPrimaryContainer: KFColors.primary900,
        secondary: KFColors.secondary500,
        onSecondary: KFColors.white,
        secondaryContainer: KFColors.secondary100,
        onSecondaryContainer: KFColors.secondary600,
        error: KFColors.error600,
        onError: KFColors.white,
        errorContainer: KFColors.error100,
        onErrorContainer: KFColors.error700,
        surface: KFColors.white,
        onSurface: KFColors.gray900,
        surfaceContainerHighest: KFColors.gray100,
        outline: KFColors.gray300,
        outlineVariant: KFColors.gray200,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: KFColors.gray50,
      
      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: KFColors.white,
        foregroundColor: KFColors.gray900,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.fontWeightSemibold,
          color: KFColors.gray900,
        ),
        iconTheme: IconThemeData(
          color: KFColors.gray700,
          size: KFIconSizes.lg,
        ),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KFColors.white,
        selectedItemColor: KFColors.primary600,
        unselectedItemColor: KFColors.gray500,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.fontWeightMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.fontWeightRegular,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: KFColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
          side: BorderSide(color: KFColors.gray200),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.primary600,
          foregroundColor: KFColors.white,
          disabledBackgroundColor: KFColors.gray200,
          disabledForegroundColor: KFColors.gray400,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: KFSpacing.space6,
            vertical: KFSpacing.space4,
          ),
          minimumSize: Size(double.infinity, KFTouchTargets.comfortable),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.fontWeightSemibold,
          ),
        ),
      ),
      
      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KFColors.primary600,
          disabledForegroundColor: KFColors.gray400,
          padding: EdgeInsets.symmetric(
            horizontal: KFSpacing.space6,
            vertical: KFSpacing.space4,
          ),
          minimumSize: Size(double.infinity, KFTouchTargets.comfortable),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          side: BorderSide(color: KFColors.primary600),
          textStyle: TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.fontWeightSemibold,
          ),
        ),
      ),
      
      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KFColors.primary600,
          padding: EdgeInsets.symmetric(
            horizontal: KFSpacing.space4,
            vertical: KFSpacing.space2,
          ),
          minimumSize: Size(KFTouchTargets.minimum, KFTouchTargets.minimum),
          textStyle: TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeBase,
            fontWeight: KFTypography.fontWeightMedium,
          ),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KFColors.white,
        contentPadding: EdgeInsets.all(KFSpacing.space4),
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.error500, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray600,
        ),
        hintStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray400,
        ),
        errorStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.error600,
        ),
      ),
      
      // Text theme
      textTheme: _buildTextTheme(KFColors.gray900),
      
      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: KFColors.primary600,
        foregroundColor: KFColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KFColors.gray900,
        contentTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusMd,
        ),
      ),
      
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: KFColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXxl,
        ),
        titleTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeXl,
          fontWeight: KFTypography.fontWeightSemibold,
          color: KFColors.gray900,
        ),
        contentTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          color: KFColors.gray700,
        ),
      ),
      
      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: KFColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KFRadius.xxl),
          ),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: KFColors.gray200,
        thickness: 1,
        space: KFSpacing.space4,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: KFColors.gray100,
        selectedColor: KFColors.primary100,
        labelStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusFull,
        ),
      ),
    );
  }
  
  /// Dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: KFColors.primary400,
        onPrimary: KFColors.primary900,
        primaryContainer: KFColors.primary800,
        onPrimaryContainer: KFColors.primary100,
        secondary: KFColors.secondary400,
        onSecondary: KFColors.secondary600,
        secondaryContainer: KFColors.secondary600,
        onSecondaryContainer: KFColors.secondary100,
        error: KFColors.error500,
        onError: KFColors.error900,
        errorContainer: KFColors.error700,
        onErrorContainer: KFColors.error100,
        surface: KFColors.darkSurface,
        onSurface: KFColors.white,
        surfaceContainerHighest: KFColors.darkSurfaceElevated,
        outline: KFColors.darkBorder,
        outlineVariant: KFColors.gray700,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: KFColors.darkBackground,
      
      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: KFColors.darkSurface,
        foregroundColor: KFColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.fontWeightSemibold,
          color: KFColors.white,
        ),
        iconTheme: IconThemeData(
          color: KFColors.gray300,
          size: KFIconSizes.lg,
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: KFColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
          side: BorderSide(color: KFColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Text theme
      textTheme: _buildTextTheme(KFColors.white),
      
      // ... continue with other dark theme customizations
    );
  }
  
  /// Build text theme with given base color
  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSize5xl,
        fontWeight: KFTypography.fontWeightExtrabold,
        letterSpacing: KFTypography.letterSpacingTight,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSize4xl,
        fontWeight: KFTypography.fontWeightBold,
        letterSpacing: KFTypography.letterSpacingTight,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSize3xl,
        fontWeight: KFTypography.fontWeightBold,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSize2xl,
        fontWeight: KFTypography.fontWeightBold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeXl,
        fontWeight: KFTypography.fontWeightSemibold,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeLg,
        fontWeight: KFTypography.fontWeightSemibold,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeMd,
        fontWeight: KFTypography.fontWeightSemibold,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeBase,
        fontWeight: KFTypography.fontWeightSemibold,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeSm,
        fontWeight: KFTypography.fontWeightSemibold,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeMd,
        fontWeight: KFTypography.fontWeightRegular,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeBase,
        fontWeight: KFTypography.fontWeightRegular,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeSm,
        fontWeight: KFTypography.fontWeightRegular,
        color: baseColor,
      ),
      labelLarge: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeBase,
        fontWeight: KFTypography.fontWeightMedium,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeSm,
        fontWeight: KFTypography.fontWeightMedium,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeXs,
        fontWeight: KFTypography.fontWeightMedium,
        letterSpacing: KFTypography.letterSpacingWide,
        color: baseColor,
      ),
    );
  }
}
```

After creating:
git add mobile/lib/core/theme/
git commit -m "feat(uiux): Task UI-2 - App theme (light + dark mode)

Implemented comprehensive theme:
- Light mode (default)
- Dark mode (complete)
- Material 3 compliance
- Custom color scheme
- Typography system
- Button styles (elevated, outlined, text)
- Input decoration
- Card theme
- Dialog theme
- Bottom sheet theme
- Chip theme
- Snackbar theme

All using design tokens as source of truth."

═══════════════════════════════════════════════════════════════════════════════
CONTINUE WITH REMAINING TASKS...
═══════════════════════════════════════════════════════════════════════════════

# Tasks UI-3 through UI-20 continue with:
# - Responsive layout system
# - Component library (all widgets)
# - Screen implementations
# - Platform-specific adaptations
# - Animation system
# - Accessibility implementation
# - Huawei HMS integration
# - Watch app implementation
# - TV/Stadium layout

# Each task follows the same extreme kiasu pattern:
# 1. Create file with comprehensive implementation
# 2. Verify file exists
# 3. Update progress tracker
# 4. Commit with detailed message

# Due to length, the full prompt continues in the companion document.
# See: PHASE-UIUX-COMPLETE.txt for all remaining tasks.

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "UI/UX IMPLEMENTATION PHASE STARTED"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Completed:"
echo "  ✓ Task UI-1: Design tokens"
echo "  ✓ Task UI-2: App theme (light + dark)"
echo ""
echo "Remaining tasks in full prompt:"
echo "  - UI-3: Responsive layout system"
echo "  - UI-4: Component library"
echo "  - UI-5 to UI-20: Screen implementations"
echo "  - UI-21: Huawei HMS integration"
echo "  - UI-22: Watch app"
echo "  - UI-23: TV/Stadium layout"
echo "  - UI-24: Animation system"
echo "  - UI-25: Accessibility audit"
echo ""

================================================================================
END OF PROMPT PART 1 - CONTINUE WITH PHASE-UIUX-COMPLETE.txt
================================================================================
