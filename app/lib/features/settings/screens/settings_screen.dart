import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/i18n/language_provider.dart';
import '../widgets/theme_selector_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ThemeSelectorTile(),
          const SizedBox(height: 8),
          // Kullanıcı bilgisi kartı
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(20),

              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giriş yapan',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            user.email ?? '—',
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          _section('Hesap'),
          _tile(
            context,
            Icons.notifications_outlined,
            'Bildirimler',
            () => context.push(AppRoute.notificationPrefs),
          ),
          _tile(
            context,
            Icons.psychology_outlined,
            'Koçun tonu',
            () => context.push(AppRoute.coachPersonaSettings),
          ),
          // Dil tile - i18n
          Consumer(
            builder: (context, ref, _) {
              final language = ref.watch(languageProvider);
              return _tile(
                context,
                Icons.language,
                'Dil / Language',
                () => context.push(AppRoute.languagePicker),
                trailing: language.label,
              );
            },
          ),

          _section('Destek ve Güvenlik'),
          _tile(
            context,
            Icons.help_outline,
            'Destek',
            () => context.push(AppRoute.support),
          ),
          _tile(
            context,
            Icons.auto_awesome,
            'AI nasıl çalışır',
            () => context.push(AppRoute.howAiWorks),
          ),
          _tile(
            context,
            Icons.privacy_tip_outlined,
            'Gizlilik ve Güvenlik',
            () => context.push(AppRoute.privacySafety),
          ),
          _tile(
            context,
            Icons.info_outline,
            'Nuveli Hakkında',
            () => context.push(AppRoute.about),
          ),

          _section('Abonelik'),
          _tile(
            context,
            Icons.workspace_premium_outlined,
            'Premium',
            () => _showPremiumComingSoon(context),
            badge: 'YAKINDA',
          ),

          _section('Oturum'),
          _tile(
            context,
            Icons.logout_outlined,
            'Çıkış Yap',
            () => _handleLogout(context, ref),
          ),

          _section('Tehlikeli Bölge'),
          _tile(
            context,
            Icons.delete_outline,
            'Hesabı Sil',
            () => context.push(AppRoute.deleteAccount),
            isDestructive: true,
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'v${AppConfig.appVersion} • ${AppConfig.env}',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yap?'),
        content: const Text('Tekrar giriş yapmak için email ve şifren gerekecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final signOut = ref.read(signOutActionProvider);
      await signOut();
      if (context.mounted) {
        context.go(AppRoute.login);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çıkış yapılamadı.')),
        );
      }
    }
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(title.toUpperCase(), style: AppTextStyles.labelSmall),
      );

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
    String? badge,
    String? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                badge,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showPremiumComingSoon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.gradientCta,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'Premium çok yakında! 🚀',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Sınırsız AI öğün analizi, gelişmiş koç ve haftalık içgörüler için son hazırlıkları yapıyoruz. Hazır olduğumuzda seninle iletişime geçeceğiz.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Features list
            _featureRow(Icons.check_circle_outline, 'Sınırsız AI öğün analizi'),
            const SizedBox(height: 8),
            _featureRow(Icons.check_circle_outline, 'Sesli koç + 3 persona'),
            const SizedBox(height: 8),
            _featureRow(Icons.check_circle_outline, 'Haftalık + aylık içgörü'),
            const SizedBox(height: 28),
            // OK button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Anladım',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
