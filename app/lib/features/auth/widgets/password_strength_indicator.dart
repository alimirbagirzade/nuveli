// ============================================================================
// password_strength_indicator.dart
// Signup'ta şifre kalitesini gösteren 4 bar göstergesi.
// Skor: 0=yok, 1=zayıf, 2=orta, 3=güçlü, 4=çok güçlü
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';

class PasswordStrength {
  final int score; // 0..4
  final String label;
  final Color color;
  final List<String> suggestions;

  const PasswordStrength({
    required this.score,
    required this.label,
    required this.color,
    required this.suggestions,
  });

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        score: 0,
        label: '',
        color: Color(0xFF4A5670),
        suggestions: [],
      );
    }

    int score = 0;
    final suggestions = <String>[];

    // Length
    if (password.length >= 8) {
      score++;
    } else {
      suggestions.add('Use at least 8 characters');
    }
    if (password.length >= 12) score++;

    // Number
    if (password.contains(RegExp(r'\d'))) {
      score++;
    } else {
      suggestions.add('Add a number');
    }

    // Mixed case
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      score++;
    } else {
      suggestions.add('Mix uppercase & lowercase');
    }

    // Symbol
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score++;
    } else if (score < 4) {
      suggestions.add('Add a symbol (!@#\$%)');
    }

    final clamped = score > 4 ? 4 : score;

    return PasswordStrength(
      score: clamped,
      label: _label(clamped),
      color: _color(clamped),
      suggestions: suggestions.take(2).toList(),
    );
  }

  static String _label(int s) => switch (s) {
        0 => '',
        1 => 'Weak',
        2 => 'Fair',
        3 => 'Strong',
        _ => 'Very strong',
      };

  static Color _color(int s) => switch (s) {
        0 => const Color(0xFF4A5670),
        1 => AppColors.danger,
        2 => AppColors.warning,
        3 => AppColors.success,
        _ => AppColors.primaryCyan,
      };
}

// ============================================================================
// WIDGET
// ============================================================================

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = PasswordStrength.evaluate(password);

    if (password.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final localizedLabel = _localizedLabel(strength.score, l10n);
    final localizedSuggestion = strength.suggestions.isEmpty
        ? null
        : _localizedSuggestion(strength.suggestions.first, l10n);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final active = i < strength.score;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: active
                        ? strength.color
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          if (localizedLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizedLabel,
                  style: AppTypography.caption12.copyWith(
                    color: strength.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (localizedSuggestion != null)
                  Expanded(
                    child: Text(
                      localizedSuggestion,
                      textAlign: TextAlign.right,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _localizedLabel(int score, AppLocalizations? l10n) => switch (score) {
        0 => '',
        1 => l10n?.passwordStrengthWeak ?? 'Weak',
        2 => l10n?.passwordStrengthFair ?? 'Fair',
        3 => l10n?.passwordStrengthStrong ?? 'Strong',
        _ => l10n?.passwordStrengthVeryStrong ?? 'Very strong',
      };

  String _localizedSuggestion(String original, AppLocalizations? l10n) {
    if (original == 'Use at least 8 characters') return l10n?.passwordStrengthSuggestLength ?? original;
    if (original == 'Add a number') return l10n?.passwordStrengthSuggestNumber ?? original;
    if (original == 'Mix uppercase & lowercase') return l10n?.passwordStrengthSuggestCase ?? original;
    if (original.startsWith('Add a symbol')) return l10n?.passwordStrengthSuggestSymbol ?? original;
    return original;
  }
}
