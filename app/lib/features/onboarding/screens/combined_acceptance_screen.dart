// app/lib/features/onboarding/screens/combined_acceptance_screen.dart
//
// Birlestirilmis Acceptance Ekrani
// 4 ayri acceptance ekranini tek scroll'lu ekrana toplar.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class CombinedAcceptanceScreen extends StatefulWidget {
  const CombinedAcceptanceScreen({super.key});

  @override
  State<CombinedAcceptanceScreen> createState() =>
      _CombinedAcceptanceScreenState();
}

class _CombinedAcceptanceScreenState extends State<CombinedAcceptanceScreen> {
  bool _wellnessChecked = false;
  bool _aiEstimatesChecked = false;
  bool _specialCasesChecked = false;
  bool _termsChecked = false;

  bool get _allChecked =>
      _wellnessChecked &&
      _aiEstimatesChecked &&
      _specialCasesChecked &&
      _termsChecked;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Bilgilendirme', style: AppTextStyles.labelMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              children: [
                // Header
                Text(
                  'Baslamadan once',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nuveli\'yi guvenli kullanman icin 4 onemli not. Hepsini onaylaman gerekiyor.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Wellness scope
                _buildAcceptanceCard(
                  number: 1,
                  icon: Icons.favorite_outline,
                  title: 'Nuveli wellness uygulamasidir',
                  body: 'Nuveli tibbi teshis, tedavi veya klinik diyet plani sunmaz. '
                      'Ozel saglik durumlarin icin doktorundan destek alman onemli.',
                  checkboxLabel: 'Anladim. Nuveli doktorumun yerini almaz.',
                  isChecked: _wellnessChecked,
                  onChanged: (v) => setState(() => _wellnessChecked = v ?? false),
                ),
                const SizedBox(height: 16),

                // 2. AI estimates
                _buildAcceptanceCard(
                  number: 2,
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI tahminleri yaklasiktir',
                  body: 'Yemek fotograflarindan yaptigimiz kalori ve besin degeri '
                      'tahminleri yaklasik sonuclardir. Her zaman duzenleyebilirsin.',
                  checkboxLabel: 'Sonuclarin yaklasik olabilecegini biliyorum.',
                  isChecked: _aiEstimatesChecked,
                  onChanged: (v) => setState(() => _aiEstimatesChecked = v ?? false),
                ),
                const SizedBox(height: 16),

                // 3. Special cases
                _buildAcceptanceCard(
                  number: 3,
                  icon: Icons.warning_amber_outlined,
                  title: 'Ozel durumlarda dikkat',
                  body: 'Hamilelik, emzirme, yeme bozuklugu gecmisi veya kronik '
                      'hastaligin varsa, kalori onerilerini uygulamadan once saglik '
                      'uzmanina danis.',
                  checkboxLabel: 'Ozel durumumda uzmana danisacagim.',
                  isChecked: _specialCasesChecked,
                  onChanged: (v) => setState(() => _specialCasesChecked = v ?? false),
                ),
                const SizedBox(height: 16),

                // 4. Terms & privacy
                _buildAcceptanceCard(
                  number: 4,
                  icon: Icons.lock_outline,
                  title: 'Sartlar ve gizlilik',
                  body: 'Kullanim Sartlari ve Gizlilik Politikasi\'ni okuyup kabul '
                      'etmelisin. Verilerin guvende tutulur ve ayarlar ekranindan '
                      'her zaman silebilirsin.',
                  checkboxLabel: 'Sartlari ve Gizlilik Politikasi\'ni kabul ediyorum.',
                  isChecked: _termsChecked,
                  onChanged: (v) => setState(() => _termsChecked = v ?? false),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.textTertiary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: PrimaryButton(
              label: _allChecked ? 'Devam et' : 'Tum kutulari isaretle',
              onPressed: _allChecked
                  ? () => context.go(AppRoute.onboardingGoal)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCard({
    required int number,
    required IconData icon,
    required String title,
    required String body,
    required String checkboxLabel,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.textTertiary.withOpacity(0.1),
          width: isChecked ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Checkbox
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onChanged(!isChecked),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: onChanged,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      checkboxLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isChecked ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
