import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../premium/data/premium_service.dart';
import '../../premium/utils/trial_gift_trigger.dart';
import '../data/home_repository.dart';
import '../widgets/coach_card.dart';
import '../widgets/craving_prompt_card.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/mini_progress_chart.dart';
import '../widgets/mini_task_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/today_meals_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Premium durumu yüklendikten sonra (free ise + bu cihazda ilk kez)
    // trial hediye modali gösterilir. Bir kez SharedPreferences flag'i ile
    // tekrar çıkmasın garantilenir.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Premium status future'ını bekle, sonra modal
      await ref.read(premiumStatusProvider.future).catchError((_) {
        return PremiumStatus.free();
      });
      if (!mounted) return;
      TrialGiftTrigger.maybeShow(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homePayloadProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('nuveli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoute.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(homePayloadProvider),
        child: homeAsync.when(
          loading: () => const HomeSkeleton(),
          error: (err, _) {
            final msg = err is AppError ? err.userMessage : 'Bir şeyler ters gitti';
            return ErrorStateView(
              message: msg,
              onRetry: () => ref.invalidate(homePayloadProvider),
            );
          },
          data: (payload) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _GreetingHeader(name: payload.greeting),
              const SizedBox(height: 16),
              DailySummaryCard(
                consumedCalories: payload.summary.totalCalories,
                targetCalories: payload.summary.targetCalories,
                protein: payload.summary.proteinG,
                carb: payload.summary.carbG,
                fat: payload.summary.fatG,
              ),
              const SizedBox(height: 16),
              const QuickActionsGrid(),
              const SizedBox(height: 16),
              CoachCard(
                message: payload.coachCard.message,
                onTap: () => context.push(AppRoute.coach),
              ),
              const SizedBox(height: 16),
              const CravingPromptCard(),
              const SizedBox(height: 16),
              const MiniProgressChart(),
              const SizedBox(height: 16),
              const TodayMealsList(),
              const SizedBox(height: 16),
              const MiniTaskCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Günaydın'
        : hour < 18
            ? 'İyi öğleden sonralar'
            : 'İyi akşamlar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(name, style: AppTextStyles.displayMedium),
      ],
    );
  }
}
