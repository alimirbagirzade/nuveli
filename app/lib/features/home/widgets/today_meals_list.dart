import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../meal/data/meal_models.dart';
import '../../meal/providers/meal_providers.dart';

/// Home ekranındaki "Bugünkü öğünler" listesi.
/// Boş gün, loading, error ve dolu durumları yönetir.
class TodayMealsList extends ConsumerWidget {
  const TodayMealsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todayMealsProvider);

    return meals.when(
      loading: () => const MealListSkeleton(),
      error: (_, __) => const SizedBox.shrink(), // Sessiz fail — home zaten hata gösteriyor
      data: (list) {
        if (list.isEmpty) {
          return _buildCard(
            child: EmptyStateView(
              icon: Icons.restaurant_outlined,
              title: 'Henüz öğün eklenmedi',
              message: 'İlk öğününü ekleyerek günü başlat',
              actionLabel: 'Öğün Ekle',
              onAction: () => context.push(AppRoute.mealCapture),
              compact: true,
            ),
          );
        }
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Bugünkü öğünler',
                        style: AppTextStyles.labelLarge),
                    const Spacer(),
                    Text(
                      '${list.length} öğün',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...list.map((meal) => _MealRow(
                    meal: meal,
                    onDelete: () => _confirmDelete(context, ref, meal),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MealLog meal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öğünü sil?'),
        content: Text('"${meal.name}" silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(deleteMealActionProvider)(meal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Öğün silindi.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silinemedi.')),
        );
      }
    }
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onDelete});
  final MealLog meal;
  final VoidCallback onDelete;

  String get _mealTypeLabel => switch (meal.mealType) {
        'breakfast' => 'Kahvaltı',
        'lunch' => 'Öğle',
        'dinner' => 'Akşam',
        _ => 'Ara öğün',
      };

  IconData get _mealTypeIcon => switch (meal.mealType) {
        'breakfast' => Icons.wb_sunny_outlined,
        'lunch' => Icons.lunch_dining_outlined,
        'dinner' => Icons.dinner_dining_outlined,
        _ => Icons.cookie_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Onay modalı içinde yönetiyoruz
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.error.withOpacity(0.1),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(_mealTypeIcon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name.isEmpty ? _mealTypeLabel : meal.name,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _mealTypeLabel,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories} kcal',
              style: AppTextStyles.headingSmall,
            ),
          ],
        ),
      ),
    );
  }
}
