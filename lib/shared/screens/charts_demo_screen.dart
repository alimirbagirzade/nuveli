import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/nuveli_card.dart';
import '../widgets/nuveli_background.dart';
import '../widgets/charts/calorie_ring_chart.dart';
import '../widgets/charts/macro_progress_bar.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/charts/weight_line_chart.dart';
import '../widgets/charts/macro_donut_chart.dart';
import '../widgets/charts/water_ring_chart.dart';
import '../widgets/charts/glasses_grid.dart';
import '../widgets/charts/consistency_bar_chart.dart';
import '../widgets/charts/nutrition_score_ring.dart';

/// Demo screen that renders every chart widget in [lib/shared/widgets/charts]
/// with realistic mock data. Useful as a visual smoke test after theme
/// or chart changes — open this screen and scroll top to bottom.
class ChartsDemoScreen extends StatelessWidget {
  const ChartsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock weight trend: 8 weeks slowly trending down
    final now = DateTime.now();
    final weightData = List.generate(8, (i) {
      return WeightDataPoint(
        date: now.subtract(Duration(days: (7 - i) * 7)),
        weight: 72.6 - (i * 0.5) + (i.isOdd ? 0.2 : -0.1),
      );
    });

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Charts Demo',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section(
                '1. Calorie Ring',
                const Center(
                  child: CalorieRingChart(consumed: 1480, target: 2100),
                ),
              ),
              _section(
                '2. Macro Bars',
                Row(
                  children: [
                    Expanded(
                      child: MacroProgressBar(
                        label: 'Protein',
                        current: 95,
                        target: 140,
                        icon: Icons.fitness_center,
                        color: AppColors.protein,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MacroProgressBar(
                        label: 'Carbs',
                        current: 160,
                        target: 220,
                        icon: Icons.grain,
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MacroProgressBar(
                        label: 'Fat',
                        current: 48,
                        target: 70,
                        icon: Icons.opacity,
                        color: AppColors.fat,
                      ),
                    ),
                  ],
                ),
              ),
              _section(
                '3. Weekly Calories',
                const WeeklyBarChart(
                  values: [1620, 1480, 1550, 1430, 1670, 1390, 1450],
                  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  averageLine: 1508,
                  showValuesOnTop: true,
                  maxY: 2200,
                ),
              ),
              _section(
                '4. Weight Trend',
                WeightLineChart(
                  data: weightData,
                  rangeLabel: 'Last 8 Weeks',
                ),
              ),
              _section(
                '5. Macro Donut',
                const MacroDonutChart(
                  proteinGrams: 95,
                  carbsGrams: 160,
                  fatGrams: 48,
                ),
              ),
              _section(
                '6. Water Ring',
                const Center(
                  child: WaterRingChart(
                    consumedLiters: 2.1,
                    targetLiters: 3.0,
                  ),
                ),
              ),
              _section(
                '7. Glasses Grid',
                GlassesGrid(
                  filledCount: 7,
                  totalCount: 10,
                  onGlassTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('+250 ml logged'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              _section(
                '8. Weekly Consistency',
                const ConsistencyBarChart(
                  dailyConsistency: [0.8, 1.0, 0.6, 0.9, 1.0, 1.0, 0.7],
                  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  highlightIndex: 5,
                  summaryText: '6 of 7 days',
                ),
              ),
              _section(
                '9. Nutrition Score',
                const Center(
                  child: NutritionScoreRing(score: 86),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NuveliCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
