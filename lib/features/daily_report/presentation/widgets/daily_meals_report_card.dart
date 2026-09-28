import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/report_exporter.dart';
import '../../../../core/utils/report_formatter.dart';
import '../../../../core/widgets/report_footer.dart';
import '../../../../core/widgets/report_header.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/model/daily_report.dart';
import '../utils/meal_parser.dart';
import 'meal_timeline_item.dart';
import 'training_card.dart';
import 'water_tracker_row.dart';

class DailyMealsReportCard extends StatelessWidget {
  final DailyReport report;
  final bool isExportMode;

  const DailyMealsReportCard({
    super.key,
    required this.report,
    this.isExportMode = false,
  });

  int _calculateLoggedMealsCount() {
    int count = 0;
    if (report.breakfast.trim().isNotEmpty) count++;
    if (report.snack.trim().isNotEmpty) count++;
    if (report.beforeTraining.trim().isNotEmpty) count++;
    if (report.lunch.trim().isNotEmpty) count++;
    if (report.afterTraining.trim().isNotEmpty) count++;
    if (report.dinner.trim().isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = ReportFormatter.formatArabicDate(report.dateTime);
    final loggedMeals = _calculateLoggedMealsCount();
    final loggedStr = ReportFormatter.toArabicDigits('$loggedMeals/6');
    final sleepStr = report.sleepTime.isNotEmpty
        ? ReportFormatter.localizeArabicDuration(report.sleepTime)
        : 'غير محدد';
    final waterStr = report.water.isNotEmpty
        ? ReportFormatter.toArabicDigits(report.water)
        : 'غير محدد';

    // Parse vitamins / supplements into chips
    final supplementsList = report.supplements.trim().isNotEmpty
        ? report.supplements
              .split(RegExp(r'[\,\+\n]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
        : <String>[];

    // Combine all text to see if macros/calories exist
    final fullText =
        '${report.breakfast} ${report.lunch} ${report.snack} ${report.beforeTraining} ${report.afterTraining} ${report.dinner} ${report.notes}';
    final macros = MealParser.extractMacros(fullText);

    Widget content = Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: ReportThemeTokens.background,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header
            ReportHeader(
              brandName: 'SAMAFIT',
              tagLine: 'ADVANCE LIKE LIGHTNING',
              reportTitle: 'تقرير الوجبات اليومية',
              dateText: dateStr,
              showCheckBadge: true,
              direction: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            // 2. Summary Strip
            _buildSummaryStrip(
              loggedStr: loggedStr,
              sleepStr: sleepStr,
              waterStr: waterStr,
            ),
            const SizedBox(height: 16),

            // 3. Segmented Macro Bar if data present
            if (macros != null && macros.hasData) ...[
              _buildMacroBar(macros),
              const SizedBox(height: 16),
            ],

            // 4. Training Card
            TrainingCard(
              trainingName: report.training,
              cardioDuration: report.cardio,
            ),
            const SizedBox(height: 20),

            // 5. Timeline Header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.timeline_rounded,
                    color: ReportThemeTokens.indigoAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'جدول الوجبات اليومي',
                    style: ReportThemeTokens.arabicHeader(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // 6. Timeline List
            MealTimelineItem(
              title: 'الإفطار',
              icon: Icons.free_breakfast_rounded,
              content: report.breakfast,
              isExportMode: isExportMode,
            ),
            MealTimelineItem(
              title: 'السناك الأول',
              icon: Icons.cookie_rounded,
              content: report.snack,
              isExportMode: isExportMode,
            ),
            MealTimelineItem(
              title: 'قبل التمرين',
              icon: Icons.bolt_rounded,
              content: report.beforeTraining,
              isExportMode: isExportMode,
            ),
            MealTimelineItem(
              title: 'الغداء',
              icon: Icons.lunch_dining_rounded,
              content: report.lunch,
              isExportMode: isExportMode,
            ),
            MealTimelineItem(
              title: 'بعد التمرين',
              icon: Icons.fitness_center_rounded,
              content: report.afterTraining,
              isExportMode: isExportMode,
            ),
            MealTimelineItem(
              title: 'العشاء',
              icon: Icons.nightlife_rounded,
              content: report.dinner,
              isLast: true,
              isExportMode: isExportMode,
            ),
            const SizedBox(height: 16),

            // 7. Water Progress Row
            if (report.water.isNotEmpty) ...[
              WaterTrackerRow(waterText: report.water),
              const SizedBox(height: 16),
            ],

            // 8. Supplements & Vitamins Chips
            if (supplementsList.isNotEmpty) ...[
              _buildSupplementsSection(supplementsList),
              const SizedBox(height: 16),
            ],

            // 9. Notes Card (Quote Style)
            if (report.notes != null && report.notes!.trim().isNotEmpty) ...[
              _buildNotesCard(report.notes!.trim()),
              const SizedBox(height: 16),
            ],

            // 10. Footer
            const ReportFooter(
              direction: TextDirection.rtl,
              text: 'تم الإنشاء بواسطة GYM TRACKER',
            ),
          ],
        ),
      ),
    );

    // Apply staggered animations for in-app mode
    if (!isExportMode && !MediaQuery.of(context).disableAnimations) {
      content = Animate(
        effects: const [
          FadeEffect(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          ),
          SlideEffect(
            begin: Offset(0, 0.05),
            end: Offset.zero,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          ),
        ],
        child: content,
      );
    }

    if (isExportMode) {
      return content;
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // In-app mode container with floating share button positioned above bottom nav bar
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 140 + bottomPadding),
          child: content,
        ),

        // Floating Share Button elevated above FloatingNavBar
        Positioned(
          bottom: 92,
          left: 24,
          child: FloatingActionButton.extended(
            heroTag: 'share_daily_meals_report_fab',
            onPressed: () {
              ReportExporter.captureAndShare(
                context: context,
                builder: (ctx) =>
                    DailyMealsReportCard(report: report, isExportMode: true),
                fileName: 'daily_meals_report_${report.id}',
                shareText: 'تقرير الوجبات اليومي عبر SAMAFIT',
              );
            },
            elevation: 8,
            backgroundColor: ReportThemeTokens.indigoAccent,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: Text(
              'مشاركة التقرير',
              style: ReportThemeTokens.arabicBody(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStrip({
    required String loggedStr,
    required String sleepStr,
    required String waterStr,
  }) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.restaurant_rounded,
            label: 'الوجبات',
            value: loggedStr,
            iconColor: ReportThemeTokens.completedGreen,
            isExportMode: isExportMode,
            direction: TextDirection.rtl,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(
            icon: Icons.bedtime_rounded,
            label: 'النوم',
            value: sleepStr,
            iconColor: ReportThemeTokens.violetAccent,
            isExportMode: isExportMode,
            direction: TextDirection.rtl,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(
            icon: Icons.water_drop_rounded,
            label: 'الماء',
            value: waterStr,
            iconColor: Colors.lightBlueAccent,
            isExportMode: isExportMode,
            direction: TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBar(MacroBreakdown macros) {
    final totalGrams =
        (macros.proteinGrams + macros.carbsGrams + macros.fatGrams).clamp(
          1,
          9999,
        );
    final pPct = macros.proteinGrams / totalGrams;
    final cPct = macros.carbsGrams / totalGrams;
    final fPct = macros.fatGrams / totalGrams;

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
              Text(
                'توزيع الماكروز والماكرو',
                style: ReportThemeTokens.arabicBody(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (macros.calories > 0)
                Text(
                  '${ReportFormatter.toArabicDigits(macros.calories.toString())} سعرة',
                  style: ReportThemeTokens.arabicBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ReportThemeTokens.warningAmber,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Multi-color Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (pPct > 0)
                    Expanded(
                      flex: (pPct * 100).toInt(),
                      child: Container(color: ReportThemeTokens.indigoAccent),
                    ),
                  if (cPct > 0)
                    Expanded(
                      flex: (cPct * 100).toInt(),
                      child: Container(color: ReportThemeTokens.violetAccent),
                    ),
                  if (fPct > 0)
                    Expanded(
                      flex: (fPct * 100).toInt(),
                      child: Container(color: ReportThemeTokens.warningAmber),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroLegendItem(
                'بروتين',
                '${ReportFormatter.toArabicDigits(macros.proteinGrams.toString())}جم',
                ReportThemeTokens.indigoAccent,
              ),
              _buildMacroLegendItem(
                'نشويات',
                '${ReportFormatter.toArabicDigits(macros.carbsGrams.toString())}جم',
                ReportThemeTokens.violetAccent,
              ),
              _buildMacroLegendItem(
                'دهون',
                '${ReportFormatter.toArabicDigits(macros.fatGrams.toString())}جم',
                ReportThemeTokens.warningAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: ReportThemeTokens.arabicBody(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: ReportThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplementsSection(List<String> items) {
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
            children: [
              const Icon(
                Icons.medication_liquid_rounded,
                color: ReportThemeTokens.violetAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'الفيتامينات والمكملات اليومية',
                style: ReportThemeTokens.arabicBody(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ReportThemeTokens.elevatedCard,
                  borderRadius: ReportThemeTokens.chipBorderRadius,
                  border: Border.all(
                    color: ReportThemeTokens.violetAccent.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: ReportThemeTokens.violetAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ReportFormatter.toArabicDigits(item),
                      style: ReportThemeTokens.arabicBody(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ReportThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ReportThemeTokens.cardBackground,
        borderRadius: ReportThemeTokens.cardBorderRadius,
        border: Border.all(
          color: ReportThemeTokens.indigoAccent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: ReportThemeTokens.indigoAccent,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'ملاحظات اليوم',
                style: ReportThemeTokens.arabicBody(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: ReportThemeTokens.indigoAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ReportFormatter.toArabicDigits(notes),
            style: ReportThemeTokens.arabicBody(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ReportThemeTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
