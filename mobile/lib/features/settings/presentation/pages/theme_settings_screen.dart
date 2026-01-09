import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Theme settings screen with system/light/dark options
class ThemeSettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const ThemeSettingsScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  String _selectedTheme = 'system';

  final List<_ThemeOption> _themes = const [
    _ThemeOption(
      'system',
      'System Default',
      'Automatically switch between light and dark based on your device settings',
      Icons.brightness_auto,
    ),
    _ThemeOption(
      'light',
      'Light',
      'Always use light theme',
      Icons.light_mode,
    ),
    _ThemeOption(
      'dark',
      'Dark',
      'Always use dark theme',
      Icons.dark_mode,
    ),
  ];

  void _selectTheme(_ThemeOption theme) {
    if (_selectedTheme == theme.value) return;

    setState(() => _selectedTheme = theme.value);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${theme.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onThemeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Theme'),
      body: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview card
            _buildPreviewCard(),
            const SizedBox(height: KFSpacing.space6),
            // Theme options
            ..._themes.map((theme) => Padding(
                  padding: const EdgeInsets.only(bottom: KFSpacing.space3),
                  child: _buildThemeOption(theme),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final isDark = _selectedTheme == 'dark' ||
        (_selectedTheme == 'system' &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : KFColors.white,
        borderRadius: KFRadius.radiusLg,
        border: Border.all(color: KFColors.gray200),
        boxShadow: KFShadows.sm,
      ),
      child: Column(
        children: [
          // Mock app bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KFSpacing.space4,
              vertical: KFSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252540) : KFColors.primary600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(KFSpacing.space3),
                topRight: Radius.circular(KFSpacing.space3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: KFColors.white.withOpacity(0.2),
                    borderRadius: KFRadius.radiusSm,
                  ),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: KFColors.white.withOpacity(0.4),
                      borderRadius: KFRadius.radiusFull,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Mock content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(KFSpacing.space3),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? KFColors.gray700
                              : KFColors.gray200,
                          borderRadius: KFRadius.radiusMd,
                        ),
                      ),
                      const SizedBox(width: KFSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: 100,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? KFColors.gray600
                                    : KFColors.gray300,
                                borderRadius: KFRadius.radiusFull,
                              ),
                            ),
                            const SizedBox(height: KFSpacing.space2),
                            Container(
                              height: 8,
                              width: 60,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? KFColors.gray700
                                    : KFColors.gray200,
                                borderRadius: KFRadius.radiusFull,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: KFColors.primary600,
                      borderRadius: KFRadius.radiusMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(_ThemeOption theme) {
    final isSelected = _selectedTheme == theme.value;

    return Material(
      color: isSelected ? KFColors.primary50 : KFColors.white,
      borderRadius: KFRadius.radiusMd,
      child: InkWell(
        onTap: () => _selectTheme(theme),
        borderRadius: KFRadius.radiusMd,
        child: Container(
          padding: const EdgeInsets.all(KFSpacing.space4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? KFColors.primary600 : KFColors.gray200,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: KFRadius.radiusMd,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? KFColors.primary600
                      : KFColors.gray100,
                  borderRadius: KFRadius.radiusMd,
                ),
                child: Icon(
                  theme.icon,
                  color: isSelected ? KFColors.white : KFColors.gray600,
                ),
              ),
              const SizedBox(width: KFSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.title,
                      style: TextStyle(
                        fontSize: KFTypography.fontSizeMd,
                        fontWeight: isSelected
                            ? KFTypography.semiBold
                            : KFTypography.regular,
                        color: isSelected
                            ? KFColors.primary700
                            : KFColors.gray900,
                      ),
                    ),
                    const SizedBox(height: KFSpacing.space1),
                    Text(
                      theme.description,
                      style: TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        color: isSelected
                            ? KFColors.primary600
                            : KFColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: theme.value,
                groupValue: _selectedTheme,
                onChanged: (value) {
                  if (value != null) {
                    _selectTheme(theme);
                  }
                },
                activeColor: KFColors.primary600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption {
  final String value;
  final String title;
  final String description;
  final IconData icon;

  const _ThemeOption(this.value, this.title, this.description, this.icon);
}
