import 'package:flutter/material.dart';
import '../_shared/dashboard_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.onNotificationTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    if (hour >= 18 && hour < 22) return 'Good evening';
    return 'Hi';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_greeting()}, $userName',
              style: const TextStyle(
                color: DashboardColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onNotificationTap ??
                () => debugPrint('Notifications tapped'),
            icon: const Icon(
              Icons.notifications_outlined,
              color: DashboardColors.textSecondary,
              size: 24,
            ),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
