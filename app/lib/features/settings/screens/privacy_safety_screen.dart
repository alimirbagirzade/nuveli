import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
          _linkTile(AppLocalizations.of(context)!.privacyPolicyLink, () {}),
          _linkTile(AppLocalizations.of(context)!.privacyTermsLink, () {}),
          _linkTile(AppLocalizations.of(context)!.privacyDownload, () {}),
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
