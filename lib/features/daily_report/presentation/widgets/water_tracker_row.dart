import 'package:flutter/material.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/report_formatter.dart';

class WaterTrackerRow extends StatelessWidget {
  final String waterText;

  const WaterTrackerRow({super.key, required this.waterText});

  int _parseGlasses() {
    if (waterText.trim().isEmpty) return 0;
    final digitsMatch = RegExp(r'(\d+)').firstMatch(waterText);
    if (digitsMatch != null) {
      final val = int.tryParse(digitsMatch.group(1)!) ?? 0;
      // If entered as liters (e.g. 3L), convert roughly to glasses (1L = 4 glasses)
      if (waterText.toLowerCase().contains('l') || waterText.contains('لتر')) {
        return (val * 4).clamp(0, 12);
      }
      return val.clamp(0, 12);
    }
    return 4; // Default if non-empty string without clear number
  }

  @override
  Widget build(BuildContext context) {
    if (waterText.trim().isEmpty) return const SizedBox.shrink();

    final glassesCount = _parseGlasses();
    const maxGlasses = 8;
    final displayVal = ReportFormatter.toArabicDigits(waterText);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ReportThemeTokens.cardBackground,
        borderRadius: ReportThemeTokens.cardBorderRadius,
        border: Border.all(color: ReportThemeTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.lightBlueAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'كمية المياه اليومية',
                    style: ReportThemeTokens.arabicBody(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: ReportThemeTokens.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                displayVal,
                style: ReportThemeTokens.arabicBody(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(maxGlasses, (index) {
              final isFilled = index < glassesCount;
              return Icon(
                isFilled ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                size: 20,
                color: isFilled
                    ? Colors.lightBlueAccent
                    : ReportThemeTokens.textMuted.withValues(alpha: 0.4),
              );
            }),
          ),
        ],
      ),
    );
  }
}
