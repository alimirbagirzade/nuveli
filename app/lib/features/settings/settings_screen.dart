import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/language_provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/providers/auth_provider.dart';
import '../coach/mood/models/coach_persona.dart';
import '../coach/mood/providers/coach_persona_provider.dart';
import 'providers/account_delete_provider.dart';
import 'providers/data_export_provider.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n?.settingsTitle ?? 'Settings',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _Section(
              title: l10n?.settingsCoachSection ?? 'Coach',
              child: const _CoachPersonaTile(),
            ),
            _Section(
              title: l10n?.settingsLanguage ?? 'Language',
              child: const _LanguageTile(),
            ),
            _Section(
              title: l10n?.settingsYourData ?? 'Your data',
              child: const _ExportDataTile(),
            ),
            _Section(
              title: l10n?.settingsAccount ?? 'Account',
              child: const _DeleteAccountTile(),
            ),
            _Section(
              title: l10n?.settingsSession ?? 'Session',
              child: const _SignOutTile(),
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

class _ExportDataTile extends ConsumerWidget {
  const _ExportDataTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dataExportProvider);
    return ListTile(
      leading: const Icon(Icons.download_for_offline_outlined,
          color: AppColors.primaryCyan),
      title: Text(l10n?.settingsExportData ?? 'Export My Data',
          style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        l10n?.settingsExportDataDesc ??
            'Download every meal, water log, weight entry, habit, and insight '
                'as a JSON file. Right to data portability (GDPR Art. 20).',
        style: const TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
      ),
      trailing: state.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primaryCyan),
              ),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF8FA0B8)),
      onTap: state.isLoading
          ? null
          : () async {
              await ref.read(dataExportProvider.notifier).exportData();
              if (!context.mounted) return;
              final next = ref.read(dataExportProvider);
              if (next.hasError) {
                final err = next.error;
                final msg = err is ApiException
                    ? err.userMessage
                    : (l10n?.settingsExportFailed ??
                        'Could not export your data.');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: const Color(0xFFFF6B6B),
                  ),
                );
              }
              // Success case: SharePlus already showed the share sheet,
              // no extra UI needed.
            },
    );
  }
}

// ---------------------------------------------------------------------------
// Coach persona picker — drives the local mood-bubble voice. Local-only
// (SharedPreferences); never round-trips to the backend.
// ---------------------------------------------------------------------------

String _personaLabel(AppLocalizations l, CoachPersona p) {
  switch (p) {
    case CoachPersona.gentle:
      return l.personaGentle;
    case CoachPersona.funny:
      return l.personaFunny;
    case CoachPersona.direct:
      return l.personaDirect;
    case CoachPersona.calm:
      return l.personaCalm;
  }
}

String _personaDesc(AppLocalizations l, CoachPersona p) {
  switch (p) {
    case CoachPersona.gentle:
      return l.personaGentleDesc;
    case CoachPersona.funny:
      return l.personaFunnyDesc;
    case CoachPersona.direct:
      return l.personaDirectDesc;
    case CoachPersona.calm:
      return l.personaCalmDesc;
  }
}

class _CoachPersonaTile extends ConsumerWidget {
  const _CoachPersonaTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final persona = ref.watch(coachPersonaProvider);
    return ListTile(
      leading: const Icon(Icons.spa_rounded, color: AppColors.primaryCyan),
      title: Text(
        l10n?.coachToneQuestion ?? 'Coach tone',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        l10n != null ? _personaLabel(l10n, persona) : persona.code,
        style: const TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF8FA0B8)),
      onTap: l10n == null ? null : () => _showPicker(context, ref, persona),
    );
  }

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    CoachPersona current,
  ) async {
    final selected = await showModalBottomSheet<CoachPersona>(
      context: context,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.coachToneQuestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              RadioGroup<CoachPersona>(
                groupValue: current,
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final p in CoachPersona.values)
                      RadioListTile<CoachPersona>(
                        value: p,
                        activeColor: AppColors.primaryCyan,
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          _personaLabel(l10n, p),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _personaDesc(l10n, p),
                          style: const TextStyle(
                            color: Color(0xFF8FA0B8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await ref.read(coachPersonaProvider.notifier).setPersona(selected);
    }
  }
}

// ---------------------------------------------------------------------------
// Language picker — drives globalLanguageNotifier (AppLanguage.system = device
// locale). Wires the previously dead changeLanguage() to a real UI.
// ---------------------------------------------------------------------------

String _languageLabel(AppLocalizations? l10n, AppLanguage lang) {
  if (lang == AppLanguage.system) {
    return l10n?.settingsLanguageSystem ?? 'System language';
  }
  return lang.label; // native name (Türkçe, English, Deutsch, …)
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: globalLanguageNotifier,
      builder: (context, current, _) {
        return ListTile(
          leading: const Icon(Icons.language_rounded,
              color: AppColors.primaryCyan),
          title: Text(
            l10n?.settingsLanguage ?? 'Language',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _languageLabel(l10n, current),
            style: const TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF8FA0B8)),
          onTap: () => _showPicker(context, current),
        );
      },
    );
  }

  Future<void> _showPicker(BuildContext context, AppLanguage current) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: SingleChildScrollView(
            child: RadioGroup<AppLanguage>(
              groupValue: current,
              onChanged: (value) => Navigator.of(sheetContext).pop(value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n?.settingsLanguage ?? 'Language',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  for (final lang in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      value: lang,
                      activeColor: AppColors.primaryCyan,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        _languageLabel(l10n, lang),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await changeLanguage(selected);
    }
  }
}

class _SignOutTile extends ConsumerWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.white70),
      title: Text(l10n?.settingsLogout ?? 'Sign out',
          style: const TextStyle(color: Colors.white)),
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(accountDeleteProvider);
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Color(0xFFFF6B6B)),
      title: Text(
        l10n?.settingsDeleteAccount ?? 'Delete My Account',
        style: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
      subtitle: Text(
        l10n?.settingsDeleteDesc ??
            'Permanently removes your profile, meals, and all data.',
        style: const TextStyle(color: Color(0xFF8FA0B8), fontSize: 12),
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

    final l10n = AppLocalizations.of(context);
    final state = ref.read(accountDeleteProvider);
    if (state.hasError) {
      final err = state.error;
      final msg = err is ApiException
          ? err.userMessage
          : (l10n?.settingsDeleteFailed ?? 'Could not delete account.');
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF142346),
      title: Text(
        l10n?.settingsDeleteTitle ?? 'Delete account?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.settingsDeleteConfirmBody ??
                'This permanently deletes your profile, all meal logs, water '
                    'logs, weight history, habits, and subscriptions. This '
                    'cannot be undone.',
            style: const TextStyle(color: Color(0xFFB8C5D6), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.settingsDeleteType ?? 'Type DELETE to confirm:',
            style: const TextStyle(color: Colors.white, fontSize: 13),
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
          child: Text(l10n?.commonCancel ?? 'Cancel',
              style: const TextStyle(color: AppColors.primaryCyan)),
        ),
        TextButton(
          onPressed: _canDelete ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            l10n?.commonDelete ?? 'Delete',
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
