import 'package:flutter/material.dart';

import '../models/coach_recommendation.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _success = Color(0xFF1AA38C);
const Color _warning = Color(0xFFFFC857);
const Color _secondaryText = Color(0xFFB8C5D6);

class DailyRecapCard extends StatelessWidget {
  final DailyRecap recap;

  const DailyRecapCard({super.key, required this.recap});

  _RecapVisuals get _visuals {
    switch (recap.status) {
      case RecapStatus.onTrack:
        return _RecapVisuals(
          icon: Icons.check_circle_outline,
          color: _success,
        );
      case RecapStatus.behind:
        return _RecapVisuals(
          icon: Icons.warning_amber_rounded,
          color: _warning,
        );
      case RecapStatus.ahead:
        return _RecapVisuals(
          icon: Icons.rocket_launch_outlined,
          color: _cyan,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visuals;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: v.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(v.icon, size: 22, color: v.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Recap',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recap.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapVisuals {
  final IconData icon;
  final Color color;
  _RecapVisuals({required this.icon, required this.color});
}
