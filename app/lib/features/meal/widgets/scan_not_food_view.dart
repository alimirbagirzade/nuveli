import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../dashboard/widgets/meal_entry_sheet.dart';
import '../providers/meal_scan_controller.dart';

/// AI couldn't see food. Show explanation + "Try again" + "Add manually".
class ScanNotFoodView extends ConsumerWidget {
  const ScanNotFoodView({super.key, this.explanation});
  final String? explanation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(mealScanControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warning.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      size: 44,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n?.mealScanNotFoodTitle ?? 'Hmm, I couldn\'t see food',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      explanation?.isNotEmpty == true
                          ? explanation!
                          : (l10n?.mealScanNotFoodHint ??
                              'Try a clearer shot of your plate, or log this meal manually.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB8D4D2),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.retake,
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              label: Text(
                l10n?.mealScanTryAnotherPhoto ?? 'Try another photo',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                controller.reset();
                await MealEntrySheet.show(context);
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: Text(
                l10n?.mealScanAddManually ?? 'Add manually',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
