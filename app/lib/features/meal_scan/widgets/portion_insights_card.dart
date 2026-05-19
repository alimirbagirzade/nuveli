import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/portion_insight.dart';

/// "Portion Insights" başlık + 64x64 donut (85%) + ana metin + highlights + chevron
class PortionInsightsCard extends StatelessWidget {
  final PortionInsight insight;
  final VoidCallback? onTap;

  const PortionInsightsCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Portion Insights',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        NuveliCard(
          onTap: onTap,
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          child: Row(
            children: [
              // Mini donut
              SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _MiniDonutPainter(score: insight.score),
                  child: Center(
                    child: Text(
                      '${insight.score}%',
                      style: AppTypography.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Metin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      insight.mainText,
                      style: AppTypography.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.highlights.join(' • '),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.secondaryText.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniDonutPainter extends CustomPainter {
  final int score;
  const _MiniDonutPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    // Arka plan halkası
    final bgPaint = Paint()
      ..color = AppColors.primaryCyan.withOpacity(0.15)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // İlerleme arc'ı
    final progressPaint = Paint()
      ..color = AppColors.primaryCyan
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweep = (score.clamp(0, 100) / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniDonutPainter old) => old.score != score;
}
