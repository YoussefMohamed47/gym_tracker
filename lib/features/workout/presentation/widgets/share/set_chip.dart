import 'package:flutter/material.dart';

import '../../../../../core/theme/report_theme_tokens.dart';

class SetChip extends StatelessWidget {
  final int setIndex;
  final String label;
  final bool isPerformed;
  final bool isCheckmarkOnly;
  final bool isBestSet;

  const SetChip({
    super.key,
    required this.setIndex,
    required this.label,
    this.isPerformed = true,
    this.isCheckmarkOnly = false,
    this.isBestSet = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPerformed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ReportThemeTokens.elevatedCard.withValues(alpha: 0.5),
          borderRadius: ReportThemeTokens.chipBorderRadius,
          border: Border.all(color: ReportThemeTokens.borderSubtle),
        ),
        child: Text(
          'S${setIndex + 1}: -',
          style: ReportThemeTokens.outfitSubtext(
            fontSize: 11,
            color: ReportThemeTokens.textMuted,
          ),
        ),
      );
    }

    if (isCheckmarkOnly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ReportThemeTokens.completedGreen.withValues(alpha: 0.15),
          borderRadius: ReportThemeTokens.chipBorderRadius,
          border: Border.all(
            color: ReportThemeTokens.completedGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_rounded,
              size: 14,
              color: ReportThemeTokens.completedGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'S${setIndex + 1}',
              style: ReportThemeTokens.outfitNumber(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: ReportThemeTokens.completedGreen,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isBestSet
            ? ReportThemeTokens.indigoAccent.withValues(alpha: 0.18)
            : ReportThemeTokens.elevatedCard,
        borderRadius: ReportThemeTokens.chipBorderRadius,
        border: Border.all(
          color: isBestSet
              ? ReportThemeTokens.indigoAccent.withValues(alpha: 0.6)
              : ReportThemeTokens.borderSubtle,
          width: isBestSet ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'S${setIndex + 1}: ',
            style: ReportThemeTokens.outfitSubtext(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isBestSet
                  ? ReportThemeTokens.indigoAccent
                  : ReportThemeTokens.textSecondary,
            ),
          ),
          Text(
            label,
            style: ReportThemeTokens.outfitNumber(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: ReportThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
