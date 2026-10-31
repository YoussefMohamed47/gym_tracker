import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_definition.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/exercise_set_log.dart';
import '../../domain/entities/workout_definition.dart';
import '../utils/video_launcher.dart';
import 'numeric_keypad_sheet.dart';
import 'set_row.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseLog log;
  final ExerciseSlot slot;
  final WeightUnit displayUnit;
  final String? previousDate;
  final List<ExerciseSetLog>? previousSets;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final Function(int setIndex, double? weight) onWeightChanged;
  final Function(int setIndex, int? reps) onRepsChanged;
  final Function(int setIndex, double delta)? onStepWeight;
  final Function(int setIndex, int delta)? onStepReps;
  final Function(int setIndex) onToggleSetPerformed;
  final Function(WeightUnit unit) onUnitChanged;
  final VoidCallback onSelectAlternative;
  final VoidCallback onAddPhoto;
  final VoidCallback onShowHistory;
  final VoidCallback? onCopyPreviousSession;
  final VoidCallback? onAddSet;
  final Function(int setIndex)? onRemoveSet;

  const ExerciseCard({
    super.key,
    required this.log,
    required this.slot,
    required this.displayUnit,
    this.previousDate,
    this.previousSets,
    this.isExpanded = false,
    required this.onExpandToggle,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onStepWeight,
    this.onStepReps,
    required this.onToggleSetPerformed,
    required this.onUnitChanged,
    required this.onSelectAlternative,
    required this.onAddPhoto,
    required this.onShowHistory,
    this.onCopyPreviousSession,
    this.onAddSet,
    this.onRemoveSet,
  });

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'CHEST':
      case 'SHOULDERS':
        return const Color(0xFFFF6B6B);
      case 'BACK':
        return const Color(0xFF00C9FF);
      case 'LEGS':
      case 'CALVES':
        return const Color(0xFF20C997);
      case 'BICEPS':
      case 'TRICEPS':
      case 'FOREARMS':
        return const Color(0xFF9B6CFF);
      default:
        return AppColors.gradientStart;
    }
  }

  List<String> _extractTags(String exerciseId, String exerciseName) {
    final tags = <String>[];
    final text = '${exerciseId}_$exerciseName'.toLowerCase();

    if (text.contains('chest') || text.contains('bench') || text.contains('fly')) {
      tags.add('CHEST');
    }
    if (text.contains('back') || text.contains('row') || text.contains('pull down') || text.contains('lat')) {
      tags.add('BACK');
    }
    if (text.contains('shoulder') || text.contains('delt') || text.contains('lateral')) {
      tags.add('SHOULDERS');
    }
    if (text.contains('bicep') || text.contains('curl')) {
      tags.add('BICEPS');
    }
    if (text.contains('tricep') || text.contains('push down')) {
      tags.add('TRICEPS');
    }
    if (text.contains('leg') || text.contains('squat') || text.contains('adduction') || text.contains('hip thrust')) {
      tags.add('LEGS');
    }
    if (text.contains('calf') || text.contains('calves')) {
      tags.add('CALVES');
    }
    if (text.contains('wrist') || text.contains('forearm')) {
      tags.add('FOREARMS');
    }

    if (text.contains('cable')) {
      tags.add('CABLE');
    } else if (text.contains('machine') || text.contains('smith')) {
      tags.add('MACHINE');
    } else if (text.contains('db') || text.contains('dumbbell')) {
      tags.add('DUMBBELL');
    }

    if (tags.isEmpty) tags.add('STRENGTH');
    return tags;
  }

  Future<void> _openNumericKeypad(
    BuildContext context, {
    required int setIndex,
    required bool isWeight,
    required double initialValue,
  }) async {
    if (isWeight) {
      final val = await NumericKeypadSheet.showWeightKeypad(
        context,
        title: 'SET WEIGHT (${displayUnit.name.toUpperCase()})',
        initialValue: initialValue > 0 ? initialValue : null,
        unit: displayUnit.name,
      );
      if (val != null) {
        final weightInKg = WeightConverter.convert(val, displayUnit, WeightUnit.kg);
        onWeightChanged(setIndex, weightInKg);
      }
    } else {
      final val = await NumericKeypadSheet.showRepsKeypad(
        context,
        title: 'SET REPS',
        initialValue: initialValue.toInt() > 0 ? initialValue.toInt() : null,
      );
      if (val != null) {
        onRepsChanged(setIndex, val);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final originalExercise = WorkoutCatalog.getExerciseById(log.plannedExerciseId);
    final performedExercise = WorkoutCatalog.getExerciseById(log.performedExerciseId);
    final isAlternative = log.plannedExerciseId != log.performedExerciseId;

    final exerciseName = performedExercise.name;
    final tempoNote = performedExercise.tempoNote ?? slot.tempoNote;
    final tags = _extractTags(performedExercise.id, exerciseName);

    final totalSets = log.sets.length;
    final performedSets = log.sets.where((s) => s.isPerformed).length;
    final isAllCompleted = totalSets > 0 && performedSets == totalSets;
    final progress = totalSets > 0 ? performedSets / totalSets : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          left: BorderSide(
            color: isAllCompleted ? AppColors.completedGreen : AppColors.indigoAccent,
            width: isExpanded ? 5 : 3,
          ),
          top: BorderSide(color: isDark ? AppColors.borderSubtle : AppColors.outline),
          bottom: BorderSide(color: isDark ? AppColors.borderSubtle : AppColors.outline),
        ),
      ),
      child: ClipRect(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? _buildExpandedContent(
                  context,
                  isDark: isDark,
                  originalExercise: originalExercise,
                  performedExercise: performedExercise,
                  isAlternative: isAlternative,
                  tags: tags,
                  tempoNote: tempoNote,
                  totalSets: totalSets,
                  performedSets: performedSets,
                )
              : _buildCollapsedSummary(
                  context,
                  isDark: isDark,
                  exerciseName: exerciseName,
                  tags: tags,
                  tempoNote: tempoNote,
                  totalSets: totalSets,
                  performedSets: performedSets,
                  progress: progress,
                  isAllCompleted: isAllCompleted,
                ),
        ),
      ),
    );
  }

  // --- COLLAPSED SUMMARY ROW ---
  Widget _buildCollapsedSummary(
    BuildContext context, {
    required bool isDark,
    required String exerciseName,
    required List<String> tags,
    required String? tempoNote,
    required int totalSets,
    required int performedSets,
    required double progress,
    required bool isAllCompleted,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onExpandToggle();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Green completion indicator or dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAllCompleted
                          ? AppColors.completedGreen
                          : (performedSets > 0 ? AppColors.indigoAccent : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Exercise Name
                  Expanded(
                    child: Text(
                      exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReportThemeTokens.outfitHeader(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
                  ),

                  // Tag Pill
                  if (tags.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTagColor(tags.first).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tags.first,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getTagColor(tags.first),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Sets Progress Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAllCompleted
                          ? AppColors.completedGreen.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$performedSets/$totalSets sets',
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isAllCompleted
                            ? AppColors.completedGreen
                            : (isDark ? AppColors.textPrimary : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              // Tempo note subtitle if present
              if (tempoNote != null && tempoNote.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    tempoNote,
                    style: ReportThemeTokens.outfitSubtext(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningAmber,
                    ),
                  ),
                ),
              ],

              // Mini progress bar
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllCompleted ? AppColors.completedGreen : AppColors.indigoAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EXPANDED FOCUS CARD ---
  Widget _buildExpandedContent(
    BuildContext context, {
    required bool isDark,
    required ExerciseDefinition originalExercise,
    required ExerciseDefinition performedExercise,
    required bool isAlternative,
    required List<String> tags,
    required String? tempoNote,
    required int totalSets,
    required int performedSets,
  }) {
    final videoUrl = performedExercise.videoUrl;
    final pairedVideoUrls = performedExercise.pairedVideoUrls;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Tags + Collapse Toggle
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: tags.map((t) {
                  final color = _getTagColor(t);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      t,
                      style: ReportThemeTokens.outfitSubtext(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),

              // KG / LB Unit Toggle with lightweight sliding animation
              _buildUnitToggle(isDark),
              const SizedBox(width: 8),

              // The parent exercise rail owns focus; no inert collapse button.
              if (!isExpanded)
                IconButton(
                  icon: const Icon(Icons.expand_less_rounded, size: 22),
                  onPressed: onExpandToggle,
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Exercise Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performedExercise.name,
                      style: ReportThemeTokens.outfitHeader(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
                    if (isAlternative) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Alternative for: ${originalExercise.name}',
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.indigoAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Tempo Note Subtitle (e.g. "Light weight, slow tempo")
          if (tempoNote != null && tempoNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warningAmber.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    size: 14,
                    color: AppColors.warningAmber,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tempoNote,
                    style: ReportThemeTokens.outfitSubtext(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningAmber,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Action Pills: Form Guide (Single or Superset), Alternatives, History, Photo
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Superset Video Buttons (e.g. Wrist Flexion + Extension)
              if (pairedVideoUrls != null && pairedVideoUrls.isNotEmpty) ...[
                if (videoUrl != null)
                  _buildVideoPill(
                    context,
                    label: 'Flexion Guide',
                    url: videoUrl,
                  ),
                ...pairedVideoUrls.map((pUrl) {
                  return _buildVideoPill(
                    context,
                    label: 'Extension Guide',
                    url: pUrl,
                  );
                }),
              ] else if (videoUrl != null) ...[
                // Standard Form Guide Button
                _buildVideoPill(
                  context,
                  label: 'Form Guide',
                  url: videoUrl,
                ),
              ],

              // Alternatives / Swap Button
              _buildHeaderActionPill(
                icon: Icons.swap_horiz_rounded,
                label: 'Alternatives',
                onTap: onSelectAlternative,
                isDark: isDark,
              ),

              // History Button
              _buildHeaderActionPill(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: onShowHistory,
                isDark: isDark,
              ),

              // Photo Button
              _buildHeaderActionPill(
                icon: Icons.camera_alt_outlined,
                label: 'Photo',
                onTap: onAddPhoto,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prescribed info text
          Text(
            'Target: ${slot.prescribedSets} sets × ${slot.prescribedReps} reps • Rest: ${slot.prescribedRest}',
            style: ReportThemeTokens.outfitSubtext(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Set Rows (using ListView.builder)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: log.sets.length,
            itemBuilder: (context, setIndex) {
              final setLog = log.sets[setIndex];
              final prevLog = (previousSets != null && previousSets!.length > setIndex)
                  ? previousSets![setIndex]
                  : null;

              return SetRow(
                index: setIndex,
                setLog: setLog,
                previousSetLog: prevLog,
                displayUnit: displayUnit,
                isWeightAllowed: performedExercise.isWeightAllowed,
                isRepsAllowed: true,
                onWeightChanged: (w) => onWeightChanged(setIndex, w),
                onRepsChanged: (r) => onRepsChanged(setIndex, r),
                onStepWeight: onStepWeight != null
                    ? (d) => onStepWeight!(setIndex, d)
                    : null,
                onStepReps: onStepReps != null
                    ? (d) => onStepReps!(setIndex, d)
                    : null,
                onTogglePerformed: () => onToggleSetPerformed(setIndex),
                onDeleteSet: onRemoveSet != null && log.sets.length > 1
                    ? () => onRemoveSet!(setIndex)
                    : null,
                onTapWeight: () {
                  final initial = setLog.weightKg != null
                      ? WeightConverter.convert(setLog.weightKg!, WeightUnit.kg, displayUnit)
                      : 0.0;
                  _openNumericKeypad(
                    context,
                    setIndex: setIndex,
                    isWeight: true,
                    initialValue: initial,
                  );
                },
                onTapReps: () {
                  final initial = (setLog.actualReps ?? 0).toDouble();
                  _openNumericKeypad(
                    context,
                    setIndex: setIndex,
                    isWeight: false,
                    initialValue: initial,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),

          // Bottom Card Actions: Add Set & Copy Previous
          Row(
            children: [
              if (onAddSet != null)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAddSet!();
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Set'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.indigoAccent,
                    textStyle: ReportThemeTokens.outfitSubtext(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              if (onCopyPreviousSession != null && previousSets != null && previousSets!.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onCopyPreviousSession!();
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy Previous'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    textStyle: ReportThemeTokens.outfitSubtext(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- COMPACT SLIDING UNIT TOGGLE ---
  Widget _buildUnitToggle(bool isDark) {
    final isKg = displayUnit == WeightUnit.kg;

    return Container(
      width: 72,
      height: 30,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: isKg ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 36,
              height: 28,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          // KG / LB Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onUnitChanged(WeightUnit.kg);
                  },
                  child: Center(
                    child: Text(
                      'KG',
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isKg ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onUnitChanged(WeightUnit.lb);
                  },
                  child: Center(
                    child: Text(
                      'LB',
                      style: ReportThemeTokens.outfitNumber(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: !isKg ? Colors.white : AppColors.textSecondary,
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

  Widget _buildVideoPill(
    BuildContext context, {
    required String label,
    required String url,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => VideoLauncher.launch(context, url),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.indigoAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.indigoAccent.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 16,
                color: AppColors.indigoAccent,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ReportThemeTokens.outfitSubtext(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.indigoAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: ReportThemeTokens.outfitSubtext(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
