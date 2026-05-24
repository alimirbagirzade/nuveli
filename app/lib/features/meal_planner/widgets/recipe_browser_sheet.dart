import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/weekly_plan.dart';
import '../providers/planner_providers.dart';

/// Provider that fetches the recipe catalogue. `autoDispose` keeps the list
/// live while the sheet is open and discards it on close.
final _recipesProvider =
    FutureProvider.autoDispose.family<List<RecipeResponse>, String>(
  (ref, search) {
    final repo = ref.watch(mealPlannerRepositoryProvider);
    return repo.getRecipes(search: search.isEmpty ? null : search);
  },
);

/// A bottom sheet that lists all recipes. Tapping one triggers an
/// "Add to plan" flow asking for day, meal-type, and servings.
///
/// Opens with [show].
class RecipeBrowserSheet extends ConsumerStatefulWidget {
  const RecipeBrowserSheet({super.key, required this.defaultDay});

  /// The day pre-selected in the "add to plan" dialog (usually the day
  /// the user tapped "Browse recipes" from).
  final DateTime defaultDay;

  static Future<void> show(BuildContext context, {required DateTime day}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RecipeBrowserSheet(defaultDay: day),
    );
  }

  @override
  ConsumerState<RecipeBrowserSheet> createState() => _RecipeBrowserSheetState();
}

class _RecipeBrowserSheetState extends ConsumerState<RecipeBrowserSheet> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipesAsync = ref.watch(_recipesProvider(_search));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n?.recipeBrowserTitle ?? 'Browse Recipes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n?.recipeBrowserSearchHint ?? 'Search recipes…',
                  hintStyle: const TextStyle(color: Color(0xFF8FA0B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA0B8)),
                  filled: true,
                  fillColor: const Color(0xFF142346),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _search = v.trim()),
              ),
            ),
            // List
            Expanded(
              child: recipesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.recipeBrowserLoadError ??
                              'Could not load recipes',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () =>
                              ref.invalidate(_recipesProvider(_search)),
                          icon: const Icon(Icons.refresh,
                              color: AppColors.primary),
                          label: Text(
                            l10n?.commonRetry ?? 'Try again',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (recipes) => recipes.isEmpty
                    ? _EmptyState(l10n: l10n)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: recipes.length,
                        itemBuilder: (context, i) => _RecipeTile(
                          recipe: recipes[i],
                          defaultDay: widget.defaultDay,
                          onAdded: () => Navigator.of(context).pop(),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.recipeBrowserEmpty ?? 'No recipes found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.recipeBrowserEmptyHint ??
                  'The recipe library will grow soon. Try adding meals manually.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeTile extends ConsumerWidget {
  const _RecipeTile({
    required this.recipe,
    required this.defaultDay,
    required this.onAdded,
  });

  final RecipeResponse recipe;
  final DateTime defaultDay;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        leading: recipe.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imageUrl!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PlaceholderIcon(),
                ),
              )
            : const _PlaceholderIcon(),
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              l10n?.recipeBrowserCaloriesPerServing(
                      recipe.caloriesPerServing) ??
                  '${recipe.caloriesPerServing} kcal / serving',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n?.recipeBrowserProtein ?? 'Protein'} ${recipe.proteinG.toInt()}g  '
              '${l10n?.recipeBrowserCarbs ?? 'Carbs'} ${recipe.carbsG.toInt()}g  '
              '${l10n?.recipeBrowserFat ?? 'Fat'} ${recipe.fatG.toInt()}g',
              style: const TextStyle(
                color: Color(0xFF8FA0B8),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.primary, size: 26),
          tooltip: l10n?.recipeBrowserAddToPlan ?? 'Add to plan',
          onPressed: () => _showAddDialog(context, ref, l10n),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations? l10n,
  ) async {
    final result = await showDialog<_AddResult>(
      context: context,
      builder: (ctx) => _AddToPlanDialog(
        recipe: recipe,
        defaultDay: defaultDay,
        l10n: l10n,
      ),
    );
    if (result == null) return;

    try {
      await ref.read(mealPlannerRepositoryProvider).createPlanEntryFromRecipe(
            planDate: result.day,
            mealType: result.mealType,
            recipeId: recipe.id,
            servings: result.servings,
          );
      refreshPlanner(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n?.recipeBrowserAdded ?? 'Added to plan'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      onAdded();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
                l10n?.recipeBrowserAddFailed ?? 'Could not add to plan'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant_rounded,
          color: AppColors.primary, size: 24),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add-to-plan dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AddResult {
  final DateTime day;
  final String mealType;
  final double servings;
  const _AddResult({
    required this.day,
    required this.mealType,
    required this.servings,
  });
}

class _AddToPlanDialog extends StatefulWidget {
  const _AddToPlanDialog({
    required this.recipe,
    required this.defaultDay,
    required this.l10n,
  });

  final RecipeResponse recipe;
  final DateTime defaultDay;
  final AppLocalizations? l10n;

  @override
  State<_AddToPlanDialog> createState() => _AddToPlanDialogState();
}

class _AddToPlanDialogState extends State<_AddToPlanDialog> {
  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  late DateTime _day;
  String _mealType = 'lunch';
  double _servings = 1.0;

  @override
  void initState() {
    super.initState();
    _day = widget.defaultDay;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      backgroundColor: const Color(0xFF142346),
      title: Text(
        widget.recipe.name,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day picker
          _FieldLabel(l10n?.recipeBrowserDay ?? 'Day'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _pickDay(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF050A1F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${_day.year}-${_day.month.toString().padLeft(2, '0')}-${_day.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Meal type picker
          _FieldLabel(l10n?.recipeBrowserMealType ?? 'Meal type'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _mealType,
            dropdownColor: const Color(0xFF142346),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF050A1F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _mealTypes
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t[0].toUpperCase() + t.substring(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _mealType = v ?? 'lunch'),
          ),
          const SizedBox(height: 14),
          // Servings stepper
          _FieldLabel(l10n?.recipeBrowserServingsLabel ?? 'Servings'),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                onPressed: _servings > 0.5
                    ? () => setState(() => _servings -= 0.5)
                    : null,
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.primary),
              ),
              Text(
                _servings.toStringAsFixed(
                    _servings == _servings.floorToDouble() ? 0 : 1),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: _servings < 10
                    ? () => setState(() => _servings += 0.5)
                    : null,
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n?.commonCancel ?? 'Cancel',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(
            _AddResult(day: _day, mealType: _mealType, servings: _servings),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          child: Text(
            l10n?.recipeBrowserAddToPlan ?? 'Add to plan',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDay(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _day = picked);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8FA0B8),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
