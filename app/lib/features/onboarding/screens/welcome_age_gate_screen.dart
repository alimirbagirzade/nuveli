import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

/// 1/5 — Yaş onayı.
class WelcomeAgeGateScreen extends StatefulWidget {
  const WelcomeAgeGateScreen({super.key});

  @override
  State<WelcomeAgeGateScreen> createState() => _WelcomeAgeGateScreenState();
}

class _WelcomeAgeGateScreenState extends State<WelcomeAgeGateScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text('nuveli', style: AppTextStyles.displayLarge.copyWith(letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('AI Calorie Coach', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            'Hoş geldin',
            style: AppTextStyles.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Nuveli, yediklerini yargısız şekilde takip etmene yardımcı olur. '
            'Başlamadan önce bir kaç şeyi teyit edelim.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _AcceptanceCheckbox(
            label: '18 yaşında veya daha büyüğüm',
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _accepted,
            onPressed: () => context.go(AppRoute.acceptanceWellnessScope),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AcceptanceCheckbox extends StatelessWidget {
  const _AcceptanceCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.divider,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.textTertiary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
