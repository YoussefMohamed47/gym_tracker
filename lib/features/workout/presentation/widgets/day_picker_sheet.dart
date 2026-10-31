import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';

class DayPickerSheet extends StatefulWidget {
  const DayPickerSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final workoutCubit = context.read<WorkoutCubit>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: workoutCubit,
        child: const DayPickerSheet(),
      ),
    );
  }

  @override
  State<DayPickerSheet> createState() => _DayPickerSheetState();
}

class _DayPickerSheetState extends State<DayPickerSheet> {
  late List<ExerciseSlot> _exercises;
  late WorkoutType _currentType;

  static const List<({int dayNum, String title, WorkoutType type, IconData icon, Color tint, bool isRest})> _rotationDays = [
    (dayNum: 1, title: 'Chest & Back', type: WorkoutType.chestAndBack, icon: Icons.fitness_center_rounded, tint: Color(0xFF6C7BFF), isRest: false),
    (dayNum: 2, title: 'Shoulder & Arms', type: WorkoutType.shoulderAndArms, icon: Icons.accessibility_new_rounded, tint: Color(0xFF9B6CFF), isRest: false),
    (dayNum: 3, title: 'Legs', type: WorkoutType.legs, icon: Icons.directions_run_rounded, tint: Color(0xFFFF6C9B), isRest: false),
    (dayNum: 4, title: 'Rest Day', type: WorkoutType.rest, icon: Icons.spa_rounded, tint: Color(0xFF3DDC97), isRest: true),
    (dayNum: 5, title: 'Full Body', type: WorkoutType.fullBody, icon: Icons.sports_gymnastics_rounded, tint: Color(0xFF00C8FF), isRest: false),
    (dayNum: 6, title: 'Rest Day', type: WorkoutType.rest, icon: Icons.spa_rounded, tint: Color(0xFF3DDC97), isRest: true),
    (dayNum: 7, title: 'Upper + Calves', type: WorkoutType.upperAndCalves, icon: Icons.boy_rounded, tint: Color(0xFFFFB800), isRest: false),
    (dayNum: 8, title: 'Rest Day', type: WorkoutType.rest, icon: Icons.spa_rounded, tint: Color(0xFF3DDC97), isRest: true),
  ];

  @override
  void initState() {
    super.initState();
    _currentType = context.read<WorkoutCubit>().state.workoutType;
    _loadExercisesForType(_currentType);
  }

  void _loadExercisesForType(WorkoutType type) {
    final workoutDef = WorkoutCatalog.getWorkoutByType(type);
    _exercises = List.from(workoutDef?.exercises ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<WorkoutCubit>().state;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? ReportThemeTokens.sheetSurfaceDark : ReportThemeTokens.sheetSurfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.outline,
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '8-DAY ROTATING SCHEDULE',
                    style: ReportThemeTokens.outfitHeader(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 8-Day Rotation Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.95,
                ),
                itemCount: _rotationDays.length,
                itemBuilder: (context, index) {
                  final day = _rotationDays[index];
                  final isSelected = day.type == state.workoutType;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _currentType = day.type;
                        _loadExercisesForType(day.type);
                      });
                      context.read<WorkoutCubit>().changeWorkoutType(day.type);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? day.tint.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: day.tint,
                                width: 2.0,
                              )
                            : Border.all(
                                color: isDark ? AppColors.borderSubtle : AppColors.outline,
                                width: 1.0,
                              ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                day.icon,
                                color: isSelected ? day.tint : AppColors.textSecondary,
                                size: 18,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: day.tint,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DAY ${day.dayNum}',
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? day.tint : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: isSelected
                                  ? (isDark ? AppColors.textPrimary : Colors.black87)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Animated Cross-fade for Reorder Section
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: state.workoutType != WorkoutType.rest && _exercises.isNotEmpty
                    ? Column(
                        key: ValueKey(state.workoutType),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'REORDER EXERCISES',
                                style: ReportThemeTokens.outfitSubtext(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_exercises.length} exercises',
                                style: ReportThemeTokens.outfitSubtext(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.borderSubtle : AppColors.outline,
                              ),
                            ),
                            child: ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _exercises.length,
                              onReorderItem: (oldIndex, newIndex) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  final item = _exercises.removeAt(oldIndex);
                                  _exercises.insert(newIndex, item);
                                });
                              },
                              itemBuilder: (context, index) {
                                final slot = _exercises[index];
                                final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

                                return Container(
                                  key: ValueKey(slot.exerciseId),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: index < _exercises.length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: isDark ? AppColors.borderSubtle : AppColors.outline,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${index + 1}',
                                        style: ReportThemeTokens.outfitNumber(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          exercise.name,
                                          style: ReportThemeTokens.outfitHeader(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.textPrimary : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.drag_handle_rounded,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_reorder')),
              ),

              // Clear Day (Reset to Suggestion) Action Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final previousType = state.workoutType;
                    context.read<WorkoutCubit>().clearWorkout();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: const Text('Reset day to schedule suggestion'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              context.read<WorkoutCubit>().changeWorkoutType(previousType);
                            },
                          ),
                        ),
                      );
                  },
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    size: 16,
                    color: AppColors.destructiveRed,
                  ),
                  label: Text(
                    'Clear day (reset to suggestion)',
                    style: ReportThemeTokens.outfitSubtext(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.destructiveRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
