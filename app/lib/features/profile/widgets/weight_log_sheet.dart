import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';

import '../providers/profile_actions.dart';

/// Bottom sheet: log a new weight measurement.
///
/// Call site:
/// ```dart
/// showModalBottomSheet(
///   context: ctx,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const WeightLogSheet(),
/// );
/// ```
class WeightLogSheet extends ConsumerStatefulWidget {
  /// Optional pre-fill (e.g. current weight from profile).
  final double? initialKg;

  const WeightLogSheet({super.key, this.initialKg});

  @override
  ConsumerState<WeightLogSheet> createState() => _WeightLogSheetState();
}

class _WeightLogSheetState extends ConsumerState<WeightLogSheet> {
  late final TextEditingController _ctrl;
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialKg?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _ctrl.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed < 20 || parsed > 400) {
      setState(() => _error = 'Enter a weight between 20 and 400 kg');
      return;
    }
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

    // Capture refs to outlive the sheet — the next pop() unmounts this
    // widget so we can't use `context` for snackbars afterwards.
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(profileActionsProvider);

    // Pop optimistically. On Render free tier the POST + dashboard
    // refetch takes 1-3 seconds; with this change the sheet feels
    // instant. Profile providers will refresh in the background and
    // the WeightGoalCard updates whenever the data lands.
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Saving ${parsed.toStringAsFixed(1)} kg...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      await actions.logWeight(weightKg: parsed, note: note);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Weight saved (${parsed.toStringAsFixed(1)} kg)'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1B5E20),
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not save ${parsed.toStringAsFixed(1)} kg'),
          backgroundColor: const Color(0xFFB71C1C),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await actions.logWeight(weightKg: parsed, note: note);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Weight saved')),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Still could not save')),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1A3D),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Log your weight',
                style: AppTypography.sectionTitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Track your progress toward your goal',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Weight input
              _LabeledField(
                label: 'Weight',
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]')),
                        ],
                        style: AppTypography.heroLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: AppTypography.heroLarge.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 32,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Text(
                      'kg',
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Optional note
              _LabeledField(
                label: 'Note (optional)',
                child: TextField(
                  controller: _noteCtrl,
                  style: AppTypography.body.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'After workout, morning, etc.',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _error!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.s24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primaryCyan.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save weight',
                    style: AppTypography.cardTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
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
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.cardBackground,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          child,
        ],
      ),
    );
  }
}

/// Top-level helper so callers don't need to remember sheet config.
Future<bool?> showWeightLogSheet(
  BuildContext context, {
  double? initialKg,
}) {
  // Provider reference is fine here because we read it inside the sheet itself.
  // Unused param suppression for the linter if not provided.
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WeightLogSheet(initialKg: initialKg),
  );
}
