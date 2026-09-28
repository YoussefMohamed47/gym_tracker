import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../../domain/entities/workout_type.dart';
import '../cubit/workout_cubit.dart';

class WorkoutSwitcherSheet extends StatefulWidget {
  const WorkoutSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final workoutCubit = context.read<WorkoutCubit>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: workoutCubit,
        child: const WorkoutSwitcherSheet(),
      ),
    );
  }

  @override
  State<WorkoutSwitcherSheet> createState() => _WorkoutSwitcherSheetState();
}

class _WorkoutSwitcherSheetState extends State<WorkoutSwitcherSheet> {
  late List<ExerciseSlot> _exercises;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    final state = context.read<WorkoutCubit>().state;
    final workoutDef = WorkoutCatalog.getWorkoutByType(state.workoutType);
    _exercises = List.from(workoutDef?.exercises ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = context.watch<WorkoutCubit>().state;

    final workoutTypes = [
      WorkoutType.pull,
      WorkoutType.push,
      WorkoutType.legs,
      WorkoutType.upper,
      WorkoutType.lower,
      WorkoutType.rest,
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: isDark ? AppColors.borderSubtle : AppColors.outline,
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
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CHANGE WORKOUT',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grid of Workout Cards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.15,
                        ),
                    itemCount: workoutTypes.length,
                    itemBuilder: (context, index) {
                      final type = workoutTypes[index];
                      final isSelected = type == state.workoutType;

                      IconData iconData = Icons.fitness_center_rounded;
                      Color colorTint = AppColors.gradientStart;

                      switch (type) {
                        case WorkoutType.pull:
                          iconData = Icons.back_hand_rounded;
                          colorTint = const Color(0xFF6C7BFF);
                          break;
                        case WorkoutType.push:
                          iconData = Icons.sports_gymnastics_rounded;
                          colorTint = const Color(0xFF9B6CFF);
                          break;
                        case WorkoutType.legs:
                          iconData = Icons.directions_run_rounded;
                          colorTint = const Color(0xFFFF6C9B);
                          break;
                        case WorkoutType.upper:
                          iconData = Icons.fitness_center_rounded;
                          colorTint = const Color(0xFF00C8FF);
                          break;
                        case WorkoutType.lower:
                          iconData = Icons.boy_rounded;
                          colorTint = const Color(0xFFFFB800);
                          break;
                        case WorkoutType.rest:
                          iconData = Icons.spa_rounded;
                          colorTint = AppColors.completedGreen;
                          break;
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorTint.withValues(alpha: 0.15)
                              : (isDark
                                    ? AppColors.darkElevated
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? colorTint
                                : (isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.outline),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorTint.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.read<WorkoutCubit>().changeWorkoutType(
                                type,
                              );
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        iconData,
                                        color: colorTint,
                                        size: 20,
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: AppColors.completedGreen,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    type.displayName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.bold,
                                      color: isSelected
                                          ? colorTint
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Reorder Exercises Section (if not rest day)
                  if (state.workoutType != WorkoutType.rest &&
                      _exercises.isNotEmpty) ...[
                    Text(
                      'REORDER EXERCISES',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkElevated
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderSubtle
                              : AppColors.outline,
                        ),
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exercises.length,
                        onReorder: (oldIndex, newIndex) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _exercises.removeAt(oldIndex);
                            _exercises.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final slot = _exercises[index];
                          final exercise = WorkoutCatalog.getExerciseById(
                            slot.exerciseId,
                          );

                          return Container(
                            key: ValueKey(slot.exerciseId),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: index < _exercises.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? AppColors.borderSubtle
                                            : AppColors.outline,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercise.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.drag_handle_rounded,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Clear Day (Reset to suggestion)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final previousType = state.workoutType;
                        context.read<WorkoutCubit>().clearWorkout();
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Reset day to schedule suggestion',
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                context.read<WorkoutCubit>().changeWorkoutType(
                                  previousType,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.destructiveRed,
                      ),
                      label: Text(
                        'Clear day (reset to suggestion)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
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
        ),
      ),
    );
  }
}
