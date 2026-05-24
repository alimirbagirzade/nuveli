import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/user_profile.dart';
import '../providers/profile_actions.dart';

/// Edit the user's profile in-app (post-onboarding).
///
/// Surfaces the same fields the onboarding wizard collected: name, sex,
/// DOB, height, weight, activity level, dietary preference. Persists
/// via `PATCH /me` (ProfileActions.updateProfile), then invalidates
/// profileProvider so the caller sees the updated values immediately.
///
/// Only sends fields that actually changed so the backend doesn't
/// clear values the user didn't touch.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, required this.initial});
  final UserProfile initial;

  static Future<bool?> open(BuildContext context, UserProfile profile) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileEditScreen(initial: profile),
      ),
    );
  }

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtl;
  late final TextEditingController _heightCtl;
  late final TextEditingController _weightCtl;
  late String? _sex;
  late DateTime? _dob;
  late String? _activity;
  late String? _diet;
  bool _saving = false;
  String? _error;

  static const _sexes = ['male', 'female', 'other'];
  static const _activities = [
    'sedentary',
    'light',
    'moderate',
    'active',
    'very_active',
  ];
  static const _diets = [
    'none',
    'vegetarian',
    'vegan',
    'pescatarian',
    'keto',
    'paleo',
    'halal',
    'kosher',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameCtl = TextEditingController(text: p.fullName ?? '');
    _heightCtl = TextEditingController(
      text: p.heightCm != null ? p.heightCm!.toStringAsFixed(0) : '',
    );
    _weightCtl = TextEditingController(
      text: p.weightKg != null ? p.weightKg!.toStringAsFixed(1) : '',
    );
    _sex = p.sex;
    _dob = p.dateOfBirth;
    _activity = p.activityLevel;
    _diet = p.dietaryPreference ?? 'none';
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _heightCtl.dispose();
    _weightCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final initial = _dob ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF0A2A3D),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Map<String, dynamic> _diffPayload() {
    final p = widget.initial;
    final out = <String, dynamic>{};
    final name = _nameCtl.text.trim();
    if (name.isNotEmpty && name != (p.fullName ?? '')) {
      out['full_name'] = name;
    }
    if (_sex != null && _sex != p.sex) out['sex'] = _sex;
    if (_dob != null && _dob != p.dateOfBirth) {
      out['date_of_birth'] = _dob!.toIso8601String().split('T').first;
    }
    final h = double.tryParse(_heightCtl.text.trim());
    if (h != null && h != p.heightCm) out['height_cm'] = h;
    final w = double.tryParse(_weightCtl.text.trim());
    if (w != null && w != p.weightKg) out['weight_kg'] = w;
    if (_activity != null && _activity != p.activityLevel) {
      out['activity_level'] = _activity;
    }
    if (_diet != null && _diet != p.dietaryPreference) {
      out['dietary_preference'] = _diet;
    }
    return out;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final patch = _diffPayload();
    if (patch.isEmpty) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileActionsProvider).updateProfile(patch);
      if (!mounted) return;
      final l10nSnack = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Text(
            l10nSnack?.profileEditUpdated ?? 'Profile updated',
            style: const TextStyle(color: Colors.white),
          ),
        ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.profileEditTitle ?? 'Edit profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (_error != null) ...[
                _ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              _Label(AppLocalizations.of(context)?.profileEditName ?? 'Name'),
              _TextField(
                controller: _nameCtl,
                hintText: AppLocalizations.of(context)?.profileEditNameHint ??
                    'Your name',
              ),
              const SizedBox(height: 14),
              _Label(AppLocalizations.of(context)?.profileEditSex ?? 'Sex'),
              _ChoiceChips(
                value: _sex,
                options: _sexes,
                labelize: (s) => s[0].toUpperCase() + s.substring(1),
                onChanged: (v) => setState(() => _sex = v),
              ),
              const SizedBox(height: 14),
              _Label(AppLocalizations.of(context)?.profileEditDob ??
                  'Date of birth'),
              _DateField(value: _dob, onTap: _pickDob, l10n: AppLocalizations.of(context)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppLocalizations.of(context)?.profileEditHeightCm ?? 'Height (cm)'),
                        _TextField(
                          controller: _heightCtl,
                          hintText: '170',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          validator: (s) {
                            if (s == null || s.trim().isEmpty) return null;
                            final n = double.tryParse(s);
                            if (n == null) return 'Invalid';
                            if (n < 50 || n > 260) return '50–260';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(AppLocalizations.of(context)?.profileEditWeightKg ?? 'Weight (kg)'),
                        _TextField(
                          controller: _weightCtl,
                          hintText: '70',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          validator: (s) {
                            if (s == null || s.trim().isEmpty) return null;
                            final n = double.tryParse(s);
                            if (n == null) return 'Invalid';
                            if (n < 20 || n > 400) return '20–400';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Label(AppLocalizations.of(context)?.profileEditActivityLevel ??
                  'Activity level'),
              _DropdownField(
                value: _activity,
                options: _activities,
                labelize: _activityLabel,
                onChanged: (v) => setState(() => _activity = v),
              ),
              const SizedBox(height: 14),
              _Label(AppLocalizations.of(context)?.profileEditDietaryPref ??
                  'Dietary preference'),
              _DropdownField(
                value: _diet,
                options: _diets,
                labelize: (s) => s[0].toUpperCase() + s.substring(1),
                onChanged: (v) => setState(() => _diet = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)?.mealScanSaveChanges ??
                              'Save changes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _activityLabel(String s) {
    switch (s) {
      case 'sedentary':
        return 'Sedentary (little exercise)';
      case 'light':
        return 'Light (1–3 days/week)';
      case 'moderate':
        return 'Moderate (3–5 days/week)';
      case 'active':
        return 'Active (6–7 days/week)';
      case 'very_active':
        return 'Very active (2x/day)';
      default:
        return s;
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB8D4D2),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF6E7B91)),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({
    required this.value,
    required this.options,
    required this.labelize,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final String Function(String) labelize;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final selected = o == value;
        return ChoiceChip(
          label: Text(
            labelize(o),
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFB8D4D2),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: selected,
          onSelected: (_) => onChanged(o),
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap, this.l10n});
  final DateTime? value;
  final VoidCallback onTap;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFFB8D4D2)),
            const SizedBox(width: 10),
            Text(
              value == null
                  ? (l10n?.profileEditSelectDate ?? 'Select date')
                  : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: value == null ? const Color(0xFF6E7B91) : Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.options,
    required this.labelize,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final String Function(String) labelize;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A2A3D),
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(labelize(o)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
