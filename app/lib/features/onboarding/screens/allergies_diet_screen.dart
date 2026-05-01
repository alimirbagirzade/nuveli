// app/lib/features/onboarding/screens/allergies_diet_screen.dart
//
// Allergies + Dietary Preference — PRD §5.4 step 7.
// Multi-select for allergies, single-select for dietary preference.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_controller.dart';

class AllergiesDietScreen extends ConsumerStatefulWidget {
  const AllergiesDietScreen({super.key});

  @override
  ConsumerState<AllergiesDietScreen> createState() =>
      _AllergiesDietScreenState();
}

class _AllergiesDietScreenState extends ConsumerState<AllergiesDietScreen> {
  final Set<String> _selectedAllergies = {};
  String _dietaryPreference = 'none';

  static const _allergens = [
    ('lactose', 'Laktoz'),
    ('gluten', 'Gluten'),
    ('peanuts', 'Yer fıstığı'),
    ('tree_nuts', 'Kuruyemiş'),
    ('eggs', 'Yumurta'),
    ('shellfish', 'Kabuklu deniz ürünü'),
    ('soy', 'Soya'),
    ('sesame', 'Susam'),
    ('fish', 'Balık'),
  ];

  static const _diets = [
    ('none', 'Belirli bir tercih yok'),
    ('vegetarian', 'Vejetaryen'),
    ('vegan', 'Vegan'),
    ('pescatarian', 'Peskatarian (sadece balık)'),
    ('halal', 'Helal'),
    ('kosher', 'Koşer'),
    ('other', 'Diğer'),
  ];

  void _onContinue() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    controller.setAllergies(_selectedAllergies.toList());
    controller.setDietaryPreference(_dietaryPreference);
    context.go(AppRoute.onboardingCoach);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Beslenme', style: AppTextStyles.labelMedium),
      ),
      padding: const EdgeInsets.all(24),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bilmemiz gereken\nbir şey var mı?',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Hiçbiri uygun değilse boş bırak — istediğin zaman değiştirirsin.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),
            Text('Alerjiler', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergens.map((a) {
                final selected = _selectedAllergies.contains(a.$1);
                return _ChipToggle(
                  label: a.$2,
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.remove(a.$1);
                      } else {
                        _selectedAllergies.add(a.$1);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            Text('Beslenme tercihi', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),

            ..._diets.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RadioRow(
                    label: d.$2,
                    selected: _dietaryPreference == d.$1,
                    onTap: () =>
                        setState(() => _dietaryPreference = d.$1),
                  ),
                )),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Devam Et',
              onPressed: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipToggle extends StatelessWidget {
  const _ChipToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
