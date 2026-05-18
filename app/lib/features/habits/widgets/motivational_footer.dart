import 'package:flutter/material.dart';

const Color _cyan = Color(0xFF00D4FF);
const Color _cyanGlow = Color(0xFF4DDBFF);
const Color _secondaryText = Color(0xFFB8C5D6);

/// Footer card encouraging the user to keep going.
class MotivationalFooter extends StatelessWidget {
  const MotivationalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing star
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _cyan.withOpacity(0.25),
                  _cyan.withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _cyan.withOpacity(0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.star_rounded,
                size: 24,
                color: _cyanGlow,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Small actions build lasting results.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep showing up for yourself.',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
