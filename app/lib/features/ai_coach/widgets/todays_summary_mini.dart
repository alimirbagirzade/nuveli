import 'package:flutter/material.dart';

import '../models/nutrition_score.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Compact 4-cell macro row. Numbers come from the same source as the
/// Dashboard, so the AI Coach screen always stays consistent with home.
class TodaysSummaryMini extends StatelessWidget {
  final TodaysMacros macros;

  const TodaysSummaryMini({super.key, required this.macros});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            "Today's Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _MacroCell(
                  value: _formatNumber(macros.calories),
                  unit: 'kcal',
                  label: 'Calories',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.proteinG}',
                  unit: 'g',
                  label: 'Protein',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.carbsG}',
                  unit: 'g',
                  label: 'Carbs',
                ),
              ),
              const _Divider(),
              Expanded(
                child: _MacroCell(
                  value: '${macros.fatG}',
                  unit: 'g',
                  label: 'Fat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 1480 → "1,480"
  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _MacroCell extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _MacroCell({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: _cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: _secondaryText.withOpacity(0.15),
    );
  }
}
