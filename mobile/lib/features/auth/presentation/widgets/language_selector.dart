import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_config.dart';
import '../../../../main.dart';

/// Language selector widget for login screen.
///
/// Features:
/// - Shows current language with flag
/// - Opens bottom sheet with all 12 supported languages
/// - Grouped by script type (Latin, Complex)
/// - Persists selection
class LanguageSelector extends ConsumerWidget {
  /// Whether to show full language name or just flag
  final bool showLabel;

  /// Whether to use compact mode (icon only)
  final bool compact;

  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final metadata = LocaleConfig.getMetadata(currentLocale.languageCode);

    if (compact) {
      return IconButton(
        icon: Text(
          metadata?.flag ?? '🌐',
          style: const TextStyle(fontSize: 24),
        ),
        onPressed: () => _showLanguageSheet(context, ref),
        tooltip: 'Change language',
      );
    }

    return InkWell(
      onTap: () => _showLanguageSheet(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metadata?.flag ?? '🌐',
              style: const TextStyle(fontSize: 20),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                metadata?.nativeName ?? 'English',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _LanguageBottomSheet(ref: ref),
    );
  }
}

class _LanguageBottomSheet extends StatelessWidget {
  final WidgetRef ref;

  const _LanguageBottomSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final allMetadata = LocaleConfig.allMetadata;

    // Group languages by script
    final latinLanguages = allMetadata
        .where((m) => !LocaleConfig.complexScriptCodes.contains(m.code))
        .toList();
    final complexLanguages = allMetadata
        .where((m) => LocaleConfig.complexScriptCodes.contains(m.code))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Select Language',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Language list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // Latin script languages
                  _buildSectionHeader(context, 'Latin Script'),
                  ...latinLanguages.map((metadata) => _buildLanguageTile(
                        context,
                        metadata,
                        isSelected: metadata.code == currentLocale.languageCode,
                      )),

                  const SizedBox(height: 16),

                  // Complex script languages
                  _buildSectionHeader(context, 'Regional Scripts'),
                  ...complexLanguages.map((metadata) => _buildLanguageTile(
                        context,
                        metadata,
                        isSelected: metadata.code == currentLocale.languageCode,
                      )),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    LocaleMetadata metadata, {
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Text(
        metadata.flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(metadata.nativeName),
      subtitle: Text(
        metadata.englishName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        ref.read(localeNotifierProvider.notifier).setLocale(metadata.locale);
        Navigator.pop(context);
      },
    );
  }
}

/// Inline language chips for horizontal scrolling display
class LanguageChips extends ConsumerWidget {
  const LanguageChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final allMetadata = LocaleConfig.allMetadata;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allMetadata.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final metadata = allMetadata[index];
          final isSelected = metadata.code == currentLocale.languageCode;

          return ChoiceChip(
            label: Text('${metadata.flag} ${metadata.nativeName}'),
            selected: isSelected,
            onSelected: (_) {
              ref
                  .read(localeNotifierProvider.notifier)
                  .setLocale(metadata.locale);
            },
          );
        },
      ),
    );
  }
}
