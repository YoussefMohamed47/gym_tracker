import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/model/daily_report.dart';

class ReportImageTemplate extends StatelessWidget {
  final DailyReport report;

  const ReportImageTemplate({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFlexibleGrid(),
            const SizedBox(height: 24),
            _buildBottomSection(),
            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAMA FIT',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'ADVANCE LIKE LIGHTNING',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'تقرير الوجبات اليومي',
                style: GoogleFonts.notoKufiArabic(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlexibleGrid() {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColWidth = (constraints.maxWidth - spacing) / 2;
        final boxWidth = twoColWidth >= 130
            ? twoColWidth
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _buildAutoBox('فطار', report.breakfast, boxWidth),
            _buildAutoBox('غداء', report.lunch, boxWidth),
            _buildAutoBox('سناك', report.snack, boxWidth),
            _buildAutoBox('قبل التمرين', report.beforeTraining, boxWidth),
            _buildAutoBox('بعد التمرين', report.afterTraining, boxWidth),
            _buildAutoBox('عشاء', report.dinner, boxWidth),
            _buildAutoBox('مياه', report.water, boxWidth),
            _buildSpecialAutoBox(boxWidth),
          ],
        );
      },
    );
  }

  Widget _buildAutoBox(String label, String content, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              content.isEmpty ? ' ' : content,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialAutoBox(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpecialItem(Icons.fitness_center_rounded, 'التمرين', report.training),
          const Divider(
            color: Colors.white24,
            height: 1,
            indent: 10,
            endIndent: 10,
          ),
          _buildSpecialItem(Icons.bolt_rounded, 'الكارديو', report.cardio),
        ],
      ),
    );
  }

  Widget _buildSpecialItem(IconData icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.notoKufiArabic(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content.isEmpty ? 'resting' : content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final singleWidth = (constraints.maxWidth - spacing * 2) / 3;
        final notesWidth = singleWidth * 2 + spacing;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Container(
              width: notesWidth,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      'ملاحظات',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      (report.notes == null || report.notes!.isEmpty)
                          ? ' '
                          : report.notes!,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildAutoBox('مدة النوم', report.sleepTime, singleWidth),
            _buildAutoBox('الفيتامينات', report.supplements, singleWidth),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.electric_bolt_rounded, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          'GENERATED BY GYM TRACKER',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
