import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/meal_scan_models.dart';

/// Bottom sheet: edit one detected food's name + kcal/macros.
/// Returns the edited DetectedFood (or null if cancelled).
class EditFoodSheet extends StatefulWidget {
  const EditFoodSheet({super.key, required this.initial});
  final DetectedFood initial;

  static Future<DetectedFood?> show(BuildContext context, DetectedFood food) {
    return showModalBottomSheet<DetectedFood>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A2A3D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditFoodSheet(initial: food),
    );
  }

  @override
  State<EditFoodSheet> createState() => _EditFoodSheetState();
}

class _EditFoodSheetState extends State<EditFoodSheet> {
  late final TextEditingController _name;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _calories = TextEditingController(text: widget.initial.calories.toString());
    _protein =
        TextEditingController(text: widget.initial.proteinG.toStringAsFixed(1));
    _carbs =
        TextEditingController(text: widget.initial.carbsG.toStringAsFixed(1));
    _fat = TextEditingController(text: widget.initial.fatG.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  void _save() {
    final calories = int.tryParse(_calories.text.trim()) ?? widget.initial.calories;
    final protein = double.tryParse(_protein.text.trim()) ?? widget.initial.proteinG;
    final carbs = double.tryParse(_carbs.text.trim()) ?? widget.initial.carbsG;
    final fat = double.tryParse(_fat.text.trim()) ?? widget.initial.fatG;
    final edited = widget.initial.copyWith(
      name: _name.text.trim().isEmpty ? widget.initial.name : _name.text.trim(),
      calories: calories.clamp(0, 9999),
      proteinG: protein.clamp(0, 999),
      carbsG: carbs.clamp(0, 999),
      fatG: fat.clamp(0, 999),
    );
    Navigator.of(context).pop(edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 12),
            Text(
              l10n?.mealScanEditFood ?? 'Edit food',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _Field(label: l10n?.mealScanFieldName ?? 'Name', controller: _name),
            const SizedBox(height: 12),
            _Field(
              label: l10n?.homeCaloriesKcal ?? 'Calories (kcal)',
              controller: _calories,
              numeric: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: l10n?.macroProteinG ?? 'Protein (g)',
                    controller: _protein,
                    decimal: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Field(
                    label: l10n?.macroCarbsG ?? 'Carbs (g)',
                    controller: _carbs,
                    decimal: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Field(
                    label: l10n?.macroFatG ?? 'Fat (g)',
                    controller: _fat,
                    decimal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n?.mealScanSaveChanges ?? 'Save changes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.numeric = false,
    this.decimal = false,
  });

  final String label;
  final TextEditingController controller;
  final bool numeric;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    final keyboard = decimal
        ? const TextInputType.numberWithOptions(decimal: true)
        : (numeric ? TextInputType.number : TextInputType.text);
    final formatters = decimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ]
        : (numeric
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : <TextInputFormatter>[]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB8D4D2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF051824),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
