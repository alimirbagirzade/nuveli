import 'package:flutter/material.dart';

import '../models/today_summary.dart';

/// Row of three macro cards: Protein, Carbs, Fat.
/// Each shows current/target grams + a thin progress bar.
class MacrosRow extends StatelessWidget {
  final TodaySummary summary;
  const MacrosRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _MacroCard(
              label: 'Protein',
              current: summary.consumedProteinG,
              target: summary.dailyProteinTargetG,
              color: const Color(0xFF3DDC97),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MacroCard(
              label: 'Carbs',
              current: summary.consumedCarbsG,
              target: summary.dailyCarbsTargetG,
              color: const Color(0xFF6BCB77),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MacroCard(
              label: 'Fat',
              current: summary.consumedFatG,
              target: summary.dailyFatTargetG,
              color: const Color(0xFFFF9F45),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF142346).withOpacity(0.5),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8C5D6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${current.round()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: ' / ${target.round()}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6E7B91),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
