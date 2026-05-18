import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/habit_check_tile.dart';
import '../widgets/insight_card.dart';
import '../widgets/meal_list_tile.dart';
import '../widgets/nuveli_background.dart';
import '../widgets/nuveli_bottom_nav.dart';
import '../widgets/nuveli_card.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/reminder_toggle_tile.dart';
import '../widgets/streak_card.dart';
import '../widgets/timeline_event.dart';

/// Chat 3'te üretilen tüm ortak widget'ların tek ekranda demo'su.
///
/// 12 örnek gösterir (bazı widget'ların farklı varyantları dahil):
/// 1. MealListTile.dashboard
/// 2. MealListTile.planner
/// 3. StreakCard.small
/// 4. StreakCard.large
/// 5. ReminderToggleTile (kart içinde 3 stack)
/// 6. InsightCard
/// 7. QuickAddButtons (3 boyut Row içinde)
/// 8. HabitCheckTile
/// 9. TimelineEvent (5'li sekans)
/// 10. AchievementBadges (3 yan yana)
/// 11. RecommendationCard.simple
/// 12. RecommendationCard.actionable
///
/// Bottom nav, ekranın altında ayrıca demo edilir.
class WidgetsDemoScreen extends StatefulWidget {
  const WidgetsDemoScreen({super.key});

  @override
  State<WidgetsDemoScreen> createState() => _WidgetsDemoScreenState();
}

class _WidgetsDemoScreenState extends State<WidgetsDemoScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Common Widgets Demo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // ──────────────────────────────
            // 1 & 2. MealListTile
            // ──────────────────────────────
            _section(
              '1. MealListTile — Dashboard',
              MealListTile.dashboard(
                mealType: 'Breakfast',
                foodName: 'Greek Yogurt Bowl',
                calories: 350,
                time: '7:30 AM',
                onTap: () {},
              ),
            ),
            _section(
              '2. MealListTile — Planner',
              MealListTile.planner(
                mealType: 'Lunch',
                foodName: 'Chicken Wrap',
                calories: 520,
                mealTypeIcon: '🥗',
                onTap: () {},
              ),
            ),

            // ──────────────────────────────
            // 3 & 4. StreakCard
            // ──────────────────────────────
            _section(
              '3. StreakCard — Small',
              const StreakCard(
                streakDays: 12,
                title: 'Daily Streak',
                subtitle: 'Keep it up!',
                size: StreakCardSize.small,
              ),
            ),
            _section(
              '4. StreakCard — Large',
              const StreakCard(
                streakDays: 18,
                subtitle: "Keep it up! You're doing great.",
                size: StreakCardSize.large,
              ),
            ),

            // ──────────────────────────────
            // 5. ReminderToggleTile (3'lü stack tek kartta)
            // ──────────────────────────────
            _section(
              '5. ReminderToggleTile (kart içinde 3 satır)',
              NuveliCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    ReminderToggleTile(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Morning reminder',
                      subtitle: '9:00 AM',
                      initialValue: true,
                      onChanged: (_) {},
                    ),
                    ReminderToggleTile(
                      icon: Icons.notifications_outlined,
                      title: 'Hydration Reminder',
                      subtitle: '1:00 PM • Every day',
                      initialValue: true,
                      onChanged: (_) {},
                    ),
                    ReminderToggleTile(
                      icon: Icons.nightlight_outlined,
                      title: 'Evening reminder',
                      subtitle: '6:30 PM',
                      initialValue: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),

            // ──────────────────────────────
            // 6. InsightCard (4 farklı renk)
            // ──────────────────────────────
            _section(
              '6. InsightCard',
              Column(
                children: [
                  InsightCard(
                    icon: Icons.fitness_center_rounded,
                    iconBackground: AppColors.primary,
                    title: 'Increase protein at lunch',
                    description:
                        'Aiming for 30-40g can support muscle and satiety.',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const InsightCard(
                    icon: Icons.water_drop_rounded,
                    iconBackground: Color(0xFF4DA8FF),
                    title: 'Hydrate earlier in the day',
                    description:
                        'Front-loading water supports energy and focus.',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const InsightCard(
                    icon: Icons.star_rounded,
                    iconBackground: Color(0xFF3DDC97),
                    title: 'Great consistency this week',
                    description:
                        'You hit your calorie goal 5/7 days. Keep it up!',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const InsightCard(
                    icon: Icons.nightlight_round,
                    iconBackground: Color(0xFFA78BFA),
                    title: 'Try a lighter evening snack',
                    description:
                        'Opt for protein + fiber to improve sleep quality.',
                  ),
                ],
              ),
            ),

            // ──────────────────────────────
            // 7. QuickAddButtons
            // ──────────────────────────────
            _section(
              '7. QuickAddButton (3 boyut)',
              Row(
                children: [
                  Expanded(
                    child: QuickAddButton(
                      icon: Icons.local_drink_outlined,
                      label: '+250 ml',
                      size: QuickAddSize.small,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickAddButton(
                      icon: Icons.local_drink_rounded,
                      label: '+500 ml',
                      size: QuickAddSize.medium,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickAddButton(
                      icon: Icons.water_drop_rounded,
                      label: '+1 L',
                      size: QuickAddSize.large,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // ──────────────────────────────
            // 8. HabitCheckTile (kart içinde 5'li liste)
            // ──────────────────────────────
            _section(
              '8. HabitCheckTile (5 habit kart içinde)',
              NuveliCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    HabitCheckTile(
                      icon: Icons.rice_bowl_rounded,
                      iconColor: const Color(0xFF3DDC97),
                      title: 'Log breakfast',
                      subtitle: 'Track your first meal',
                      initialChecked: true,
                      onChanged: (_) {},
                    ),
                    HabitCheckTile(
                      icon: Icons.water_drop_rounded,
                      iconColor: AppColors.primary,
                      title: 'Drink 8 glasses',
                      subtitle: 'Stay hydrated',
                      initialChecked: true,
                      onChanged: (_) {},
                    ),
                    HabitCheckTile(
                      icon: Icons.directions_walk_rounded,
                      iconColor: const Color(0xFF6BCB77),
                      title: 'Walk 6,000 steps',
                      subtitle: 'Daily movement goal',
                      initialChecked: true,
                      onChanged: (_) {},
                    ),
                    HabitCheckTile(
                      icon: Icons.fitness_center_rounded,
                      iconColor: const Color(0xFFFF9F45),
                      title: 'Protein goal',
                      subtitle: 'Hit your daily protein target',
                      initialChecked: true,
                      onChanged: (_) {},
                    ),
                    HabitCheckTile(
                      icon: Icons.nightlight_round,
                      iconColor: const Color(0xFFA78BFA),
                      title: 'Sleep before 11 PM',
                      subtitle: 'Get quality rest',
                      initialChecked: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),

            // ──────────────────────────────
            // 9. TimelineEvent (5'li sekans, kart içinde)
            // ──────────────────────────────
            _section(
              "9. TimelineEvent — Today's Hydration",
              NuveliCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: const [
                    TimelineEvent(
                      time: '9:00 AM',
                      value: '250 ml',
                      isCompleted: true,
                      isFirst: true,
                    ),
                    TimelineEvent(
                      time: '11:30 AM',
                      value: '500 ml',
                      isCompleted: true,
                    ),
                    TimelineEvent(
                      time: '1:00 PM',
                      value: '500 ml',
                      isCompleted: true,
                    ),
                    TimelineEvent(
                      time: '3:45 PM',
                      value: '250 ml',
                      isCompleted: false,
                    ),
                    TimelineEvent(
                      time: '6:30 PM',
                      value: '600 ml',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // ──────────────────────────────
            // 10. AchievementBadges (3 yan yana + 1 locked)
            // ──────────────────────────────
            _section(
              '10. AchievementBadge (3 yan yana)',
              Row(
                children: const [
                  Expanded(
                    child: AchievementBadge(
                      icon: Icons.local_fire_department_rounded,
                      color: Color(0xFFFF6B35),
                      title: '7 Day Streak',
                      subtitle: 'Keep it up!',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AchievementBadge(
                      icon: Icons.gps_fixed_rounded,
                      color: Color(0xFF00D4FF),
                      title: 'Calorie Goal',
                      subtitle: '5/7 days',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AchievementBadge(
                      icon: Icons.monitor_weight_outlined,
                      color: Color(0xFF00D4FF),
                      title: '3.5 kg Lost',
                      subtitle: 'Great progress!',
                    ),
                  ),
                ],
              ),
            ),
            _section(
              '10b. AchievementBadge (locked state)',
              Row(
                children: const [
                  Expanded(
                    child: AchievementBadge(
                      icon: Icons.workspace_premium_rounded,
                      color: Color(0xFFFFC857),
                      title: '30 Day Pro',
                      subtitle: 'Locked',
                      isUnlocked: false,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AchievementBadge(
                      icon: Icons.bolt_rounded,
                      color: Color(0xFFFFC857),
                      title: 'Hit Macro',
                      subtitle: 'Locked',
                      isUnlocked: false,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),

            // ──────────────────────────────
            // 11. RecommendationCard.simple
            // ──────────────────────────────
            _section(
              '11. RecommendationCard — Simple',
              Column(
                children: [
                  RecommendationCard(
                    icon: Icons.restaurant_rounded,
                    iconColor: const Color(0xFF3DDC97),
                    description:
                        'High protein days help you stay full and support your goal.',
                    style: RecommendationCardStyle.simple,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RecommendationCard(
                    icon: Icons.water_drop_rounded,
                    iconColor: AppColors.primary,
                    description:
                        'Stay hydrated! Aim for 2–3L of water daily.',
                    style: RecommendationCardStyle.simple,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ──────────────────────────────
            // 12. RecommendationCard.actionable
            // ──────────────────────────────
            _section(
              '12. RecommendationCard — Actionable',
              RecommendationCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.primary,
                title: 'Recommended for You',
                description:
                    'Add a 20-30g protein-rich meal at lunch to reach your daily target.',
                style: RecommendationCardStyle.actionable,
                primaryActionLabel: 'Apply Tip',
                secondaryActionLabel: 'See Details',
                onPrimaryAction: () {},
                onSecondaryAction: () {},
              ),
            ),

            // Alttaki bottom nav için boşluk
            const SizedBox(height: AppSpacing.xxl),
          ],
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
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
