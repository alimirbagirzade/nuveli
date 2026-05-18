import 'package:flutter/material.dart';

import '../models/ai_insight.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _warning = Color(0xFFFFC857);
const Color _secondaryText = Color(0xFFB8C5D6);

/// The headline insight at the top of the AI Coach screen.
/// A cyan vertical accent on the left ties it visually to the score ring above.
class TodaysInsightCard extends StatelessWidget {
  final AIInsight insight;

  const TodaysInsightCard({super.key, required this.insight});

  Color get _accent {
    switch (insight.tone) {
      case InsightTone.positive:
        return _cyan;
      case InsightTone.warning:
        return _warning;
      case InsightTone.neutral:
        return _cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent stripe with subtle glow
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(insight.icon, size: 22, color: accent),
                        const SizedBox(width: 8),
                        const Text(
                          "Today's Insight",
                          style: TextStyle(
                            color: _secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insight.headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.supportingText,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
