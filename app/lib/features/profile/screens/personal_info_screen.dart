import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/profile_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Personal info edit screen — all fields the user provided during
/// onboarding plus anything they want to update later.
///
/// View mode: read-only display of every field with an "edit" button.
/// Edit mode: each field becomes inline-editable; Save persists the
/// whole form in one PATCH /profile call.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() =>
      _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  bool _editing = false;
  bool _saving = false;

  // Working copy of editable fields. Filled when entering edit mode
  // from the latest snapshot of the profile, sent to the server on save.
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  int? _birthYear;
  String? _gender;
  String? _activityLevel;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _startEdit(UserProfile p) {
    setState(() {
      _editing = true;
      _nameCtrl.text = p.displayName ?? '';
      _heightCtrl.text = p.heightCm?.toStringAsFixed(0) ?? '';
      _weightCtrl.text = p.weightKg?.toStringAsFixed(1) ?? '';
      _birthYear = p.birthYear;
      _gender = p.gender;
      _activityLevel = p.activityLevel;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Pull values from controllers and only send non-empty / changed fields
      final name = _nameCtrl.text.trim();
      final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
      final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));

      await ref.read(profileRepositoryProvider).updateProfile(
            displayName: name.isEmpty ? null : name,
            heightCm: height,
            weightKg: weight,
            birthYear: _birthYear,
            gender: _gender,
            activityLevel: _activityLevel,
          );
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      setState(() {
        _editing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.personalInfoSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(e is AppError ? e.userMessage : AppLocalizations.of(context)!.personalInfoSaveFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.personalInfoTitle),
        actions: [
          if (!_editing)
            profileAsync.maybeWhen(
              data: (p) => TextButton(
                onPressed: () => _startEdit(p),
                child: Text(AppLocalizations.of(context)!.personalInfoEdit),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppError ? e.userMessage : AppLocalizations.of(context)!.personalInfoLoadFailed),
        ),
        data: (p) {
          if (_editing) return _buildEditForm(p);
          return _buildReadView(p);
        },
      ),
    );
  }

  // ─── Read mode ─────────────────────────────────────────────────────

  Widget _buildReadView(UserProfile p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(AppLocalizations.of(context)!.personalInfoSecAccount),
        _ReadRow(label: AppLocalizations.of(context)!.personalInfoName, value: p.displayName ?? '—'),
        _ReadRow(label: AppLocalizations.of(context)!.personalInfoEmail, value: p.email ?? '—'),

        const SizedBox(height: 16),
        _Section(AppLocalizations.of(context)!.personalInfoSecBody),
        _ReadRow(
          label: AppLocalizations.of(context)!.personalInfoBirthYear,
          value: p.birthYear?.toString() ?? '—',
        ),
        _ReadRow(label: AppLocalizations.of(context)!.personalInfoGender, value: _genderLabel(context, p.gender)),
        _ReadRow(
          label: AppLocalizations.of(context)!.personalInfoHeight,
          value: p.heightCm != null ? '${p.heightCm!.toInt()} cm' : '—',
        ),
        _ReadRow(
          label: AppLocalizations.of(context)!.personalInfoWeight,
          value: p.weightKg != null
              ? '${p.weightKg!.toStringAsFixed(1)} kg'
              : '—',
        ),

        const SizedBox(height: 16),
        _Section(AppLocalizations.of(context)!.personalInfoSecActivity),
        _ReadRow(
          label: AppLocalizations.of(context)!.personalInfoActivityLevel,
          value: _activityLabel(context, p.activityLevel),
        ),
      ],
    );
  }

  // ─── Edit mode ─────────────────────────────────────────────────────

  Widget _buildEditForm(UserProfile p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Section(AppLocalizations.of(context)!.personalInfoSecAccount),
        _TextField(
          label: AppLocalizations.of(context)!.personalInfoName,
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
        ),

        const SizedBox(height: 16),
        _Section(AppLocalizations.of(context)!.personalInfoSecBody),
        _BirthYearPicker(
          value: _birthYear,
          onChanged: (y) => setState(() => _birthYear = y),
        ),
        const SizedBox(height: 12),
        _GenderPicker(
          value: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        const SizedBox(height: 12),
        _TextField(
          label: AppLocalizations.of(context)!.personalInfoHeightCm,
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _TextField(
          label: AppLocalizations.of(context)!.personalInfoWeightKg,
          controller: _weightCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 16),
        _Section(AppLocalizations.of(context)!.personalInfoSecActivity),
        _ActivityPicker(
          value: _activityLevel,
          onChanged: (a) => setState(() => _activityLevel = a),
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _editing = false),
                child: Text(AppLocalizations.of(context)!.personalInfoCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Labels ────────────────────────────────────────────────────────

  static String _genderLabel(BuildContext context, String? g) {
    final l10n = AppLocalizations.of(context)!;
    switch (g) {
      case 'female':
        return l10n.genderFemale;
      case 'male':
        return l10n.genderMale;
      case 'other':
        return l10n.genderOther;
      default:
        return '—';
    }
  }

  static String _activityLabel(BuildContext context, String? a) {
    final l10n = AppLocalizations.of(context)!;
    switch (a) {
      case 'sedentary':
        return l10n.activitySedentary;
      case 'light':
        return l10n.activityLight;
      case 'moderate':
        return l10n.activityModerate;
      case 'active':
        return l10n.activityActive;
      case 'very_active':
        return l10n.activityVeryActive;
      default:
        return '—';
    }
  }
}

// ─── Reusable widgets ────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _ReadRow extends StatelessWidget {
  const _ReadRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
            Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
        ),
      );
}

class _BirthYearPicker extends StatelessWidget {
  const _BirthYearPicker({required this.value, required this.onChanged});
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(80, (i) => DateTime.now().year - 12 - i);
    return DropdownButtonFormField<int>(
      value: value,
      hint: Text(AppLocalizations.of(context)!.personalInfoBirthYear),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.personalInfoBirthYear,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.personalInfoGender,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'female', child: Text(AppLocalizations.of(context)!.genderFemale)),
        DropdownMenuItem(value: 'male', child: Text(AppLocalizations.of(context)!.genderMale)),
        DropdownMenuItem(value: 'other', child: Text(AppLocalizations.of(context)!.genderOther)),
      ],
      onChanged: onChanged,
    );
  }
}

class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.personalInfoActivityLevelLabel,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'sedentary', child: Text(AppLocalizations.of(context)!.activitySedentaryFull)),
        DropdownMenuItem(value: 'light', child: Text(AppLocalizations.of(context)!.activityLightFull)),
        DropdownMenuItem(value: 'moderate', child: Text(AppLocalizations.of(context)!.activityModerateFull)),
        DropdownMenuItem(value: 'active', child: Text(AppLocalizations.of(context)!.activityActiveFull)),
        DropdownMenuItem(value: 'very_active', child: Text(AppLocalizations.of(context)!.activityVeryActiveFull)),
      ],
      onChanged: onChanged,
    );
  }
}
