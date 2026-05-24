import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/settings_screen.dart';

/// Top section of the Dashboard: date, greeting, and avatar.
///
/// Reads the current user identity from [currentAuthUserProvider] (which
/// in turn is fed by AuthNotifier subscribing to Supabase auth state).
/// Going through Riverpod instead of `Supabase.instance.client` lets
/// widget tests inject a fake user via ProviderScope.overrides.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  String _greeting(AppLocalizations? l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n?.homeGreetingMorning ?? 'Good morning';
    if (hour < 17) return l10n?.homeGreetingAfternoon ?? 'Good afternoon';
    return l10n?.homeGreetingEvening ?? 'Good evening';
  }

  ({String displayName, String initial}) _resolveIdentity(WidgetRef ref) {
    final user = ref.watch(currentAuthUserProvider);

    final fullName = user?.displayName;
    final email = user?.email;

    String displayName;
    if (fullName != null && fullName.trim().isNotEmpty) {
      displayName = fullName.trim().split(' ').first;
    } else if (email != null && email.isNotEmpty) {
      displayName = email.split('@').first;
    } else {
      displayName = 'there';
    }

    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return (displayName: displayName, initial: initial);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('EEEE, MMMM d', locale).format(DateTime.now());
    final identity = _resolveIdentity(ref);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB8C5D6),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_greeting(l10n)}, ${identity.displayName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar doubles as the entry point into Settings. App Review reaches
          // the in-app account-deletion flow (Apple 5.1.1(v)) by tapping here.
          Semantics(
            label: l10n?.homeOpenSettings ?? 'Open settings',
            button: true,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: _Avatar(initial: identity.initial),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withValues(alpha: 0.25),
            const Color(0xFF4DDBFF).withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
