import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/workout_definition.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../utils/video_launcher.dart';

class WarmupSection extends StatelessWidget {
  const WarmupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final warmup = WorkoutCatalog.getUpperBodyWarmup();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'WARM-UP',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...warmup.exercises.map((slot) {
          return _WarmupCard(slot: slot);
        }),
      ],
    );
  }
}

class _WarmupCard extends StatelessWidget {
  final ExerciseSlot slot;

  const _WarmupCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final exercise = WorkoutCatalog.getExerciseById(slot.exerciseId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${slot.prescribedSets} × ${slot.prescribedReps}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (exercise.videoUrl != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Watch',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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

                    return _WarmupSetChip(
                      exerciseId: slot.exerciseId,
                      index: index,
                      actualReps: setLog?.actualReps,
                      isPerformed: isPerformed,
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

class _WarmupSetChip extends StatefulWidget {
  final String exerciseId;
  final int index;
  final int? actualReps;
  final bool isPerformed;

  const _WarmupSetChip({
    required this.exerciseId,
    required this.index,
    this.actualReps,
    required this.isPerformed,
  });

  @override
  State<_WarmupSetChip> createState() => _WarmupSetChipState();
}

class _WarmupSetChipState extends State<_WarmupSetChip> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.actualReps?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(_WarmupSetChip oldWidget) {
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
            ? AppColors.completedGreen.withValues(alpha: 0.15)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isPerformed
              ? AppColors.completedGreen
              : Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S${widget.index + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: widget.isPerformed
                      ? AppColors.completedGreen
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () => context.read<WorkoutCubit>().toggleSetPerformed(
                      widget.exerciseId,
                      widget.index,
                    ),
                child: Icon(
                  widget.isPerformed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14,
                  color: widget.isPerformed
                      ? AppColors.completedGreen
                      : Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
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
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
