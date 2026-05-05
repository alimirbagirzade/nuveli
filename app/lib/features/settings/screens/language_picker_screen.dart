// lib/features/settings/screens/language_picker_screen.dart
//
// Settings -> Dil ekrani.
// Kullanici 5 dil + Sistem secebilir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';

class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = globalLanguageNotifier.value;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.settingsLanguage, style: AppTextStyles.labelMedium),
      ),
      padding: const EdgeInsets.all(16),
      body: ListView(
        children: AppLanguage.values.map((lang) {
          final isSelected = current == lang;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textTertiary.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: _buildFlag(lang),
              title: Text(
                lang.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                changeLanguage(lang);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlag(AppLanguage lang) {
    final emoji = switch (lang) {
      AppLanguage.system => '🌍',
      AppLanguage.turkish => '🇹🇷',
      AppLanguage.english => '🇬🇧',
      AppLanguage.german => '🇩🇪',
      AppLanguage.french => '🇫🇷',
      AppLanguage.spanish => '🇪🇸',
      AppLanguage.russian => '🇷🇺',
      AppLanguage.italian => '🇮🇹',
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
