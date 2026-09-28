import 'package:flutter/material.dart';

import '../theme/report_theme_tokens.dart';

class ReportHeader extends StatelessWidget {
  final String brandName;
  final String tagLine;
  final String reportTitle;
  final String dateText;
  final bool showCheckBadge;
  final TextDirection direction;

  const ReportHeader({
    super.key,
    this.brandName = 'SAMAFIT',
    this.tagLine = 'ADVANCE LIKE LIGHTNING',
    required this.reportTitle,
    required this.dateText,
    this.showCheckBadge = false,
    this.direction = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ReportThemeTokens.cardBackground,
          borderRadius: ReportThemeTokens.cardBorderRadius,
          border: Border.all(color: ReportThemeTokens.borderSubtle, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Column
                Column(
                  crossAxisAlignment: direction == TextDirection.rtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => ReportThemeTokens
                              .primaryGradient
                              .createShader(bounds),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          brandName,
                          style: ReportThemeTokens.outfitHeader(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tagLine,
                      style: ReportThemeTokens.outfitSubtext(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: ReportThemeTokens.textMuted,
                      ),
                    ),
                  ],
                ),

                // Check Badge or Icon
                if (showCheckBadge)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ReportThemeTokens.completedGreen.withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ReportThemeTokens.completedGreen.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: ReportThemeTokens.completedGreen,
                      size: 22,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title & Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: ReportThemeTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ReportThemeTokens.indigoAccent.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    reportTitle,
                    style: direction == TextDirection.rtl
                        ? ReportThemeTokens.arabicHeader(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )
                        : ReportThemeTokens.outfitHeader(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                  ),
                ),

                // Date Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ReportThemeTokens.elevatedCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ReportThemeTokens.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: ReportThemeTokens.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: direction == TextDirection.rtl
                            ? ReportThemeTokens.arabicBody(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ReportThemeTokens.textSecondary,
                              )
                            : ReportThemeTokens.outfitSubtext(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ReportThemeTokens.textSecondary,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
