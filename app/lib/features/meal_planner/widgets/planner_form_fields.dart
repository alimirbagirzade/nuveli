import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Shared form primitives for the meal-planner write sheets (add / edit /
/// generate). Styled with [AppColors] so they match the planner surface,
/// unlike the dashboard's `meal_entry_sheet` which predates the token set.

const List<String> kPlannerMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

/// Time-of-day heuristic so the add sheet preselects a sensible meal type.
String defaultMealTypeForNow() {
  final h = DateTime.now().hour;
  if (h < 11) return 'breakfast';
  if (h < 15) return 'lunch';
  if (h < 17) return 'snack';
  if (h < 22) return 'dinner';
  return 'snack';
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Maps a meal-type slug ('breakfast'|'lunch'|'dinner'|'snack') to its
/// localized label, falling back to a capitalized slug for unknown values.
String localizedMealTypeLabel(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context);
  switch (type) {
    case 'breakfast':
      return l10n?.mealTypeBreakfast ?? capitalize(type);
    case 'lunch':
      return l10n?.mealTypeLunch ?? capitalize(type);
    case 'dinner':
      return l10n?.mealTypeDinner ?? capitalize(type);
    case 'snack':
      return l10n?.mealTypeSnack ?? capitalize(type);
    default:
      return capitalize(type);
  }
}

class PlannerLabeledField extends StatelessWidget {
  const PlannerLabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.autofocus = false,
    this.maxLength,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB8D4D2),
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
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: const TextStyle(color: Color(0xFF6E7B91)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class PlannerMealTypePicker extends StatelessWidget {
  const PlannerMealTypePicker({
    super.key,
    required this.selected,
    required this.onSelect,
    this.types = kPlannerMealTypes,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              localizedMealTypeLabel(context, t),
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Inline error banner shared by the sheets.
class PlannerFormError extends StatelessWidget {
  const PlannerFormError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF8A8A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFB3B3), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drag handle + title row used at the top of each sheet.
class PlannerSheetHeader extends StatelessWidget {
  const PlannerSheetHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
