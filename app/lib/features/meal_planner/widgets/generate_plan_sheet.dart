import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meal_planner_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/planner_providers.dart';
import 'planner_form_fields.dart';

/// Premium AI generate sheet — collects dietary preferences, then calls
/// `POST /meal-plans/generate` for the given week. Gating happens upstream
/// (the screen routes free users to the paywall before opening this).
class GeneratePlanSheet extends ConsumerStatefulWidget {
  const GeneratePlanSheet({super.key, required this.weekStart});

  final DateTime weekStart;

  static Future<void> show(BuildContext context, {required DateTime weekStart}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GeneratePlanSheet(weekStart: weekStart),
    );
  }

  @override
  ConsumerState<GeneratePlanSheet> createState() => _GeneratePlanSheetState();
}

class _GeneratePlanSheetState extends ConsumerState<GeneratePlanSheet> {
  final _dietCtrl = TextEditingController();
  final _avoidCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int _mealsPerDay = 4;
  bool _isGenerating = false;
  String? _formError;

  static const _mealsOptions = [3, 4, 5];

  @override
  void initState() {
    super.initState();
    // Prefill the calorie target from the profile if it's already loaded.
    final target =
        ref.read(profileProvider).valueOrNull?.dailyCalorieTarget;
    if (target != null && target > 0) {
      _targetCtrl.text = target.toString();
    }
  }

  @override
  void dispose() {
    _dietCtrl.dispose();
    _avoidCtrl.dispose();
    _targetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_isGenerating) return;

    int? target = int.tryParse(_targetCtrl.text.trim());
    if (target != null && (target < 800 || target > 6000)) {
      setState(() => _formError = 'Calorie target must be 800–6000');
      return;
    }

    final avoid = _avoidCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      _isGenerating = true;
      _formError = null;
    });

    try {
      final repo = ref.read(mealPlannerRepositoryProvider);
      final result = await repo.generateWeeklyPlan(
        weekStart: widget.weekStart,
        mealsPerDay: _mealsPerDay,
        targetCalories: target,
        dietaryPreference: _dietCtrl.text.trim(),
        avoidIngredients: avoid,
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      refreshPlanner(ref);
      // Capture the messenger BEFORE popping — after pop this sheet's
      // context is defunct. The messenger lives above the modal route, so
      // the snackbar still shows on the planner screen.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Text(
              '${result.plansCreated} meals planned for your week.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = 'Could not generate: ${e.toString().split('\n').first}';
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const PlannerSheetHeader(title: 'Generate AI plan'),
            const SizedBox(height: 6),
            const Text(
              'Your coach drafts a full week. Tweak the details below — all '
              'optional.',
              style: TextStyle(color: Color(0xFFB8D4D2), fontSize: 13),
            ),
            const SizedBox(height: 16),
            PlannerLabeledField(
              label: 'Dietary preference (optional)',
              hint: 'e.g. high-protein, vegetarian, Mediterranean',
              controller: _dietCtrl,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            PlannerLabeledField(
              label: 'Avoid ingredients (comma-separated)',
              hint: 'e.g. peanuts, shellfish',
              controller: _avoidCtrl,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            PlannerLabeledField(
              label: 'Daily calorie target (optional)',
              hint: 'e.g. 2000',
              controller: _targetCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            const Text(
              'Meals per day',
              style: TextStyle(
                color: Color(0xFFB8D4D2),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _mealsOptions.map((n) {
                final active = n == _mealsPerDay;
                return InkWell(
                  onTap: () => setState(() => _mealsPerDay = n),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: active
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                        color: active ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            PlannerLabeledField(
              label: 'Anything else? (optional)',
              hint: 'e.g. quick breakfasts, batch-cook dinners',
              controller: _noteCtrl,
              maxLength: 500,
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              PlannerFormError(message: _formError!),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generate,
                icon: _isGenerating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white),
                label: Text(
                  _isGenerating ? 'Generating…' : 'Generate plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
