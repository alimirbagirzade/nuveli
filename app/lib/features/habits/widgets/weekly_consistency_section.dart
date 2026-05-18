import 'package:flutter/material.dart';

import '../models/habits_screen_data.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _cyanGlow = Color(0xFF4DDBFF);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Section: "Weekly Consistency" header (with "6 of 7 days" badge) +
/// a 7-pill consistency bar chart. Highlighted bar is brighter & boxed.
class WeeklyConsistencySection extends StatelessWidget {
  final WeeklyConsistencyData data;

  const WeeklyConsistencySection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Weekly Consistency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${data.completedDays} of ${data.totalDays} days',
                style: const TextStyle(
                  color: _cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: _ConsistencyBars(data: data),
        ),
      ],
    );
  }
}

class _ConsistencyBars extends StatelessWidget {
  final WeeklyConsistencyData data;
  const _ConsistencyBars({required this.data});

  static const double _maxBarHeight = 90;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.dailyConsistency.length, (i) {
        final value = data.dailyConsistency[i].clamp(0.0, 1.0);
        final isHighlighted = i == data.highlightIndex;
        final label = i < data.dayLabels.length ? data.dayLabels[i] : '';
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _maxBarHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _Pill(
                    value: value,
                    maxHeight: _maxBarHeight,
                    highlighted: isHighlighted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : _secondaryText,
                  fontSize: 11,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Pill extends StatelessWidget {
  final double value;
  final double maxHeight;
  final bool highlighted;

  const _Pill({
    required this.value,
    required this.maxHeight,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final height = (maxHeight * value).clamp(8.0, maxHeight);
    return Container(
      width: 18,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlighted
              ? const [_cyanGlow, _cyan]
              : [_cyan.withOpacity(0.55), _cyan.withOpacity(0.30)],
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: _cyan.withOpacity(0.6),
                  blurRadius: 10,
                ),
              ]
            : null,
        border: highlighted
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
            : null,
      ),
    );
  }
}
