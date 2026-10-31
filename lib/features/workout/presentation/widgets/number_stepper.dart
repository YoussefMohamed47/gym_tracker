import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';

class NumberStepper extends StatefulWidget {
  final String label;
  final String valueText;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onTapValue;
  final double width;
  final String? unit;

  const NumberStepper({
    super.key,
    required this.label,
    required this.valueText,
    required this.onIncrement,
    required this.onDecrement,
    this.onTapValue,
    this.width = 0,
    this.unit,
  });

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  Timer? _autoRepeatTimer;

  void _startContinuous(VoidCallback action) {
    _autoRepeatTimer?.cancel();
    _autoRepeatTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      HapticFeedback.selectionClick();
      action();
    });
  }

  void _stopContinuous() {
    _autoRepeatTimer?.cancel();
    _autoRepeatTimer = null;
  }

  @override
  void dispose() {
    _stopContinuous();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      constraints: widget.width > 0 ? BoxConstraints(minWidth: widget.width) : null,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Decrement Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onDecrement();
              },
              onLongPressStart: (_) => _startContinuous(widget.onDecrement),
              onLongPressEnd: (_) => _stopContinuous(),
              child: SizedBox(
                width: 28,
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
              ),
            ),

            // Value Display
            Expanded(
              child: GestureDetector(
                onTap: widget.onTapValue,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            widget.valueText.isEmpty ? '—' : widget.valueText,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: widget.valueText.isEmpty
                                  ? (isDark ? Colors.white38 : Colors.black38)
                                  : (isDark ? AppColors.textPrimary : Colors.black87),
                            ),
                          ),
                          if (widget.unit != null && widget.valueText.isNotEmpty) ...[
                            const SizedBox(width: 2),
                            Text(
                              widget.unit!,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.gradientStart : AppColors.indigoAccent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Increment Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onIncrement();
              },
              onLongPressStart: (_) => _startContinuous(widget.onIncrement),
              onLongPressEnd: (_) => _stopContinuous(),
              child: SizedBox(
                width: 28,
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: isDark ? AppColors.gradientStart : AppColors.indigoAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
