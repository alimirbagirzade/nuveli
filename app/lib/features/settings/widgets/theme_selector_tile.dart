import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class ThemeSelectorTile extends ConsumerWidget {
  const ThemeSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.settingsAppearance, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                ],
              ),
            ),
            ...NuveliThemeMode.values.map((mode) {
              final isSelected = current == mode;
              return InkWell(
                onTap: () => ref.read(themeProvider.notifier).setMode(mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Icon(mode.icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_themeLabel(context, mode), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 22) else Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.divider, width: 2))),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String _themeLabel(BuildContext context, NuveliThemeMode mode) {
  final l10n = AppLocalizations.of(context)!;
  switch (mode) {
    case NuveliThemeMode.system: return l10n.themeSystem;
    case NuveliThemeMode.dark: return l10n.themeDark;
  }
}
