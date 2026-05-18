import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// 4 sekmeli alt navigasyon (Dashboard / Meals / Analytics / Profile).
///
/// Frosted glass effect (BackdropFilter + yarı saydam koyu lacivert bg),
/// üst border 1px rgba(white, 0.1).
/// Seçili item: cyan; seçili değil: secondary text.
class NuveliBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NuveliBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItemData>[
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Dashboard'),
    _NavItemData(icon: Icons.restaurant_rounded, label: 'Meals'),
    _NavItemData(icon: Icons.analytics_rounded, label: 'Analytics'),
    _NavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF050A1F).withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_items.length, (i) {
                  return Expanded(
                    child: _NavItem(
                      data: _items[i],
                      isActive: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

class _NavItem extends StatefulWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? AppColors.primaryCyan
        : AppColors.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.data.icon,
              size: 24,
              color: color,
              shadows: widget.isActive
                  ? [
                      Shadow(
                        color: AppColors.primaryCyan.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight:
                    widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
