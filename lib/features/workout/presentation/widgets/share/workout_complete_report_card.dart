import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/report_theme_tokens.dart';
import '../../../../../core/utils/report_exporter.dart';
import '../../../../../core/utils/report_formatter.dart';
import '../../../../../core/utils/weight_converter.dart';
import '../../../../../core/widgets/report_footer.dart';
import '../../../../../core/widgets/report_header.dart';
import '../../../../../core/widgets/stat_tile.dart';
import '../../../data/datasources/workout_catalog.dart';
import '../../../domain/entities/workout_definition.dart';
import '../../../domain/entities/workout_session.dart';
import 'exercise_report_card.dart';

class WorkoutCompleteReportCard extends StatelessWidget {
  final WorkoutSession session;
  final bool isExportMode;

  const WorkoutCompleteReportCard({
    super.key,
    required this.session,
    this.isExportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final workoutType = session.workoutType;
    final workoutName = workoutType.name.toUpperCase();
    final dateStr = ReportFormatter.formatEnglishDate(
      DateTime.tryParse(session.dateKey),
    );

    final dailyRoutine = WorkoutCatalog.getDailyRoutine();
    final workoutDef = WorkoutCatalog.workouts.firstWhere(
      (w) => w.type == workoutType,
      orElse: () => WorkoutCatalog.workouts.first,
    );

    // Compute stats
    int totalSetsCount = 0;
    double totalVolumeKg = 0;

    for (final entry in session.exerciseLogs.entries) {
      final log = entry.value;
      if (!log.isPerformed && !log.sets.any((s) => s.isPerformed)) continue;

      for (final s in log.sets) {
        if (!s.isPerformed) continue;
        totalSetsCount++;

        if (s.weightKg != null) {
          final reps = s.actualReps ?? 1;
          totalVolumeKg += (s.weightKg! * reps);
        }
      }
    }

    final convertedVolume = WeightConverter.convert(
      totalVolumeKg,
      WeightUnit.kg,
      session.displayUnit,
    );
    final volumeStr = totalVolumeKg > 0
        ? '${WeightConverter.format(convertedVolume)} ${session.displayUnit.name}'
        : '-';

    Widget content = Container(
      color: ReportThemeTokens.background,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Hero Header
          ReportHeader(
            brandName: 'GYM TRACKER',
            tagLine: 'WORKOUT COMPLETE',
            reportTitle: '$workoutName WORKOUT',
            dateText: dateStr,
            showCheckBadge: true,
            direction: TextDirection.ltr,
          ),
          const SizedBox(height: 16),

          // 2. Stat Tiles Row
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.timer_outlined,
                  label: 'DURATION',
                  value: '45 min',
                  iconColor: ReportThemeTokens.indigoAccent,
                  isExportMode: isExportMode,
                  direction: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.fitness_center_rounded,
                  label: 'VOLUME',
                  value: volumeStr,
                  iconColor: ReportThemeTokens.violetAccent,
                  isExportMode: isExportMode,
                  direction: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.repeat_rounded,
                  label: 'TOTAL SETS',
                  value: '$totalSetsCount',
                  iconColor: ReportThemeTokens.completedGreen,
                  isExportMode: isExportMode,
                  direction: TextDirection.ltr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Warm-up & Rehab Section
          _buildWarmupSection(dailyRoutine),
          const SizedBox(height: 20),

          // 4. Main Lifts Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center_rounded,
                  color: ReportThemeTokens.indigoAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'MAIN LIFTS',
                  style: ReportThemeTokens.outfitHeader(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // 5. Main Lift Exercise Cards
          ...workoutDef.exercises.map((slot) {
            final log = session.exerciseLogs[slot.exerciseId];
            if (log == null) return const SizedBox.shrink();

            final isPerformed =
                log.isPerformed || log.sets.any((s) => s.isPerformed);
            if (!isPerformed) return const SizedBox.shrink();

            return ExerciseReportCard(log: log, isExportMode: isExportMode);
          }),

          const SizedBox(height: 16),

          // 6. Footer
          const ReportFooter(
            direction: TextDirection.ltr,
            text: 'GENERATED BY GYM TRACKER',
          ),
        ],
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
          bottom: 92 + bottomPadding,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'share_workout_complete_report_fab',
            onPressed: () {
              ReportExporter.captureAndShare(
                context: context,
                builder: (ctx) => WorkoutCompleteReportCard(
                  session: session,
                  isExportMode: true,
                ),
                fileName: 'workout_complete_${session.dateKey}',
                shareText:
                    'Finished my ${session.workoutType.name} workout on Gym Tracker!',
              );
            },
            elevation: 8,
            backgroundColor: ReportThemeTokens.indigoAccent,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: Text(
              'SHARE REPORT',
              style: ReportThemeTokens.outfitHeader(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarmupSection(WorkoutDefinition dailyRoutine) {
    final List<Widget> warmupRows = [];

    for (final slot in dailyRoutine.exercises) {
      final log = session.exerciseLogs[slot.exerciseId];
      if (log == null) continue;

      final isPerformed = log.isPerformed || log.sets.any((s) => s.isPerformed);
      if (!isPerformed) continue;

      final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

      warmupRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ReportThemeTokens.completedGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: ReportThemeTokens.outfitSubtext(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ReportThemeTokens.textPrimary,
                  ),
                ),
              ),
              Text(
                '${slot.prescribedSets} sets ✓',
                style: ReportThemeTokens.outfitSubtext(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ReportThemeTokens.completedGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (warmupRows.isEmpty) return const SizedBox.shrink();

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
                Icons.accessibility_new_rounded,
                color: ReportThemeTokens.completedGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'WARM-UP & REHAB',
                style: ReportThemeTokens.outfitHeader(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ReportThemeTokens.completedGreen,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: ReportThemeTokens.borderSubtle),
          const SizedBox(height: 8),
          ...warmupRows,
        ],
      ),
    );
  }
}
