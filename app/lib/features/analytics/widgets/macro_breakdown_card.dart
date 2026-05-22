import 'package:flutter/material.dart';

import '../models/weekly_analytics.dart';

/// Three-bar macro breakdown for the analytics screen. Shows the
/// 7-day average % of protein/carbs/fat plus the user's target band
/// labels so they can see how close they are to a balanced split.
class MacroBreakdownCard extends StatelessWidget {
  final MacroPercentages avg;

  const MacroBreakdownCard({super.key, required this.avg});

  static const _protein = Color(0xFF3DDC97);
  static const _carbs = Color(0xFF4DDBFF);
  static const _fat = Color(0xFFFFB454);

  @override
  Widget build(BuildContext context) {
    if (!avg.hasData) {
      return _empty();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macro breakdown',
            style: TextStyle(
              color: Color(0xFFB8C5D6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '7-day average',
            style: TextStyle(color: Color(0xFF6E7B91), fontSize: 11),
          ),
          const SizedBox(height: 14),
          // Stacked horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: avg.protein.round().clamp(0, 100),
                    child: Container(color: _protein),
                  ),
                  Expanded(
                    flex: avg.carbs.round().clamp(0, 100),
                    child: Container(color: _carbs),
                  ),
                  Expanded(
                    flex: avg.fat.round().clamp(0, 100),
                    child: Container(color: _fat),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: _protein, label: 'Protein', percent: avg.protein),
              const SizedBox(width: 12),
              _Legend(color: _carbs, label: 'Carbs', percent: avg.carbs),
              const SizedBox(width: 12),
              _Legend(color: _fat, label: 'Fat', percent: avg.fat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Center(
        child: Text(
          'Macro breakdown shows up once you log a meal',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB8C5D6), fontSize: 13),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;

  const _Legend({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ${percent.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
