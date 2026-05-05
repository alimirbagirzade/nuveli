// app/lib/features/progress/screens/empty_day_screen.dart
//
// Recovery Day / Empty Day — PRD §6.5
// Kullanici 24+ saat hic meal log'lamadiysa home'a girince hafifce buraya yonlendirilir.
// Mesaj: "Burdayiz, baski yok, hazirsan kucuk basla."
//
// 3 mini CTA:
//   1. "Bugun ne yedim?" → manual meal entry
//   2. "Simdi bir sey yiyecegim" → meal capture (foto)
//   3. "Sadece su ictim" → water tracker
//
// Backend: POST /checkins type=recovery_day_acknowledge
// Bu, "kullanici Recovery Day'i gordu" event'i olarak kaydedilir,
// daha sonra coach memory'sinde (PRD §10) referansli olur.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class EmptyDayScreen extends ConsumerStatefulWidget {
  const EmptyDayScreen({super.key});

  @override
  ConsumerState<EmptyDayScreen> createState() => _EmptyDayScreenState();
}

class _EmptyDayScreenState extends ConsumerState<EmptyDayScreen> {
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _acknowledge());
  }

  /// Backend'e "kullanici Recovery Day'i gordu" event'i gonder.
  /// Hata olursa sessizce yut — UI bloklanmasin.
  Future<void> _acknowledge() async {
    if (_acknowledged) return;
    _acknowledged = true;
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/checkins', data: {
        'type': 'recovery_day_acknowledge',
        'data': {},
      });
    } on DioException catch (e) {
      debugPrint('EmptyDayScreen: acknowledge failed (non-fatal): ${e.message}');
    } catch (e) {
      debugPrint('EmptyDayScreen: acknowledge error: $e');
    }
  }

  void _onAteEarlier() {
    // "Bugun ne yedim?" → manual entry
    context.go(AppRoute.mealManual);
  }

  void _onWillEat() {
    // "Simdi bir sey yiyecegim" → camera/capture
    context.go(AppRoute.mealCapture);
  }

  void _onJustWater() {
    // "Sadece su ictim" → water tracker
    context.go(AppRoute.waterHistory);
  }

  void _onJustBack() {
    // "Simdilik degil" — home'a don
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoute.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _onJustBack,
            child: Text(
              'Şimdilik değil',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Hero icon
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Buradayız.',
              style: AppTextStyles.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Dün veya bugün hiç kayıt yok. Baskı yok, yargı yok.\n'
              'Hazırsan küçük bir adımla başla.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            // 3 mini CTA
            _OptionCard(
              icon: Icons.history_edu_outlined,
              title: 'Bugün ne yedim?',
              subtitle: 'Geriye dönüp birkaç öğün ekleyebilirsin',
              onTap: _onAteEarlier,
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.camera_alt_outlined,
              title: 'Şimdi bir şey yiyeceğim',
              subtitle: 'Fotoğraf çek — koçun gerisini halletsin',
              onTap: _onWillEat,
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.water_drop_outlined,
              title: 'Sadece su içtim',
              subtitle: 'Bu da bir kayıt — saymaya başlayalım',
              onTap: _onJustWater,
            ),

            const SizedBox(height: 32),

            // Soft note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Boş günler de kayıt sayılır. Düzenli olmak '
                      'mükemmel olmak değildir.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
