import 'package:flutter/material.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TODO: optional small Nuveli logo (16x16). Drop the SVG in
          // assets/ and uncomment when ready.
          // SvgPicture.asset('assets/logo_mark.svg', width: 16, height: 16),
          // const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_greeting()}, $userName',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onNotificationTap ??
                () => debugPrint(
                    'Notifications tapped - Chat 17 will hook the real screen'),
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.secondaryText,
              size: 24,
            ),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
