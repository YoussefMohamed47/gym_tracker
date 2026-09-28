import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/rest_time_parser.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class WorkoutRestTimerBar extends StatefulWidget {
  final WorkoutState state;

  const WorkoutRestTimerBar({super.key, required this.state});

  @override
  State<WorkoutRestTimerBar> createState() => _WorkoutRestTimerBarState();
}

class _WorkoutRestTimerBarState extends State<WorkoutRestTimerBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _manageTimer();
  }

  @override
  void didUpdateWidget(covariant WorkoutRestTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _manageTimer();
  }

  void _manageTimer() {
    if (widget.state.isRestTimerActive) {
      if (_timer == null || !_timer!.isActive) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            context.read<WorkoutCubit>().tickRestTimer();
          }
        });
      }
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isRestTimerActive) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final seconds = widget.state.restTimerSeconds;
    final target = widget.state.restTimerTargetSeconds > 0
        ? widget.state.restTimerTargetSeconds
        : 1;
    final progress = (seconds / target).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.state.restTimerExerciseName.isNotEmpty
                          ? 'Rest Time • ${widget.state.restTimerExerciseName}'
                          : 'Rest Time',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      RestTimeParser.formatDisplay(seconds),
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<WorkoutCubit>().addRestTimerSeconds(30);
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  '+30 Seconds',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {
                  context.read<WorkoutCubit>().skipRestTimer();
                },
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Skip Rest',
                color: colorScheme.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
