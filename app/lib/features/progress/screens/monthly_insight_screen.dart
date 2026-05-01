// app/lib/features/progress/screens/monthly_insight_screen.dart
//
// Monthly Insight — son 30 gun orutu yorumu.
// Backend: GET /summary/monthly/current
//
// Premium gating:
//   Free  → 1 insight + lock kart
//   Premium → 3 insight + AI yorum + weekday/weekend pattern

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../premium/data/premium_service.dart';
import '../data/progress_repository.dart';

class MonthlyInsightScreen extends ConsumerWidget {
  const MonthlyInsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyInsightProvider);
    final premiumStatus = ref.watch(premiumStatusProvider);
    final isPremium =
        premiumStatus.maybeWhen(data: (s) => s.isPremium, orElse: () => false);

    return AppScaffold(
      appBar: AppBar(title: const Text('Aylık İçgörü')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(monthlyInsightProvider);
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: monthlyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _Error(
            message: e is AppError ? e.userMessage : 'Yüklenemedi',
            onRetry: () => ref.invalidate(monthlyInsightProvider),
          ),
          data: (monthly) => _Body(monthly: monthly, isPremium: isPremium),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.monthly, required this.isPremium});
  final MonthlyInsight monthly;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final visibleInsights =
        isPremium ? monthly.insights : monthly.insights.take(1).toList();
    final lockedCount =
        isPremium ? 0 : (monthly.insights.length - 1).clamp(0, 99);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Son 30 gün', style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          '${monthly.insights.length} önemli örüntü',
          style: AppTextStyles.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${monthly.daysLogged} gün kayıt / ${monthly.totalDays}',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Premium AI insight kart (premium-only)
        if (isPremium && monthly.aiInsight != null && monthly.aiInsight!.isNotEmpty)
          _AiInsightCard(text: monthly.aiInsight!)
        else if (!isPremium && monthly.aiInsight != null)
          _LockedAiInsightCard(),
        if ((isPremium && monthly.aiInsight != null) ||
            (!isPremium && monthly.aiInsight != null))
          const SizedBox(height: 16),

        // Insight'lar
        for (var i = 0; i < visibleInsights.length; i++) ...[
          _InsightBlock(
            index: (i + 1).toString().padLeft(2, '0'),
            title: visibleInsights[i].title,
            body: visibleInsights[i].body,
            color: _colorForIndex(i),
          ),
          if (i < visibleInsights.length - 1) const SizedBox(height: 12),
        ],

        // Locked insight'lar (free için)
        if (lockedCount > 0) ...[
          const SizedBox(height: 12),
          _LockedInsightsCard(count: lockedCount),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Color _colorForIndex(int i) {
    const palette = [AppColors.primary, AppColors.accent, AppColors.warning];
    return palette[i % palette.length];
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'KOÇUN YORUMU',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

class _LockedAiInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoute.paywall),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Koçun yorumu',
                      style: AppTextStyles.headingSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Premium ile aylık örüntülerin için kişisel yorum',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LockedInsightsCard extends StatelessWidget {
  const _LockedInsightsCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoute.paywall),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+$count daha derin örüntü',
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Premium ile tümünü aç',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({
    required this.index,
    required this.title,
    required this.body,
    required this.color,
  });

  final String index;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(index,
                  style: AppTextStyles.labelSmall.copyWith(color: color)),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              Text(message, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
}
