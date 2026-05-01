import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Skeleton loader — animasyonlu gradient shimmer ile placeholder gösterir.
/// Spinner'dan çok daha iyi UX: kullanıcı gelecek içeriğin şeklini görür.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        // -1 → 2 arası değer: gradient soldan sağa kayar
        final t = _controller.value * 3 - 1;
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: [
                AppColors.surface,
                AppColors.surfaceElevated,
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Kart iskeletonu — genişlik full, belirli yükseklik.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 120});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      height: height,
      borderRadius: 16,
    );
  }
}

/// Liste öğesi iskeletonu — row with avatar + 2 satır metin.
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const SkeletonBox(width: 36, height: 36, borderRadius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 100, height: 11),
              ],
            ),
          ),
          const SkeletonBox(width: 60, height: 16),
        ],
      ),
    );
  }
}

/// Home ekranı için komple skeleton — daily summary + quick actions + meal list.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Daily summary card
        SkeletonCard(height: 140),
        SizedBox(height: 16),
        // Quick actions grid (2x2 gibi)
        Row(
          children: [
            Expanded(child: SkeletonCard(height: 90)),
            SizedBox(width: 12),
            Expanded(child: SkeletonCard(height: 90)),
          ],
        ),
        SizedBox(height: 12),
        // Coach card
        SkeletonCard(height: 110),
        SizedBox(height: 16),
        // Mini chart
        SkeletonCard(height: 120),
        SizedBox(height: 16),
        // Meal list header
        SkeletonBox(width: 140, height: 18),
        SizedBox(height: 12),
        SkeletonListItem(),
        SkeletonListItem(),
        SkeletonListItem(),
      ],
    );
  }
}

/// Meal list için skeleton (3 item).
class MealListSkeleton extends StatelessWidget {
  const MealListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: SkeletonBox(width: 140, height: 14),
          ),
          Divider(height: 1),
          SkeletonListItem(),
          SkeletonListItem(),
          SkeletonListItem(),
        ],
      ),
    );
  }
}
