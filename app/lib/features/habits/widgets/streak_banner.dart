import 'package:flutter/material.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _cyanGlow = Color(0xFF4DDBFF);
const Color _orange = Color(0xFFFF6B35);
const Color _orangeBright = Color(0xFFFF9F45);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Top banner combining a streak headline with today's progress bar.
///
/// Composition is fully inline (no external `NuveliCard` / `StreakCard`
/// widgets needed). Two stacked cards per the mockup:
///   1. 🔥 18 day streak — Keep it up! You're doing great.
///   2. "4 of 5 habits completed" + cyan progress bar
class StreakBanner extends StatelessWidget {
  final int streakDays;
  final int habitsCompleted;
  final int habitsTotal;

  const StreakBanner({
    super.key,
    required this.streakDays,
    required this.habitsCompleted,
    required this.habitsTotal,
  });

  double get _progress =>
      habitsTotal <= 0 ? 0.0 : (habitsCompleted / habitsTotal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StreakHeadlineCard(streakDays: streakDays),
        const SizedBox(height: 12),
        _ProgressCard(
          completed: habitsCompleted,
          total: habitsTotal,
          progress: _progress,
        ),
      ],
    );
  }
}

// ─── Card 1: streak headline ─────────────────────────────────────────────────

class _StreakHeadlineCard extends StatelessWidget {
  final int streakDays;
  const _StreakHeadlineCard({required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Fire icon in glowing orange circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_orange, _orangeBright],
              ),
              boxShadow: [
                BoxShadow(
                  color: _orange.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(text: '$streakDays '),
                      const TextSpan(
                        text: 'day streak',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Keep it up! You're doing great.",
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    height: 1.3,
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

// ─── Card 2: progress ────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completed of $total habits completed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _AnimatedProgressBar(value: progress),
        ],
      ),
    );
  }
}

/// 8px progress bar — cyan gradient with a soft glow.
class _AnimatedProgressBar extends StatelessWidget {
  final double value;
  const _AnimatedProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 8,
              width: width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 8,
              width: width * value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [_cyan, _cyanGlow],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
