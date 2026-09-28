import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
import '../utils/video_launcher.dart';
import 'exercise_set_row.dart';

class ExerciseLogCard extends StatefulWidget {
  final ExerciseLog log;
  final ExerciseSlot slot;
  final WeightUnit displayUnit;
  final String? previousDate;
  final List<ExerciseSetLog>? previousSets;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;
  final Function(int setIndex, double? weight) onWeightChanged;
  final Function(int setIndex, int? reps) onRepsChanged;
  final Function(int setIndex, double delta)? onStepWeight;
  final Function(int setIndex, int delta)? onStepReps;
  final Function(int setIndex) onToggleSetPerformed;
  final Function(WeightUnit unit) onUnitChanged;
  final VoidCallback onSelectAlternative;
  final VoidCallback onAddPhoto;
  final VoidCallback onShowHistory;
  final VoidCallback? onUseLegacyWeight;
  final VoidCallback? onCopyPreviousSession;
  final VoidCallback? onAddSet;
  final Function(int setIndex)? onRemoveSet;

  const ExerciseLogCard({
    super.key,
    required this.log,
    required this.slot,
    required this.displayUnit,
    this.previousDate,
    this.previousSets,
    this.isExpanded = true,
    this.onExpandToggle,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onStepWeight,
    this.onStepReps,
    required this.onToggleSetPerformed,
    required this.onUnitChanged,
    required this.onSelectAlternative,
    required this.onAddPhoto,
    required this.onShowHistory,
    this.onUseLegacyWeight,
    this.onCopyPreviousSession,
    this.onAddSet,
    this.onRemoveSet,
  });

  @override
  State<ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<ExerciseLogCard> {
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
  }

  void _initFocusNodes() {
    _weightFocusNodes = List.generate(
      widget.log.sets.length,
      (index) => FocusNode(),
    );
    _repsFocusNodes = List.generate(
      widget.log.sets.length,
      (index) => FocusNode(),
    );
  }

  @override
  void didUpdateWidget(ExerciseLogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log.sets.length != widget.log.sets.length) {
      for (final node in _weightFocusNodes) {
        node.dispose();
      }
      for (final node in _repsFocusNodes) {
        node.dispose();
      }
      _initFocusNodes();
    }
  }

  @override
  void dispose() {
    for (final node in _weightFocusNodes) {
      node.dispose();
    }
    for (final node in _repsFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<String> _getMuscleAndEquipmentChips(
    String exerciseId,
    String exerciseName,
  ) {
    final chips = <String>[];
    final text = '${exerciseId}_$exerciseName'.toLowerCase();

    if (text.contains('chest') ||
        text.contains('bench') ||
        text.contains('fly')) {
      chips.add('CHEST');
    } else if (text.contains('lat') ||
        text.contains('row') ||
        text.contains('t_bar') ||
        text.contains('pull_over')) {
      chips.add('BACK');
    } else if (text.contains('leg') ||
        text.contains('squat') ||
        text.contains('rdl') ||
        text.contains('adduction') ||
        text.contains('calve')) {
      chips.add('LEGS');
    } else if (text.contains('shoulder') ||
        text.contains('lateral') ||
        text.contains('rear_delt')) {
      chips.add('SHOULDERS');
    } else if (text.contains('bicep') || text.contains('curl')) {
      chips.add('BICEPS');
    } else if (text.contains('tricep') || text.contains('push_down')) {
      chips.add('TRICEPS');
    } else if (text.contains('shrug')) {
      chips.add('TRAPS');
    } else if (text.contains('routine') ||
        text.contains('pose') ||
        text.contains('bug') ||
        text.contains('twist')) {
      chips.add('CORE & MOBILITY');
    }

    if (text.contains('barbell') || text.contains('bb')) {
      chips.add('BARBELL');
    } else if (text.contains('db') || text.contains('dumbbell')) {
      chips.add('DUMBBELL');
    } else if (text.contains('cable')) {
      chips.add('CABLE');
    } else if (text.contains('machine') || text.contains('press_machine')) {
      chips.add('MACHINE');
    } else if (text.contains('body_weighted') ||
        text.contains('pose') ||
        text.contains('bug')) {
      chips.add('BODYWEIGHT');
    }

    return chips;
  }

  bool _checkIsPR() {
    if (widget.previousSets == null || widget.previousSets!.isEmpty) {
      return false;
    }
    double maxPrevWeight = 0;
    for (final s in widget.previousSets!) {
      if (s.weightKg != null && s.weightKg! > maxPrevWeight) {
        maxPrevWeight = s.weightKg!;
      }
    }
    if (maxPrevWeight <= 0) return false;

    for (final s in widget.log.sets) {
      if (s.isPerformed && s.weightKg != null && s.weightKg! > maxPrevWeight) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final originalExercise = WorkoutCatalog.getExerciseById(
      widget.log.plannedExerciseId,
    );
    final performedExercise = WorkoutCatalog.getExerciseById(
      widget.log.performedExerciseId,
    );
    final isAlternative =
        widget.log.plannedExerciseId != widget.log.performedExerciseId;

    final performedSetsCount = widget.log.sets
        .where((s) => s.isPerformed)
        .length;
    final totalSetsCount = widget.log.sets.length;
    final isFullyPerformed =
        totalSetsCount > 0 && performedSetsCount == totalSetsCount;
    final isPR = _checkIsPR();

    final isDurationBased = widget.slot.prescribedReps.contains('s');
    final chips = _getMuscleAndEquipmentChips(
      performedExercise.id,
      performedExercise.name,
    );

    final cardBorderColor = isFullyPerformed
        ? AppColors.completedGreen
        : (performedSetsCount > 0
              ? AppColors.gradientStart.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderSubtle : AppColors.outline));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isFullyPerformed
            ? AppColors.completedGreen.withValues(alpha: isDark ? 0.06 : 0.04)
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cardBorderColor,
          width: isFullyPerformed ? 2.0 : 1.0,
        ),
        boxShadow: isFullyPerformed
            ? [
                BoxShadow(
                  color: AppColors.completedGreen.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // Collapsed Summary Header / Expand Controller
            InkWell(
              onTap: widget.onExpandToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips Row & Collapsed Status Bar
                    Row(
                      children: [
                        if (chips.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: chips.map((chip) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.gradientStart.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      chip,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gradientStart,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        if (isPR)
                          Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFF8C00),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 11,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'PR',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shimmer(
                                duration: 1500.ms,
                                color: Colors.white70,
                              ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Exercise Name & Chevron / Progress Mini Bar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: 'ex_name_${widget.log.performedExerciseId}',
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isAlternative)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        'Planned: ${originalExercise.name}'
                                            .toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.restAmber,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    performedExercise.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      color: isFullyPerformed
                                          ? AppColors.completedGreen
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Progress mini pill or done badge
                        if (isFullyPerformed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.completedGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.completedGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DONE',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.completedGreen,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            '$performedSetsCount/$totalSetsCount SETS',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gradientStart,
                            ),
                          ),

                        const SizedBox(width: 8),

                        // Expand / Collapse Chevron
                        AnimatedRotation(
                          turns: widget.isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ],
                    ),

                    // Progress Mini Bar in collapsed mode
                    if (!widget.isExpanded && totalSetsCount > 0) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: performedSetsCount / totalSetsCount,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFullyPerformed
                                ? AppColors.completedGreen
                                : AppColors.gradientStart,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Expanded Card Body
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: widget.isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: 12),

                          // Header Info: Prescription & Form Guide & KG/LB Segmented Switch
                          Row(
                            children: [
                              Icon(
                                Icons.repeat_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.slot.prescribedSets} sets • ${widget.slot.prescribedReps} • Rest ${widget.slot.prescribedRest}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),

                              if (performedExercise.videoUrl != null) ...[
                                InkWell(
                                  onTap: () => VideoLauncher.launch(
                                    context,
                                    performedExercise.videoUrl!,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gradientStart.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.play_circle_fill_rounded,
                                          size: 14,
                                          color: AppColors.gradientStart,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Form Guide',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.gradientStart,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],

                              _KgLbSegmentedToggle(
                                unit: widget.log.displayUnit,
                                onChanged: widget.onUnitChanged,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Previous Info & Copy Session
                          if (widget.previousDate != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkElevated
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PREVIOUS • ${widget.previousDate}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (widget.onCopyPreviousSession != null)
                                    TextButton.icon(
                                      onPressed: widget.onCopyPreviousSession,
                                      icon: const Icon(
                                        Icons.electric_bolt_rounded,
                                        size: 13,
                                        color: AppColors.gradientStart,
                                      ),
                                      label: Text(
                                        'Copy Previous',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gradientStart,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // Legacy Weight Warning
                          if (widget.log.weightKg != null &&
                              widget.log.sets.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Material(
                                color: AppColors.restAmber.withValues(
                                  alpha: 0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.restAmber.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: widget.onUseLegacyWeight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.history_rounded,
                                          size: 16,
                                          color: AppColors.restAmber,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Legacy ref: ${WeightConverter.format(WeightConverter.convert(widget.log.weightKg!, WeightUnit.kg, widget.displayUnit))} ${widget.displayUnit.name}. Apply to all sets?',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: AppColors.restAmber,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Set Table Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 28,
                                  child: Text(
                                    'SET',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'LAST',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 5,
                                  child: Text(
                                    'WEIGHT',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 5,
                                  child: Text(
                                    'REPS',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 44,
                                  child: Text(
                                    'DONE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Set Rows
                          ...List.generate(widget.log.sets.length, (index) {
                            return ExerciseSetRow(
                              index: index,
                              setLog: widget.log.sets[index],
                              previousSetLog:
                                  (widget.previousSets != null &&
                                      widget.previousSets!.length > index)
                                  ? widget.previousSets![index]
                                  : null,
                              displayUnit: widget.log.displayUnit,
                              isRepsAllowed: !isDurationBased,
                              exerciseName: performedExercise.name,
                              onWeightChanged: (w) =>
                                  widget.onWeightChanged(index, w),
                              onRepsChanged: (r) =>
                                  widget.onRepsChanged(index, r),
                              onStepWeight: widget.onStepWeight != null
                                  ? (delta) =>
                                        widget.onStepWeight!(index, delta)
                                  : null,
                              onStepReps: widget.onStepReps != null
                                  ? (delta) => widget.onStepReps!(index, delta)
                                  : null,
                              onTogglePerformed: () =>
                                  widget.onToggleSetPerformed(index),
                              onDeleteSet: widget.onRemoveSet != null
                                  ? () => widget.onRemoveSet!(index)
                                  : null,
                              weightFocusNode: _weightFocusNodes[index],
                              repsFocusNode: _repsFocusNodes[index],
                              onWeightSubmitted: () {
                                if (!isDurationBased) {
                                  _repsFocusNodes[index].requestFocus();
                                } else if (index < widget.log.sets.length - 1) {
                                  _weightFocusNodes[index + 1].requestFocus();
                                }
                              },
                              onRepsSubmitted: () {
                                if (index < widget.log.sets.length - 1) {
                                  _weightFocusNodes[index + 1].requestFocus();
                                }
                              },
                            );
                          }),

                          // Dashed Outline "+ Add Set" Button
                          if (widget.onAddSet != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 6,
                              ),
                              child: GestureDetector(
                                onTap: widget.onAddSet,
                                child: Container(
                                  height: 38,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.gradientStart.withValues(
                                        alpha: 0.4,
                                      ),
                                      style: BorderStyle.solid,
                                      width: 1.5,
                                    ),
                                    color: AppColors.gradientStart.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                        color: AppColors.gradientStart,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add Set',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gradientStart,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: 12),

                          // Scrollable Action Chips Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _ActionChip(
                                  icon: Icons.history_rounded,
                                  label: 'History',
                                  onPressed: widget.onShowHistory,
                                ),
                                const SizedBox(width: 8),
                                _ActionChip(
                                  icon: widget.log.imagePath != null
                                      ? Icons.image_rounded
                                      : Icons.add_a_photo_rounded,
                                  label: 'Photo',
                                  onPressed: widget.onAddPhoto,
                                  active: widget.log.imagePath != null,
                                ),
                                const SizedBox(width: 8),
                                _ActionChip(
                                  icon: Icons.swap_horiz_rounded,
                                  label: 'Alternatives',
                                  onPressed: widget.onSelectAlternative,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _KgLbSegmentedToggle extends StatelessWidget {
  final WeightUnit unit;
  final Function(WeightUnit) onChanged;

  const _KgLbSegmentedToggle({required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isKg = unit == WeightUnit.kg;

    return Container(
      width: 72,
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: isKg ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 34,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(WeightUnit.kg),
                  child: Center(
                    child: Text(
                      'KG',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isKg
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(WeightUnit.lb),
                  child: Center(
                    child: Text(
                      'LB',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: !isKg
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: active
          ? AppColors.gradientStart.withValues(alpha: 0.15)
          : (isDark ? AppColors.darkElevated : Colors.grey.shade100),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: active
                    ? AppColors.gradientStart
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: active
                      ? AppColors.gradientStart
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
