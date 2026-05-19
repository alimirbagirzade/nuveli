// ============================================================================
// step_2_personal_info.dart
// Display name + Date of birth + Gender.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/auth_primary_button.dart';
import '../../../widgets/auth_text_field.dart';

class Step2PersonalInfo extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const Step2PersonalInfo({super.key, required this.onNext});

  @override
  ConsumerState<Step2PersonalInfo> createState() => _Step2State();
}

class _Step2State extends ConsumerState<Step2PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtl;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingDataProvider);
    _nameCtl = TextEditingController(text: data.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final data = ref.read(onboardingDataProvider);
    final now = DateTime.now();
    final initial = data.dateOfBirth ?? DateTime(now.year - 25, now.month, now.day);
    final earliest = DateTime(now.year - 100);
    final latest = DateTime(now.year - 13);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(latest) ? initial : latest,
      firstDate: earliest,
      lastDate: latest,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryCyan,
            onPrimary: Colors.white,
            surface: const Color(0xFF142346),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(onboardingDataProvider.notifier).update(dateOfBirth: picked);
    }
  }

  void _selectGender(Gender g) {
    ref.read(onboardingDataProvider.notifier).update(gender: g);
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final data = ref.read(onboardingDataProvider);
    if (data.dateOfBirth == null) {
      _showSnack('Please select your date of birth');
      return;
    }
    if (data.gender == null) {
      _showSnack('Please select your gender');
      return;
    }
    ref
        .read(onboardingDataProvider.notifier)
        .update(displayName: _nameCtl.text.trim());
    widget.onNext();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingDataProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tell us about yourself',
              style: AppTypography.heading28.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us calculate your daily needs.',
              style: AppTypography.body14
                  .copyWith(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  AuthTextField(
                    controller: _nameCtl,
                    label: 'Your name',
                    hint: 'How should we call you?',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.done,
                    validator: (v) => AuthValidators.required(
                      v,
                      fieldName: 'Name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DateField(
                    label: 'Date of birth',
                    date: data.dateOfBirth,
                    onTap: _pickDob,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gender',
                    style: AppTypography.caption12.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: Gender.values.map((g) {
                      final selected = data.gender == g;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: g != Gender.values.last ? 8 : 0,
                          ),
                          child: _GenderChip(
                            label: g.label,
                            selected: selected,
                            onTap: () => _selectGender(g),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AuthPrimaryButton(label: 'Continue', onPressed: _continue),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUBWIDGETS
// ============================================================================

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTypography.caption12.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF142346).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.cake_outlined,
                    color: AppColors.secondaryText, size: 20),
                const SizedBox(width: 12),
                Text(
                  date == null
                      ? 'Select date'
                      : '${date!.day.toString().padLeft(2, '0')}/'
                          '${date!.month.toString().padLeft(2, '0')}/'
                          '${date!.year}',
                  style: AppTypography.body16.copyWith(
                    color: date == null
                        ? AppColors.tertiaryText
                        : Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_outlined,
                    color: AppColors.tertiaryText, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withValues(alpha: 0.3),
                    AppColors.primaryCyan.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: selected ? null : const Color(0xFF142346).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryCyan.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.body14.copyWith(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
