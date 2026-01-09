import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

/// KerjaFlow App Theme v5.0
/// Material 3 with custom design tokens
/// Supports light, dark, and high-contrast modes
class KFTheme {
  KFTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: KFTypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: KFColors.primary600,
        onPrimary: KFColors.white,
        primaryContainer: KFColors.primary100,
        onPrimaryContainer: KFColors.primary900,
        secondary: KFColors.secondary500,
        onSecondary: KFColors.white,
        secondaryContainer: KFColors.secondary100,
        onSecondaryContainer: KFColors.secondary700,
        tertiary: KFColors.info500,
        onTertiary: KFColors.white,
        error: KFColors.error600,
        onError: KFColors.white,
        errorContainer: KFColors.error100,
        onErrorContainer: KFColors.error700,
        surface: KFColors.white,
        onSurface: KFColors.gray900,
        surfaceContainerHighest: KFColors.gray100,
        onSurfaceVariant: KFColors.gray600,
        outline: KFColors.gray300,
        outlineVariant: KFColors.gray200,
        shadow: KFColors.black,
        scrim: KFColors.black,
      ),

      // Scaffold
      scaffoldBackgroundColor: KFColors.gray50,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: KFColors.white,
        foregroundColor: KFColors.gray900,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        iconTheme: IconThemeData(
          color: KFColors.gray700,
          size: KFIconSizes.lg,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KFColors.white,
        elevation: 8,
        selectedItemColor: KFColors.primary600,
        unselectedItemColor: KFColors.gray500,
        selectedLabelStyle: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.medium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.regular,
        ),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Navigation Rail (tablets)
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: KFColors.white,
        elevation: 0,
        selectedIconTheme: IconThemeData(color: KFColors.primary600),
        unselectedIconTheme: IconThemeData(color: KFColors.gray500),
        selectedLabelTextStyle: TextStyle(
          color: KFColors.primary600,
          fontWeight: KFTypography.medium,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: KFColors.gray500,
        ),
        useIndicator: true,
        indicatorColor: KFColors.primary100,
      ),

      // Cards
      cardTheme: CardTheme(
        color: KFColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
          side: const BorderSide(color: KFColors.gray200),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.primary600,
          foregroundColor: KFColors.white,
          disabledBackgroundColor: KFColors.gray200,
          disabledForegroundColor: KFColors.gray400,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, KFTouchTargets.comfortable),
          padding: KFSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.semibold,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KFColors.primary600,
          disabledForegroundColor: KFColors.gray400,
          minimumSize: const Size(double.infinity, KFTouchTargets.comfortable),
          padding: KFSpacing.buttonPadding,
          side: const BorderSide(color: KFColors.primary600),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.semibold,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KFColors.primary600,
          disabledForegroundColor: KFColors.gray400,
          minimumSize:
              const Size(KFTouchTargets.minimum, KFTouchTargets.minimum),
          padding: const EdgeInsets.symmetric(horizontal: KFSpacing.space4),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeBase,
            fontWeight: KFTypography.medium,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: KFColors.secondary500,
        foregroundColor: KFColors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KFColors.white,
        contentPadding: KFSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.error600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.gray200),
        ),
        labelStyle: const TextStyle(
          color: KFColors.gray600,
          fontSize: KFTypography.fontSizeBase,
        ),
        hintStyle: const TextStyle(
          color: KFColors.gray400,
          fontSize: KFTypography.fontSizeBase,
        ),
        errorStyle: const TextStyle(
          color: KFColors.error600,
          fontSize: KFTypography.fontSizeSm,
        ),
        helperStyle: const TextStyle(
          color: KFColors.gray500,
          fontSize: KFTypography.fontSizeSm,
        ),
        prefixIconColor: KFColors.gray500,
        suffixIconColor: KFColors.gray500,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: KFColors.gray100,
        disabledColor: KFColors.gray100,
        selectedColor: KFColors.primary100,
        secondarySelectedColor: KFColors.primary100,
        padding: KFSpacing.chipPadding,
        labelStyle: const TextStyle(
          color: KFColors.gray700,
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
        ),
        secondaryLabelStyle: const TextStyle(
          color: KFColors.primary700,
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusFull,
        ),
        side: BorderSide.none,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KFColors.gray900,
        contentTextStyle: const TextStyle(
          color: KFColors.white,
          fontSize: KFTypography.fontSizeBase,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusMd,
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: KFColors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXxl,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray900,
          fontSize: KFTypography.fontSizeXl,
          fontWeight: KFTypography.semibold,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray700,
          fontSize: KFTypography.fontSizeBase,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: KFColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusTop,
        ),
        dragHandleColor: KFColors.gray300,
        dragHandleSize: const Size(40, 4),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: KFColors.gray200,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: KFSpacing.listItemPadding,
        minVerticalPadding: KFSpacing.space3,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusMd,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray900,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
        ),
        subtitleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray600,
          fontSize: KFTypography.fontSizeSm,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray500,
          fontSize: KFTypography.fontSizeSm,
        ),
        iconColor: KFColors.gray600,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.white;
          }
          return KFColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary600;
          }
          return KFColors.gray200;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary600;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(KFColors.white),
        side: const BorderSide(color: KFColors.gray400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusSm,
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary600;
          }
          return KFColors.gray400;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KFColors.primary600,
        linearTrackColor: KFColors.gray200,
        circularTrackColor: KFColors.gray200,
      ),

      // Tab Bar
      tabBarTheme: TabBarTheme(
        labelColor: KFColors.primary600,
        unselectedLabelColor: KFColors.gray500,
        indicatorColor: KFColors.primary600,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.semibold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
        ),
        dividerColor: KFColors.gray200,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: KFColors.gray900,
          borderRadius: KFRadius.radiusSm,
        ),
        textStyle: const TextStyle(
          color: KFColors.white,
          fontSize: KFTypography.fontSizeSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KFSpacing.space3,
          vertical: KFSpacing.space2,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: KFTypography.fontSize5xl,
          fontWeight: KFTypography.bold,
          color: KFColors.gray900,
          letterSpacing: KFTypography.letterSpacingTight,
        ),
        displayMedium: TextStyle(
          fontSize: KFTypography.fontSize4xl,
          fontWeight: KFTypography.bold,
          color: KFColors.gray900,
          letterSpacing: KFTypography.letterSpacingTight,
        ),
        displaySmall: TextStyle(
          fontSize: KFTypography.fontSize3xl,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        headlineLarge: TextStyle(
          fontSize: KFTypography.fontSize2xl,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        headlineMedium: TextStyle(
          fontSize: KFTypography.fontSizeXl,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        headlineSmall: TextStyle(
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        titleLarge: TextStyle(
          fontSize: KFTypography.fontSizeMd,
          fontWeight: KFTypography.semibold,
          color: KFColors.gray900,
        ),
        titleMedium: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
          color: KFColors.gray900,
        ),
        titleSmall: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
          color: KFColors.gray900,
        ),
        bodyLarge: TextStyle(
          fontSize: KFTypography.fontSizeMd,
          fontWeight: KFTypography.regular,
          color: KFColors.gray700,
        ),
        bodyMedium: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.regular,
          color: KFColors.gray700,
        ),
        bodySmall: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.regular,
          color: KFColors.gray600,
        ),
        labelLarge: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
          color: KFColors.gray900,
        ),
        labelMedium: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
          color: KFColors.gray700,
        ),
        labelSmall: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.medium,
          color: KFColors.gray600,
          letterSpacing: KFTypography.letterSpacingWide,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: KFTypography.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: KFColors.primary400,
        onPrimary: KFColors.primary900,
        primaryContainer: KFColors.primary800,
        onPrimaryContainer: KFColors.primary100,
        secondary: KFColors.secondary400,
        onSecondary: KFColors.secondary700,
        secondaryContainer: KFColors.secondary700,
        onSecondaryContainer: KFColors.secondary100,
        tertiary: KFColors.info500,
        onTertiary: KFColors.info700,
        error: KFColors.error500,
        onError: KFColors.error900,
        errorContainer: KFColors.error700,
        onErrorContainer: KFColors.error100,
        surface: KFColors.darkSurface,
        onSurface: KFColors.white,
        surfaceContainerHighest: KFColors.darkSurfaceElevated,
        onSurfaceVariant: KFColors.gray400,
        outline: KFColors.darkBorder,
        outlineVariant: KFColors.gray800,
        shadow: KFColors.black,
        scrim: KFColors.black,
      ),

      scaffoldBackgroundColor: KFColors.darkBackground,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: KFColors.darkSurface,
        foregroundColor: KFColors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        iconTheme: IconThemeData(
          color: KFColors.gray300,
          size: KFIconSizes.lg,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KFColors.darkSurface,
        elevation: 8,
        selectedItemColor: KFColors.primary400,
        unselectedItemColor: KFColors.gray500,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.medium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.regular,
        ),
      ),

      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: KFColors.darkSurface,
        elevation: 0,
        selectedIconTheme: IconThemeData(color: KFColors.primary400),
        unselectedIconTheme: IconThemeData(color: KFColors.gray500),
        selectedLabelTextStyle: TextStyle(
          color: KFColors.primary400,
          fontWeight: KFTypography.medium,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: KFColors.gray500,
        ),
        useIndicator: true,
        indicatorColor: KFColors.primary800,
      ),

      cardTheme: CardTheme(
        color: KFColors.darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
          side: const BorderSide(color: KFColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.primary500,
          foregroundColor: KFColors.white,
          disabledBackgroundColor: KFColors.gray800,
          disabledForegroundColor: KFColors.gray500,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, KFTouchTargets.comfortable),
          padding: KFSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.semibold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KFColors.primary400,
          disabledForegroundColor: KFColors.gray600,
          minimumSize: const Size(double.infinity, KFTouchTargets.comfortable),
          padding: KFSpacing.buttonPadding,
          side: const BorderSide(color: KFColors.primary400),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.semibold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KFColors.primary400,
          disabledForegroundColor: KFColors.gray600,
          minimumSize:
              const Size(KFTouchTargets.minimum, KFTouchTargets.minimum),
          padding: const EdgeInsets.symmetric(horizontal: KFSpacing.space4),
          textStyle: const TextStyle(
            fontFamily: KFTypography.fontFamily,
            fontSize: KFTypography.fontSizeBase,
            fontWeight: KFTypography.medium,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: KFColors.secondary500,
        foregroundColor: KFColors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXl,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KFColors.darkSurfaceElevated,
        contentPadding: KFSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.primary400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.error500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: const BorderSide(color: KFColors.gray800),
        ),
        labelStyle: const TextStyle(
          color: KFColors.gray400,
          fontSize: KFTypography.fontSizeBase,
        ),
        hintStyle: const TextStyle(
          color: KFColors.gray500,
          fontSize: KFTypography.fontSizeBase,
        ),
        errorStyle: const TextStyle(
          color: KFColors.error500,
          fontSize: KFTypography.fontSizeSm,
        ),
        helperStyle: const TextStyle(
          color: KFColors.gray500,
          fontSize: KFTypography.fontSizeSm,
        ),
        prefixIconColor: KFColors.gray500,
        suffixIconColor: KFColors.gray500,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: KFColors.darkSurfaceElevated,
        disabledColor: KFColors.gray800,
        selectedColor: KFColors.primary800,
        secondarySelectedColor: KFColors.primary800,
        padding: KFSpacing.chipPadding,
        labelStyle: const TextStyle(
          color: KFColors.gray300,
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
        ),
        secondaryLabelStyle: const TextStyle(
          color: KFColors.primary300,
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusFull,
        ),
        side: BorderSide.none,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: KFColors.gray100,
        contentTextStyle: const TextStyle(
          color: KFColors.gray900,
          fontSize: KFTypography.fontSizeBase,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusMd,
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: KFColors.darkSurface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusXxl,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.white,
          fontSize: KFTypography.fontSizeXl,
          fontWeight: KFTypography.semibold,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray300,
          fontSize: KFTypography.fontSizeBase,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: KFColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusTop,
        ),
        dragHandleColor: KFColors.gray600,
        dragHandleSize: const Size(40, 4),
      ),

      dividerTheme: const DividerThemeData(
        color: KFColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: KFSpacing.listItemPadding,
        minVerticalPadding: KFSpacing.space3,
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusMd,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.white,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
        ),
        subtitleTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray400,
          fontSize: KFTypography.fontSizeSm,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          color: KFColors.gray500,
          fontSize: KFTypography.fontSizeSm,
        ),
        iconColor: KFColors.gray400,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.white;
          }
          return KFColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary500;
          }
          return KFColors.gray700;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary500;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(KFColors.white),
        side: const BorderSide(color: KFColors.gray500, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusSm,
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KFColors.primary500;
          }
          return KFColors.gray500;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KFColors.primary400,
        linearTrackColor: KFColors.gray700,
        circularTrackColor: KFColors.gray700,
      ),

      tabBarTheme: TabBarTheme(
        labelColor: KFColors.primary400,
        unselectedLabelColor: KFColors.gray500,
        indicatorColor: KFColors.primary400,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.semibold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: KFTypography.fontFamily,
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
        ),
        dividerColor: KFColors.darkBorder,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: KFColors.gray100,
          borderRadius: KFRadius.radiusSm,
        ),
        textStyle: const TextStyle(
          color: KFColors.gray900,
          fontSize: KFTypography.fontSizeSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KFSpacing.space3,
          vertical: KFSpacing.space2,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: KFTypography.fontSize5xl,
          fontWeight: KFTypography.bold,
          color: KFColors.white,
          letterSpacing: KFTypography.letterSpacingTight,
        ),
        displayMedium: TextStyle(
          fontSize: KFTypography.fontSize4xl,
          fontWeight: KFTypography.bold,
          color: KFColors.white,
          letterSpacing: KFTypography.letterSpacingTight,
        ),
        displaySmall: TextStyle(
          fontSize: KFTypography.fontSize3xl,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: KFTypography.fontSize2xl,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: KFTypography.fontSizeXl,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: KFTypography.fontSizeLg,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        titleLarge: TextStyle(
          fontSize: KFTypography.fontSizeMd,
          fontWeight: KFTypography.semibold,
          color: KFColors.white,
        ),
        titleMedium: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
          color: KFColors.white,
        ),
        titleSmall: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
          color: KFColors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: KFTypography.fontSizeMd,
          fontWeight: KFTypography.regular,
          color: KFColors.gray300,
        ),
        bodyMedium: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.regular,
          color: KFColors.gray300,
        ),
        bodySmall: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.regular,
          color: KFColors.gray400,
        ),
        labelLarge: TextStyle(
          fontSize: KFTypography.fontSizeBase,
          fontWeight: KFTypography.medium,
          color: KFColors.white,
        ),
        labelMedium: TextStyle(
          fontSize: KFTypography.fontSizeSm,
          fontWeight: KFTypography.medium,
          color: KFColors.gray300,
        ),
        labelSmall: TextStyle(
          fontSize: KFTypography.fontSizeXs,
          fontWeight: KFTypography.medium,
          color: KFColors.gray400,
          letterSpacing: KFTypography.letterSpacingWide,
        ),
      ),
    );
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeContextExtension on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
