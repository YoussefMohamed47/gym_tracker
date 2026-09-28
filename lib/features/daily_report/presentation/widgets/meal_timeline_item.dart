import 'package:flutter/material.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../utils/meal_parser.dart';
import 'food_row.dart';

class MealTimelineItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final bool isLast;
  final bool isExportMode;

  const MealTimelineItem({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.isLast = false,
    this.isExportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final parsedItems = MealParser.parse(content);
    final isEmpty = parsedItems.isEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Node (Dot & Line)
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Node Dot
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? ReportThemeTokens.textMuted.withValues(alpha: 0.3)
                        : ReportThemeTokens.completedGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEmpty
                          ? ReportThemeTokens.borderSubtle
                          : ReportThemeTokens.completedGreen.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: isEmpty
                        ? null
                        : [
                            BoxShadow(
                              color: ReportThemeTokens.completedGreen
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: isEmpty
                      ? null
                      : const Center(
                          child: Icon(
                            Icons.check,
                            size: 8,
                            color: Colors.black,
                          ),
                        ),
                ),

                // Connecting Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isEmpty
                          ? ReportThemeTokens.borderSubtle
                          : ReportThemeTokens.completedGreen.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Meal Card Body
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ReportThemeTokens.cardBackground,
                borderRadius: ReportThemeTokens.cardBorderRadius,
                border: Border.all(
                  color: isEmpty
                      ? ReportThemeTokens.borderSubtle
                      : ReportThemeTokens.indigoAccent.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Meal Header Row
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isEmpty
                            ? ReportThemeTokens.textMuted
                            : ReportThemeTokens.indigoAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: ReportThemeTokens.arabicBody(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isEmpty
                                ? ReportThemeTokens.textMuted
                                : ReportThemeTokens.textPrimary,
                          ),
                        ),
                      ),
                      if (!isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: ReportThemeTokens.completedGreen
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'مسجلة',
                            style: ReportThemeTokens.arabicBody(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ReportThemeTokens.completedGreen,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Meal Content or Collapsed Slim Row
                  if (isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'لم يتم التسجيل',
                      style: ReportThemeTokens.arabicBody(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ReportThemeTokens.textMuted,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      color: ReportThemeTokens.borderSubtle,
                    ),
                    const SizedBox(height: 6),
                    ...parsedItems.map((item) => FoodRow(item: item)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
