import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

/// 5 kabul ekranının ortak iskeleti.
/// Her ekran bu widget'ı kullanarak checkbox + devam akışını sağlar.
class AcceptanceScreenBase extends StatefulWidget {
  const AcceptanceScreenBase({
    super.key,
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.checkboxLabel,
    required this.onAccept,
    this.secondaryLink,
  });

  final int stepNumber;
  final int totalSteps;
  final String title;
  final String body;
  final String checkboxLabel;
  final VoidCallback onAccept;
  final Widget? secondaryLink;

  @override
  State<AcceptanceScreenBase> createState() => _AcceptanceScreenBaseState();
}

class _AcceptanceScreenBaseState extends State<AcceptanceScreenBase> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Progress dots
          Row(
            children: List.generate(widget.totalSteps, (i) {
              final active = i < widget.stepNumber;
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: active ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          Text(widget.title, style: AppTextStyles.displayMedium),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(widget.body, style: AppTextStyles.bodyLarge.copyWith(height: 1.6)),
            ),
          ),
          if (widget.secondaryLink != null) ...[
            widget.secondaryLink!,
            const SizedBox(height: 12),
          ],
          _CheckboxTile(
            label: widget.checkboxLabel,
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Devam',
            onPressed: _accepted ? widget.onAccept : null,
            isEnabled: _accepted,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  const _CheckboxTile({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
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
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
