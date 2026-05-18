import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/meal_plan.dart';
import 'providers/meal_planner_provider.dart';
import 'widgets/create_plan_button.dart';
import 'widgets/daily_total_card.dart';
import 'widgets/grocery_summary_card.dart';
import 'widgets/meal_plan_card.dart';
import 'widgets/meal_planner_header.dart';
import 'widgets/today_week_toggle.dart';
import 'widgets/weekly_calendar.dart';

/// Main screen for Görsel 6 — "Plan Meals Ahead".
///
/// Structure (top → bottom, all inside a scrollable column):
///   1. Header (logo / title / settings)
///   2. Today/Week pill toggle
///   3. WeeklyCalendar (7-day strip, Mon 20 → Sun 26)
///   4. _MealsListCard (4 stacked [MealPlanCard])
///   5. DailyTotalCard
///   6. GrocerySummaryCard
///   7. CreatePlanButton CTA
///   8. Bottom nav (Meals tab selected)
class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  PlannerView _view = PlannerView.week;
  DateTime _selectedDate = DateTime(2026, 5, 20); // matches the mockup

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(mealPlannerProvider(_selectedDate));

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050A1F), Color(0xFF0B1A3D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: asyncData.when(
            loading: () => const _PlannerSkeleton(),
            error: (e, _) => _PlannerError(message: e.toString()),
            data: (data) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: MealPlannerHeader(onSettingsTap: () {
                    // Settings nav wired in Chat 12 (routing).
                  }),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      TodayWeekToggle(
                        currentView: _view,
                        onChanged: (v) => setState(() => _view = v),
                      ),
                      const SizedBox(height: 16),
                      WeeklyCalendar(
                        selectedDate: _selectedDate,
                        weekData: data.weekCalories,
                        onDateSelected: (d) => setState(() => _selectedDate = d),
                      ),
                      const SizedBox(height: 16),
                      _MealsListCard(meals: data.todaysPlans),
                      const SizedBox(height: 12),
                      DailyTotalCard(
                        consumed: data.dailyTotal,
                        target: data.targetCalories,
                      ),
                      const SizedBox(height: 12),
                      GrocerySummaryCard(
                        items: data.groceryItems,
                        totalCount: data.groceryItemCount,
                      ),
                      const SizedBox(height: 20),
                      CreatePlanButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Create Plan — AI generation wired in Chat 14.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const _MealsBottomNav(),
      ),
    );
  }
}

/// Wraps the 4 [MealPlanCard] rows in a single glass card with hairline
/// dividers between rows.
class _MealsListCard extends StatelessWidget {
  final List<MealPlan> meals;
  const _MealsListCard({required this.meals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < meals.length; i++)
            MealPlanCard(
              plan: meals[i],
              showDivider: i < meals.length - 1,
              onTap: () {
                // Recipe detail nav wired in Chat 12.
              },
            ),
        ],
      ),
    );
  }
}

class _PlannerSkeleton extends StatelessWidget {
  const _PlannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF00D4FF)),
      ),
    );
  }
}

class _PlannerError extends StatelessWidget {
  final String message;
  const _PlannerError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFFF5C5C),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline placeholder bottom nav. In Chat 12 this is replaced with
/// `NuveliBottomNav(currentIndex: 1, onTap: ...)` from `lib/shared/widgets/`.
class _MealsBottomNav extends StatelessWidget {
  const _MealsBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A1F).withOpacity(0.92),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 26, left: 16, right: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.bar_chart_outlined, label: 'Dashboard'),
          _NavItem(
            icon: Icons.restaurant,
            label: 'Meals',
            selected: true,
          ),
          _NavItem(icon: Icons.show_chart, label: 'Analytics'),
          _NavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF00D4FF)
        : const Color(0xFFB8C5D6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
