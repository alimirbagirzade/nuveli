import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../streak/data/streak_repository.dart';
import '../providers/settings_providers.dart';

class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends ConsumerState<NotificationPrefsScreen> {
  bool _saving = false;
  String? _errorMsg;

  /// "22:00" string'ini TimeOfDay'e çevirir.
  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final prefs = ref.read(notificationPrefsControllerProvider).value;
    if (prefs == null) return;

    final initial =
        _parseTime(isStart ? prefs.quietStart : prefs.quietEnd);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final controller = ref.read(notificationPrefsControllerProvider.notifier);
    if (isStart) {
      controller.setQuietStart(_formatTime(picked));
    } else {
      controller.setQuietEnd(_formatTime(picked));
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorMsg = null;
    });

    try {
      await ref.read(notificationPrefsControllerProvider.notifier).save();

      // Backend kaydı başarılı — local notification'ları yeniden schedule et.
      // Permission yoksa OS dialog'u burada açılır (ilk seferinde).
      final prefs = ref.read(notificationPrefsControllerProvider).value;
      if (prefs != null) {
        // İzin yoksa iste; reddederse de devam — schedule fail olmaz,
        // sadece bildirim gözükmez.
        await LocalNotificationService.instance.requestPermissions();

        // Streak verisi varsa onu da hesaba kat. Yoksa null geçilir
        // (streak risk reminder schedule edilmez, diğerleri yine olur).
        StreakInfo? currentStreak;
        try {
          currentStreak = await ref.read(streakProvider.future);
        } catch (_) {
          currentStreak = null;
        }

        await LocalNotificationService.instance.rescheduleAll(
          prefs: prefs,
          streak: currentStreak,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tercihler kaydedildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e is AppError ? e.userMessage : 'Kaydedilemedi.';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPrefs = ref.watch(notificationPrefsControllerProvider);
    final controller = ref.read(notificationPrefsControllerProvider.notifier);

    return AppScaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: asyncPrefs.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // 3 switch placeholder
            SkeletonCard(height: 70),
            SizedBox(height: 8),
            SkeletonCard(height: 70),
            SizedBox(height: 8),
            SkeletonCard(height: 70),
            SizedBox(height: 24),
            SkeletonBox(width: 140, height: 12),
            SizedBox(height: 12),
            // Quiet hours
            SkeletonCard(height: 60),
            SizedBox(height: 8),
            SkeletonCard(height: 60),
          ],
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  err is AppError ? err.userMessage : 'Yüklenemedi.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(notificationPrefsControllerProvider),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
        data: (prefs) => Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    value: prefs.mealReminders,
                    onChanged: controller.setMealReminders,
                    title: const Text('Öğün Hatırlatıcıları'),
                    subtitle: Text(
                      'Kahvaltı, öğle, akşam zamanı nazik hatırlatma',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  SwitchListTile(
                    value: prefs.coachNudges,
                    onChanged: controller.setCoachNudges,
                    title: const Text('Koç Nüdgleri'),
                    subtitle: Text(
                      'Kişisel destek ve motivasyon mesajları',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  SwitchListTile(
                    value: prefs.weeklySummary,
                    onChanged: controller.setWeeklySummary,
                    title: const Text('Haftalık Özet'),
                    subtitle: Text(
                      'Pazartesi sabahı geçen haftanın özeti',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'SESSİZ SAATLER',
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Bu saatler arasında hiçbir bildirim gelmez.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Başlangıç'),
                    trailing: Text(
                      prefs.quietStart,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _pickTime(context, true),
                  ),
                  ListTile(
                    title: const Text('Bitiş'),
                    trailing: Text(
                      prefs.quietEnd,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _pickTime(context, false),
                  ),
                ],
              ),
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Kaydet',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
