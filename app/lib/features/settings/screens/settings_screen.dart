import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          _section('Hesap'),
          _tile(context, Icons.person_outline, 'Profil', () {}),
          _tile(context, Icons.notifications_outlined, 'Bildirimler',
              () => context.push(AppRoute.notificationPrefs)),
          _section('Destek ve Güvenlik'),
          _tile(context, Icons.help_outline, 'Destek', () => context.push(AppRoute.support)),
          _tile(context, Icons.auto_awesome, 'AI nasıl çalışır',
              () => context.push(AppRoute.howAiWorks)),
          _tile(context, Icons.privacy_tip_outlined, 'Gizlilik ve Güvenlik',
              () => context.push(AppRoute.privacySafety)),
          _section('Abonelik'),
          _tile(context, Icons.workspace_premium_outlined, 'Premium',
              () => context.push(AppRoute.paywall)),
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
            child: Text('v1.0.0', style: AppTextStyles.caption),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(title.toUpperCase(), style: AppTextStyles.labelSmall),
      );

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textPrimary),
      title: Text(label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          )),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
