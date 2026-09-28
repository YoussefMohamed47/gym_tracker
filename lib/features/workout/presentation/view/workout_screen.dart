import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_type.dart';
import '../../domain/usecases/get_exercise_history.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../services/photo_service.dart';
import '../services/workout_share_service.dart';
import '../widgets/alternative_exercise_bottom_sheet.dart';
import '../widgets/exercise_history_sheet.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/workout_content_sliver.dart';
import '../widgets/workout_header.dart';
import '../widgets/workout_rest_timer_bar.dart';
import '../widgets/workout_sticky_save_bar.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final PhotoService _photoService = PhotoService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load current date on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutCubit>().loadDate(DateTime.now());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _showWorkoutTypeSelector() {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Change Workout for Today'),
        children: [
          ...WorkoutType.values.map((type) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<WorkoutCubit>().changeWorkoutType(type);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      type == WorkoutType.rest
                          ? Icons.coffee
                          : Icons.fitness_center,
                      size: 20,
                      color:
                          type == context.read<WorkoutCubit>().state.workoutType
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontWeight: type ==
                                context.read<WorkoutCubit>().state.workoutType
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutCubit>().clearWorkout();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Clear Day (Reset to Suggestion)',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
          final double workoutSaveBarHeight = 110;

          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: WorkoutHeader(
                          state: state,
                          onTypeTapped: _showWorkoutTypeSelector,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: WeekDaySelector(
                          selectedDate: state.selectedDate,
                          onDateSelected: (date) =>
                              context.read<WorkoutCubit>().loadDate(date),
                        ),
                      ),
                      WorkoutContentSliver(
                        state: state,
                        onSelectAlternative: _showAlternativeBottomSheet,
                        onAddPhoto: _handleAddPhoto,
                        onShowHistory: _showHistoryBottomSheet,
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: keyboardOpen ? 24 : workoutSaveBarHeight + 32,
                        ),
                      ),
                    ],
                  ),
                  if (!keyboardOpen)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WorkoutRestTimerBar(state: state),
                          WorkoutStickySaveBar(state: state),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
