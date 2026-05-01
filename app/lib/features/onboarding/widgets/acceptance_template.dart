import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

/// Tüm kabul ekranları için ortak template (DRY).
class AcceptanceTemplate extends StatefulWidget {
  const AcceptanceTemplate({
    super.key,
    required this.stepLabel,
    required this.title,
    required this.body,
    required this.checkboxLabel,
    required this.onContinue,
    this.onBack,
  });

  final String stepLabel;
  final String title;
  final String body;
  final String checkboxLabel;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  @override
  State<AcceptanceTemplate> createState() => _AcceptanceTemplateState();
}

class _AcceptanceTemplateState extends State<AcceptanceTemplate> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack)
            : null,
        title: Text(widget.stepLabel, style: AppTextStyles.labelMedium),
      ),
      padding: const EdgeInsets.all(24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(widget.title, style: AppTextStyles.displayMedium),
          const SizedBox(height: 12),
          Text(widget.body, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          _CheckboxCard(
            label: widget.checkboxLabel,
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Devam Et',
            isEnabled: _accepted,
            onPressed: widget.onContinue,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CheckboxCard extends StatelessWidget {
  const _CheckboxCard({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.divider,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.textTertiary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
