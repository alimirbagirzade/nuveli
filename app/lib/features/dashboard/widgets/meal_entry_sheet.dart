import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repositories/meals_repository.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/dashboard_provider.dart';

/// Bottom-sheet form for the "Add Food" CTA on the dashboard.
///
/// Until the AI meal-scan UI lands (F1 in the launch gap doc), this is
/// the only way to log a meal from the app. Keep it fast:
///   - Required: name + calories
///   - Optional: macros (P/C/F), meal type (defaults from time of day)
///   - One-tap save with optimistic dashboard refresh on success
class MealEntrySheet extends ConsumerStatefulWidget {
  const MealEntrySheet({super.key});

  /// Convenience opener. Returns true on successful save.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const MealEntrySheet(),
    );
  }

  @override
  ConsumerState<MealEntrySheet> createState() => _MealEntrySheetState();
}

class _MealEntrySheetState extends ConsumerState<MealEntrySheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _caloriesCtrl = TextEditingController();
  final TextEditingController _proteinCtrl = TextEditingController();
  final TextEditingController _carbsCtrl = TextEditingController();
  final TextEditingController _fatCtrl = TextEditingController();

  late String _mealType;
  bool _isSaving = false;
  String? _formError;

  static const List<String> _mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  @override
  void initState() {
    super.initState();
    _mealType = _defaultMealTypeForNow();
  }

  /// Cheap heuristic — saves the user a tap most of the time.
  static String _defaultMealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 15) return 'lunch';
    if (h < 17) return 'snack';
    if (h < 22) return 'dinner';
    return 'snack';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameCtrl.text.trim();
    final calories = int.tryParse(_caloriesCtrl.text.trim());
    if (name.isEmpty) {
      setState(() => _formError = 'Food name is required');
      return;
    }
    if (calories == null || calories <= 0) {
      setState(() => _formError = 'Enter a calorie value (> 0)');
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      final repo = ref.read(mealsRepositoryProvider);
      await repo.createMeal(
        name: name,
        totalCalories: calories,
        proteinG: double.tryParse(_proteinCtrl.text.trim()) ?? 0,
        carbsG: double.tryParse(_carbsCtrl.text.trim()) ?? 0,
        fatG: double.tryParse(_fatCtrl.text.trim()) ?? 0,
        mealType: _mealType,
      );
      // Invalidate without awaiting the refetch — sheet closes
      // immediately; dashboard updates as soon as the new query
      // resolves. Awaiting here would block the close on a network
      // round-trip and confuse the user.
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(todayMealsProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = 'Could not save: ${e.toString().split('\n').first}';
          _isSaving = false;
        });
      }
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
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add Food',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _MealTypePicker(
              types: _mealTypes,
              selected: _mealType,
              onSelect: (t) => setState(() => _mealType = t),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'What did you eat?',
              hint: 'e.g. Greek yogurt with berries',
              controller: _nameCtrl,
              keyboardType: TextInputType.text,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Calories (kcal)',
              hint: 'e.g. 180',
              controller: _caloriesCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Protein (g)',
                    hint: '0',
                    controller: _proteinCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LabeledField(
                    label: 'Carbs (g)',
                    hint: '0',
                    controller: _carbsCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LabeledField(
                    label: 'Fat (g)',
                    hint: '0',
                    controller: _fatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C5C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF5C5C).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFFF8A8A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formError!,
                        style: const TextStyle(
                          color: Color(0xFFFFB3B3),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
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
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save meal',
                        style: TextStyle(
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

class _MealTypePicker extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ValueChanged<String> onSelect;

  const _MealTypePicker({
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: types.map((t) {
        final isActive = t == selected;
        return InkWell(
          onTap: () => onSelect(t),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isActive
                  ? const Color(0xFF00D4FF).withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF00D4FF).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              _capitalize(t),
              style: TextStyle(
                color: isActive ? const Color(0xFF4DDBFF) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB8C5D6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6E7B91)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
