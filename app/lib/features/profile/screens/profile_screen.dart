import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/meal_image_capture.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/nuveli_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/profile_repository.dart';
import 'goals_screen.dart';
import 'personal_info_screen.dart';

/// Profile screen — user identity (avatar + name) at the top,
/// settings tiles below in 6 grouped sections.
///
/// Editing the name happens inline via [_NameEditor] — no separate
/// route push, no modal sheet. Avatar editing opens a bottom sheet
/// because picking from 5 styles × dozens of seeds needs more space.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is AppError ? e.userMessage : 'Profil yüklenemedi.',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      // Scroll physics + drag device handling are configured globally
      // via _AppScrollBehavior in app.dart. We only set bottom padding
      // here so the last item doesn't sit flush against the home
      // indicator on iPhones with rounded corners.
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        _IdentityHeader(profile: profile),
        const SizedBox(height: 24),
        _SectionLabel('Hesap'),
        _Tile(
          icon: Icons.person_outline,
          title: 'Kişisel bilgiler',
          subtitle: 'İsim, hedefler, vücut bilgileri',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PersonalInfoScreen(),
            ),
          ),
        ),
        _Tile(
          icon: Icons.flag_outlined,
          title: 'Hedefler',
          subtitle: 'Kalori ve makro hedefin',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GoalsScreen(),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _SectionLabel('Bildirimler'),
        _Tile(
          icon: Icons.notifications_outlined,
          title: 'Bildirim tercihleri',
          subtitle: 'Hatırlatmalar ve sessiz saatler',
          onTap: () => context.push(AppRoute.notificationPrefs),
        ),

        const SizedBox(height: 16),
        _SectionLabel('Tema'),
        _Tile(
          icon: Icons.dark_mode_outlined,
          title: 'Karanlık tema',
          subtitle: 'Şu an aktif (varsayılan)',
          trailing: Switch.adaptive(
            value: true,
            onChanged: (_) => _showComingSoon(context, 'Açık tema yakında'),
            activeColor: AppColors.primary,
          ),
        ),

        const SizedBox(height: 16),
        _SectionLabel('Premium'),
        _Tile(
          icon: Icons.star_outline,
          title: 'Premium aboneliğim',
          subtitle: 'Plan, fatura ve özellikler',
          onTap: () => context.push(AppRoute.paywall),
          highlight: true,
        ),

        const SizedBox(height: 16),
        _SectionLabel('Yardım & Güvenlik'),
        _Tile(
          icon: Icons.help_outline,
          title: 'Destek',
          subtitle: 'Sorular ve geri bildirim',
          onTap: () => context.push(AppRoute.support),
        ),
        _Tile(
          icon: Icons.auto_awesome_outlined,
          title: 'AI nasıl çalışır',
          onTap: () => context.push(AppRoute.howAiWorks),
        ),
        _Tile(
          icon: Icons.privacy_tip_outlined,
          title: 'Gizlilik ve güvenlik',
          onTap: () => context.push(AppRoute.privacySafety),
        ),
        _Tile(
          icon: Icons.info_outline,
          title: 'Nuveli hakkında',
          onTap: () => context.push(AppRoute.about),
        ),

        const SizedBox(height: 24),
        _SectionLabel('Çıkış'),
        _Tile(
          icon: Icons.logout,
          title: 'Çıkış yap',
          color: AppColors.warning,
          onTap: () => _confirmSignOut(context, ref),
        ),
        _Tile(
          icon: Icons.delete_outline,
          title: 'Hesabı sil',
          color: AppColors.error,
          onTap: () => context.push(AppRoute.deleteAccount),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Çıkış yap'),
        content: const Text('Hesabından çıkmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Çıkış yap',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
    if (yes == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go(AppRoute.login);
    }
  }
}

// ─── Identity Header (avatar + editable name) ────────────────────────

class _IdentityHeader extends ConsumerStatefulWidget {
  const _IdentityHeader({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_IdentityHeader> createState() => _IdentityHeaderState();
}

class _IdentityHeaderState extends ConsumerState<_IdentityHeader> {
  bool _editingName = false;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      _snack('İsim boş olamaz');
      return;
    }
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(displayName: newName);
      ref.invalidate(userProfileProvider);
      setState(() => _editingName = false);
    } catch (e) {
      _snack(e is AppError ? e.userMessage : 'İsim kaydedilemedi');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AvatarPickerSheet(profile: widget.profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with tap-to-edit hint
          GestureDetector(
            onTap: _openAvatarPicker,
            child: Stack(
              children: [
                NuveliAvatar(
                  style: widget.profile.avatarStyle,
                  seed: widget.profile.avatarSeed,
                  photoUrl: widget.profile.avatarPhotoUrl,
                  size: 120,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Name + inline edit
          if (!_editingName) ...[
            GestureDetector(
              onTap: () => setState(() {
                _editingName = true;
                _nameCtrl.text = widget.profile.displayName ?? '';
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.profile.effectiveName,
                    style: AppTextStyles.headingLarge,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ] else ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: TextField(
                controller: _nameCtrl,
                autofocus: true,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                style: AppTextStyles.headingLarge,
                onSubmitted: (_) => _saveName(),
                decoration: InputDecoration(
                  hintText: 'İsmin',
                  hintStyle: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: const UnderlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => _editingName = false),
                  child: const Text('Vazgeç'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveName,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],

          // Email (read only)
          if (widget.profile.email != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.profile.email!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Avatar picker sheet ─────────────────────────────────────────────

class _AvatarPickerSheet extends ConsumerStatefulWidget {
  const _AvatarPickerSheet({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_AvatarPickerSheet> createState() =>
      _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends ConsumerState<_AvatarPickerSheet> {
  late String _style;
  late String _seed;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _style = widget.profile.avatarStyle;
    _seed = widget.profile.avatarSeed;
  }

  /// Generate 16 deterministic seed candidates so the user has a
  /// reasonable selection without scrolling forever.
  List<String> _seedCandidates() {
    final rng = Random(widget.profile.id.hashCode);
    return List.generate(16, (_) {
      final n = rng.nextInt(1 << 30);
      return 'nuveli-$n';
    });
  }

  Future<void> _saveGeneratedAvatar() async {
    setState(() => _saving = true);
    try {
      // Saving a generated avatar means we ALSO want to clear any uploaded
      // photo, otherwise the photo keeps overriding it.
      await ref.read(profileRepositoryProvider).updateProfile(
            avatarStyle: _style,
            avatarSeed: _seed,
            avatarPhotoUrl: '', // empty string → backend translates to NULL
          );
      ref.invalidate(userProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppError ? e.userMessage : 'Avatar kaydedilemedi'),
        ),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _uploading = true);
    try {
      final path = await MealImageCapture.fromGallery();
      if (path == null) {
        // user cancelled
        setState(() => _uploading = false);
        return;
      }
      final b64 = await MealImageCapture.toBase64(path);
      if (b64 == null) {
        throw Exception('Fotoğraf okunamadı');
      }
      final url = await ref.read(profileRepositoryProvider).uploadAvatarPhoto(b64);
      // Backend already updated profiles.avatar_photo_url; just invalidate.
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar güncellendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppError ? e.userMessage : 'Yüklenemedi: $e'),
        ),
      );
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seeds = _seedCandidates();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Avatarını seç', style: AppTextStyles.headingMedium),
                const Spacer(),
                NuveliAvatar(
                  style: _style,
                  seed: _seed,
                  photoUrl: widget.profile.avatarPhotoUrl,
                  size: 56,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Photo upload — galeriden kendi fotoğrafını seç
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploading ? null : _pickFromGallery,
                icon: _uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(_uploading
                    ? 'Yükleniyor…'
                    : 'Galeri\'den fotoğraf seç'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            // If user already has an uploaded photo, offer a clear button
            if (widget.profile.hasPhoto) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(profileRepositoryProvider).clearAvatarPhoto();
                  ref.invalidate(userProfileProvider);
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Yüklenen fotoğrafı kaldır'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'veya hazır avatar seç',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Style chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AvatarStyles.all.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = AvatarStyles.all[i];
                  final selected = _style == s;
                  return ChoiceChip(
                    label: Text(AvatarStyles.label(s)),
                    selected: selected,
                    onSelected: (_) => setState(() => _style = s),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: seeds.length,
                itemBuilder: (_, i) {
                  final seed = seeds[i];
                  final selected = _seed == seed;
                  return GestureDetector(
                    onTap: () => setState(() => _seed = seed),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: NuveliAvatar(style: _style, seed: seed, size: 64),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _saveGeneratedAvatar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Hazır avatarı kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable section + tile ─────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return Material(
      color: highlight
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primary).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: tileColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(color: tileColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error view ──────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
