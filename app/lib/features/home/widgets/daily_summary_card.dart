import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  final int consumedCalories;
  final int targetCalories;
  final double protein;
  final double carb;
  final double fat;

  @override
  Widget build(BuildContext context) {
    final remaining = (targetCalories - consumedCalories).clamp(0, targetCalories);
    final progress = (consumedCalories / targetCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bugün', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    '$consumedCalories',
                    style: AppTextStyles.displayLarge.copyWith(height: 1.0),
                  ),
                  const SizedBox(height: 2),
                  Text('/ $targetCalories kcal hedefi',
                      style: AppTextStyles.bodySmall),
                ],
              ),
              _CircleProgress(progress: progress, remaining: remaining),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MacroChip(label: 'Protein', value: '${protein.toInt()}g', color: AppColors.accent),
              const SizedBox(width: 8),
              _MacroChip(label: 'Karb', value: '${carb.toInt()}g', color: AppColors.primary),
              const SizedBox(width: 8),
              _MacroChip(label: 'Yağ', value: '${fat.toInt()}g', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleProgress extends StatelessWidget {
  const _CircleProgress({required this.progress, required this.remaining});
  final double progress;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$remaining', style: AppTextStyles.headingSmall),
              Text('kaldı', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}
