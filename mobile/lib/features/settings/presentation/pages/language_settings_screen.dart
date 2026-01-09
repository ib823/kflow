import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Language selection screen with 12 supported languages
class LanguageSettingsScreen extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSettingsScreen({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en';

  final List<_LanguageOption> _languages = const [
    _LanguageOption('en', 'English', 'English'),
    _LanguageOption('ms', 'Bahasa Malaysia', 'Malay'),
    _LanguageOption('id', 'Bahasa Indonesia', 'Indonesian'),
    _LanguageOption('th', 'ภาษาไทย', 'Thai'),
    _LanguageOption('vi', 'Tiếng Việt', 'Vietnamese'),
    _LanguageOption('tl', 'Filipino', 'Filipino'),
    _LanguageOption('zh', '简体中文', 'Chinese Simplified'),
    _LanguageOption('ta', 'தமிழ்', 'Tamil'),
    _LanguageOption('bn', 'বাংলা', 'Bengali'),
    _LanguageOption('ne', 'नेपाली', 'Nepali'),
    _LanguageOption('km', 'ភាសាខ្មែរ', 'Khmer'),
    _LanguageOption('my', 'မြန်မာဘာသာ', 'Myanmar'),
  ];

  void _selectLanguage(_LanguageOption language) {
    if (_selectedLanguage == language.code) return;

    setState(() => _selectedLanguage = language.code);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to ${language.englishName}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Restart',
          onPressed: () {
            // In real app, would restart or reload
            widget.onLanguageChanged?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Language'),
      body: ListView.builder(
        padding: KFSpacing.screenPadding,
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = _selectedLanguage == language.code;

          return Padding(
            padding: const EdgeInsets.only(bottom: KFSpacing.space2),
            child: Material(
              color: isSelected ? KFColors.primary50 : KFColors.white,
              borderRadius: KFRadius.radiusMd,
              child: InkWell(
                onTap: () => _selectLanguage(language),
                borderRadius: KFRadius.radiusMd,
                child: Container(
                  padding: const EdgeInsets.all(KFSpacing.space4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? KFColors.primary600
                          : KFColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.nativeName,
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
                              language.englishName,
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
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: KFColors.primary600,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;

  const _LanguageOption(this.code, this.nativeName, this.englishName);
}
