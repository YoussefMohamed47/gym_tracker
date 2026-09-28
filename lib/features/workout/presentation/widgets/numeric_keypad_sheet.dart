import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';

class NumericKeypadSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final String unit;
  final bool isDecimal;

  const NumericKeypadSheet({
    super.key,
    required this.title,
    required this.initialValue,
    this.unit = '',
    this.isDecimal = true,
  });

  static Future<double?> showWeightKeypad(
    BuildContext context, {
    required String title,
    required double? initialValue,
    required String unit,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NumericKeypadSheet(
        title: title,
        initialValue: initialValue != null
            ? (initialValue % 1 == 0
                  ? initialValue.toInt().toString()
                  : initialValue.toString())
            : '',
        unit: unit,
        isDecimal: true,
      ),
    );
    if (result == null || result.isEmpty) return null;
    return double.tryParse(result);
  }

  static Future<int?> showRepsKeypad(
    BuildContext context, {
    required String title,
    required int? initialValue,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NumericKeypadSheet(
        title: title,
        initialValue: initialValue?.toString() ?? '',
        unit: 'reps',
        isDecimal: false,
      ),
    );
    if (result == null || result.isEmpty) return null;
    return int.tryParse(result);
  }

  @override
  State<NumericKeypadSheet> createState() => _NumericKeypadSheetState();
}

class _NumericKeypadSheetState extends State<NumericKeypadSheet> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'BACK') {
        if (_value.isNotEmpty) {
          _value = _value.substring(0, _value.length - 1);
        }
      } else if (key == 'CLEAR') {
        _value = '';
      } else if (key == '.') {
        if (widget.isDecimal && !_value.contains('.')) {
          _value = _value.isEmpty ? '0.' : '$_value.';
        }
      } else {
        if (_value == '0') {
          _value = key;
        } else {
          _value += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.outline,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Display
              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _value.isEmpty ? '0' : _value,
                    style: GoogleFonts.outfit(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: _value.isEmpty
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            )
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (widget.unit.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.unit,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gradientStart,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Quick Step Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _quickAddPill('+1'),
                  const SizedBox(width: 8),
                  _quickAddPill('+2.5'),
                  const SizedBox(width: 8),
                  _quickAddPill('+5'),
                  const SizedBox(width: 8),
                  _quickAddPill('+10'),
                ],
              ),
              const SizedBox(height: 20),

              // Numeric Keypad Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  ...[
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                  ].map((digit) => _keypadButton(digit, () => _onKeyPress(digit))),
                  _keypadButton(
                    widget.isDecimal ? '.' : '',
                    widget.isDecimal ? () => _onKeyPress('.') : null,
                  ),
                  _keypadButton('0', () => _onKeyPress('0')),
                  _keypadButton(
                    'BACK',
                    () => _onKeyPress('BACK'),
                    icon: Icons.backspace_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm / Done Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, _value);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        'DONE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAddPill(String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final addVal = double.tryParse(label.replaceAll('+', '')) ?? 0;
        final currVal = double.tryParse(_value) ?? 0;
        final newVal = currVal + addVal;
        setState(() {
          _value = newVal % 1 == 0
              ? newVal.toInt().toString()
              : newVal.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gradientStart.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gradientStart.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.gradientStart,
          ),
        ),
      ),
    );
  }

  Widget _keypadButton(String label, VoidCallback? onTap, {IconData? icon}) {
    if (label.isEmpty && icon == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: icon != null
              ? Icon(icon, color: theme.colorScheme.onSurface, size: 20)
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: theme.colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
