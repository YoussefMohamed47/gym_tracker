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
  Timer? _initialDelayTimer;

  void _startAutoRepeat(VoidCallback action) {
    HapticFeedback.lightImpact();
    action();
    _initialDelayTimer?.cancel();
    _autoRepeatTimer?.cancel();

    _initialDelayTimer = Timer(const Duration(milliseconds: 350), () {
      _autoRepeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        HapticFeedback.selectionClick();
        action();
      });
    });
  }

  void _stopAutoRepeat() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _autoRepeatTimer?.cancel();
    _autoRepeatTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      constraints: widget.width > 0 ? BoxConstraints(minWidth: widget.width) : null,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _startAutoRepeat(widget.onDecrement),
            onTapUp: (_) => _stopAutoRepeat(),
            onTapCancel: () => _stopAutoRepeat(),
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.remove_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        const SizedBox(width: 3),
                        Text(
                          widget.unit!,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
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

          // Increment Button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _startAutoRepeat(widget.onIncrement),
            onTapUp: (_) => _stopAutoRepeat(),
            onTapCancel: () => _stopAutoRepeat(),
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.indigoAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
