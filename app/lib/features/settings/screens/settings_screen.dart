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
import '../../../l10n/generated/app_localizations.dart';
import '../widgets/theme_selector_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
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
                        color: AppColors.primary.withValues(alpha: 0.15),
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
                            l10n.settingsSignedInAs,
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

          _section(l10n.settingsAccount),
          _tile(
            context,
            Icons.notifications_outlined,
            l10n.settingsNotifications,
            () => context.push(AppRoute.notificationPrefs),
          ),
          _tile(
            context,
            Icons.psychology_outlined,
            l10n.settingsCoachTone,
            () => context.push(AppRoute.coachPersonaSettings),
          ),
          // Dil tile - i18n
          Consumer(
            builder: (context, ref, _) {
              final language = globalLanguageNotifier.value;
              return _tile(
                context,
                Icons.language,
                l10n.settingsLanguage,
                () => context.push(AppRoute.languagePicker),
                trailing: language.label,
              );
            },
          ),

          _section(l10n.settingsSupportSecurity),
          _tile(
            context,
            Icons.help_outline,
            l10n.settingsSupport,
            () => context.push(AppRoute.support),
          ),
          _tile(
            context,
            Icons.auto_awesome,
            l10n.settingsHowAiWorks,
            () => context.push(AppRoute.howAiWorks),
          ),
          _tile(
            context,
            Icons.privacy_tip_outlined,
            l10n.settingsPrivacySafety,
            () => context.push(AppRoute.privacySafety),
          ),
          _tile(
            context,
            Icons.info_outline,
            l10n.settingsAboutNuveli,
            () => context.push(AppRoute.about),
          ),

          _section(l10n.settingsSubscription),
          _tile(
            context,
            Icons.workspace_premium_outlined,
            l10n.settingsPremium,
            () => _showPremiumComingSoon(context),
            badge: l10n.settingsPremiumComingSoon,
          ),

          _section(l10n.settingsSession),
          _tile(
            context,
            Icons.logout_outlined,
            l10n.settingsLogout,
            () => _handleLogout(context, ref),
          ),

          _section(l10n.settingsDangerZone),
          _tile(
            context,
            Icons.delete_outline,
            l10n.settingsDeleteAccount,
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
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLogoutTitle),
        content: Text(l10n.settingsLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsLogoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsLogout),
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
          SnackBar(content: Text(l10n.settingsLogoutFailed)),
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
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
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
    final l10n = AppLocalizations.of(context)!;
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
                color: AppColors.textTertiary.withValues(alpha: 0.3),
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
              l10n.premiumModalTitle,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              l10n.premiumModalBody,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Features list
            _featureRow(Icons.check_circle_outline, l10n.premiumFeatureUnlimited),
            const SizedBox(height: 8),
            _featureRow(Icons.check_circle_outline, l10n.premiumFeatureVoice),
            const SizedBox(height: 8),
            _featureRow(Icons.check_circle_outline, l10n.premiumFeatureInsights),
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
                  l10n.premiumUnderstood,
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
