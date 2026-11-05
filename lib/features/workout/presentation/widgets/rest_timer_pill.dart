import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
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
    final target = widget.state.restTimerTargetSeconds;
    final ratio = target > 0 ? widget.state.restTimerSeconds / target : 0.0;

    // Collapse completely while not resting so it takes no space in the dock.
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: !isActive
          ? const SizedBox(width: double.infinity)
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xF2162329),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.restAmber.withValues(alpha: .4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  RepaintBoundary(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: ratio.clamp(0.0, 1.0)),
                        duration: const Duration(milliseconds: 250),
                        builder: (context, val, _) => Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: val,
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.restAmber,
                              ),
                            ),
                            // Just "1:55" (no "Min"), scaled to fit the ring.
                            Padding(
                              padding: const EdgeInsets.all(9),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _clock(widget.state.restTimerSeconds),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: ReportThemeTokens.outfitNumber(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Resting',
                          style: ReportThemeTokens.outfitNumber(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.state.restTimerExerciseName.isNotEmpty)
                          Text(
                            widget.state.restTimerExerciseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _RestButton(
                    label: '+15s',
                    filled: false,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<WorkoutCubit>().addRestTimerSeconds(15);
                    },
                  ),
                  const SizedBox(width: 8),
                  _RestButton(
                    label: 'Skip',
                    filled: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<WorkoutCubit>().skipRestTimer();
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

String _clock(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class _RestButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _RestButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.restAmber : Colors.white10,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Text(
            label,
            style: ReportThemeTokens.outfitNumber(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: filled ? const Color(0xFF1A1205) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
