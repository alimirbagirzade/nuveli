import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/weekly_plan.dart';
import '../providers/planner_providers.dart';
import 'planner_form_fields.dart';

/// Bottom sheet to rename / re-note an existing plan entry (PATCH).
///
/// Only name + note are editable — the backend PATCH path does not
/// recompute `total_*`, so changing servings/calories goes through
/// delete + re-add instead (see [MealPlannerRepository.updatePlanEntry]).
class EditMealPlanSheet extends ConsumerStatefulWidget {
  const EditMealPlanSheet({super.key, required this.entry});

  final MealPlanEntry entry;

  static Future<bool?> show(BuildContext context, MealPlanEntry entry) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditMealPlanSheet(entry: entry),
    );
  }

  @override
  ConsumerState<EditMealPlanSheet> createState() => _EditMealPlanSheetState();
}

class _EditMealPlanSheetState extends ConsumerState<EditMealPlanSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;
  late final bool _isRecipe;
  bool _isSaving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    // Recipe-linked entries keep their recipe name; only custom entries
    // expose a name field. Both can edit the note.
    _isRecipe = widget.entry.recipeName != null &&
        widget.entry.recipeName!.isNotEmpty;
    _nameCtrl = TextEditingController(text: widget.entry.customName ?? '');
    _noteCtrl = TextEditingController(text: widget.entry.note ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    if (!_isRecipe && name.isEmpty) {
      setState(() => _formError =
          l10n?.plannerMealNameRequired ?? 'Meal name is required');
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      final repo = ref.read(mealPlannerRepositoryProvider);
      await repo.updatePlanEntry(
        planId: widget.entry.id,
        customName: _isRecipe ? null : name,
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      refreshPlanner(ref);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = 'Could not save: ${e.toString().split('\n').first}';
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
              title: l10n?.plannerEditEntry ?? 'Edit entry',
            ),
            const SizedBox(height: 16),
            if (_isRecipe)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.entry.recipeName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              PlannerLabeledField(
                label: l10n?.plannerMealName ?? 'Meal name',
                hint: l10n?.plannerHintMealName ?? 'e.g. Grilled chicken salad',
                controller: _nameCtrl,
                autofocus: true,
                maxLength: 120,
              ),
            const SizedBox(height: 12),
            PlannerLabeledField(
              label: l10n?.plannerNoteOptional ?? 'Note (optional)',
              hint: l10n?.plannerHintEditNote ?? 'e.g. swap for leftovers',
              controller: _noteCtrl,
              maxLength: 200,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.plannerEditCaloriesHint ??
                  'To change calories or servings, delete this entry and add it '
                  'again.',
              style: const TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
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
                        l10n?.mealScanSaveChanges ?? 'Save changes',
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
}
