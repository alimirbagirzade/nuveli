import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/language_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';

class PrivacySafetyScreen extends ConsumerWidget {
  const PrivacySafetyScreen({super.key});

  String _buildUrl(String docType, String langCode) {
    // Site URL: nuveli.com.tr/privacy → TR (default)
    //          nuveli.com.tr/privacy/en → English
    if (langCode == 'tr') {
      return 'https://nuveli.com.tr/$docType';
    }
    return 'https://nuveli.com.tr/$docType/$langCode';
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL açılamadı: $url')),
      );
    }
  }

  Future<void> _exportData(BuildContext context) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.privacyDownload),
        content: const Text(
          'Verilerinizi indirmek için support@nuveli.com.tr adresine email gönderiniz. 7 gün içinde size dönüş yapılacaktır.\n\n'
          'Email: support@nuveli.com.tr\n'
          'Konu: Veri İndirme Talebi',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openUrl(context, 'mailto:support@nuveli.com.tr?subject=Veri İndirme Talebi');
            },
            child: const Text('E-posta gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final langCode = lang.code;

    return AppScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(AppLocalizations.of(context)!.privacyHeading, style: AppTextStyles.headingMedium),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.privacyBody,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.privacyEmergency, style: AppTextStyles.headingSmall),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.privacyHotline,
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _linkTile(
            AppLocalizations.of(context)!.privacyPolicyLink,
            () => _openUrl(context, _buildUrl('privacy', langCode)),
          ),
          _linkTile(
            AppLocalizations.of(context)!.privacyTermsLink,
            () => _openUrl(context, _buildUrl('terms', langCode)),
          ),
          _linkTile(
            AppLocalizations.of(context)!.privacyDownload,
            () => _exportData(context),
          ),
        ],
      ),
    );
  }

  Widget _linkTile(String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
