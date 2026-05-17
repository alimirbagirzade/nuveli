import 'package:flutter/material.dart';

import '../../../shared/widgets/nuveli_button.dart';

/// CTA: tıklayınca state'i initial'a döndürür.
class AnalyzeAnotherButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AnalyzeAnotherButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NuveliButton(
        onPressed: onPressed,
        label: 'Analyze Another Meal',
        icon: Icons.search,
        fullWidth: true,
      ),
    );
  }
}
