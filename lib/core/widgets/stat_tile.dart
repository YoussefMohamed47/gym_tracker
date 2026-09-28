import 'package:flutter/material.dart';
import '../theme/report_theme_tokens.dart';

class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? iconColor;
  final bool isExportMode;
  final TextDirection direction;

  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconColor,
    this.isExportMode = false,
    this.direction = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? ReportThemeTokens.indigoAccent;
    final disableAnim = isExportMode || MediaQuery.of(context).disableAnimations;

    // Parse numeric component for animation if possible
    final numMatch = RegExp(r'^(\d+)').firstMatch(value.trim());
    final intValue = numMatch != null ? int.tryParse(numMatch.group(1)!) : null;
    final suffix = intValue != null ? value.trim().substring(numMatch!.group(1)!.length) : '';

    return Directionality(
      textDirection: direction,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ReportThemeTokens.cardBackground,
          borderRadius: ReportThemeTokens.cardBorderRadius,
          border: Border.all(
            color: ReportThemeTokens.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Value displaying logic
            if (intValue != null && !disableAnim)
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: intValue),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedVal, child) {
                  return Text(
                    '$animatedVal$suffix',
                    style: direction == TextDirection.rtl
                        ? ReportThemeTokens.arabicHeader(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ReportThemeTokens.textPrimary,
                          )
                        : ReportThemeTokens.outfitNumber(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: ReportThemeTokens.textPrimary,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              )
            else
              Text(
                value,
                style: direction == TextDirection.rtl
                    ? ReportThemeTokens.arabicHeader(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ReportThemeTokens.textPrimary,
                      )
                    : ReportThemeTokens.outfitNumber(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: ReportThemeTokens.textPrimary,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: direction == TextDirection.rtl
                    ? ReportThemeTokens.arabicBody(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ReportThemeTokens.textMuted,
                      )
                    : ReportThemeTokens.outfitSubtext(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ReportThemeTokens.textMuted,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
