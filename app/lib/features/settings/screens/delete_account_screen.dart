import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmed = false;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final canDelete = _confirmed && _ctrl.text.trim().toUpperCase() == 'SIL';
    return AppScaffold(
      appBar: AppBar(title: const Text('Hesabı Sil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bu işlem geri alınamaz. Tüm öğün kayıtların, koç konuşmaların ve profil bilgilerin silinecek.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v ?? false),
              title: Text('Bu eylemin geri alınamayacağını anladım',
                  style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 12),
            Text('Onaylamak için aşağıya SIL yaz', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'SIL'),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Hesabı Kalıcı Olarak Sil',
              isEnabled: canDelete,
              onPressed: canDelete ? () {} : null,
            ),
          ],
        ),
      ),
    );
  }
}
