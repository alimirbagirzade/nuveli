import 'package:flutter/material.dart';

/// Top header of the Meal Planner screen: N-logo, centered title, settings cog.
class MealPlannerHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const MealPlannerHeader({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const _NuveliMark(),
          const Expanded(
            child: Center(
              child: Text(
                'Meal Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          _SettingsButton(onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _NuveliMark extends StatelessWidget {
  const _NuveliMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF00D4FF),
            letterSpacing: -1,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.55),
                blurRadius: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(
          Icons.settings_outlined,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
