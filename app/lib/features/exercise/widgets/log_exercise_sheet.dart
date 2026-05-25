import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/exercise_log.dart';
import '../providers/exercise_provider.dart';
import 'today_activity_list.dart';

/// Canonical activity types (must match the API contract enum exactly).
const List<String> kExerciseTypes = [
  'walking',
  'running',
  'cycling',
  'hiking',
  'swimming',
  'gym',
  'yoga',
  'pilates',
  'dancing',
  'hiit',
  'jump_rope',
  'rowing',
  'sports',
  'other',
];

/// Optional intensity levels (API contract).
const List<String> kExerciseIntensities = [
  'light',
  'moderate',
  'vigorous',
];

/// Material icon for each activity type.
IconData exerciseTypeIcon(String type) {
  switch (type) {
    case 'walking':
      return Icons.directions_walk_rounded;
    case 'running':
      return Icons.directions_run_rounded;
    case 'cycling':
      return Icons.directions_bike_rounded;
    case 'hiking':
      return Icons.terrain_rounded;
    case 'swimming':
      return Icons.pool_rounded;
    case 'gym':
      return Icons.fitness_center_rounded;
    case 'yoga':
      return Icons.self_improvement_rounded;
    case 'pilates':
      return Icons.accessibility_new_rounded;
    case 'dancing':
      return Icons.music_note_rounded;
    case 'hiit':
      return Icons.local_fire_department_rounded;
    case 'jump_rope':
      return Icons.cyclone_rounded;
    case 'rowing':
      return Icons.rowing_rounded;
    case 'sports':
      return Icons.sports_soccer_rounded;
    default:
      return Icons.bolt_rounded;
  }
}

/// Localized display name for an activity type.
String exerciseTypeLabel(AppLocalizations? l10n, String type) {
  switch (type) {
    case 'walking':
      return l10n?.exerciseTypeWalking ?? 'Walking';
    case 'running':
      return l10n?.exerciseTypeRunning ?? 'Running';
    case 'cycling':
      return l10n?.exerciseTypeCycling ?? 'Cycling';
    case 'hiking':
      return l10n?.exerciseTypeHiking ?? 'Hiking';
    case 'swimming':
      return l10n?.exerciseTypeSwimming ?? 'Swimming';
    case 'gym':
      return l10n?.exerciseTypeGym ?? 'Gym';
    case 'yoga':
      return l10n?.exerciseTypeYoga ?? 'Yoga';
    case 'pilates':
      return l10n?.exerciseTypePilates ?? 'Pilates';
    case 'dancing':
      return l10n?.exerciseTypeDancing ?? 'Dancing';
    case 'hiit':
      return l10n?.exerciseTypeHiit ?? 'HIIT';
    case 'jump_rope':
      return l10n?.exerciseTypeJumpRope ?? 'Jump rope';
    case 'rowing':
      return l10n?.exerciseTypeRowing ?? 'Rowing';
    case 'sports':
      return l10n?.exerciseTypeSports ?? 'Sports';
    default:
      return l10n?.exerciseTypeOther ?? 'Other';
  }
}

/// Localized display name for an intensity level.
String exerciseIntensityLabel(AppLocalizations? l10n, String intensity) {
  switch (intensity) {
    case 'light':
      return l10n?.exerciseIntensityLight ?? 'Light';
    case 'moderate':
      return l10n?.exerciseIntensityModerate ?? 'Moderate';
    case 'vigorous':
      return l10n?.exerciseIntensityVigorous ?? 'Vigorous';
    default:
      return intensity;
  }
}

// Card palette — mirrors the dashboard's dark surface so the sheet
// matches the water/meal sheets. The exercise accent is a mint-green
// "movement" tone (distinct from water's cyan).
const Color _kSheetBg = Color(0xFF142346);
const Color _kAccent = Color(0xFF4ADE80);
const Color _kAccentSoft = Color(0xFF86EFAC);

/// Bottom sheet for logging an activity session.
///
/// Wellness boundary: this captures activity (type, duration, optional
/// intensity/note). The backend returns an *informational* `est_calories`
/// estimate which we surface as a neutral, display-only badge — it never
/// affects the calorie budget. See `docs/protocols/safety-wellness-boundary.md`.
class LogExerciseSheet extends ConsumerStatefulWidget {
  /// Opener. Returns true on a successful save.
  ///
  /// Uses a tall, draggable, scroll-controlled sheet so all 14 activity chips
  /// + duration + intensity + note + the Today list fit comfortably and the
  /// keyboard never covers the Save button.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) =>
            LogExerciseSheet(scrollController: scrollController),
      ),
    );
  }

  /// Provided by [DraggableScrollableSheet] so the inner scroll view drives
  /// the sheet's drag-to-resize.
  final ScrollController? scrollController;

  const LogExerciseSheet({super.key, this.scrollController});

  @override
  ConsumerState<LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends ConsumerState<LogExerciseSheet> {
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  String _activityType = 'walking';
  String? _intensity; // optional — null until the user picks one.
  bool _isSaving = false;
  String? _formError;

  @override
  void dispose() {
    _durationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);

    final duration = int.tryParse(_durationCtrl.text.trim());
    if (duration == null || duration <= 0) {
      setState(() => _formError = l10n?.exerciseDurationRequired ??
          'Enter a duration (more than 0 minutes)');
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      final note = _noteCtrl.text.trim();
      final ExerciseLog saved =
          await ref.read(logExerciseProvider)(ExerciseLogInput(
        activityType: _activityType,
        durationMin: duration,
        intensity: _intensity,
        note: note.isEmpty ? null : note,
      ));
      if (!mounted) return;
      // Informational only: when the backend returned an estimate, append a
      // neutral "(≈N kcal)" note. Never implies the user earned food or can
      // eat more — purely a celebratory data point.
      final base =
          l10n?.exerciseSaved ?? 'Great job! Your activity is logged 💪';
      final kcal = saved.estCalories;
      final message = kcal != null
          ? (l10n?.exerciseSavedWithCalories(kcal) ?? '$base (≈$kcal kcal)')
          : base;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = AppLocalizations.of(context)?.exerciseSaveFailed ??
              'Could not save your activity. Tap to retry.';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n?.exerciseLogTitle ?? 'Add activity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.exerciseActivityType ?? 'Activity type',
              style: const _LabelStyle().style,
            ),
            const SizedBox(height: 8),
            _ActivityTypeChips(
              selected: _activityType,
              onSelect: (t) => setState(() => _activityType = t),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: l10n?.exerciseDurationMinutes ?? 'Duration (min)',
              hint: l10n?.exerciseDurationHint ?? 'e.g. 30',
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.exerciseIntensityOptional ?? 'Intensity (optional)',
              style: const _LabelStyle().style,
            ),
            const SizedBox(height: 8),
            _IntensitySelector(
              selected: _intensity,
              onSelect: (i) => setState(() {
                // Tapping the active chip clears the optional choice.
                _intensity = _intensity == i ? null : i;
              }),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: l10n?.exerciseNoteOptional ?? 'Note (optional)',
              hint: l10n?.exerciseNoteHint ?? 'e.g. walk in the park',
              controller: _noteCtrl,
              keyboardType: TextInputType.text,
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _formError!),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: l10n?.exerciseSave ?? 'Save activity',
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: 20),
            // Today's logged activities (with delete + informational kcal
            // badges). Renders nothing when the user hasn't logged today.
            const TodayActivityList(),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _LabelStyle {
  const _LabelStyle();
  TextStyle get style => const TextStyle(
        color: Color(0xFFB8C5D6),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );
}

class _ActivityTypeChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _ActivityTypeChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kExerciseTypes.map((t) {
        final isActive = t == selected;
        return InkWell(
          onTap: () => onSelect(t),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isActive
                  ? _kAccent.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isActive
                    ? _kAccent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  exerciseTypeIcon(t),
                  size: 16,
                  color: isActive ? _kAccentSoft : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  exerciseTypeLabel(l10n, t),
                  style: TextStyle(
                    color: isActive ? _kAccentSoft : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IntensitySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _IntensitySelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: kExerciseIntensities.map((i) {
        final isActive = i == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isActive
                      ? _kAccent.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: isActive
                        ? _kAccent.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  exerciseIntensityLabel(l10n, i),
                  style: TextStyle(
                    color: isActive ? _kAccentSoft : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C5C).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF5C5C).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF8A8A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFB3B3), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const _LabelStyle().style),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6E7B91)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
