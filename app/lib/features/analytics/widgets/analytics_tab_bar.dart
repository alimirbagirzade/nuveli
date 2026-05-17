import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';

/// Analytics ekranı için 4 sekmeli tab bar.
///
/// Sekmeler: Overview | Nutrition | Meals | Trends
/// Seçili sekmenin altında 3px kalınlığında cyan underline gösterir.
class AnalyticsTabBar extends StatelessWidget {
  final TabController controller;

  const AnalyticsTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textTertiary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicatorColor: AppColors.primaryCyan,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primaryCyan,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Nutrition'),
          Tab(text: 'Meals'),
          Tab(text: 'Trends'),
        ],
      ),
    );
  }
}
