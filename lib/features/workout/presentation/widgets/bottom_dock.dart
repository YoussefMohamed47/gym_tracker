import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
      builder: (sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: isDark ? AppColors.borderSubtle : AppColors.outline,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebratory Icon Animation
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.completedGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 42,
                    color: Colors.black,
                  ),
                ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 16),

                Text(
                  'WORKOUT COMPLETED!',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  state.workoutType.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gradientStart,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid Cards
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        context,
                        title: 'SETS DONE',
                        value: '$performedSets/$totalSets',
                        icon: Icons.repeat_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                const SizedBox(height: 28),

                // Save & Share Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        workoutCubit.saveWorkout();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          'SAVE & VIEW REPORT',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.gradientStart),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.workoutType == WorkoutType.rest ||
        state.status == WorkoutStatus.loading) {
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
        // Sliding Rest Timer Pill
        RestTimerPill(state: state),

        // Floating Rounded Glass Dock
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard.withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderSubtle
                        : AppColors.outline,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Exercise & Set Stats + Progress Mini Bar
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
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '$performedSets/$totalSets SETS',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  color: AppColors.gradientStart,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: exerciseProgress,
                              minHeight: 6,
                              backgroundColor:
                                  isDark ? Colors.white10 : Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.completedGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Primary Gradient "Finish Workout" Button
                    GestureDetector(
                      onTap: () => _showSummaryBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.gradientStart.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'FINISH WORKOUT',
                          style: GoogleFonts.outfit(
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
            ),
          ),
        ),
      ],
    );
  }
}
