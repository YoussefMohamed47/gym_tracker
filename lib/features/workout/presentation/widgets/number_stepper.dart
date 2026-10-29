import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/report_theme_tokens.dart';
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.valueText.isEmpty ? '—' : widget.valueText,
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: widget.valueText.isEmpty
                            ? AppColors.textMuted
                            : (isDark ? AppColors.textPrimary : Colors.black87),
                      ),
                    ),
                    if (widget.unit != null && widget.valueText.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Text(
                        widget.unit!,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
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
