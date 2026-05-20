// lib/features/premium/widgets/premium_badge.dart
//
// Premium kullanıcıları işaretleyen küçük "PRO" rozeti.
// Profile screen header'ında, settings'te, vs. kullanılır.

import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final double height;
  final String label;
  final bool compact;

  const PremiumBadge({
    super.key,
    this.height = 22,
    this.label = 'PRO',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.35),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            const Icon(
              Icons.workspace_premium_rounded,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
