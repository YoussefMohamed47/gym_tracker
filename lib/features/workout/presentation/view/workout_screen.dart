import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/usecases/get_exercise_history.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../services/photo_service.dart';
import '../services/workout_share_service.dart';
import '../widgets/alternative_exercise_bottom_sheet.dart';
import '../widgets/bottom_dock.dart';
import '../widgets/exercise_history_sheet.dart';
import '../widgets/week_day_selector.dart';
import '../widgets/workout_content_sliver.dart';
import '../widgets/workout_header.dart';
import '../widgets/workout_switcher_sheet.dart';

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
        title: Text(
          'Review Workout',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have $count exercise(s) not marked as performed. Do you want to save anyway?',
          style: GoogleFonts.outfit(),
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
    final workoutCubit = context.read<WorkoutCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: workoutCubit,
        child: AlternativeExerciseBottomSheet(
          originalExerciseId: plannedId,
          currentPerformedId: currentPerformedId,
          onSelect: (altId) {
            workoutCubit.selectAlternative(plannedId, altId);
          },
        ),
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
      backgroundColor: Colors.transparent,
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
          final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: WorkoutHeader(
                          state: state,
                          onTypeTapped: () => WorkoutSwitcherSheet.show(context),
                        ),
                      ),

                      // Week Selector Strip
                      SliverToBoxAdapter(
                        child: WeekDaySelector(
                          selectedDate: state.selectedDate,
                          onDateSelected: (date) =>
                              context.read<WorkoutCubit>().loadDate(date),
                        ),
                      ),

                      // Exercises Content
                      WorkoutContentSliver(
                        state: state,
                        onSelectAlternative: _showAlternativeBottomSheet,
                        onAddPhoto: _handleAddPhoto,
                        onShowHistory: _showHistoryBottomSheet,
                      ),

                      // Scroll Padding for Bottom Dock & Floating Nav
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: keyboardOpen ? 24 : 140,
                        ),
                      ),
                    ],
                  ),

                  // Floating Bottom Dock
                  if (!keyboardOpen)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: BottomDock(state: state),
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
