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

  /// Optimistic delta — how many ml we've added since the parent widget's
  /// `consumedMl` was last seen. Lets the tile jump immediately on tap
  /// instead of waiting for the dashboard provider to re-fetch (which
  /// on Render free tier can take 1-3 seconds — perceived as broken).
  /// Reset to 0 when the parent's `consumedMl` changes (= refetch
  /// landed and now includes our delta).
  int _pendingMl = 0;

  /// Preset portions in ml. Covers small-sip → sport-bottle. Selecting
  /// "Custom" opens a numeric input so power-users can log any volume.
  static const List<int> _presetMl = [
    100, 150, 200, 250, 300, 350, 400, 500, 600, 750, 1000,
  ];

  @override
  void didUpdateWidget(WaterQuickCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch landed. Canonical totals now include whatever we
    // optimistically added — clear the local delta.
    if (oldWidget.consumedMl != widget.consumedMl) {
      _pendingMl = 0;
    }
  }

  Future<void> _addAmount(int amountMl) async {
    if (_isAdding) return;
    setState(() {
      _isAdding = true;
      _pendingMl += amountMl; // Optimistic — tile jumps right now.
    });
    try {
      await widget.onAddWater(amountMl);
    } catch (e) {
      // Rollback the optimistic update so the user doesn't see a phantom
      // glass that isn't actually saved.
      if (mounted) {
        setState(() => _pendingMl -= amountMl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log water. Tap to retry.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _showPortionPicker() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      // isScrollControlled lets the sheet expand to accommodate the
      // keyboard when the "Custom (ml)" TextField is focused. Without
      // this, the sheet is locked to ~half-screen and the keyboard
      // pushes the inner Column into negative space → an infinite-width
      // BoxConstraints assertion cascade that freezes the app.
      isScrollControlled: true,
      backgroundColor: const Color(0xFF142346),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => const _WaterPortionSheet(presets: _presetMl),
    );
    if (picked != null && picked > 0) {
      await _addAmount(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMl = widget.consumedMl + _pendingMl;
    final glasses = (effectiveMl / 250).floor();
    final glassesTarget = (widget.targetMl / 250).ceil().clamp(1, 99);
    final progress = widget.targetMl > 0
        ? (effectiveMl / widget.targetMl).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
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
                  const Color(0xFF00D4FF).withValues(alpha: 0.25),
                  const Color(0xFF4DDBFF).withValues(alpha: 0.10),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4DDBFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Two buttons stacked horizontally: the big "+250" quick-add
          // for the common case (a glass), and a smaller chevron that
          // opens the portion picker for other volumes.
          _QuickAddButton(
            isLoading: _isAdding,
            onTap: () => _addAmount(250),
          ),
          const SizedBox(width: 6),
          _PickerChevron(onTap: _isAdding ? () {} : _showPortionPicker),
        ],
      ),
    );
  }
}

/// Bottom sheet listing preset portion sizes. Returns the selected ml
/// via Navigator.pop. Custom-input TextField removed — see comment in
/// the Wrap below for the iOS freeze that prompted that decision.
class _WaterPortionSheet extends StatelessWidget {
  final List<int> presets;
  const _WaterPortionSheet({required this.presets});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add water',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            // Preset chips only. Earlier this sheet had a "Custom (ml)"
            // TextField below, which on iOS sim consistently froze the
            // app: focusing the TextField raised the keyboard,
            // MediaQuery.viewInsets.bottom pushed the inner Column into
            // negative space, and Flutter cascaded into an infinite-width
            // BoxConstraints assertion that killed the simulator. The
            // preset set was widened (extra 350/400/750/1000 ml) so the
            // user still has fine-grained control without typing.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets
                  .map((ml) => _PortionChip(
                        label: '$ml ml',
                        onTap: () => Navigator.pop(context, ml),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PortionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFF00D4FF).withValues(alpha: 0.12),
          border: Border.all(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4DDBFF),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _QuickAddButton({required this.isLoading, required this.onTap});

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
              color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
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

/// Small chevron beside the quick-add button. Opens the portion
/// picker so the user can log a non-standard volume.
class _PickerChevron extends StatelessWidget {
  final VoidCallback onTap;
  const _PickerChevron({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFFB8C5D6),
          size: 18,
        ),
      ),
    );
  }
}
