import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/shared/widgets/nuveli_background.dart';
import 'package:nuveli/shared/widgets/nuveli_bottom_nav.dart';

import 'models/water_log.dart';
import 'models/water_reminder.dart';
import 'providers/water_tracker_provider.dart';
import 'widgets/glasses_section.dart';
import 'widgets/quick_add_row.dart';
import 'widgets/water_error.dart';
import 'widgets/water_header.dart';
import 'widgets/water_insights_card.dart';
import 'widgets/water_reminders_card.dart';
import 'widgets/water_skeleton.dart';
import 'widgets/water_summary_section.dart';
import 'widgets/water_timeline_card.dart';

/// Görsel 5 — Water Tracker ana ekranı.
///
/// `AsyncNotifierProvider` ile mutable state yönetir. Tüm interaktif
/// aksiyonlar (`+250ml`, bardak tap, reminder toggle) anlık olarak halka /
/// ızgara / timeline'ı günceller.
///
/// Routing Chat 12'de eklenecek; şu an `currentIndex: 0` (Dashboard) sabit.
class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(waterTrackerProvider);

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: waterAsync.when(
            loading: () => const WaterSkeleton(),
            error: (e, st) => WaterError(
              onRetry: () => ref.invalidate(waterTrackerProvider),
            ),
            data: (data) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: WaterHeader(onNotificationTap: () {}),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      // 1. "Today" + halka.
                      WaterSummarySection(
                        consumedLiters: data.consumedLiters,
                        targetLiters: data.targetLiters,
                      ),
                      const SizedBox(height: 20),
                      // 2. +250ml / +500ml / +1L butonları.
                      QuickAddRow(
                        onAddWater: (ml) => ref
                            .read(waterTrackerProvider.notifier)
                            .addWater(ml),
                      ),
                      const SizedBox(height: 20),
                      // 3. Bardak ızgarası.
                      GlassesSection(
                        filledCount: data.filledGlasses,
                        totalCount: data.totalGlasses,
                        consumedLiters: data.consumedLiters,
                        targetLiters: data.targetLiters,
                        onGlassTap: () => ref
                            .read(waterTrackerProvider.notifier)
                            .addWater(250),
                      ),
                      const SizedBox(height: 20),
                      // 4. Timeline + Reminders (yan yana).
                      _TimelineAndRemindersRow(
                        timeline: data.timeline,
                        reminders: data.reminders,
                        onReminderToggle: (id, v) => ref
                            .read(waterTrackerProvider.notifier)
                            .toggleReminder(id, v),
                      ),
                      const SizedBox(height: 20),
                      // 5. AI Insight kartı.
                      WaterInsightsCard(insight: data.insight),
                      // Bottom nav'ın altında kalmasın diye boşluk.
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: 0,
          onTap: (_) {
            // Routing Chat 12'de eklenecek.
          },
        ),
      ),
    );
  }
}

/// Timeline kartı + Reminders kartı yan yana (eşit yükseklik).
///
/// Dar ekranlarda (< 360px) alt alta düşmesi için ileride `LayoutBuilder`
/// eklenebilir; şimdilik tüm hedef cihazlarda yan yana çalışıyor.
class _TimelineAndRemindersRow extends StatelessWidget {
  final List<WaterLog> timeline;
  final List<WaterReminder> reminders;
  final void Function(String id, bool value)? onReminderToggle;

  const _TimelineAndRemindersRow({
    required this.timeline,
    required this.reminders,
    this.onReminderToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: WaterTimelineCard(
              events: timeline,
              onViewAll: () {
                // Detay sayfası Chat 12'de.
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: WaterRemindersCard(
              reminders: reminders,
              onToggle: onReminderToggle,
            ),
          ),
        ],
      ),
    );
  }
}
