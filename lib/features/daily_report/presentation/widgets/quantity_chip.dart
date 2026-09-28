import 'package:flutter/material.dart';
import '../../../../core/theme/report_theme_tokens.dart';

class QuantityChip extends StatelessWidget {
  final String text;

  const QuantityChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ReportThemeTokens.elevatedCard,
        borderRadius: ReportThemeTokens.chipBorderRadius,
        border: Border.all(
          color: ReportThemeTokens.indigoAccent.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: ReportThemeTokens.arabicBody(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ReportThemeTokens.indigoAccent,
        ),
      ),
    );
  }
}
