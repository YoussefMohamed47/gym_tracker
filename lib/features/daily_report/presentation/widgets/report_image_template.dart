import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/model/daily_report.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: const Color(0xFF1A46A0),
                ),
              ),
              Text(
                'FITNESS, NUTRITION & LIFESTYLE',
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A46A0),
              borderRadius: BorderRadius.circular(12),
            ),
            // 💡 SUGGESTION: FittedBox lets the badge text shrink instead of
            // wrapping to a new line, guaranteeing it stays beside the title.
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
  // ⚠️ CRITICAL: fixed width:160 was forcing 1 box per row on normal phone
  // widths, which is what pushed the total height past the screen and
  // caused the overflow. Now derived from available width via LayoutBuilder.
  Widget _buildFlexibleGrid() {
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Aim for 2 columns; fall back to 1 if the space is too narrow
        // (e.g. below ~260 logical px) to keep text readable.
        final twoColWidth = (constraints.maxWidth - spacing) / 2;
        final boxWidth = twoColWidth >= 130 ? twoColWidth : constraints.maxWidth;

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
      width: width, // 💡 SUGGESTION: now responsive instead of hardcoded
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A46A0), width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1A46A0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              content.isEmpty ? ' ' : content,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
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
        color: const Color(0xFF2B7CFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSpecialItem(Icons.fitness_center, 'التمرين', report.training),
          const Divider(color: Colors.white30, height: 1, indent: 10, endIndent: 10),
          _buildSpecialItem(Icons.directions_run, 'الكارديو', report.cardio),
        ],
      ),
    );
  }

  Widget _buildSpecialItem(IconData icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
                style: GoogleFonts.notoKufiArabic(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              content.isEmpty ? 'resting' : content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
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
                border: Border.all(color: const Color(0xFF1A46A0), width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A46A0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      'ملاحظات',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      (report.notes == null || report.notes!.isEmpty) ? ' ' : report.notes!,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.flash_on, color: Color(0xFF1A46A0), size: 32),
        const SizedBox(width: 8),
        Text(
          'ADVANCE LIKE LIGHTNING',
          style: GoogleFonts.montserrat(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: const Color(0xFF1A46A0),
          ),
        ),
      ],
    );
  }
}