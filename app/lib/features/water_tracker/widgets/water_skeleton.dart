import 'package:flutter/material.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';

/// Loading state — ekran yüklenirken gösterilen iskelet (skeleton) widget.
///
/// `shimmer` paketi yokken bile çalışacak şekilde basit placeholder
/// kutuları kullanır. Hafif animasyon için `AnimatedOpacity` ile fade in/out.
class WaterSkeleton extends StatefulWidget {
  const WaterSkeleton({super.key});

  @override
  State<WaterSkeleton> createState() => _WaterSkeletonState();
}

class _WaterSkeletonState extends State<WaterSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = 0.4 + (_controller.value * 0.4);
          return Opacity(opacity: opacity, child: child);
        },
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header placeholder.
              _bar(height: 32),
              const SizedBox(height: 24),
              // Halka placeholder (220x220 daire).
              Center(child: _circle(220)),
              const SizedBox(height: 20),
              // 3 buton placeholder.
              Row(
                children: [
                  Expanded(child: _bar(height: 56)),
                  const SizedBox(width: 12),
                  Expanded(child: _bar(height: 56)),
                  const SizedBox(width: 12),
                  Expanded(child: _bar(height: 56)),
                ],
              ),
              const SizedBox(height: 20),
              // Bardak ızgarası placeholder.
              _bar(height: 70),
              const SizedBox(height: 20),
              // İki kart yan yana.
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _bar(height: 200)),
                    const SizedBox(width: 12),
                    Expanded(child: _bar(height: 200)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Insight placeholder.
              _bar(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}
