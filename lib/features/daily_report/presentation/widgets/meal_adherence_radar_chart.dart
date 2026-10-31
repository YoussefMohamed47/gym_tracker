import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/models/meal_adherence_data_point.dart';

class MealAdherenceRadarChart extends StatelessWidget {
  final List<MealAdherenceDataPoint> data;

  const MealAdherenceRadarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No meal data available."));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RadarChart(
          RadarChartData(
            radarTouchData: RadarTouchData(enabled: false),
            dataSets: [
              RadarDataSet(
                fillColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                borderColor: AppColors.primaryBlue,
                entryRadius: 3,
                dataEntries: data
                    .map((d) => RadarEntry(value: d.adherenceScore))
                    .toList(),
                borderWidth: 2,
              ),
            ],
            radarBackgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),
            radarBorderData: const BorderSide(color: Colors.transparent),
            tickCount: 5,
            ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
            tickBorderData: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1,
            ),
            gridBorderData: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1.5,
            ),
            getTitle: (index, angle) {
              return RadarChartTitle(
                text: data[index].mealType,
                angle: 0,
                positionPercentageOffset: 0.1,
              );
            },
            titleTextStyle: GoogleFonts.outfit(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }
}
