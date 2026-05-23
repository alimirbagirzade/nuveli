import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/ai_insight.dart';
import 'tip_icon_map.dart';

class TipTile extends StatelessWidget {
  const TipTile({super.key, required this.tip});
  final CoachTip tip;

  @override
  Widget build(BuildContext context) {
    final tint = TipIconMap.tintFor(tip.icon);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              TipIconMap.iconFor(tip.icon),
              color: tint,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tip.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tip.description,
                    style: const TextStyle(
                      color: Color(0xFFB8D4D2),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
