import 'package:flutter/material.dart';
import '../_shared/primary_button.dart';

class AddFoodButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddFoodButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NuveliButton(
        onPressed: onPressed ?? () => debugPrint('Add Food tapped'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add Food',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
