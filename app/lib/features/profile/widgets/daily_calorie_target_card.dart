import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

import '../models/user_profile.dart';
import '../models/weekly_analytics.dart';

/// Large hero card: daily calorie target with a mini progress donut that
/// shows today's consumption against the goal.
///
/// Layout (left → right):
///   [   Daily target            ]
///   [   3,269 kcal              ]   [DONUT — 38% consumed]
///   [   1,247 left              ]
class DailyCalorieTargetCard extends StatelessWidget {
  final UserProfile profile;
  final TodaySummary todaySummary;

  const DailyCalorieTargetCard({
    super.key,
    required this.profile,
    required this.todaySummary,
  });

  @override
  Widget build(BuildContext context) {
    final target = profile.dailyCalorieTarget;
    final consumed = todaySummary.caloriesConsumed;
    final remaining = (target - consumed).clamp(-9999, 99999).toInt();
    final fraction = todaySummary.progressFraction;
    final percentLabel = (fraction * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryCyan.withValues(alpha: 0.18),
            AppColors.cyanGlow.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryCyan.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: target + remaining numbers
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Target',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                RichText(
                  text: TextSpan(
                    style: AppTypography.heroLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(text: _formatNumber(target)),
                      TextSpan(
                        text: ' kcal',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Icon(
                      remaining > 0
                          ? Icons.arrow_downward_rounded
                          : Icons.check_circle_outline,
                      size: 16,
                      color: remaining > 0
                          ? AppColors.primaryCyan
                          : AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Text(
                      remaining > 0
                          ? '${_formatNumber(remaining)} kcal left today'
                          : 'Daily target reached',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: mini donut
          SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _DonutPainter(
                fraction: fraction,
                trackColor: Colors.white.withValues(alpha: 0.08),
                progressColor: AppColors.primaryCyan,
                glowColor: AppColors.cyanGlow,
              ),
              child: Center(
                child: Text(
                  '$percentLabel%',
                  style: AppTypography.cardTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _DonutPainter extends CustomPainter {
  final double fraction; // 0..1
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  _DonutPainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (fraction <= 0) return;

    // Glow underlay
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = glowColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      glowPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [progressColor, glowColor, progressColor],
      ).createShader(rect);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.fraction != fraction ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.glowColor != glowColor;
}
