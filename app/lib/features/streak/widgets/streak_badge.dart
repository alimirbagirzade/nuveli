import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/streak_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Ana ekrana eklenen streak rozeti.
///
/// Tasarım kararı: streak yoksa "Henüz başlamadın" demek yerine widget'ı
/// hiç göstermiyoruz — UI gürültüsünü azaltmak için. İlk öğün eklenince
/// ortaya çıkar (1 gün) ve her gün arttıkça motivasyon olur.
///
/// Tap ile streak history ekranına gider.
class StreakBadge extends ConsumerWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStreak = ref.watch(streakProvider);

    return asyncStreak.when(
      // Loading: shimmer yok, sadece yer tutucu — UI atmasın diye
      loading: () => const SizedBox(height: 0),
      error: (_, __) => const SizedBox(height: 0),
      data: (streak) {
        if (streak.current == 0) {
          // Streak yok — widget'ı gizle. Ana ekran daha sade kalır.
          return const SizedBox(height: 0);
        }
        return _StreakCard(streak: streak);
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final isMilestone = streak.milestone != null;
    final isAtRisk = streak.atRisk;

    // Renk paletini duruma göre seçelim:
    //   - Risk altında (akşam, kayıt yok) → uyarı turuncu
    //   - Milestone'a ulaştı → kutlama (gradient mor)
    //   - Normal → ateş kırmızısı (gradient)
    final List<Color> gradient;
    final Color glowColor;
    if (isAtRisk) {
      gradient = const [Color(0xFFFF8C42), Color(0xFFFF6B35)];
      glowColor = const Color(0xFFFF6B35);
    } else if (isMilestone) {
      gradient = [AppColors.primary, AppColors.primaryLight];
      glowColor = AppColors.primary;
    } else {
      gradient = const [Color(0xFFFF6B35), Color(0xFFFFB020)];
      glowColor = const Color(0xFFFF6B35);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showStreakDetails(context, streak),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ateş emoji + sayı (büyük rakam dikkat çeker)
                Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 32,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${streak.current}',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              streak.current == 1 ? AppLocalizations.of(context)!.streakDay : AppLocalizations.of(context)!.streakDays,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitleText(streak),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitleText(StreakInfo streak) {
    if (streak.milestone != null) {
      // Milestone'lara özel mesajlar — küçük zaferleri kutla.
      switch (streak.milestone) {
        case '3':
          return 'Üç gün arka arkaya, harika başlangıç! 🎉';
        case '7':
          return 'Bir haftalık mücadele tamam! 💪';
        case '14':
          return 'İki haftadır sürdürüyorsun, alışkanlık olmaya başladı';
        case '21':
          return 'Yeni bir alışkanlığın doğdu! ✨';
        case '30':
          return 'Bir aylık seri — sen artık disiplinin tanımısın';
        case '60':
          return 'İki ay! Çok az kişi buraya gelir';
        case '90':
          return 'Üç ay arka arkaya — efsane seviye 🏆';
        case '100':
          return '100 gün! Tarih yazdın';
        default:
          return 'En uzun serin: ${streak.longest} gün';
      }
    }
    if (streak.atRisk) {
      return 'Bugün öğün eklemedin — sersin tehlikede! ⚠️';
    }
    if (streak.todayLogged) {
      return 'Bugün de hallettin · En uzun: ${streak.longest} gün';
    }
    return 'Bugünü de eklemeyi unutma · En uzun: ${streak.longest}';
  }

  void _showStreakDetails(BuildContext context, StreakInfo streak) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StreakDetailsSheet(streak: streak),
    );
  }
}

// ─── Details Sheet ───────────────────────────────────────────────────

class _StreakDetailsSheet extends StatelessWidget {
  const _StreakDetailsSheet({required this.streak});
  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streak.current} günlük seri',
                      style: AppTextStyles.displayMedium,
                    ),
                    if (streak.lastActiveDay != null)
                      Text(
                        'Son kayıt: ${_formatDateLocalized(context, streak.lastActiveDay!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: AppLocalizations.of(context)!.streakNow,
                  value: '${streak.current}',
                  unit: AppLocalizations.of(context)!.streakDay,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: AppLocalizations.of(context)!.streakLongestShort,
                  value: '${streak.longest}',
                  unit: AppLocalizations.of(context)!.streakDay,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Açıklama / motivasyon mesajı
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  streak.atRisk
                      ? Icons.warning_amber_rounded
                      : Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: streak.atRisk
                      ? AppColors.warning
                      : AppColors.primaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _explanationText(context, streak),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // CTA — bugün öğün eklenmediyse direkt yönlendir
          if (!streak.todayLogged)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoute.mealCapture);
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(AppLocalizations.of(context)!.streakAddMealNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDateLocalized(BuildContext context, DateTime d) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec,
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _explanationText(BuildContext context, StreakInfo streak) {
    if (streak.atRisk) {
      return AppLocalizations.of(context)!.streakAtRisk;
    }
    if (streak.current == 0) {
      return AppLocalizations.of(context)!.streakNotStarted;
    }
    if (streak.todayLogged) {
      return AppLocalizations.of(context)!.streakTodayLogged;
    }
    return 'Streak\'in arka arkaya öğün eklediğin gün sayısıdır. Bugün de bir öğün ekleyerek ${streak.current} günlük seriyi ${streak.current + 1} güne çıkarabilirsin.';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(color: color),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
