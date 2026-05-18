import 'package:flutter/material.dart';

/// Top bar for the AI Coach screen.
/// Layout: [← back] [— AI Coach centered —] [⚙️ settings]
///
/// Visually identical to `HabitsHeader` (Chat 10) — same circle icon buttons,
/// same padding, same centered title — so the header rhythm stays consistent
/// across the app.
class CoachHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSettings;

  const CoachHeader({
    super.key,
    this.onBack,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 18,
            onTap: onBack,
            semanticLabel: 'Back',
          ),
          const Expanded(
            child: Center(
              child: Text(
                'AI Coach',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            iconSize: 20,
            onTap: onSettings,
            semanticLabel: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// 40x40 round button with subtle glass background.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _CircleIconButton({
    required this.icon,
    required this.iconSize,
    required this.semanticLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Center(
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
