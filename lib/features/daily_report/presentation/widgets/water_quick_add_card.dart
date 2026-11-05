import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/owned_text_controllers.dart';
import '../../domain/model/water_amount.dart';

/// Water without typing: a filling glass, +250 / +500 ml buttons, and a tap on
/// the amount to type an exact value or change the daily target.
class WaterQuickAddCard extends StatelessWidget {
  final String waterText;
  final double targetLiters;
  final ValueChanged<double> onAdd;
  final ValueChanged<String> onSetText;
  final ValueChanged<double> onSetTarget;

  const WaterQuickAddCard({
    super.key,
    required this.waterText,
    required this.targetLiters,
    required this.onAdd,
    required this.onSetText,
    required this.onSetTarget,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liters = WaterAmount.parseLiters(waterText) ?? 0;
    final ratio = targetLiters <= 0
        ? 0.0
        : (liters / targetLiters).clamp(0.0, 1.0);
    final glassesLeft = ((targetLiters - liters) / 0.25).ceil().clamp(0, 99);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          _Glass(fill: ratio),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _edit(context, liters),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt(liters)} L',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    glassesLeft == 0
                        ? 'Target reached · ${_fmt(targetLiters)} L'
                        : 'of ${_fmt(targetLiters)} L · $glassesLeft glasses left',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: glassesLeft == 0
                          ? AppColors.completedGreen
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _AddButton(label: '+250', onTap: () => _add(0.25)),
          const SizedBox(width: 7),
          _AddButton(label: '+500', onTap: () => _add(0.5)),
        ],
      ),
    );
  }

  void _add(double liters) {
    HapticFeedback.lightImpact();
    onAdd(liters);
  }

  static String _fmt(double v) {
    final r = (v * 100).round() / 100;
    return r == r.roundToDouble() ? r.toStringAsFixed(1) : r.toString();
  }

  Future<void> _edit(BuildContext context, double current) async {
    // The sheet returns the typed values; its controllers live inside it and
    // are disposed only after it has fully closed.
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => OwnedTextControllers(
        initialTexts: [waterText, _fmt(targetLiters)],
        builder: (sheet, controllers) {
          final amount = controllers[0];
          final target = controllers[1];
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              8,
              22,
              MediaQuery.viewInsetsOf(sheet).bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'كمية المياه',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amount,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'اليوم (مثال: 2.5 لتر أو 750 مل)',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: target,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Daily target (L)',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.pop(sheet, (
                    amount.text.trim(),
                    target.text.trim(),
                  )),
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (result == null) return;
    final (amountText, targetText) = result;
    onSetText(amountText);
    final t = WaterAmount.parseLiters(targetText);
    if (t != null && t > 0 && t != targetLiters) onSetTarget(t);
  }
}

class _Glass extends StatelessWidget {
  final double fill;
  const _Glass({required this.fill});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.violetAccent;
    return Container(
      width: 40,
      height: 54,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 2.5),
          right: BorderSide(color: color, width: 2.5),
          bottom: BorderSide(color: color, width: 2.5),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      alignment: Alignment.bottomCenter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fill),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, v, _) => FractionallySizedBox(
          heightFactor: v.clamp(0.0, 1.0),
          widthFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF99B8EF), Color(0xFF6F93D8)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.violetAccent.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.violetAccent,
            ),
          ),
        ),
      ),
    );
  }
}
