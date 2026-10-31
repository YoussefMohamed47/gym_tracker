import 'package:flutter/material.dart';
import '../theme/report_theme_tokens.dart';

/// Shared flat, typographic header for offscreen/export and on-screen reports.
/// Uses the report's natural width, never the device viewport width.
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
  Widget build(BuildContext context) => Directionality(
    textDirection: direction,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Container(width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: ReportThemeTokens.indigoAccent,
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 23)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(brandName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: ReportThemeTokens.outfitHeader(fontSize: 23, fontWeight: FontWeight.w900)),
            Text(tagLine, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: ReportThemeTokens.outfitSubtext(fontSize: 9, letterSpacing: 1.0)),
          ])),
          if (showCheckBadge)
            const Icon(Icons.check_circle_rounded,
              size: 17, color: ReportThemeTokens.completedGreen),
        ]),
        const SizedBox(height: 24),
        Text(reportTitle, style: direction == TextDirection.rtl
          ? ReportThemeTokens.arabicHeader(fontSize: 24, fontWeight: FontWeight.w900)
          : ReportThemeTokens.outfitHeader(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(dateText, style: direction == TextDirection.rtl
          ? ReportThemeTokens.arabicBody(fontSize: 12, color: ReportThemeTokens.textSecondary)
          : ReportThemeTokens.outfitSubtext(fontSize: 12)),
        const SizedBox(height: 15),
        Container(height: 3, color: ReportThemeTokens.indigoAccent),
      ],
    )),
  );
}
