import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/theme_transition_controller.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubit/workout_state.dart';

/// Athletic editorial hero: a training session first, stats second.
class WorkoutHeader extends StatefulWidget {
  final WorkoutState state;
  final VoidCallback onTypeTapped;
  const WorkoutHeader({super.key, required this.state, required this.onTypeTapped});
  @override
  State<WorkoutHeader> createState() => _WorkoutHeaderState();
}

class _WorkoutHeaderState extends State<WorkoutHeader> {
  final GlobalKey _themeButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var all = 0;
    var done = 0;
    for (final log in widget.state.exerciseLogs.values) {
      all += log.sets.length;
      done += log.sets.where((s) => s.isPerformed).length;
    }
    final progress = all == 0 ? 0.0 : done / all;
    return Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: Text('TRAINING / ${DateFormat('MMM d').format(widget.state.selectedDate).toUpperCase()}',
            style: GoogleFonts.outfit(letterSpacing: 2.1, fontSize: 11, fontWeight: FontWeight.w900, color: scheme.primary))),
          IconButton(key: _themeButtonKey, tooltip: 'Theme',
            onPressed: () => di.sl<ThemeTransitionController>().animateThemeToggle(
              context: context, buttonKey: _themeButtonKey,
              onToggle: () => context.read<ThemeCubit>().toggleTheme()),
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('YOUR\nSESSION.', style: GoogleFonts.outfit(fontSize: 43, fontWeight: FontWeight.w900,
              letterSpacing: -1.9, height: 0.92)),
            const SizedBox(height: 14),
            OutlinedButton.icon(onPressed: () {
              HapticFeedback.selectionClick();
              widget.onTypeTapped();
            }, icon: const Icon(Icons.swap_horiz_rounded, size: 17),
              label: Text(widget.state.workoutType.displayName,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$done', style: GoogleFonts.outfit(fontSize: 72, fontWeight: FontWeight.w900,
              letterSpacing: -3, height: .94, color: scheme.primary)),
            Text('OF $all SETS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: scheme.onSurfaceVariant)),
          ]),
        ]),
        const SizedBox(height: 22),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
          minHeight: 6, value: progress, color: scheme.primary, backgroundColor: scheme.surfaceContainerHigh)),
        const SizedBox(height: 5),
        Text('SESSION PROGRESS  ·  ${(progress * 100).round()}%',
          textAlign: TextAlign.end, style: GoogleFonts.outfit(fontSize: 10,
            color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
      ],
    ));
  }
}
