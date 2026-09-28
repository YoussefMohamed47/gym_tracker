import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/rest_time_parser.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class RestTimerPill extends StatefulWidget {
  final WorkoutState state;

  const RestTimerPill({super.key, required this.state});

  @override
  State<RestTimerPill> createState() => _RestTimerPillState();
}

class _RestTimerPillState extends State<RestTimerPill> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _manageTimer();
  }

  @override
  void didUpdateWidget(covariant RestTimerPill oldWidget) {
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
    final isActive = widget.state.isRestTimerActive;

    return AnimatedSlide(
      offset: isActive ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.restAmber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.restAmber,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.restAmber.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Countdown Ring
              SizedBox(
                width: 28,
                height: 28,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 1.0,
                    end: widget.state.restTimerTargetSeconds > 0
                        ? (widget.state.restTimerSeconds /
                            widget.state.restTimerTargetSeconds)
                        : 0.0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, val, _) {
                    return CircularProgressIndicator(
                      value: val,
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.restAmber,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Time String & Exercise
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    RestTimeParser.formatDisplay(widget.state.restTimerSeconds),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.restAmber,
                    ),
                  ),
                  if (widget.state.restTimerExerciseName.isNotEmpty)
                    Text(
                      widget.state.restTimerExerciseName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.restAmber.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // +15s Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<WorkoutCubit>().addRestTimerSeconds(15);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.restAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+15s',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.restAmber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Skip Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<WorkoutCubit>().skipRestTimer();
                },
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.restAmber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
