import 'package:flutter/material.dart';

/// Compact water tracker row on the dashboard.
/// Shows glasses consumed / target and a "+250 ml" quick-add button.
///
/// The full water tracker screen (with timeline, reminders, insights)
/// lands in Chat 8. This card is just enough to log a glass from the
/// dashboard without a screen jump.
class WaterQuickCard extends StatefulWidget {
  final int consumedMl;
  final int targetMl;
  final Future<void> Function(int amountMl) onAddWater;

  const WaterQuickCard({
    super.key,
    required this.consumedMl,
    required this.targetMl,
    required this.onAddWater,
  });

  @override
  State<WaterQuickCard> createState() => _WaterQuickCardState();
}

class _WaterQuickCardState extends State<WaterQuickCard> {
  bool _isAdding = false;

  Future<void> _handleAdd() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);
    try {
      await widget.onAddWater(250);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not log water. Tap to retry.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glasses = (widget.consumedMl / 250).floor();
    final glassesTarget = (widget.targetMl / 250).ceil().clamp(1, 99);
    final progress = widget.targetMl > 0
        ? (widget.consumedMl / widget.targetMl).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF142346).withOpacity(0.5),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Water droplet icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D4FF).withOpacity(0.25),
                  const Color(0xFF4DDBFF).withOpacity(0.10),
                ],
              ),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF4DDBFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Water',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB8C5D6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$glasses',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' of $glassesTarget glasses',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6E7B91),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4DDBFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AddButton(isLoading: _isAdding, onTap: _handleAdd),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _AddButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF4DDBFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 14),
                  SizedBox(width: 2),
                  Text(
                    '250 ml',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
