import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// A single rectangular skeleton placeholder with the shimmer effect
/// already applied. Use this for "the data is loading" boxes — meal
/// cards, header bars, chart frames, anything that has a stable
/// rectangular footprint while data fetches.
///
/// Wraps with the underwater-friendly base color + the standard
/// border radius (matches Nuveli card chrome).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Fixed width. Null → expand within parent (Row/Column).
  final double? width;

  /// Fixed height. Defaults to 16 (single line of text).
  final double height;

  /// Corner radius. Defaults to 8 (cards/buttons), use 0 for
  /// edge-to-edge or [height]/2 for pill shapes.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
    return Shimmer.fromColors(
      baseColor: const Color(0xFF142346),
      highlightColor: AppColors.primaryCyan.withValues(alpha: 0.18),
      period: const Duration(milliseconds: 1400),
      child: box,
    );
  }
}

/// A circular skeleton placeholder. Useful for avatars, icon slots,
/// the calorie ring chart before its data lands.
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SkeletonBox(
        width: size,
        height: size,
        borderRadius: size / 2,
      );
}
