import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/settings_providers.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmCtrl = TextEditingController();
  bool _confirmed = false;
  bool _deleting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      _confirmed && _confirmCtrl.text.trim().toUpperCase() == 'SIL';

  Future<void> _handleDelete() async {
    // Ek güvenlik: son onay modalı
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Son kez soruyoruz'),
        content: const Text(
          'Hesabını kalıcı olarak silmek üzeresin. Öğünlerin, koç konuşmaların, '
          'tüm profil bilgilerin silinecek ve geri getirilemeyecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Evet, sil'),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;

    setState(() {
      _deleting = true;
      _errorMsg = null;
    });

    try {
      AppHaptics.heavy(); // Kritik geri alınamaz aksiyon
      await ref.read(deleteAccountActionProvider)();
      if (!mounted) return;
      // Login'e yönlendir (tüm stack'i temizle)
      context.go(AppRoute.login);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesabın silindi.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e is AppError ? e.userMessage : 'Silinemedi. Tekrar dene.';
        _deleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Hesabı Sil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uyarı banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz. Tüm öğün kayıtların, koç '
                      'konuşmaların ve profil bilgilerin silinecek.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Açıklama
            Text(
              'Silinecek veriler:',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            ...[
              'Tüm öğün kayıtların ve analiz geçmişin',
              'Koç ile yaptığın tüm konuşmalar',
              'Profil bilgilerin ve hedeflerin',
              'Bildirim tercihlerin',
              'Premium abonelik durumun',
            ].map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 8),
                        child: Icon(
                          Icons.circle,
                          size: 5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Checkbox onayı
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: _deleting
                  ? null
                  : (v) => setState(() => _confirmed = v ?? false),
              title: Text(
                'Bu eylemin geri alınamayacağını anladım',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Metin onayı
            Text(
              'Onaylamak için aşağıya SIL yaz',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmCtrl,
              enabled: !_deleting,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'SIL'),
            ),
            const SizedBox(height: 16),

            // Hata
            if (_errorMsg != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMsg!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ),

            const Spacer(),

            // Sil butonu (red)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_canDelete && !_deleting) ? _handleDelete : null,
                child: _deleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Hesabı Kalıcı Olarak Sil',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _deleting ? null : () => context.pop(),
                child: const Text('Vazgeç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
