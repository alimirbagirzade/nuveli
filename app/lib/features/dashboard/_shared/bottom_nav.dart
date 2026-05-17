import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class NuveliBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NuveliBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.restaurant_menu_outlined, label: 'Meals'),
    _NavItem(icon: Icons.show_chart, label: 'Analytics'),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: DashboardColors.cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: DashboardColors.cardBorder),
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = i == currentIndex;
            final color =
                active ? DashboardColors.cyan : DashboardColors.textTertiary;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_items[i].icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
