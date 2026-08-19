import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../../../core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/video_launcher.dart';

class DailyRoutineSection extends StatelessWidget {
  const DailyRoutineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyRoutine = WorkoutCatalog.getDailyRoutine();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Daily Routine',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...dailyRoutine.exercises.map((slot) {
          return _DailyRoutineCard(slot: slot);
        }),
      ],
    );
  }
}

class _DailyRoutineCard extends StatelessWidget {
  final ExerciseSlot slot;

  const _DailyRoutineCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);
    final isRepBased = !slot.prescribedReps.contains('s');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${slot.prescribedSets} sets • ${slot.prescribedReps} • Rest ${slot.prescribedRest}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (exercise.videoUrl != null)
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                    onPressed: () => VideoLauncher.launch(
                      context,
                      exercise.videoUrl!,
                    ),
                  ),
              ],
            ),
            const Divider(height: 16),
            BlocBuilder<WorkoutCubit, WorkoutState>(
              builder: (context, state) {
                final log = state.exerciseLogs[slot.exerciseId];
                if (log == null) return const SizedBox.shrink();

                return Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: List.generate(slot.prescribedSets, (index) {
                    final setLog = log.sets.length > index
                        ? log.sets[index]
                        : null;
                    final isPerformed = setLog?.isPerformed ?? false;

                    if (isRepBased) {
                      return _RepBasedRoutineSet(
                        exerciseId: slot.exerciseId,
                        index: index,
                        actualReps: setLog?.actualReps,
                        isPerformed: isPerformed,
                      );
                    }

                    return InkWell(
                      onTap: () => context
                          .read<WorkoutCubit>()
                          .toggleSetPerformed(slot.exerciseId, index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPerformed
                              ? AppColors.primaryBlue
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPerformed
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Set ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPerformed
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isPerformed
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isPerformed) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RepBasedRoutineSet extends StatefulWidget {
  final String exerciseId;
  final int index;
  final int? actualReps;
  final bool isPerformed;

  const _RepBasedRoutineSet({
    required this.exerciseId,
    required this.index,
    this.actualReps,
    required this.isPerformed,
  });

  @override
  State<_RepBasedRoutineSet> createState() => _RepBasedRoutineSetState();
}

class _RepBasedRoutineSetState extends State<_RepBasedRoutineSet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.actualReps?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(_RepBasedRoutineSet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actualReps != widget.actualReps) {
      final newText = widget.actualReps?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isPerformed
            ? AppColors.primaryBlue.withValues(alpha: 0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isPerformed ? AppColors.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S${widget.index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.isPerformed
                      ? AppColors.primaryBlue
                      : Colors.grey[600],
                ),
              ),
              GestureDetector(
                onTap: () => context.read<WorkoutCubit>().toggleSetPerformed(
                  widget.exerciseId,
                  widget.index,
                ),
                child: Icon(
                  widget.isPerformed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 14,
                  color: widget.isPerformed
                      ? AppColors.primaryBlue
                      : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: '0',
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            onChanged: (value) {
              final reps = int.tryParse(value);
              if (reps != null && reps > 0) {
                context.read<WorkoutCubit>().updateSetReps(
                  widget.exerciseId,
                  widget.index,
                  reps,
                );
              } else if (value.isEmpty) {
                context.read<WorkoutCubit>().updateSetReps(
                  widget.exerciseId,
                  widget.index,
                  null,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
