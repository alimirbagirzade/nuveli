import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/planner_providers.dart';
import 'planner_form_fields.dart';

/// Bottom sheet to add one custom meal to a plan day (POST /meal-plans).
///
/// Custom entry only (no recipe link) — `calories`/macros are the entry
/// total; servings is metadata, not a multiplier (matches the backend's
/// custom-calorie create path).
class AddMealPlanSheet extends ConsumerStatefulWidget {
  const AddMealPlanSheet({super.key, required this.initialDate});

  /// The day the user tapped "add" on. Editable in the sheet.
  final DateTime initialDate;

  /// Returns true on a successful create.
  static Future<bool?> show(BuildContext context, DateTime day) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddMealPlanSheet(initialDate: day),
    );
  }

  @override
  ConsumerState<AddMealPlanSheet> createState() => _AddMealPlanSheetState();
}

class _AddMealPlanSheetState extends ConsumerState<AddMealPlanSheet> {
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();

  late String _mealType;
  late DateTime _date;
  bool _isSaving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _mealType = defaultMealTypeForNow();
    _date = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _servingsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    final calories = int.tryParse(_caloriesCtrl.text.trim());
    if (name.isEmpty) {
      setState(() => _formError =
          l10n?.plannerMealNameRequired ?? 'Meal name is required');
      return;
    }
    if (calories == null || calories <= 0) {
      setState(() => _formError =
          l10n?.homeCaloriesRequired ?? 'Enter a calorie value (> 0)');
      return;
    }
    final servings = double.tryParse(_servingsCtrl.text.trim().replaceAll(',', '.'));
    if (servings == null || servings <= 0) {
      setState(() => _formError =
          l10n?.plannerServingsError ?? 'Servings must be greater than 0');
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      final repo = ref.read(mealPlannerRepositoryProvider);
      await repo.createPlanEntry(
        planDate: _date,
        mealType: _mealType,
        customName: name,
        customCalories: calories,
        customProteinG: double.tryParse(_proteinCtrl.text.trim()) ?? 0,
        customCarbsG: double.tryParse(_carbsCtrl.text.trim()) ?? 0,
        customFatG: double.tryParse(_fatCtrl.text.trim()) ?? 0,
        servings: servings,
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      refreshPlanner(ref);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = 'Could not add: ${e.toString().split('\n').first}';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlannerSheetHeader(
              title: l10n?.plannerAddToPlan ?? 'Add to plan',
            ),
            const SizedBox(height: 16),
            _DateRow(date: _date, onTap: _pickDate),
            const SizedBox(height: 16),
            PlannerMealTypePicker(
              selected: _mealType,
              onSelect: (t) => setState(() => _mealType = t),
            ),
            const SizedBox(height: 16),
            PlannerLabeledField(
              label: l10n?.plannerMealName ?? 'Meal name',
              hint: l10n?.plannerHintMealName ?? 'e.g. Grilled chicken salad',
              controller: _nameCtrl,
              autofocus: true,
              maxLength: 120,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: PlannerLabeledField(
                    label: l10n?.homeCaloriesKcal ?? 'Calories (kcal)',
                    hint: l10n?.plannerHintCalories ?? 'e.g. 450',
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PlannerLabeledField(
                    label: l10n?.plannerServings ?? 'Servings',
                    hint: '1',
                    controller: _servingsCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*$')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _macroField(
                    l10n?.macroProteinG ?? 'Protein (g)', _proteinCtrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _macroField(
                    l10n?.macroCarbsG ?? 'Carbs (g)', _carbsCtrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _macroField(
                    l10n?.macroFatG ?? 'Fat (g)', _fatCtrl),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PlannerLabeledField(
              label: l10n?.plannerNoteOptional ?? 'Note (optional)',
              hint: l10n?.plannerHintNote ?? 'e.g. meal prep on Sunday',
              controller: _noteCtrl,
              maxLength: 200,
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              PlannerFormError(message: _formError!),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        l10n?.plannerAddToPlan ?? 'Add to plan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroField(String label, TextEditingController ctrl) {
    return PlannerLabeledField(
      label: label,
      hint: '0',
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final label =
        '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_outlined,
                color: Color(0xFFB8D4D2), size: 18),
          ],
        ),
      ),
    );
  }
}
