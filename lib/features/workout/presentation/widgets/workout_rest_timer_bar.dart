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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator Ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 44,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3.5,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Exercise Name & Remaining Countdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.state.restTimerExerciseName.isNotEmpty
                      ? widget.state.restTimerExerciseName.toUpperCase()
                      : 'REST TIME',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  RestTimeParser.formatDisplay(seconds),
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Controls: +30s and Skip
          OutlinedButton.icon(
            onPressed: () {
              context.read<WorkoutCubit>().addRestTimerSeconds(30);
            },
            icon: const Icon(Icons.add_rounded, size: 14),
            label: const Text(
              '+30s',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () {
              context.read<WorkoutCubit>().skipRestTimer();
            },
            icon: const Icon(Icons.close_rounded, size: 18),
            tooltip: 'Skip Rest',
            color: colorScheme.onSurfaceVariant,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
