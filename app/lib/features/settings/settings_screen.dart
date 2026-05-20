import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/account_delete_provider.dart';

/// Settings screen — minimum viable surface for Apple 5.1.1(v) compliance.
///
/// Hosts the "Delete Account" entry point that App Review reaches by
/// tapping the avatar in the dashboard header. Full settings (notifications,
/// language, theme) live elsewhere; this screen exists so the delete flow
/// has a stable home.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: const [
            _Section(
              title: 'Account',
              child: _DeleteAccountTile(),
            ),
            _Section(
              title: 'Session',
              child: _SignOutTile(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8FA0B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF142346).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SignOutTile extends ConsumerWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.white70),
      title: const Text('Sign out', style: TextStyle(color: Colors.white)),
      onTap: () async {
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}

class _DeleteAccountTile extends ConsumerWidget {
  const _DeleteAccountTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountDeleteProvider);
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Color(0xFFFF6B6B)),
      title: const Text(
        'Delete My Account',
        style: TextStyle(color: Color(0xFFFF6B6B)),
      ),
      subtitle: const Text(
        'Permanently removes your profile, meals, and all data.',
        style: TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
      ),
      trailing: state.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
              ),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF8FA0B8)),
      onTap: state.isLoading
          ? null
          : () => _confirmAndDelete(context, ref),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteConfirmDialog(),
    );
    if (confirmed != true) return;

    await ref.read(accountDeleteProvider.notifier).deleteAccount();
    if (!context.mounted) return;

    final state = ref.read(accountDeleteProvider);
    if (state.hasError) {
      final err = state.error;
      final msg = err is ApiException ? err.userMessage : 'Could not delete account.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF6B6B)),
      );
      return;
    }

    // AuthGate will repaint to WelcomeScreen as soon as Supabase emits
    // signedOut. Pop any modal sheets and the settings route on top of it.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog();

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final ok = _controller.text.trim().toUpperCase() == 'DELETE';
      if (ok != _canDelete) setState(() => _canDelete = ok);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF142346),
      title: const Text(
        'Delete account?',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your profile, all meal logs, water logs, '
            'weight history, habits, and subscriptions. This cannot be undone.',
            style: TextStyle(color: Color(0xFFB8C5D6), fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type DELETE to confirm:',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'DELETE',
              hintStyle: const TextStyle(color: Color(0xFF8FA0B8)),
              filled: true,
              fillColor: const Color(0xFF050A1F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.primaryCyan)),
        ),
        TextButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            'Delete',
            style: TextStyle(
              color: _canDelete ? const Color(0xFFFF6B6B) : const Color(0xFF8FA0B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
