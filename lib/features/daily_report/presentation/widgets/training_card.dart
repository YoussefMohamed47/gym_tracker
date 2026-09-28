import 'package:flutter/material.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/report_formatter.dart';

class TrainingCard extends StatelessWidget {
  final String trainingName;
  final String cardioDuration;

  const TrainingCard({
    super.key,
    required this.trainingName,
    required this.cardioDuration,
  });

  bool get isRestDay {
    final lower = trainingName.toLowerCase().trim();
    return lower.isEmpty ||
        lower == 'resting' ||
        lower == 'rest' ||
        lower == 'راحة' ||
        lower == 'لا يوجد' ||
        lower == 'يوم راحة';
  }

  @override
  Widget build(BuildContext context) {
    if (isRestDay) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ReportThemeTokens.cardBackground,
          borderRadius: ReportThemeTokens.cardBorderRadius,
          border: Border.all(
            color: ReportThemeTokens.warningAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ReportThemeTokens.warningAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: ReportThemeTokens.warningAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'يوم راحة وتستعيد فيه القوة',
                    style: ReportThemeTokens.arabicBody(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ReportThemeTokens.textPrimary,
                    ),
                  ),
                  Text(
                    'الاستشفاء جزء أساسي من التطور',
                    style: ReportThemeTokens.arabicBody(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ReportThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ReportThemeTokens.warningAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'راحة',
                style: ReportThemeTokens.arabicBody(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ReportThemeTokens.warningAmber,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final localizedWorkout = ReportFormatter.localizeArabicWorkoutType(trainingName);
    final localizedCardio = ReportFormatter.localizeArabicDuration(cardioDuration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ReportThemeTokens.primaryGradient,
        borderRadius: ReportThemeTokens.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: ReportThemeTokens.indigoAccent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'نشاط التمرين اليومي',
                    style: ReportThemeTokens.arabicHeader(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'تم الإنجاز',
                  style: ReportThemeTokens.arabicBody(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizedWorkout,
            style: ReportThemeTokens.arabicHeader(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (localizedCardio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.directions_run_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'الكارديو: $localizedCardio',
                  style: ReportThemeTokens.arabicBody(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
