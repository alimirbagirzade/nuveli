import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Glass bottom navigation bar with 5 fixed tabs.
class NuveliBottomNav extends StatelessWidget {
  const NuveliBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.camera_alt_rounded, label: 'Scan'),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Plan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    _NavItem(icon: Icons.water_drop_rounded, label: 'Water'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.lg),
        topRight: Radius.circular(AppRadius.lg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryBackground.withValues(alpha: 0.65),
            border: const Border(
              top: BorderSide(
                color: AppColors.borderGlass,
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: bottomInset + AppSpacing.xs,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                return _NavButton(
                  item: _items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primaryCyan;
    final inactiveColor = Colors.white.withValues(alpha: 0.5);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: activeColor.withValues(alpha: 0.15),
          highlightColor: activeColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 24,
                  color: selected ? activeColor : inactiveColor,
                  shadows: selected
                      ? [
                          Shadow(
                            color: activeColor.withValues(alpha: 0.6),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: activeColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
