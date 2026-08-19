import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/usecases/get_exercise_history.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../services/photo_service.dart';
import '../services/workout_share_service.dart';
import '../widgets/alternative_exercise_bottom_sheet.dart';
import '../widgets/daily_routine_section.dart';
import '../widgets/exercise_history_sheet.dart';
import '../widgets/exercise_log_card.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/weight_unit_selector.dart';
import '../widgets/workout_week_header.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final PhotoService _photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    // Load current date on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutCubit>().loadDate(DateTime.now());
    });
  }

  void _showReviewDialog(int count) {
    final workoutCubit = context.read<WorkoutCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review Workout'),
        content: Text(
          'You have $count exercise(s) not marked as performed. Do you want to save anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              workoutCubit.saveWorkout(forceSave: true);
            },
            child: const Text('Save Anyway'),
          ),
        ],
      ),
    );
  }

  void _showAlternativeBottomSheet(
    String plannedId,
    String currentPerformedId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AlternativeExerciseBottomSheet(
        originalExerciseId: plannedId,
        currentPerformedId: currentPerformedId,
        onSelect: (altId) {
          context.read<WorkoutCubit>().selectAlternative(plannedId, altId);
        },
      ),
    );
  }

  Future<void> _showHistoryBottomSheet(String exerciseId, String name) async {
    final getHistory = GetIt.I<GetExerciseHistory>();
    final workoutType = context.read<WorkoutCubit>().state.workoutType;
    final history = await getHistory(workoutType.name, exerciseId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExerciseHistorySheet(
        exerciseName: name,
        history: history,
        displayUnit: context.read<WorkoutCubit>().state.displayUnit,
      ),
    );
  }

  Future<void> _handleAddPhoto(String exerciseId) async {
    final path = await _photoService.capturePhoto();
    if (path != null && mounted) {
      context.read<WorkoutCubit>().updatePhoto(exerciseId, path);
    }
  }

  Future<void> _handleShare(WorkoutState state) async {
    final session = WorkoutSession(
      dateKey: state.dateKey,
      workoutType: state.workoutType,
      exerciseLogs: state.exerciseLogs,
      displayUnit: state.displayUnit,
    );
    await WorkoutShareService.shareWorkout(context, session);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutCubit, WorkoutState>(
      listener: (context, state) {
        if (state.status == WorkoutStatus.failure &&
            state.errorMessage != null) {
          if (state.errorMessage!.startsWith('REVIEW_REQUIRED:')) {
            final count = int.parse(state.errorMessage!.split(':')[1]);
            _showReviewDialog(count);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        } else if (state.status == WorkoutStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout saved and finished!')),
          );
          _handleShare(state);
        }
      },
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, state),
                  WeekDaySelector(
                    selectedDate: state.selectedDate,
                    onDateSelected: (date) =>
                        context.read<WorkoutCubit>().loadDate(date),
                  ),
                  Expanded(child: _buildContent(context, state)),
                  _buildStickySaveBar(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.workoutType.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Weekly Workout',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Row(
              //   children: [
              //     IconButton(
              //       icon: const Icon(Icons.download_outlined),
              //       onPressed: () => WorkoutShareService.saveToGallery(
              //         context,
              //         WorkoutSession(
              //           dateKey: state.dateKey,
              //           workoutType: state.workoutType,
              //           exerciseLogs: state.exerciseLogs,
              //           displayUnit: state.displayUnit,
              //         ),
              //       ),
              //       tooltip: 'Save To Gallery',
              //     ),
              //     const WeightUnitSelector(),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 8),
          WorkoutWeekHeader(
            selectedDate: state.selectedDate,
            onPreviousWeek: () => context.read<WorkoutCubit>().navigateWeek(-1),
            onNextWeek: () => context.read<WorkoutCubit>().navigateWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySaveBar(BuildContext context, WorkoutState state) {
    if (state.workoutType == WorkoutType.rest ||
        state.status == WorkoutStatus.loading) {
      return const SizedBox.shrink();
    }

    final performedCount = state.exerciseLogs.values
        .where((log) => log.sets.any((s) => s.isPerformed))
        .length;
    final totalCount = state.exerciseLogs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$performedCount of $totalCount exercises done',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? performedCount / totalCount : 0,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: state.status == WorkoutStatus.saving
                ? null
                : () => context.read<WorkoutCubit>().saveWorkout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.status == WorkoutStatus.saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Finish'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutState state) {
    if (state.status == WorkoutStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.workoutType == WorkoutType.rest) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 64),
            Icon(
              Icons.coffee,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Rest Day',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('Active recovery and proper nutrition!'),
          ],
        ),
      );
    }

    final workoutDef = WorkoutCatalog.workouts.firstWhere(
      (w) => w.type == state.workoutType,
      orElse: () => WorkoutCatalog.workouts.first,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const DailyRoutineSection(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...workoutDef.exercises.map((slot) {
          final log = state.exerciseLogs[slot.exerciseId];
          if (log == null) return const SizedBox.shrink();

          final performedExercise = WorkoutCatalog.getExerciseById(
            log.performedExerciseId,
          );

          return ExerciseLogCard(
            log: log,
            slot: slot,
            displayUnit: state.displayUnit,
            onWeightChanged: (setIndex, weight) {
              context.read<WorkoutCubit>().updateSetWeight(
                slot.exerciseId,
                setIndex,
                weight,
                log.displayUnit,
              );
            },
            onRepsChanged: (setIndex, reps) {
              context.read<WorkoutCubit>().updateSetReps(
                slot.exerciseId,
                setIndex,
                reps,
              );
            },
            onToggleSetPerformed: (setIndex) {
              context.read<WorkoutCubit>().toggleSetPerformed(
                slot.exerciseId,
                setIndex,
              );
            },
            onUnitChanged: (unit) {
              context.read<WorkoutCubit>().updateExerciseUnit(
                slot.exerciseId,
                unit,
              );
            },
            onSelectAlternative: () {
              _showAlternativeBottomSheet(
                slot.exerciseId,
                log.performedExerciseId,
              );
            },
            onAddPhoto: () => _handleAddPhoto(slot.exerciseId),
            onShowHistory: () => _showHistoryBottomSheet(
              log.performedExerciseId,
              performedExercise.name,
            ),
            onUseLegacyWeight: () => context
                .read<WorkoutCubit>()
                .useLegacyWeightForAllSets(slot.exerciseId),
          );
        }),
      ],
    );
  }
}
