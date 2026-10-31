import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../workout/domain/models/volume_data_point.dart';
import '../../../../core/utils/app_colors.dart';

class VolumeLineChart extends StatelessWidget {
  final VolumeTonnageReport report;

  const VolumeLineChart({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.points.isEmpty) {
      return const Center(child: Text("No volume data for last 30 days."));
    }

    final maxY = report.points.fold<double>(
          0.0,
          (max, point) => point.tonnage > max ? point.tonnage : max,
        ) * 1.2;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: maxY > 0 ? maxY / 5 : 1,
              verticalInterval: 5,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: AppColors.borderSubtle,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: AppColors.borderSubtle,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 || value.toInt() >= report.points.length) {
                      return const SizedBox.shrink();
                    }
                    final date = report.points[value.toInt()].date;
                    return SideTitleWidget(
                      meta: meta,
                      space: 8.0,
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: GoogleFonts.outfit(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxY > 0 ? maxY / 5 : 1,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.outfit(fontSize: 10),
                      textAlign: TextAlign.left,
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            minX: 0,
            maxX: report.points.length.toDouble() - 1,
            minY: 0,
            maxY: maxY == 0 ? 100 : maxY,
            lineBarsData: [
              LineChartBarData(
                spots: report.points
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.tonnage))
                    .toList(),
                isCurved: true,
                color: AppColors.primaryBlue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
