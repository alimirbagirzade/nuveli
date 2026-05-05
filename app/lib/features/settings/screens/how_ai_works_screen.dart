import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../l10n/generated/app_localizations.dart';

class HowAiWorksScreen extends StatelessWidget {
  const HowAiWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.howAiTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Block(
            icon: Icons.camera_alt_outlined,
            title: AppLocalizations.of(context)!.aiBlockFood,
            body: AppLocalizations.of(context)!.aiBlockFoodBody,
          ),
          _Block(
            icon: Icons.auto_awesome,
            title: AppLocalizations.of(context)!.aiBlockCoach,
            body: AppLocalizations.of(context)!.aiBlockCoachBody,
          ),
          _Block(
            icon: Icons.shield_outlined,
            title: AppLocalizations.of(context)!.aiBlockSafety,
            body: AppLocalizations.of(context)!.aiBlockSafetyBody,
          ),
          _Block(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context)!.aiBlockData,
            body: AppLocalizations.of(context)!.aiBlockDataBody,
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingSmall),
                const SizedBox(height: 6),
                Text(body, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
