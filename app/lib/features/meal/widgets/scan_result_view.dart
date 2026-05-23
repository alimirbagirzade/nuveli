import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/meal_scan_models.dart';
import '../providers/meal_scan_controller.dart';
import 'edit_food_sheet.dart';

/// Editable preview of detected foods. User can:
///   - Tap a food to edit name/calories/macros
///   - Remove a food
///   - Drag the scale slider to bulk-scale portions (0.5x ↔ 2x)
///   - Override meal type
///   - Save (→ POST /meals with scan_source='ai_scan')
class ScanResultView extends ConsumerWidget {
  const ScanResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealScanControllerProvider);
    final controller = ref.read(mealScanControllerProvider.notifier);
    final foods = state.effectiveFoods;
    final insight = state.scanResult?.portionInsight;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              _TotalsCard(
                calories: state.totalCalories,
                proteinG: state.totalProteinG,
                carbsG: state.totalCarbsG,
                fatG: state.totalFatG,
                confidence: insight?.score,
              ),
              const SizedBox(height: 16),
              _MealTypeChips(
                selected: state.mealType ?? 'snack',
                onChanged: controller.setMealType,
              ),
              const SizedBox(height: 16),
              _ScaleSlider(
                factor: state.scaleFactor,
                onChanged: controller.setScale,
              ),
              const SizedBox(height: 16),
              const Text(
                'Detected foods',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < foods.length; i++)
                _FoodRow(
                  food: foods[i],
                  onEdit: () => _openEditor(context, ref, i),
                  onRemove: () => controller.removeFood(i),
                ),
              if (insight != null && insight.highlights.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InsightCard(insight: insight),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.retake,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Discard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: foods.isEmpty ? null : () => controller.save(),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'Save meal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, int index) async {
    final state = ref.read(mealScanControllerProvider);
    final controller = ref.read(mealScanControllerProvider.notifier);
    // Editor operates on the unscaled food so per-food edits compose
    // cleanly with the slider.
    final base = state.editedFoods[index];
    final edited = await EditFoodSheet.show(context, base);
    if (edited != null) controller.updateFood(index, edited);
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.confidence,
  });

  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final int? confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$calories',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'kcal',
                  style: TextStyle(
                    color: Color(0xFFB8D4D2),
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              if (confidence != null) _ConfidenceChip(score: confidence!),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MacroPill(label: 'P', value: proteinG, color: AppColors.primary),
              const SizedBox(width: 8),
              _MacroPill(label: 'C', value: carbsG, color: AppColors.accent),
              const SizedBox(width: 8),
              _MacroPill(label: 'F', value: fatG, color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    Color tint;
    if (score >= 70) {
      tint = AppColors.success;
    } else if (score >= 40) {
      tint = AppColors.warning;
    } else {
      tint = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: tint.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$score% confident',
        style: TextStyle(
          color: tint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '${value.toStringAsFixed(1)}g',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTypeChips extends StatelessWidget {
  const _MealTypeChips({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  static const _types = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final type = _types[i];
          final active = type == selected;
          return ChoiceChip(
            label: Text(
              type[0].toUpperCase() + type.substring(1),
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFFB8D4D2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: active,
            onSelected: (_) => onChanged(type),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: active ? AppColors.primary : AppColors.border,
            ),
          );
        },
      ),
    );
  }
}

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({required this.factor, required this.onChanged});
  final double factor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Portion size',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${factor.toStringAsFixed(2)}x',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: factor.clamp(0.5, 2.0),
            min: 0.5,
            max: 2.0,
            divisions: 6,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({
    required this.food,
    required this.onEdit,
    required this.onRemove,
  });

  final DetectedFood food;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (food.portion.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          food.portion,
                          style: const TextStyle(
                            color: Color(0xFFB8D4D2),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${food.calories} kcal',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF7A95A0), size: 18),
                  onPressed: onRemove,
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final PortionInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 16),
              SizedBox(width: 6),
              Text(
                'AI tip',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (insight.mainText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              insight.mainText,
              style: const TextStyle(
                color: Color(0xFFE8F3F1),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          for (final h in insight.highlights) ...[
            const SizedBox(height: 4),
            Text(
              '• $h',
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
