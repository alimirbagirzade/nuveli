import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/widgets/meal_entry_sheet.dart';
import '../providers/meal_scan_controller.dart';

/// Error screen: timeout, rate limit, OpenAI 5xx, no-network.
/// Offers retry + manual fallback.
class ScanErrorView extends ConsumerWidget {
  const ScanErrorView({
    super.key,
    required this.message,
    this.isRateLimited = false,
  });

  final String message;
  final bool isRateLimited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mealScanControllerProvider.notifier);
    final title = isRateLimited ? 'Too many scans, too fast' : 'Scan failed';

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
                      color: AppColors.error.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
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
                      message,
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
              onPressed: controller.reset,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try again',
                style: TextStyle(
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
              label: const Text(
                'Add manually instead',
                style: TextStyle(
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
