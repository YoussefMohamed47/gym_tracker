import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import 'rest_timer_pill.dart';

class BottomDock extends StatelessWidget {
  final WorkoutState state;

  const BottomDock({super.key, required this.state});

  void _showSummaryBottomSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    final workoutCubit = context.read<WorkoutCubit>();

    int totalExercises = state.exerciseLogs.length;
    int performedExercises = state.exerciseLogs.values
        .where((l) => l.sets.any((s) => s.isPerformed))
        .length;

    int totalSets = 0;
    int performedSets = 0;
    double totalVolumeKg = 0;

    for (final log in state.exerciseLogs.values) {
      totalSets += log.sets.length;
      for (final s in log.sets) {
        if (s.isPerformed) {
          performedSets++;
          final weight = s.weightKg ?? 0;
          final reps = s.actualReps ?? 1;
          totalVolumeKg += weight * reps;
        }
      }
    }

    final displayVolume = WeightConverter.format(
      WeightConverter.convert(
        totalVolumeKg,
        WeightUnit.kg,
        state.displayUnit,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? ReportThemeTokens.sheetSurfaceDark : ReportThemeTokens.sheetSurfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.outline,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Celebratory Icon (Isolated in RepaintBoundary)
            RepaintBoundary(
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.completedGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 38,
                  color: Colors.black,
                ),
              ).animate().scale(
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
            const SizedBox(height: 14),

            Text(
              'WORKOUT SUMMARY',
              style: ReportThemeTokens.outfitHeader(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              state.workoutType.displayName,
              style: ReportThemeTokens.outfitSubtext(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.indigoAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context,
                    title: 'EXERCISES',
                    value: '$performedExercises/$totalExercises',
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard(
                    context,
                    title: 'SETS DONE',
                    value: '$performedSets/$totalSets',
                    icon: Icons.repeat_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard(
                    context,
                    title: 'VOLUME',
                    value: '$displayVolume ${state.displayUnit.name}',
                    icon: Icons.monitor_weight_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save & Share Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  workoutCubit.saveWorkout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigoAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'SAVE & VIEW REPORT',
                      style: ReportThemeTokens.outfitHeader(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.indigoAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: ReportThemeTokens.outfitNumber(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: ReportThemeTokens.outfitSubtext(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.workoutType == WorkoutType.rest || state.status == WorkoutStatus.loading) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    int totalExercises = state.exerciseLogs.length;
    int performedExercises = state.exerciseLogs.values
        .where((l) => l.sets.any((s) => s.isPerformed))
        .length;

    int totalSets = 0;
    int performedSets = 0;
    for (final log in state.exerciseLogs.values) {
      totalSets += log.sets.length;
      performedSets += log.sets.where((s) => s.isPerformed).length;
    }

    final double exerciseProgress =
        totalExercises > 0 ? (performedExercises / totalExercises) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sliding Rest Timer Pill (Slides up only while resting)
        RestTimerPill(state: state),

        // Floating Rounded Solid Dock (NO BLUR, NO BackdropFilter)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? ReportThemeTokens.sheetSurfaceDark : ReportThemeTokens.sheetSurfaceLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.outline,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Exercise & Set Stats + Progress Bar
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$performedExercises/$totalExercises EXERCISES',
                          style: ReportThemeTokens.outfitSubtext(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$performedSets/$totalSets SETS',
                          style: ReportThemeTokens.outfitSubtext(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: AppColors.indigoAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: exerciseProgress,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.completedGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Gradient "Finish Workout" Button
              GestureDetector(
                onTap: () => _showSummaryBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'FINISH WORKOUT',
                    style: ReportThemeTokens.outfitHeader(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
