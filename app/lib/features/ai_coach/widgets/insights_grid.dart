import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nuveli_card.dart';
import '../models/ai_insight.dart';

/// 2x2 grid of small AI insights.
///
/// Uses an inline tile rather than depending on `InsightCard.icon` from
/// Chat 3, so this screen compiles even if that variant lands later.
/// When Chat 3's icon variant is ready, swap `_SmallInsightTile` for it.
class InsightsGrid extends StatelessWidget {
  final List<AIInsight> insights;

  const InsightsGrid({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    // Defensive: pad/trim to exactly 4 so layout never breaks.
    final tiles = insights.take(4).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        // Aspect ratio ~1.45 keeps text breathing room without going too tall.
        final tileHeight = tileWidth / 1.45;

        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: tiles.isNotEmpty
                      ? _SmallInsightTile(insight: tiles[0])
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: tiles.length > 1
                      ? _SmallInsightTile(insight: tiles[1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: tiles.length > 2
                      ? _SmallInsightTile(insight: tiles[2])
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: tileWidth,
                  height: tileHeight,
                  child: tiles.length > 3
                      ? _SmallInsightTile(insight: tiles[3])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SmallInsightTile extends StatelessWidget {
  final AIInsight insight;

  const _SmallInsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    return NuveliCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: insight.iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(insight.icon, size: 20, color: insight.iconColor),
          ),
          const Spacer(),
          Text(
            insight.headline,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            insight.supportingText,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
